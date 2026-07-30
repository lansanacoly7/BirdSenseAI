"""
BirdSense AI - Standalone ONNX Runtime Inference Engine (Ext 4.1 & Problem 4 Fix)
Provides lightweight, ultra-fast model inference using ONNX Runtime with NMS (Non-Maximum Suppression).
"""

from pathlib import Path
from typing import List, Dict, Any, Union, Optional
import numpy as np
import cv2
import onnxruntime as ort


from .config import vision_config


class ONNXInferenceEngine:
    """
    Direct ONNX Runtime execution engine for YOLO models exported to .onnx format with Class-wise NMS.
    """

    def __init__(
        self,
        onnx_model_path: str,
        input_size: Optional[int] = None,
        confidence_threshold: Optional[float] = None,
        iou_threshold: Optional[float] = None
    ):
        self.model_path = Path(onnx_model_path)
        self.input_size = input_size if input_size is not None else vision_config.image_size[0]
        self.confidence_threshold = confidence_threshold if confidence_threshold is not None else vision_config.confidence_threshold
        self.iou_threshold = iou_threshold if iou_threshold is not None else vision_config.iou_threshold

        if not self.model_path.exists():
            raise FileNotFoundError(f"ONNX model not found at {self.model_path}")

        # Initialize ONNX Runtime session
        self.session = ort.InferenceSession(
            str(self.model_path),
            providers=["CPUExecutionProvider"]
        )

        # Get input and output names
        self.input_name = self.session.get_inputs()[0].name
        self.output_names = [o.name for o in self.session.get_outputs()]

    def preprocess(self, image: np.ndarray) -> np.ndarray:
        """
        Preprocesses image for YOLO ONNX input: Resize, Letterbox, BGR->RGB, Normalize [0-1], CHW tensor.
        """
        h, w = image.shape[:2]
        scale = min(self.input_size / h, self.input_size / w)
        new_w, new_h = int(w * scale), int(h * scale)

        resized = cv2.resize(image, (new_w, new_h), interpolation=cv2.INTER_LINEAR)
        
        canvas = np.full((self.input_size, self.input_size, 3), 114, dtype=np.uint8)
        canvas[:new_h, :new_w] = resized

        tensor = canvas.transpose((2, 0, 1)).astype(np.float32) / 255.0
        return np.expand_dims(tensor, axis=0)

    def run_inference(self, image: np.ndarray) -> Dict[str, Any]:
        """
        Runs ONNX inference and applies Class-wise Non-Maximum Suppression (NMS).
        """
        h_orig, w_orig = image.shape[:2]
        input_tensor = self.preprocess(image)

        outputs = self.session.run(self.output_names, {self.input_name: input_tensor})
        raw_output = outputs[0]  # Shape: [1, 84, 8400] or similar

        scale = min(self.input_size / h_orig, self.input_size / w_orig)
        
        candidate_boxes = []
        candidate_scores = []
        candidate_class_ids = []
        candidate_xyxy = []

        if len(raw_output.shape) == 3:
            predictions = raw_output[0].T  # Transpose to [8400, N_classes + 4]

            boxes = predictions[:, :4]
            scores_matrix = predictions[:, 4:]

            for i in range(len(predictions)):
                max_score = float(np.max(scores_matrix[i]))
                if max_score < self.confidence_threshold:
                    continue

                class_id = int(np.argmax(scores_matrix[i]))
                cx, cy, w, h = boxes[i]

                # Scale back to original image dimensions
                x1 = max(0.0, float((cx - w / 2.0) / scale))
                y1 = max(0.0, float((cy - h / 2.0) / scale))
                x2 = min(float(w_orig), float((cx + w / 2.0) / scale))
                y2 = min(float(h_orig), float((cy + h / 2.0) / scale))

                box_w = max(1.0, x2 - x1)
                box_h = max(1.0, y2 - y1)

                candidate_boxes.append([int(x1), int(y1), int(box_w), int(box_h)])
                candidate_scores.append(float(max_score))
                candidate_class_ids.append(class_id)
                candidate_xyxy.append([round(x1, 2), round(y1, 2), round(x2, 2), round(y2, 2)])

        # Apply Non-Maximum Suppression (NMS) via OpenCV
        final_detections = []
        if candidate_boxes:
            indices = cv2.dnn.NMSBoxes(
                bboxes=candidate_boxes,
                scores=candidate_scores,
                score_threshold=self.confidence_threshold,
                nms_threshold=self.iou_threshold
            )

            if len(indices) > 0:
                indices = indices.flatten() if hasattr(indices, 'flatten') else indices
                for idx in indices:
                    cls_id = candidate_class_ids[idx]
                    conf_val = candidate_scores[idx]
                    box_px = candidate_xyxy[idx]
                    
                    x1, y1, x2, y2 = box_px
                    norm_box = [
                        round(x1 / w_orig, 4),
                        round(y1 / h_orig, 4),
                        round(x2 / w_orig, 4),
                        round(y2 / h_orig, 4)
                    ]

                    final_detections.append({
                        "class_id": cls_id,
                        "confidence": round(conf_val, 4),
                        "box_pixel": box_px,
                        "box_normalized": norm_box
                    })

        return {
            "model_path": str(self.model_path),
            "width": w_orig,
            "height": h_orig,
            "count": len(final_detections),
            "detections": final_detections
        }

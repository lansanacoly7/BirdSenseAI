"""
BirdSense AI - Standalone ONNX Runtime Inference Engine (Ext 4.1)
Provides lightweight, ultra-fast model inference using ONNX Runtime without PyTorch dependency.
"""

from pathlib import Path
from typing import List, Dict, Any, Union, Optional
import numpy as np
import cv2
import onnxruntime as ort


class ONNXInferenceEngine:
    """
    Direct ONNX Runtime execution engine for YOLO models exported to .onnx format.
    """

    def __init__(
        self,
        onnx_model_path: str,
        input_size: int = 640,
        confidence_threshold: float = 0.25,
        iou_threshold: float = 0.45
    ):
        self.model_path = Path(onnx_model_path)
        self.input_size = input_size
        self.confidence_threshold = confidence_threshold
        self.iou_threshold = iou_threshold

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
        # Calculate resize scale
        scale = min(self.input_size / h, self.input_size / w)
        new_w, new_h = int(w * scale), int(h * scale)

        resized = cv2.resize(image, (new_w, new_h), interpolation=cv2.INTER_LINEAR)
        
        # Letterbox padding
        canvas = np.full((self.input_size, self.input_size, 3), 114, dtype=np.uint8)
        canvas[:new_h, :new_w] = resized

        # Format to [1, 3, H, W] float32 normalized 0-1
        tensor = canvas.transpose((2, 0, 1)).astype(np.float32) / 255.0
        return np.expand_dims(tensor, axis=0)

    def run_inference(self, image: np.ndarray) -> Dict[str, Any]:
        """
        Runs ONNX inference and returns post-processed bounding boxes and confidence scores.
        """
        h_orig, w_orig = image.shape[:2]
        input_tensor = self.preprocess(image)

        outputs = self.session.run(self.output_names, {self.input_name: input_tensor})
        raw_output = outputs[0]  # Shape: [1, 84, 8400] or similar

        # Post-process YOLO outputs
        scale = min(self.input_size / h_orig, self.input_size / w_orig)
        detections = []

        if len(raw_output.shape) == 3:
            predictions = raw_output[0].T  # Transpose to [8400, 84]

            boxes = predictions[:, :4]
            scores_matrix = predictions[:, 4:]

            for i in range(len(predictions)):
                max_score = float(np.max(scores_matrix[i]))
                if max_score < self.confidence_threshold:
                    continue

                class_id = int(np.argmax(scores_matrix[i]))
                cx, cy, w, h = boxes[i]

                # Convert center xywh to xyxy on original image scale
                x1 = max(0, (cx - w / 2.0) / scale)
                y1 = max(0, (cy - h / 2.0) / scale)
                x2 = min(w_orig, (cx + w / 2.0) / scale)
                y2 = min(h_orig, (cy + h / 2.0) / scale)

                detections.append({
                    "class_id": class_id,
                    "confidence": round(max_score, 4),
                    "box_pixel": [round(x1, 2), round(y1, 2), round(x2, 2), round(y2, 2)],
                    "box_normalized": [
                        round(x1 / w_orig, 4),
                        round(y1 / h_orig, 4),
                        round(x2 / w_orig, 4),
                        round(y2 / h_orig, 4)
                    ]
                })

        return {
            "model_path": str(self.model_path),
            "width": w_orig,
            "height": h_orig,
            "count": len(detections),
            "detections": detections
        }

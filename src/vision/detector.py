"""
Bird Sense AI - Core Bird Detection Engine (T4.1 & T4.3)
Wraps YOLO inference for single image detection, bounding box normalization, and structured output.
"""

import io
from pathlib import Path
from typing import List, Dict, Any, Union, Optional
import numpy as np
import cv2
from PIL import Image
from ultralytics import YOLO


class BirdDetector:
    """
    BirdDetector handles loading YOLO model weights and performing object detection on images.
    """

    def __init__(
        self,
        model_path: str = "yolov8n.pt",
        confidence_threshold: float = 0.25,
        target_classes: Optional[List[int]] = None
    ):
        """
        :param model_path: Path to .pt or .onnx model weights file.
        :param confidence_threshold: Minimum confidence score to accept detection.
        :param target_classes: Optional list of target class IDs (e.g. COCO 14 for bird).
        """
        self.model_path = model_path
        self.confidence_threshold = confidence_threshold
        self.target_classes = target_classes
        self.model = YOLO(model_path)

    def _prepare_image(self, image_input: Union[str, Path, bytes, np.ndarray, Image.Image]) -> np.ndarray:
        """
        Converts diverse image formats into standard BGR numpy array for OpenCV/YOLO processing.
        """
        if isinstance(image_input, (str, Path)):
            img = cv2.imread(str(image_input))
            if img is None:
                raise ValueError(f"Could not read image file at {image_input}")
            return img

        elif isinstance(image_input, bytes):
            pil_img = Image.open(io.BytesIO(image_input)).convert("RGB")
            return cv2.cvtColor(np.array(pil_img), cv2.COLOR_RGB2BGR)

        elif isinstance(image_input, Image.Image):
            return cv2.cvtColor(np.array(image_input.convert("RGB")), cv2.COLOR_RGB2BGR)

        elif isinstance(image_input, np.ndarray):
            return image_input

        else:
            raise TypeError(f"Unsupported image input type: {type(image_input)}")

    def detect(
        self,
        image_input: Union[str, Path, bytes, np.ndarray, Image.Image],
        conf: Optional[float] = None
    ) -> Dict[str, Any]:
        """
        Performs detection on an image.
        Returns a dictionary containing summary counts, image dimensions, and detailed detection list.
        """
        img = self._prepare_image(image_input)
        height, width = img.shape[:2]
        confidence = conf if conf is not None else self.confidence_threshold

        results = self.model.predict(
            source=img,
            conf=confidence,
            classes=self.target_classes,
            verbose=False
        )

        detections: List[Dict[str, Any]] = []
        if len(results) > 0 and results[0].boxes is not None:
            boxes = results[0].boxes
            for box in boxes:
                xyxy = box.xyxy[0].cpu().numpy().tolist()  # [x1, y1, x2, y2]
                conf_score = float(box.conf[0].cpu().numpy())
                cls_id = int(box.cls[0].cpu().numpy())
                cls_name = self.model.names.get(cls_id, f"class_{cls_id}")

                # Normalized coordinates [0.0 - 1.0]
                norm_box = [
                    round(xyxy[0] / width, 4),
                    round(xyxy[1] / height, 4),
                    round(xyxy[2] / width, 4),
                    round(xyxy[3] / height, 4),
                ]

                detections.append({
                    "class_id": cls_id,
                    "class_name": cls_name,
                    "confidence": round(conf_score, 4),
                    "box_pixel": [round(c, 2) for c in xyxy],
                    "box_normalized": norm_box
                })

        return {
            "width": width,
            "height": height,
            "count": len(detections),
            "detections": detections
        }

    def draw_detections(
        self,
        image_input: Union[str, Path, bytes, np.ndarray, Image.Image],
        detections: List[Dict[str, Any]]
    ) -> np.ndarray:
        """
        Draws bounding box overlays and text labels on image.
        """
        img = self._prepare_image(image_input).copy()
        
        for det in detections:
            x1, y1, x2, y2 = [int(v) for v in det["box_pixel"]]
            label = f"{det['class_name']} {det['confidence']*100:.1f}%"

            # Draw rectangle (Canopy Green #1E3A2B in BGR -> (43, 58, 30))
            cv2.rectangle(img, (x1, y1), (x2, y2), (43, 58, 30), 2)

            # Label banner
            (w, h), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 1)
            cv2.rectangle(img, (x1, max(0, y1 - 20)), (x1 + w, y1), (43, 58, 30), -1)
            cv2.putText(img, label, (x1, max(12, y1 - 5)), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)

        return img


if __name__ == "__main__":
    detector = BirdDetector(model_path="yolov8n.pt")
    # Quick test on synthetic empty canvas
    test_img = np.zeros((480, 640, 3), dtype=np.uint8)
    res = detector.detect(test_img)
    print(f"[BirdDetector] Operational. Test detection output: {res}")

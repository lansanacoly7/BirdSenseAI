"""
BirdSense AI - Centralized Computer Vision Configuration Engine
Centralizes all vision parameters, model paths, thresholds, and bioacoustic settings.
"""

from dataclasses import dataclass
from pathlib import Path
from typing import Tuple


ROOT_DIR = Path(__file__).resolve().parent.parent.parent


@dataclass
class VisionConfig:
    """
    Centralized configuration dataclass for Computer Vision, Audio, and AI inference engines.
    """
    # YOLO & Detection Parameters
    yolo_model_path: str = "yolov8n.pt"
    onnx_model_path: str = "yolov8n.onnx"
    confidence_threshold: float = 0.25
    iou_threshold: float = 0.45
    image_size: Tuple[int, int] = (640, 640)
    device: str = "cpu"
    max_detections: int = 300

    # Multi-Object Tracking (ByteTrack)
    tracking_threshold: float = 0.25
    tracker_config: str = "bytetrack.yaml"

    # Stage 2 BioCLIP / OpenCLIP Species Classification
    bioclip_model_name: str = "ViT-B-32"
    bioclip_pretrained: str = "laion2b_s34b_b79k"
    bioclip_enable_clip: bool = True

    # Bioacoustic Audio Classification Parameters
    audio_sample_rate: int = 22050
    audio_detection_db_threshold: float = -40.0

    def resolve_yolo_weights(self) -> str:
        """
        Dynamically detects fine-tuned best.pt weights under runs/ or falls back to base COCO yolov8n.pt.
        """
        runs_dir = ROOT_DIR / "runs"
        best_weights = list(runs_dir.glob("**/weights/best.pt"))
        if best_weights and best_weights[0].exists() and best_weights[0].stat().st_size > 0:
            return str(best_weights[0])
        return self.yolo_model_path


# Global singleton configuration instance
vision_config = VisionConfig()

"""
Non utilisé dans le pipeline de production actuel — conservé pour une itération future si un dataset d'espèces sénégalaises annoté devient disponible.

YOLOv8 / YOLOv11 Fine-Tuning & Export Module for BirdSense AI (T4.1)
Handles fine-tuning on bird datasets, weights checkpointing, and ONNX export.
"""

import os
from pathlib import Path
from typing import Dict, Any, Optional
from ultralytics import YOLO

from .dataset_prep import DatasetPreparer
from .logger import log_yolo


class YOLOTrainer:
    """
    Automated trainer class for fine-tuning YOLO models on bird detection tasks.
    """

    def __init__(
        self,
        base_model: str = "yolov8n.pt",
        data_yaml: Optional[str] = None,
        project_dir: str = "runs/detect",
        experiment_name: str = "birdsense_yolo"
    ):
        self.base_model = base_model
        self.project_dir = Path(project_dir)
        self.experiment_name = experiment_name
        
        if data_yaml is None:
            preparer = DatasetPreparer()
            self.data_yaml = str(preparer.create_yaml_config())
        else:
            self.data_yaml = data_yaml

    def train(
        self,
        epochs: int = 10,
        imgsz: int = 640,
        batch: int = 16,
        device: str = "cpu",
        kwargs: Optional[Dict[str, Any]] = None
    ) -> Dict[str, str]:
        extra_args = kwargs or {}
        model = YOLO(self.base_model)
        
        log_yolo(f"[YOLOTrainer] Starting training on model '{self.base_model}' with dataset '{self.data_yaml}'...")
        results = model.train(
            data=self.data_yaml,
            epochs=epochs,
            imgsz=imgsz,
            batch=batch,
            device=device,
            project=str(self.project_dir),
            name=self.experiment_name,
            exist_ok=True,
            **extra_args
        )

        save_dir = Path(self.project_dir) / self.experiment_name / "weights"
        best_pt_path = save_dir / "best.pt"
        
        onnx_path = None
        if best_pt_path.exists():
            log_yolo(f"[YOLOTrainer] Exporting best model to ONNX format...")
            trained_model = YOLO(str(best_pt_path))
            exported_path = trained_model.export(format="onnx", imgsz=imgsz)
            onnx_path = str(exported_path)

        return {
            "best_pt": str(best_pt_path) if best_pt_path.exists() else self.base_model,
            "onnx": onnx_path or ""
        }


if __name__ == "__main__":
    trainer = YOLOTrainer(base_model="yolov8n.pt")
    log_yolo("[YOLOTrainer] Ready to execute training pipeline.")

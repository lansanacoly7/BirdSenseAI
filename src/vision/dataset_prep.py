"""
Dataset Preparation & Management Module for BirdSense AI YOLO Fine-Tuning (T4.1)
Handles Roboflow/YOLO dataset creation, validation, directory setup, sample seeding, and data.yaml generation.
"""

import os
import yaml
from pathlib import Path
from typing import List, Dict, Optional, Union
import numpy as np
import cv2

# Species categories for BirdSense AI fine-tuning
DEFAULT_BIRD_SPECIES = [
    "Oiseau_Generique",
    "Aigle",
    "Flamant_Rose",
    "Pelican",
    "Pigeon",
    "Passereau",
    "Heron",
    "Faucon"
]


class DatasetPreparer:
    """
    Manages structure, data.yaml configuration, sample image generation, and validation for YOLO fine-tuning dataset.
    """

    def __init__(
        self,
        dataset_dir: Union[str, Path] = "dataset",
        species_names: Optional[List[str]] = None
    ):
        self.dataset_dir = Path(dataset_dir)
        self.species_names = species_names or DEFAULT_BIRD_SPECIES

    def setup_directories(self) -> Dict[str, Path]:
        """
        Creates canonical YOLO dataset layout:
        dataset/
          ├── images/
          │   ├── train/
          │   └── val/
          └── labels/
              ├── train/
              └── val/
        """
        paths = {
            "images_train": self.dataset_dir / "images" / "train",
            "images_val": self.dataset_dir / "images" / "val",
            "labels_train": self.dataset_dir / "labels" / "train",
            "labels_val": self.dataset_dir / "labels" / "val",
        }
        for p in paths.values():
            p.mkdir(parents=True, exist_ok=True)
        return paths

    def seed_sample_data(self) -> None:
        """
        Generates synthetic training and validation sample images and YOLO annotation txt labels
        to ensure YOLO fine-tuning scripts can run out-of-the-box in clean environment.
        """
        paths = self.setup_directories()
        
        # Check if dataset already has images
        train_count = len(list(paths["images_train"].glob("*.*")))
        if train_count > 0:
            return

        print("[DatasetPreparer] Seeding sample bird training & validation dataset...")

        def create_sample_pair(img_path: Path, label_path: Path, class_id: int = 0):
            # Create synthetic 320x320 image with simulated bird shape
            img = np.zeros((320, 320, 3), dtype=np.uint8)
            img[:] = (40, 120, 40)  # Forest background
            cv2.circle(img, (160, 160), 30, (255, 255, 255), -1)  # White bird circle
            cv2.imwrite(str(img_path), img)

            # Create corresponding YOLO label: class_id cx cy w h (normalized 0-1)
            with open(label_path, "w", encoding="utf-8") as f:
                f.write(f"{class_id} 0.5 0.5 0.25 0.25\n")

        # Create 4 training samples
        for i in range(1, 5):
            img_p = paths["images_train"] / f"sample_bird_train_{i}.jpg"
            lbl_p = paths["labels_train"] / f"sample_bird_train_{i}.txt"
            create_sample_pair(img_p, lbl_p, class_id=i % len(self.species_names))

        # Create 2 validation samples
        for i in range(1, 3):
            img_p = paths["images_val"] / f"sample_bird_val_{i}.jpg"
            lbl_p = paths["labels_val"] / f"sample_bird_val_{i}.txt"
            create_sample_pair(img_p, lbl_p, class_id=i % len(self.species_names))

    def create_yaml_config(self, yaml_filename: str = "data.yaml") -> Path:
        """
        Generates standard data.yaml required by Ultralytics YOLOv8/v11.
        """
        self.setup_directories()
        self.seed_sample_data()
        
        yaml_path = self.dataset_dir / yaml_filename
        
        config = {
            "path": str(self.dataset_dir.resolve()),
            "train": "images/train",
            "val": "images/val",
            "names": {i: name for i, name in enumerate(self.species_names)}
        }

        with open(yaml_path, "w", encoding="utf-8") as f:
            yaml.dump(config, f, default_flow_style=False, sort_keys=False)

        return yaml_path

    def validate_dataset(self) -> Dict[str, int]:
        """
        Validates presence of images and label files.
        """
        paths = self.setup_directories()
        
        counts = {
            "train_images": len(list(paths["images_train"].glob("*.*"))),
            "val_images": len(list(paths["images_val"].glob("*.*"))),
            "train_labels": len(list(paths["labels_train"].glob("*.txt"))),
            "val_labels": len(list(paths["labels_val"].glob("*.txt")))
        }
        return counts


if __name__ == "__main__":
    preparer = DatasetPreparer()
    yaml_file = preparer.create_yaml_config()
    stats = preparer.validate_dataset()
    print(f"[DatasetPreparer] Generated YAML config at: {yaml_file}")
    print(f"[DatasetPreparer] Dataset Stats: {stats}")

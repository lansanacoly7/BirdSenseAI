"""
Non utilisé dans le pipeline de production actuel — conservé pour une itération future si un dataset d'espèces sénégalaises annoté devient disponible.

Dataset Preparation & Management Module for BirdSense AI YOLO Fine-Tuning (T4.1)
Handles Roboflow/YOLO dataset creation, validation, real dataset ingestion, and data.yaml generation.
"""

import os
import yaml
from pathlib import Path
from typing import List, Dict, Optional, Union
import numpy as np
import cv2

from .download_birds import download_real_bird_dataset, SPECIES_LIST


class DatasetPreparer:
    """
    Manages structure, real dataset ingestion, data.yaml configuration, and validation for YOLO fine-tuning dataset.
    """

    def __init__(
        self,
        dataset_dir: Union[str, Path] = "dataset",
        species_names: Optional[List[str]] = None
    ):
        self.dataset_dir = Path(dataset_dir)
        self.species_names = species_names or SPECIES_LIST

    def setup_directories(self) -> Dict[str, Path]:
        paths = {
            "images_train": self.dataset_dir / "images" / "train",
            "images_val": self.dataset_dir / "images" / "val",
            "labels_train": self.dataset_dir / "labels" / "train",
            "labels_val": self.dataset_dir / "labels" / "val",
        }
        for p in paths.values():
            p.mkdir(parents=True, exist_ok=True)
        return paths

    def seed_real_bird_dataset(self) -> int:
        return download_real_bird_dataset(self.dataset_dir)

    def seed_placeholder_data_FOR_TESTS_ONLY(self) -> None:
        paths = self.setup_directories()
        train_count = len(list(paths["images_train"].glob("*.*")))
        if train_count > 0:
            return

        def create_sample_pair(img_path: Path, label_path: Path, class_id: int = 0):
            img = np.zeros((320, 320, 3), dtype=np.uint8)
            img[:] = (40, 120, 40)
            cv2.circle(img, (160, 160), 30, (255, 255, 255), -1)
            cv2.imwrite(str(img_path), img)

            with open(label_path, "w", encoding="utf-8") as f:
                f.write(f"{class_id} 0.5 0.5 0.25 0.25\n")

        for i in range(1, 5):
            create_sample_pair(paths["images_train"] / f"sample_bird_train_{i}.jpg", paths["labels_train"] / f"sample_bird_train_{i}.txt", class_id=i % len(self.species_names))

        for i in range(1, 3):
            create_sample_pair(paths["images_val"] / f"sample_bird_val_{i}.jpg", paths["labels_val"] / f"sample_bird_val_{i}.txt", class_id=i % len(self.species_names))

    def create_yaml_config(self, yaml_filename: str = "data.yaml") -> Path:
        self.setup_directories()
        paths = self.setup_directories()
        train_count = len(list(paths["images_train"].glob("*.*")))
        if train_count == 0:
            self.seed_real_bird_dataset()
        
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
        paths = self.setup_directories()
        counts = {
            "train_images": len(list(paths["images_train"].glob("*.*"))),
            "val_images": len(list(paths["images_val"].glob("*.*"))),
            "train_labels": len(list(paths["labels_train"].glob("*.txt"))),
            "val_labels": len(list(paths["labels_val"].glob("*.txt")))
        }
        return counts


from .logger import log_vision

if __name__ == "__main__":
    preparer = DatasetPreparer()
    yaml_file = preparer.create_yaml_config()
    stats = preparer.validate_dataset()
    log_vision(f"Generated YAML config at: {yaml_file}")
    log_vision(f"Dataset Stats: {stats}")

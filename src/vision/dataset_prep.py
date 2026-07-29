"""
Dataset Preparation & Management Module for BirdSense AI YOLO Fine-Tuning (T4.1)
Handles Roboflow/YOLO dataset creation, validation, directory setup, and data.yaml generation.
"""

import os
import yaml
from pathlib import Path
from typing import List, Dict, Optional, Union

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
    Manages structure, data.yaml configuration, and validation for YOLO fine-tuning dataset.
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

    def create_yaml_config(self, yaml_filename: str = "data.yaml") -> Path:
        """
        Generates the standard data.yaml file required by Ultralytics YOLOv8/v11.
        """
        self.setup_directories()
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
        Validates presence of images and corresponding label files in train and val sets.
        Returns image counts per partition.
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

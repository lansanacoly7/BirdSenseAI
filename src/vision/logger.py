"""
BirdSense AI - Professional Computer Vision Logging Engine
Provides structured, categorized logging across all Vision, YOLO, Tracking, Audio, BioCLIP, and ONNX modules.
"""

import logging
import sys
from typing import Optional


class VisionLogFormatter(logging.Formatter):
    """Custom formatter providing clean log outputs with category tags."""
    def format(self, record: logging.LogRecord) -> str:
        category = getattr(record, "category", "VISION")
        level_name = record.levelname
        msg = record.getMessage()
        return f"[{level_name}] [{category}] {msg}"


def setup_vision_logger(name: str = "BirdSenseVision", level: int = logging.INFO) -> logging.Logger:
    """
    Description:
        Initialise et configure le logger central pour le périmètre Computer Vision.

    Responsabilités:
        - Créer le handler de sortie stdout avec le format catégorisé `[LEVEL] [CATEGORY] Message`.
        - Fournir des fonctions d'émission par sous-système (YOLO, TRACKING, AUDIO, BIOCLIP, ONNX).

    Entrées:
        - `name`: Nom du logger Python (par défaut: 'BirdSenseVision').
        - `level`: Niveau de filtre de sévérité (par défaut: `logging.INFO`).

    Sorties:
        - Instance `logging.Logger` configurée.

    Exceptions:
        - Aucune exception levée.

    Exemple d'utilisation:
        >>> from src.vision.logger import log_yolo, log_audio
        >>> log_yolo("YOLO Model loaded")
        [INFO] [YOLO] YOLO Model loaded
        >>> log_audio("FFT analysis complete")
        [INFO] [AUDIO] FFT analysis complete
    """
    logger = logging.getLogger(name)
    logger.setLevel(level)

    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)
        handler.setFormatter(VisionLogFormatter())
        logger.addHandler(handler)

    logger.propagate = False
    return logger


logger = setup_vision_logger()


def log_category(category: str, message: str, level: int = logging.INFO) -> None:
    """Emits a log entry tagged with a specific category."""
    extra = {"category": category.upper()}
    logger.log(level, message, extra=extra)


def log_vision(message: str, level: int = logging.INFO) -> None:
    log_category("VISION", message, level)


def log_yolo(message: str, level: int = logging.INFO) -> None:
    log_category("YOLO", message, level)


def log_tracking(message: str, level: int = logging.INFO) -> None:
    log_category("TRACKING", message, level)


def log_audio(message: str, level: int = logging.INFO) -> None:
    log_category("AUDIO", message, level)


def log_bioclip(message: str, level: int = logging.INFO) -> None:
    log_category("BIOCLIP", message, level)


def log_onnx(message: str, level: int = logging.INFO) -> None:
    log_category("ONNX", message, level)

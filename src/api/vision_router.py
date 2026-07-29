"""
BirdSense AI - Vision API Router (T4.3)
FastAPI endpoints for bird detection in photos and multi-object tracking in videos.
"""

import os
import tempfile
from pathlib import Path
from typing import Dict, Any, Optional
from fastapi import APIRouter, File, UploadFile, Query, HTTPException, status
from fastapi.responses import JSONResponse

from ..vision.detector import BirdDetector
from ..vision.tracker import ByteTrackTracker

router = APIRouter(prefix="/api/v1/vision", tags=["Computer Vision & IA"])

# Singleton detector and tracker instances
_detector: Optional[BirdDetector] = None
_tracker: Optional[ByteTrackTracker] = None


def get_detector() -> BirdDetector:
    global _detector
    if _detector is None:
        _detector = BirdDetector(model_path="yolov8n.pt", confidence_threshold=0.25)
    return _detector


def get_tracker() -> ByteTrackTracker:
    global _tracker
    if _tracker is None:
        _tracker = ByteTrackTracker(model_path="yolov8n.pt", confidence_threshold=0.25)
    return _tracker


@router.get("/health", summary="Statut du Service Vision IA")
def vision_health() -> Dict[str, Any]:
    """
    Vérifie l'état de fonctionnement du modèle et du moteur d'inférence IA.
    """
    detector = get_detector()
    return {
        "status": "online",
        "service": "BirdSense AI Computer Vision Engine",
        "model_path": detector.model_path,
        "confidence_threshold": detector.confidence_threshold,
        "backend": "Ultralytics YOLO + ByteTrack"
    }


@router.post("/detect", summary="Détecter et compter les oiseaux sur une image")
async def detect_birds_in_image(
    file: UploadFile = File(...),
    conf: float = Query(0.25, ge=0.01, le=1.0, description="Seuil de confiance minimum (0.01 - 1.0)")
) -> Dict[str, Any]:
    """
    Accepte une image (JPEG/PNG) et renvoie :
    - Le nombre d'oiseaux détectés
    - Les coordonnées des Bounding Boxes (pixels et normalisées [0-1])
    - Les espèces et scores de confiance
    """
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Le fichier fourni doit être une image valide (image/jpeg, image/png, etc.)"
        )

    try:
        contents = await file.read()
        detector = get_detector()
        result = detector.detect(image_input=contents, conf=conf)
        return {
            "success": True,
            "filename": file.filename,
            "data": result
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du traitement de l'image : {str(e)}"
        )


@router.post("/track", summary="Suivre et compter les oiseaux uniques sur une vidéo (ByteTrack)")
async def track_birds_in_video(
    file: UploadFile = File(...),
    conf: float = Query(0.25, ge=0.01, le=1.0, description="Seuil de confiance minimum")
) -> Dict[str, Any]:
    """
    Accepte une séquence vidéo (MP4/AVI/MOV) et exécute le tracking vidéo ByteTrack :
    - Attribue un track_id unique à chaque individu
    - Élimine le sur-comptage (calcul du nombre exact d'oiseaux uniques)
    - Renvoie la trajectoire et le journal de présence de chaque individu
    """
    if not file.filename or not any(file.filename.endswith(ext) for ext in [".mp4", ".avi", ".mov", ".mkv"]):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Le fichier fourni doit être un fichier vidéo (.mp4, .avi, .mov, .mkv)"
        )

    # Save uploaded video to temporary file for OpenCV processing
    temp_dir = tempfile.mkdtemp()
    temp_video_path = Path(temp_dir) / file.filename

    try:
        with open(temp_video_path, "wb") as buffer:
            buffer.write(await file.read())

        tracker = get_tracker()
        result = tracker.track_video(video_path=temp_video_path, conf=conf)

        return {
            "success": True,
            "filename": file.filename,
            "data": result
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du traitement du suivi vidéo : {str(e)}"
        )
    finally:
        # Cleanup temp file
        if temp_video_path.exists():
            try:
                os.remove(temp_video_path)
            except OSError:
                pass

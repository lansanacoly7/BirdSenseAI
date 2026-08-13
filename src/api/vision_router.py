"""
BirdSense AI - Vision API Router (Stage 1 Detection + Stage 2 Species Zero-Shot Identification)
FastAPI endpoints for 2-stage bird detection in photos and multi-object tracking in videos.
"""

import os
import tempfile
from pathlib import Path
from typing import Dict, Any, Optional
import cv2
import numpy as np
from fastapi import APIRouter, File, UploadFile, Form, Query, HTTPException, status
from pydantic import BaseModel, Field

from ..vision.detector import BirdDetector
from ..vision.tracker import ByteTrackTracker
from ..vision.bioclip_engine import BioCLIPEngine
from ..vision.audio_classifier import AudioBirdClassifier
from ..vision.explainability import explainability_engine
from ..vision.arbitration import arbitration_engine
from ..vision.expert_validation import expert_validation_engine
from ..vision.config import vision_config

class ArbitrateRequest(BaseModel):
    ai_species: str = Field(..., description="Nom de l'espèce identifiée par l'IA")
    ai_confidence: float = Field(..., ge=0.0, le=1.0, description="Confiance de l'IA (0.0 à 1.0)")
    suggested_species_votes: Optional[Dict[str, int]] = Field(default=None, description="Votes par espèce")
    total_validations: int = Field(default=0, ge=0, description="Nombre total de validations")


router = APIRouter(prefix="/api/v1/vision", tags=["Computer Vision & IA"])

ROOT_DIR = Path(__file__).resolve().parent.parent.parent

# Singleton model instances
_detector: Optional[BirdDetector] = None
_tracker: Optional[ByteTrackTracker] = None
_bioclip_engine: Optional[BioCLIPEngine] = None
_audio_classifier: Optional[AudioBirdClassifier] = None


def get_audio_classifier() -> AudioBirdClassifier:
    global _audio_classifier
    if _audio_classifier is None:
        _audio_classifier = AudioBirdClassifier()
    return _audio_classifier


from ..vision.logger import log_vision

def resolve_model_path() -> str:
    """Detects fine-tuned best.pt weights under runs/ or falls back to base COCO yolov8n.pt with warning."""
    model_p = vision_config.resolve_yolo_weights()
    if "best.pt" in model_p:
        log_vision(f"Loaded fine-tuned YOLO model weights: {model_p}")
    else:
        log_vision("[WARN] Aucun modèle fine-tuné trouvé, utilisation du modèle COCO de base — détection limitée à la classe générique 'bird'.")
    return model_p


def get_detector() -> BirdDetector:
    global _detector
    if _detector is None:
        _detector = BirdDetector(model_path=resolve_model_path(), confidence_threshold=0.25)
    return _detector


def get_tracker() -> ByteTrackTracker:
    global _tracker
    if _tracker is None:
        _tracker = ByteTrackTracker(model_path=resolve_model_path(), confidence_threshold=0.25)
    return _tracker


def get_bioclip_engine() -> BioCLIPEngine:
    global _bioclip_engine
    if _bioclip_engine is None:
        _bioclip_engine = BioCLIPEngine()
    return _bioclip_engine


MAX_IMAGE_SIZE_BYTES = 10 * 1024 * 1024  # 10 MB
MAX_VIDEO_SIZE_BYTES = 50 * 1024 * 1024  # 50 MB
MAX_AUDIO_SIZE_BYTES = 20 * 1024 * 1024  # 20 MB

ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".bmp"}
ALLOWED_VIDEO_EXTENSIONS = {".mp4", ".avi", ".mov", ".mkv"}
ALLOWED_AUDIO_EXTENSIONS = {".wav", ".mp3", ".ogg", ".flac", ".pcm"}


def validate_upload_security(
    file: UploadFile,
    contents: bytes,
    allowed_extensions: set,
    max_bytes: int,
    file_type_label: str
) -> str:
    """
    Validates file extension, sanitizes filename against Path Traversal, and enforces max size to prevent DoS.
    """
    raw_filename = file.filename or f"upload.{file_type_label}"
    # Sanitize against Path Traversal
    safe_filename = Path(raw_filename).name

    ext = Path(safe_filename).suffix.lower()
    if ext not in allowed_extensions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Format de fichier non autorisé ('{ext}'). Formats acceptés : {', '.join(sorted(allowed_extensions))}"
        )

    if len(contents) > max_bytes:
        max_mb = max_bytes // (1024 * 1024)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Taille de fichier trop grande ({len(contents) / (1024*1024):.1f} Mo). Limite maximale : {max_mb} Mo."
        )

    return safe_filename


@router.get("/health", summary="Statut du Service Vision IA")
def vision_health() -> Dict[str, Any]:
    detector = get_detector()
    bioclip = get_bioclip_engine()
    return {
        "status": "online",
        "service": "BirdSense AI 2-Stage Computer Vision & Audio Engine",
        "stage_1_detector": f"YOLOv8 Generic Bird Detector ({detector.model_path})",
        "stage_2_classifier": f"Zero-Shot CLIP Species Classifier (Active: {bioclip.use_clip})",
        "audio_classifier": "Bioacoustic FFT & Spectral Classifier Active (T4.5)",
        "backend": "Ultralytics YOLO + ByteTrack + OpenCLIP Zero-Shot + Audio Bioacoustics"
    }


@router.post("/detect", summary="Détecter (Stage 1) et Identifier les Espèces en Zero-Shot (Stage 2)")
async def detect_birds_in_image(
    file: UploadFile = File(...),
    conf: float = Query(0.25, ge=0.01, le=1.0, description="Seuil de confiance minimum (0.01 - 1.0)")
) -> Dict[str, Any]:
    """
    Pipeline 2-Étages complet :
    - Étage 1 : Détection et localisation des oiseaux avec YOLOv8 (COCO class 14) + format ar_hud_box (T4.4)
    - Étage 2 : Découpage de chaque Bounding Box et classification d'espèce zéro-shot CLIP
    """
    contents = await file.read()
    safe_filename = validate_upload_security(file, contents, ALLOWED_IMAGE_EXTENSIONS, MAX_IMAGE_SIZE_BYTES, "image")

    try:
        detector = get_detector()
        bioclip = get_bioclip_engine()

        # Stage 1: Generic Bird Detection
        stage1_result = detector.detect(image_input=contents, conf=conf)
        raw_img = stage1_result.pop("raw_image", None)

        detections = stage1_result.get("detections", [])

        # Stage 2: Species Fine Identification on crops
        if raw_img is not None and len(detections) > 0:
            h_img, w_img = raw_img.shape[:2]
            for det in detections:
                x1, y1, x2, y2 = [int(v) for v in det["box_pixel"]]
                
                # Clip box coordinates
                x1_c, y1_c = max(0, x1), max(0, y1)
                x2_c, y2_c = min(w_img, x2), min(h_img, y2)

                crop = raw_img[y1_c:y2_c, x1_c:x2_c]
                if crop.size > 0:
                    try:
                        species_res = bioclip.classify_crop(crop)
                        det["species_identification"] = species_res
                        det["class_name"] = species_res["top_species"]
                    except Exception as e:
                        det["species_identification"] = {"error": str(e)}

        return {
            "success": True,
            "filename": file.filename,
            "pipeline": "Stage 1 (YOLOv8 Detection) -> Stage 2 (CLIP Zero-Shot Species)",
            "data": stage1_result
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du traitement du pipeline vision 2-étages : {str(e)}"
        )


@router.post("/track", summary="Suivre et compter les oiseaux uniques sur une vidéo (ByteTrack)")
async def track_birds_in_video(
    file: UploadFile = File(...),
    conf: float = Query(0.25, ge=0.01, le=1.0, description="Seuil de confiance minimum")
) -> Dict[str, Any]:
    contents = await file.read()
    safe_filename = validate_upload_security(file, contents, ALLOWED_VIDEO_EXTENSIONS, MAX_VIDEO_SIZE_BYTES, "video")

    temp_dir = tempfile.mkdtemp()
    temp_video_path = Path(temp_dir) / safe_filename

    try:
        with open(temp_video_path, "wb") as buffer:
            buffer.write(contents)

        tracker = get_tracker()
        result = tracker.track_video(video_path=temp_video_path, conf=conf)

        return {
            "success": True,
            "filename": safe_filename,
            "data": result
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du traitement du suivi vidéo : {str(e)}"
        )
    finally:
        if temp_video_path.exists():
            try:
                os.remove(temp_video_path)
            except OSError:
                pass


@router.post("/audio-classify", summary="Classifier un fichier audio bioacoustique de chant d'oiseau (T4.5)")
async def classify_bird_audio(
    file: UploadFile = File(...)
) -> Dict[str, Any]:
    """
    Analyse bioacoustique spectrale du signal audio (WAV, MP3, OGG) pour la reconnaissance des chants d'oiseaux.
    """
    contents = await file.read()
    safe_filename = validate_upload_security(file, contents, ALLOWED_AUDIO_EXTENSIONS, MAX_AUDIO_SIZE_BYTES, "audio")

    try:
        classifier = get_audio_classifier()
        result = classifier.classify_audio_bytes(contents, filename=safe_filename)
        return result
    except ValueError as ve:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(ve)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors du traitement de la classification audio bioacoustique : {str(e)}"
        )


@router.post("/explain", summary="Générer l'explicabilité visuelle 'Pourquoi cette identification ?' (T4.1)")
async def explain_identification(
    file: UploadFile = File(...)
) -> Dict[str, Any]:
    """
    T4.1: Analyse l'image et génère le rapport d'explicabilité 'Pourquoi cette identification ?'.
    """
    contents = await file.read()
    safe_filename = validate_upload_security(file, contents, ALLOWED_IMAGE_EXTENSIONS, MAX_IMAGE_SIZE_BYTES, "image")

    try:
        detector = get_detector()
        bioclip = get_bioclip_engine()

        # Step 1: Detect
        det_res = detector.detect(image_input=contents)
        raw_img = det_res.pop("raw_image", None)
        detections = det_res.get("detections", [])

        if raw_img is None or len(detections) == 0:
            return {
                "success": True,
                "message": "Aucun oiseau détecté sur l'image.",
                "explanation": None
            }

        top_det = detections[0]
        x1, y1, x2, y2 = [int(v) for v in top_det["box_pixel"]]
        h_img, w_img = raw_img.shape[:2]
        crop = raw_img[max(0, y1):min(h_img, y2), max(0, x1):min(w_img, x2)]

        try:
            species_res = bioclip.classify_crop(crop)
            top_species = species_res["top_species"]
            top_confidence = species_res["top_confidence"]
            candidates = species_res.get("candidates", [])
        except Exception:
            top_species = "Bird (Generic)"
            top_confidence = top_det["confidence"]
            candidates = []

        explanation = explainability_engine.generate_explanation(
            crop_bgr=crop,
            top_species=top_species,
            top_confidence=top_confidence,
            candidates=candidates,
            ar_hud_box=top_det.get("ar_hud_box"),
            detector_confidence=top_det["confidence"]
        )

        return {
            "success": True,
            "filename": safe_filename,
            "explanation": explanation
        }

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de la génération de l'explicabilité IA : {str(e)}"
        )


@router.post("/arbitrate", summary="Arbitrer entre la confiance IA et les votes communautaires (T4.2)")
def arbitrate_ai_vs_community(payload: ArbitrateRequest) -> Dict[str, Any]:
    """
    T4.2: Évalue l'alignement IA vs Communauté, calcule le score d'anomalie et recommande l'action.
    """
    try:
        result = arbitration_engine.arbitrate(
            ai_species=payload.ai_species,
            ai_confidence=payload.ai_confidence,
            suggested_species_votes=payload.suggested_species_votes,
            total_validations=payload.total_validations
        )
        return {
            "success": True,
            "data": result
        }
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de l'arbitrage IA vs Communauté : {str(e)}"
        )


@router.post("/expert-validate", summary="Ré-inférence automatisée TTA et validation experte (T4.3)")
async def run_expert_validation_job(
    file: UploadFile = File(...),
    initial_ai_species: str = Form(..., description="Espèce initialement prédite"),
    community_suggested_species: Optional[str] = Form(None, description="Espèce proposée par la communauté")
) -> Dict[str, Any]:
    """
    T4.3: Exécute un job de ré-inférence automatisée (multi-crops + Test-Time Augmentations).
    """
    contents = await file.read()
    safe_filename = validate_upload_security(file, contents, ALLOWED_IMAGE_EXTENSIONS, MAX_IMAGE_SIZE_BYTES, "image")

    try:
        detector = get_detector()
        bioclip = get_bioclip_engine()

        det_res = detector.detect(image_input=contents)
        raw_img = det_res.pop("raw_image", None)
        detections = det_res.get("detections", [])

        if raw_img is not None and len(detections) > 0:
            top_det = detections[0]
            x1, y1, x2, y2 = [int(v) for v in top_det["box_pixel"]]
            h_img, w_img = raw_img.shape[:2]
            crop = raw_img[max(0, y1):min(h_img, y2), max(0, x1):min(w_img, x2)]
        else:
            # Fallback if no box found: use whole image as crop
            crop = detector._prepare_image(contents)

        report = expert_validation_engine.run_expert_validation(
            crop_bgr=crop,
            initial_ai_species=initial_ai_species,
            community_suggested_species=community_suggested_species,
            bioclip_engine=bioclip
        )

        return {
            "success": True,
            "filename": safe_filename,
            "report": report
        }

    except RuntimeError as re:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(re)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de la validation experte automatisée : {str(e)}"
        )



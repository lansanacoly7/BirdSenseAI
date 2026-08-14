"""
BirdSense AI — Routeur Computer Vision (Mock)
Auteur : (Mock pour Hackathon)
"""
import random
import uuid
from typing import List, Dict, Any

from fastapi import APIRouter, UploadFile, File, HTTPException

router = APIRouter(prefix="/api/v1/cv", tags=["Computer Vision"])


@router.post("/detect", summary="Détection d'oiseaux sur une image (Mock YOLO)")
async def detect_birds_in_image(image: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Endpoint temporaire pour simuler la détection par un modèle YOLO.
    Reçoit une image et renvoie un nombre aléatoire d'oiseaux détectés
    avec des fausses bounding boxes.
    """
    # Validation basique du fichier
    if not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Le fichier doit être une image.")

    # Simulation d'un temps de traitement YOLO (Optionnel, on peut le rendre instantané pour la démo)
    # await asyncio.sleep(1)

    # Mock : Générer entre 1 et 6 oiseaux
    bird_count = random.randint(1, 6)
    
    detections = []
    species_pool = [
        {"name": "Pélican blanc", "conf": 0.94},
        {"name": "Flamant rose", "conf": 0.88},
        {"name": "Aigle martial", "conf": 0.72},
        {"name": "Vautour oricou", "conf": 0.85},
    ]

    for _ in range(bird_count):
        bird = random.choice(species_pool)
        detections.append({
            "track_id": str(uuid.uuid4()),
            "species": bird["name"],
            "confidence": round(random.uniform(0.60, bird["conf"]), 2),
            "bbox": {
                "x_center": random.uniform(0.1, 0.9),
                "y_center": random.uniform(0.1, 0.9),
                "width": random.uniform(0.05, 0.2),
                "height": random.uniform(0.05, 0.2)
            }
        })

    return {
        "status": "success",
        "bird_count": bird_count,
        "filename": image.filename,
        "detections": detections
    }

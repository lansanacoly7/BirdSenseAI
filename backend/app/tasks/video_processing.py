"""
BirdSense AI — Tâches Celery pour le traitement lourd (vidéos)
Auteur : Pape Alioune Sène
"""
import time
import logging

from app.celery_app import celery_app

logger = logging.getLogger(__name__)

@celery_app.task(bind=True, name="process_video_task")
def process_video_task(self, observation_id: str, video_url: str):
    """
    Tâche asynchrone lourde simulant le traitement d'une vidéo
    par le modèle d'inférence YOLO et le suivi ByteTrack.
    
    Cette tâche sera exécutée en arrière-plan par le Celery Worker.
    """
    logger.info(f"Début du traitement de la vidéo {video_url} pour l'observation {observation_id}")
    
    # Simulation d'un traitement lourd (ex: extraction de frames, inférence GPU)
    total_steps = 5
    for i in range(total_steps):
        time.sleep(2)  # Simule le temps de traitement de l'IA (2 secondes par batch)
        progress = int(((i + 1) / total_steps) * 100)
        
        # Mise à jour de l'état de la tâche pour suivi éventuel (websockets/polling)
        self.update_state(state='PROGRESS', meta={'progress': progress})
        logger.info(f"Traitement vidéo {observation_id} : {progress}%")
        
    logger.info(f"Fin du traitement de la vidéo {video_url}")
    
    return {
        "status": "success",
        "observation_id": observation_id,
        "frames_processed": 150,
        "unique_birds_tracked": 3
    }

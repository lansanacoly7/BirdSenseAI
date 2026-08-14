"""
BirdSense AI — Service de Modération Automatique
Auteur : Pape Alioune Sène
"""
import logging
from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.community import Report
from app.models.observation import Observation

# Configuration de la modération
MODERATION_REPORT_THRESHOLD = 5
MODERATION_TIME_WINDOW_HOURS = 24

logger = logging.getLogger(__name__)

async def check_and_apply_moderation(db: AsyncSession, observation_id: str) -> bool:
    """
    Vérifie si une observation a atteint le seuil de signalements et la masque le cas échéant.
    Retourne True si l'observation a été masquée, False sinon.
    """
    obs = await db.get(Observation, observation_id)
    if not obs:
        return False
        
    # Si déjà masquée, on ne fait rien
    if obs.is_hidden:
        return False
        
    time_threshold = datetime.utcnow() - timedelta(hours=MODERATION_TIME_WINDOW_HOURS)
    
    # Compter les signalements récents pour cette observation
    stmt = select(func.count(Report.id)).where(
        Report.observation_id == obs.id,
        Report.created_at >= time_threshold
    )
    result = await db.execute(stmt)
    report_count = result.scalar() or 0
    
    if report_count >= MODERATION_REPORT_THRESHOLD:
        obs.is_hidden = True
        db.add(obs)
        await db.commit()
        
        # Log de l'action de modération
        logger.warning(
            f"MODERATION_ACTION: Observation {obs.id} masquée automatiquement. "
            f"Raison: {report_count} signalements dans les dernières {MODERATION_TIME_WINDOW_HOURS}h."
        )
        return True
        
    return False

async def handle_new_report(db: AsyncSession, observation_id: str, user_id: str, reason: str) -> Report:
    """
    Traite un nouveau signalement et déclenche la vérification de modération.
    """
    report = Report(
        observation_id=observation_id,
        user_id=user_id,
        reason=reason
    )
    db.add(report)
    await db.commit()
    
    # Vérification automatique après l'ajout du signalement
    await check_and_apply_moderation(db, observation_id)
    
    return report

"""
BirdSense AI — Routeur Admin pour la modération
Auteur : Pape Alioune Sène
"""
from typing import Any
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models.observation import Observation

router = APIRouter(prefix="/admin", tags=["Admin"])

@router.get("/moderation/pending")
async def get_pending_moderations(
    page: int = Query(1, ge=1, description="Numéro de page"),
    size: int = Query(20, ge=1, le=100, description="Taille de la page"),
    db: AsyncSession = Depends(get_db)
) -> Any:
    """
    Endpoint admin listant les éléments masqués en attente de revue humaine.
    Ici, on retourne toutes les observations ayant is_hidden=True.
    """
    # TODO: Ajouter une dépendance pour vérifier les rôles Admin (ex: Depends(get_current_admin_user))
    
    stmt = select(Observation).where(Observation.is_hidden == True)
    stmt = stmt.order_by(Observation.updated_at.desc())
    stmt = stmt.offset((page - 1) * size).limit(size)
    stmt = stmt.options(selectinload(Observation.reports))
    
    result = await db.execute(stmt)
    hidden_observations = result.scalars().unique().all()
    
    data = []
    for obs in hidden_observations:
        data.append({
            "observation_id": str(obs.id),
            "user_id": str(obs.user_id),
            "is_hidden": obs.is_hidden,
            "reports_count": len(obs.reports),
            "created_at": obs.created_at,
            "updated_at": obs.updated_at
        })
        
    return {
        "data": data,
        "page": page,
        "size": size,
        "total_returned": len(data)
    }

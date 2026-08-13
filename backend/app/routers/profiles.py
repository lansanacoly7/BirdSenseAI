"""
BirdSense AI — Routeur de Profils Utilisateurs (Gamification)
Auteur : Pape Alioune Sène
"""
from typing import Any
import uuid

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models.user import User
from app.models.community import UserBadge
from app.models.observation import Observation, ObservationItem
from app.models.species import Species

router = APIRouter(prefix="/users", tags=["Profils"])

@router.get("/{user_id}/profile")
async def get_user_profile(
    user_id: uuid.UUID,
    db: AsyncSession = Depends(get_db)
) -> Any:
    """
    Récupère le profil public d'un utilisateur incluant ses points, niveau,
    badges et sa collection d'espèces uniques.
    """
    user = await db.get(User, user_id, options=[selectinload(User.badges)])
    if not user:
        raise HTTPException(status_code=404, detail="Utilisateur introuvable")
        
    # Récupération de la collection d'espèces uniques de l'utilisateur
    # On veut distinct(species_id) des observations de cet user
    stmt = (
        select(Species.id, Species.scientific_name, Species.common_name)
        .join(ObservationItem, ObservationItem.species_id == Species.id)
        .join(Observation, Observation.id == ObservationItem.observation_id)
        .where(Observation.user_id == user_id)
        .group_by(Species.id, Species.scientific_name, Species.common_name)
    )
    result = await db.execute(stmt)
    species_collection = result.all()
    
    collection = [
        {
            "id": str(sp.id),
            "scientific_name": sp.scientific_name,
            "common_name": sp.common_name
        }
        for sp in species_collection
    ]
    
    return {
        "id": str(user.id),
        "username": user.username,
        "points": user.points,
        "level": user.level,
        "badges": [badge.badge_name for badge in user.badges],
        "collection_count": len(collection),
        "collection": collection
    }

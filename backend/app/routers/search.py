"""
BirdSense AI — Routeur de recherche d'observations
Auteur : Pape Alioune Sène
"""
from datetime import datetime
from typing import List, Optional
import uuid

from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy import func, select, or_, and_
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.database import get_db
from app.models.observation import Observation
from app.models.community import Favorite, Comment
from app.models.species import Species

router = APIRouter(prefix="/observations", tags=["Recherche"])

@router.get("/search")
async def search_observations(
    lat: float = Query(..., description="Latitude"),
    lon: float = Query(..., description="Longitude"),
    radius_km: float = Query(5.0, description="Rayon de recherche en km"),
    date_from: Optional[datetime] = Query(None, description="Date de début"),
    date_to: Optional[datetime] = Query(None, description="Date de fin"),
    rare_species: bool = Query(False, description="Filtrer uniquement les espèces rares"),
    page: int = Query(1, ge=1, description="Numéro de page"),
    size: int = Query(20, ge=1, le=100, description="Taille de la page"),
    db: AsyncSession = Depends(get_db)
):
    """
    Recherche avancée d'observations.
    Combine proximité géospatiale, filtres d'espèces rares, de date, et tri par popularité.
    Respecte le floutage GPS pour les espèces protégées/rares.
    """
    
    # Construction de la requête de base
    # NOTE: location est stocké sous forme de texte POINT(lon lat) en base pour ST_DWithin
    # PostGIS function ST_DWithin: ST_DWithin(geom, ST_MakePoint(lon, lat)::geography, radius_m)
    
    radius_meters = radius_km * 1000
    point_geom = func.ST_SetSRID(func.ST_MakePoint(lon, lat), 4326)
    
    # Requête de base pour les observations
    stmt = select(Observation).where(
        func.ST_DWithin(func.ST_GeomFromText(Observation.location, 4326), point_geom, radius_meters)
    )
    
    # Ne pas retourner les observations masquées par la modération
    stmt = stmt.where(Observation.is_hidden == False)

    # Filtrage par dates
    if date_from:
        stmt = stmt.where(Observation.observed_at >= date_from)
    if date_to:
        stmt = stmt.where(Observation.observed_at <= date_to)
        
    # Filtrage espèces rares (has_protected_species)
    if rare_species:
        stmt = stmt.where(Observation.has_protected_species == True)
        
    # Sous-requêtes pour le calcul de popularité (favorites * 2 + comments)
    fav_count = select(func.count(Favorite.id)).where(Favorite.observation_id == Observation.id).scalar_subquery()
    comment_count = select(func.count(Comment.id)).where(Comment.observation_id == Observation.id).scalar_subquery()
    
    popularity = (func.coalesce(fav_count, 0) * 2 + func.coalesce(comment_count, 0)).label("popularity")
    
    # Application du tri et de la pagination
    stmt = stmt.order_by(popularity.desc(), Observation.observed_at.desc())
    stmt = stmt.offset((page - 1) * size).limit(size)
    stmt = stmt.options(selectinload(Observation.items).selectinload(ObservationItem.species))
    
    # Exécution
    # On gère manuellement ObservationItem car l'import est dans model
    from app.models.observation import ObservationItem
    
    result = await db.execute(stmt)
    observations = result.scalars().unique().all()
    
    # Préparation de la réponse et application du floutage GPS
    response_data = []
    for obs in observations:
        obs_dict = {
            "id": str(obs.id),
            "user_id": str(obs.user_id),
            "observed_at": obs.observed_at,
            "media_url": obs.media_url,
            "thumbnail_url": obs.thumbnail_url,
            "has_protected_species": obs.has_protected_species,
        }
        
        # Floutage GPS
        if obs.has_protected_species and obs.location_public:
            obs_dict["location"] = obs.location_public
        else:
            obs_dict["location"] = obs.location
            
        # Informations sur les espèces
        items_data = []
        for item in obs.items:
            items_data.append({
                "species_id": str(item.species_id) if item.species_id else None,
                "species_name": item.species.scientific_name if item.species else item.species_raw_name,
                "count": item.count
            })
        obs_dict["items"] = items_data
        
        response_data.append(obs_dict)
        
    return {
        "data": response_data,
        "page": page,
        "size": size,
        "total": len(response_data) # Note: Ce n'est pas le vrai total, il faudrait un count(*)
    }

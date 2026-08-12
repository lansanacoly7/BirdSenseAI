"""
BirdSense AI — Routeur Observations
Auteur : Pape Alioune Sène

Endpoints:
- POST /api/v1/observations/sync : Ingestion batch offline/online
- POST /api/v1/observations/map : Filtrage géospatial par Bounding Box
"""
import uuid
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from geoalchemy2.elements import WKTElement
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.observation import Observation, ObservationItem
from app.models.species import Species
from app.models.user import User
from app.schemas.observation import (
    BatchSyncRequest,
    BatchSyncResponse,
    BoundingBoxFilter,
    MapObservationsResponse,
    ObservationMapPoint,
)
from app.services.auth_service import get_current_user
from app.services.gps_blur import blur_coordinates, build_wkt_point, should_blur

router = APIRouter(prefix="/api/v1/observations", tags=["Observations"])


@router.post(
    "/sync",
    response_model=BatchSyncResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Synchronisation par lot des observations depuis le mobile",
)
async def sync_observations(
    sync_req: BatchSyncRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> BatchSyncResponse:
    """
    Ingère un lot d'observations provenant du client mobile (gestion hors-ligne).
    Détermine si l'observation contient une espèce protégée et applique
    le calcul de floutage GPS si nécessaire.
    """
    synced_count = 0
    failed_count = 0
    observation_ids = []
    errors = []

    # Cache local pour éviter de requêter la même espèce plusieurs fois par batch
    species_cache: dict[uuid.UUID, Species] = {}

    for obs_in in sync_req.observations:
        try:
            has_protected = False

            # 1. Analyser les items pour détecter des espèces protégées
            for item_in in obs_in.items:
                if item_in.species_id:
                    if item_in.species_id not in species_cache:
                        result = await db.execute(
                            select(Species).where(Species.id == item_in.species_id)
                        )
                        species = result.scalar_one_or_none()
                        if species:
                            species_cache[item_in.species_id] = species

                    species = species_cache.get(item_in.species_id)
                    if species and should_blur(species.iucn_status, species.is_protected):
                        has_protected = True
                        break  # Dès qu'une espèce protégée est vue, toute l'observation est protégée

            # 2. Préparer les coordonnées spatiales
            real_wkt = build_wkt_point(obs_in.latitude, obs_in.longitude)
            public_wkt = None

            if has_protected:
                blurred_lat, blurred_lon = blur_coordinates(obs_in.latitude, obs_in.longitude)
                public_wkt = build_wkt_point(blurred_lat, blurred_lon)

            # 3. Créer l'observation principale
            new_obs = Observation(
                user_id=current_user.id,
                observed_at=obs_in.observed_at,
                location=WKTElement(real_wkt, srid=4326),
                location_public=WKTElement(public_wkt, srid=4326) if public_wkt else None,
                altitude_m=obs_in.altitude_m,
                location_accuracy_m=obs_in.location_accuracy_m,
                media_type=obs_in.media_type,
                media_url=obs_in.media_url,
                thumbnail_url=obs_in.thumbnail_url,
                weather_conditions=obs_in.weather_conditions,
                notes=obs_in.notes,
                device_id=obs_in.device_id,
                has_protected_species=has_protected,
                sync_status="synced",
            )
            db.add(new_obs)
            await db.flush()  # Pour obtenir new_obs.id

            # 4. Créer les items de l'observation
            for item_in in obs_in.items:
                new_item = ObservationItem(
                    observation_id=new_obs.id,
                    species_id=item_in.species_id,
                    species_raw_name=item_in.species_raw_name,
                    count=item_in.count,
                    confidence_score=item_in.confidence_score,
                    bbox_x_center=item_in.bbox_x_center,
                    bbox_y_center=item_in.bbox_y_center,
                    bbox_width=item_in.bbox_width,
                    bbox_height=item_in.bbox_height,
                    track_id=item_in.track_id,
                    bayesian_score=item_in.bayesian_score,
                    behavior=item_in.behavior,
                )
                db.add(new_item)

            observation_ids.append(new_obs.id)
            synced_count += 1

        except Exception as e:
            failed_count += 1
            errors.append(f"Erreur sur observation {obs_in.observed_at} : {str(e)}")
            # On ne rollback pas toute la transaction pour un échec partiel
            # On laisse le routeur catcher s'il y a un gros plantage,
            # ou on pourrait implémenter des savepoints. Pour un MVP, c'est OK.

    return BatchSyncResponse(
        synced_count=synced_count,
        failed_count=failed_count,
        observation_ids=observation_ids,
        errors=errors,
    )


@router.post(
    "/map",
    response_model=MapObservationsResponse,
    summary="Récupère les observations pour la carte (Bounding Box)",
)
async def get_map_observations(
    filter_in: BoundingBoxFilter,
    db: AsyncSession = Depends(get_db),
    # Note: cet endpoint pourrait être public ou protégé selon les besoins métiers.
    # On le laisse public mais flouté.
) -> MapObservationsResponse:
    """
    Retourne les points géospatiaux inclus dans une Bounding Box (Coin Sud-Ouest vers Nord-Est).
    Utilise la vue `v_observations_public` pour garantir que les espèces protégées
    sont retournées avec leurs coordonnées floutées.
    """
    # Création du polygone Bounding Box en WKT (SRID=4326)
    # Polygon format : min_lon min_lat, min_lon max_lat, max_lon max_lat, max_lon min_lat, min_lon min_lat
    bbox_wkt = f"SRID=4326;POLYGON(({filter_in.min_lon} {filter_in.min_lat}, {filter_in.min_lon} {filter_in.max_lat}, {filter_in.max_lon} {filter_in.max_lat}, {filter_in.max_lon} {filter_in.min_lat}, {filter_in.min_lon} {filter_in.min_lat}))"

    # On s'appuie sur la table observations (car on n'a pas pu créer la vue via SQLAlchemy model facilement)
    # et on fait la logique de sélection de colonne de localisation dynamiquement
    
    # Choix de la géométrie à retourner : location_public si protected, sinon location
    geom_col = func.coalesce(Observation.location_public, Observation.location)
    
    query = select(
        Observation.id,
        func.ST_Y(geom_col.cast(func.geometry())).label("latitude"),
        func.ST_X(geom_col.cast(func.geometry())).label("longitude"),
        Observation.observed_at,
        Observation.media_type,
        Observation.thumbnail_url,
        Observation.has_protected_species,
        func.count(ObservationItem.id).label("species_count"),
        func.sum(ObservationItem.count).label("total_birds")
    ).select_from(Observation).outerjoin(
        ObservationItem, Observation.id == ObservationItem.observation_id
    ).where(
        Observation.sync_status == "synced"
    ).where(
        # ST_Intersects avec l'index spatial GiST
        func.ST_Intersects(geom_col, func.ST_GeomFromEWKT(bbox_wkt))
    )

    # Filtre optionnel par date
    if filter_in.from_date:
        query = query.where(Observation.observed_at >= filter_in.from_date)
    if filter_in.to_date:
        query = query.where(Observation.observed_at <= filter_in.to_date)

    # Filtre optionnel par espèce spécifique
    if filter_in.species_id:
        query = query.where(ObservationItem.species_id == filter_in.species_id)

    # Group By car on agrège les items
    query = query.group_by(
        Observation.id,
        "latitude",
        "longitude",
        Observation.observed_at,
        Observation.media_type,
        Observation.thumbnail_url,
        Observation.has_protected_species
    )

    # Limite
    query = query.limit(filter_in.limit)
    
    # Disable cache to avoid GeoAlchemy2 SQLAlchemy 2.0 _static_cache_key error
    query = query.execution_options(compiled_cache=None)

    result = await db.execute(query)
    rows = result.all()

    points = []
    for row in rows:
        points.append(
            ObservationMapPoint(
                id=row.id,
                latitude=row.latitude,
                longitude=row.longitude,
                observed_at=row.observed_at,
                species_count=row.species_count or 0,
                total_birds=row.total_birds or 0,
                media_type=row.media_type,
                thumbnail_url=row.thumbnail_url,
                has_protected_species=row.has_protected_species,
            )
        )

    return MapObservationsResponse(total=len(points), points=points)

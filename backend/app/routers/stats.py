"""
BirdSense AI — Routeur Stats / Dashboard
"""
from fastapi import APIRouter, Depends
from sqlalchemy import select, func, case
from sqlalchemy.ext.asyncio import AsyncSession
from pydantic import BaseModel

from app.database import get_db
from app.models.observation import Observation, ObservationItem
from app.models.species import Species

router = APIRouter(prefix="/api/v1/stats", tags=["Statistiques"])


class DashboardStats(BaseModel):
    total_observations: int = 0
    total_species: int = 0
    total_birds_counted: int = 0
    species_endangered: int = 0
    recent_observations_7d: int = 0


@router.get("", response_model=DashboardStats, summary="Statistiques du dashboard")
async def get_dashboard_stats(
    db: AsyncSession = Depends(get_db),
) -> DashboardStats:
    # Total observations
    obs_count = await db.execute(select(func.count(Observation.id)))
    total_obs = obs_count.scalar() or 0

    # Total species in DB
    sp_count = await db.execute(select(func.count(Species.id)))
    total_species = sp_count.scalar() or 0

    # Total birds counted
    birds_count = await db.execute(select(func.coalesce(func.sum(ObservationItem.count), 0)))
    total_birds = birds_count.scalar() or 0

    # Species endangered (EN or CR)
    endangered_count = await db.execute(
        select(func.count(Species.id)).where(Species.iucn_status.in_(["EN", "CR"]))
    )
    endangered = endangered_count.scalar() or 0

    # Recent observations (7 days)
    from datetime import datetime, timedelta, timezone
    seven_days_ago = datetime.now(timezone.utc) - timedelta(days=7)
    recent_count = await db.execute(
        select(func.count(Observation.id)).where(Observation.observed_at >= seven_days_ago)
    )
    recent = recent_count.scalar() or 0

    return DashboardStats(
        total_observations=total_obs,
        total_species=total_species,
        total_birds_counted=total_birds,
        species_endangered=endangered,
        recent_observations_7d=recent,
    )

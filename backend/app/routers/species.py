"""
BirdSense AI — Routeur Species
Auteur : Pape Alioune Sène
"""
from fastapi import APIRouter, Depends
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.species import Species
from app.schemas.species import SpeciesResponse, SpeciesListResponse

router = APIRouter(prefix="/api/v1/species", tags=["Espèces"])


@router.get(
    "",
    response_model=SpeciesListResponse,
    summary="Liste de toutes les espèces répertoriées",
)
async def list_species(
    db: AsyncSession = Depends(get_db),
) -> SpeciesListResponse:
    result = await db.execute(select(Species).order_by(Species.common_name_fr))
    species = result.scalars().all()
    return SpeciesListResponse(total=len(species), species=species)


@router.get(
    "/{species_id}",
    response_model=SpeciesResponse,
    summary="Détails d'une espèce",
)
async def get_species(
    species_id: str,
    db: AsyncSession = Depends(get_db),
) -> SpeciesResponse:
    from uuid import UUID
    result = await db.execute(select(Species).where(Species.id == UUID(species_id)))
    species = result.scalar_one_or_none()
    if not species:
        from fastapi import HTTPException, status
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Espèce non trouvée")
    return species

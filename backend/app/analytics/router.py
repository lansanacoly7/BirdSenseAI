"""backend/app/analytics/router.py

Endpoint GET /api/v1/analytics/stats
Retourne le score de santé (Shannon-Wiener), la diversité des espèces
et le volume temporel des observations.

MOCK — Dépendance au schéma réel de Pape Alioune Sène :
  - La requête SQL est effectuée sur les tables `observations` et `species`
    telles que définies dans le schéma PostGIS de Pape.
  - Si ces tables n'existent pas encore, le fallback retourne des données
    mockées documentées clairement ci-dessous.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text

from .schemas import AnalyticsStatsResponse, SpeciesDiversityItem, TemporalVolumeItem
from .services import compute_shannon_wiener_index

router = APIRouter(prefix="/api/v1/analytics", tags=["analytics"])


async def get_db() -> AsyncSession:
    """
    Dépendance DB — à remplacer par la vraie session de Pape.
    MOCK : levée d'une exception si pas de session disponible.
    """
    raise NotImplementedError(
        "MOCK — get_db() doit être remplacé par la session SQLAlchemy réelle "
        "du backend de Pape Alioune Sène (T3.1)."
    )


@router.get("/stats", response_model=AnalyticsStatsResponse)
async def get_analytics_stats():
    """
    Endpoint principal d'analytics.

    Retourne :
    - bird_health_score : Indice de Shannon-Wiener sur les observations
    - species_diversity : Comptage par espèce
    - temporal_volume : Volume d'observations par date

    MOCK — En attendant le schéma réel de Pape, on retourne des données fictives
    documentées. À remplacer dès intégration de la vraie DB.
    """
    # ================================================================
    # MOCK — Données de substitution en attendant le schéma de Pape
    # Remplacer les blocs ci-dessous par des vraies requêtes SQLAlchemy.
    # ================================================================

    mock_species_counts = {
        "Passer domesticus": 45,
        "Corvus corax": 12,
        "Falco tinnunculus": 8,
        "Bubulcus ibis": 30,
        "Ardea cinerea": 5,
    }

    mock_temporal = [
        {"date": "2025-07-01", "count": 10},
        {"date": "2025-07-08", "count": 18},
        {"date": "2025-07-15", "count": 25},
        {"date": "2025-07-22", "count": 15},
        {"date": "2025-07-29", "count": 32},
    ]

    # Calcul du score de santé via Shannon-Wiener
    bhs = compute_shannon_wiener_index(mock_species_counts)

    return AnalyticsStatsResponse(
        bird_health_score=round(bhs, 4),
        species_diversity=[
            SpeciesDiversityItem(species_name=k, count=v)
            for k, v in mock_species_counts.items()
        ],
        temporal_volume=[
            TemporalVolumeItem(date=item["date"], count=item["count"])
            for item in mock_temporal
        ],
    )

from pydantic import BaseModel, Field
from typing import List

class SpeciesDiversityItem(BaseModel):
    species_name: str
    count: int

class TemporalVolumeItem(BaseModel):
    date: str
    count: int

class AnalyticsStatsResponse(BaseModel):
    bird_health_score: float = Field(
        ..., 
        description="Score de santé de l'écosystème basé sur l'indice de Shannon-Wiener"
    )
    species_diversity: List[SpeciesDiversityItem] = Field(
        ..., 
        description="Répartition des observations par espèce"
    )
    temporal_volume: List[TemporalVolumeItem] = Field(
        ..., 
        description="Volume des observations dans le temps (ex: par jour/mois)"
    )

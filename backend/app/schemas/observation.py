"""
BirdSense AI — Schemas Pydantic v2 : Observations
Auteur : Pape Alioune Sène
"""
import uuid
from datetime import datetime

from pydantic import BaseModel, Field, model_validator


# =============================================================================
# Schemas Input (client → serveur)
# =============================================================================

class ObservationItemIn(BaseModel):
    """Un item de détection dans une observation (1 espèce)."""
    species_id: uuid.UUID | None = None
    species_raw_name: str | None = Field(None, max_length=255)
    count: int = Field(1, ge=1, le=10000)
    confidence_score: float | None = Field(None, ge=0.0, le=1.0)
    bbox_x_center: float | None = Field(None, ge=0.0, le=1.0)
    bbox_y_center: float | None = Field(None, ge=0.0, le=1.0)
    bbox_width: float | None = Field(None, ge=0.0, le=1.0)
    bbox_height: float | None = Field(None, ge=0.0, le=1.0)
    track_id: int | None = None
    bayesian_score: float | None = Field(None, ge=0.0, le=1.0)
    behavior: str | None = Field(None, max_length=100)

    @model_validator(mode="after")
    def check_species_or_raw_name(self) -> "ObservationItemIn":
        if self.species_id is None and self.species_raw_name is None:
            raise ValueError("Au moins species_id ou species_raw_name est requis.")
        return self


class ObservationIn(BaseModel):
    """Une observation unique (photo ou vidéo) à synchroniser."""
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    altitude_m: float | None = None
    location_accuracy_m: float | None = Field(None, ge=0.0)
    observed_at: datetime
    media_type: str = Field("photo", pattern=r"^(photo|video)$")
    media_url: str | None = None
    thumbnail_url: str | None = None
    weather_conditions: str | None = None
    notes: str | None = Field(None, max_length=2000)
    device_id: str | None = Field(None, max_length=255)
    items: list[ObservationItemIn] = Field(..., min_length=1)


class BatchSyncRequest(BaseModel):
    """Requête de synchronisation par lot depuis le mobile."""
    observations: list[ObservationIn] = Field(..., min_length=1, max_length=100)


# =============================================================================
# Schemas Bounding Box pour le filtre géospatial
# =============================================================================

class BoundingBoxFilter(BaseModel):
    """Filtre géospatial pour la carte (coin SW → coin NE)."""
    min_lat: float = Field(..., ge=-90.0, le=90.0)
    min_lon: float = Field(..., ge=-180.0, le=180.0)
    max_lat: float = Field(..., ge=-90.0, le=90.0)
    max_lon: float = Field(..., ge=-180.0, le=180.0)
    species_id: uuid.UUID | None = None
    iucn_status: str | None = None
    from_date: datetime | None = None
    to_date: datetime | None = None
    limit: int = Field(500, ge=1, le=2000)

    @model_validator(mode="after")
    def check_bbox(self) -> "BoundingBoxFilter":
        if self.min_lat >= self.max_lat:
            raise ValueError("min_lat doit être inférieur à max_lat.")
        if self.min_lon >= self.max_lon:
            raise ValueError("min_lon doit être inférieur à max_lon.")
        return self


# =============================================================================
# Schemas Output (serveur → client)
# =============================================================================

class ObservationItemOut(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    species_id: uuid.UUID | None
    species_raw_name: str | None
    count: int
    confidence_score: float | None
    bbox_x_center: float | None
    bbox_y_center: float | None
    bbox_width: float | None
    bbox_height: float | None
    track_id: int | None
    bayesian_score: float | None
    behavior: str | None


class ObservationOut(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    user_id: uuid.UUID
    latitude: float
    longitude: float
    has_protected_species: bool
    observed_at: datetime
    media_type: str
    media_url: str | None
    thumbnail_url: str | None
    notes: str | None
    items: list[ObservationItemOut]
    created_at: datetime


class ObservationMapPoint(BaseModel):
    """Point allégé pour l'affichage carte (sans items détaillés)."""
    id: uuid.UUID
    latitude: float
    longitude: float
    observed_at: datetime
    species_count: int
    total_birds: int
    media_type: str
    thumbnail_url: str | None
    has_protected_species: bool


class BatchSyncResponse(BaseModel):
    synced_count: int
    failed_count: int
    observation_ids: list[uuid.UUID]
    errors: list[str]


class MapObservationsResponse(BaseModel):
    total: int
    points: list[ObservationMapPoint]

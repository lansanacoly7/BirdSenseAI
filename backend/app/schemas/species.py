"""
BirdSense AI — Schemas Pydantic v2 : Species
Auteur : Pape Alioune Sène
"""
import uuid
from datetime import datetime

from pydantic import BaseModel, Field


class SpeciesResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    scientific_name: str
    common_name_fr: str
    common_name_en: str | None
    family: str | None
    order_name: str | None
    iucn_status: str
    is_protected: bool
    ebird_code: str | None
    audio_url: str | None
    image_url: str | None
    description: str | None
    habitat: str | None
    yolo_class_id: int | None
    created_at: datetime


class SpeciesListResponse(BaseModel):
    total: int
    species: list[SpeciesResponse]

"""
BirdSense AI — Schemas Pydantic v2 : Communauté
Auteur : Pape Alioune Sène

Schémas pour : Comments, Validations, Reports, Favorites
"""
import uuid
from datetime import datetime

from pydantic import BaseModel, Field


# =============================================================================
# COMMENT Schemas
# =============================================================================

class CommentIn(BaseModel):
    """Payload pour créer un commentaire sur une observation."""
    content: str = Field(..., min_length=1, max_length=2000)


class CommentOut(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    observation_id: uuid.UUID
    user_id: uuid.UUID
    content: str
    created_at: datetime
    updated_at: datetime


class CommentsListResponse(BaseModel):
    total: int
    items: list[CommentOut]


# =============================================================================
# VALIDATION Schemas
# =============================================================================

class ValidationIn(BaseModel):
    """
    Payload pour valider ou contester une identification d'espèce.
    - Si is_confirmation=True : l'utilisateur confirme l'espèce identifiée par l'IA.
    - Si is_confirmation=False : l'utilisateur propose une autre espèce (proposed_species_id requis).
    """
    is_confirmation: bool = True
    proposed_species_id: uuid.UUID | None = None
    comment: str | None = Field(None, max_length=1000)


class ValidationOut(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    observation_id: uuid.UUID
    user_id: uuid.UUID
    is_confirmation: bool
    proposed_species_id: uuid.UUID | None
    comment: str | None
    created_at: datetime


class ValidationsListResponse(BaseModel):
    total: int
    confirmations: int  # nombre de votes "confirmation"
    contestations: int  # nombre de votes "contestation"
    items: list[ValidationOut]


# =============================================================================
# REPORT Schemas
# =============================================================================

VALID_REPORT_REASONS = {
    "spam",
    "inappropriate",
    "wrong_species",
    "duplicate",
    "other",
}


class ReportIn(BaseModel):
    """Payload pour signaler une observation abusive ou incorrecte."""
    reason: str = Field(..., description="spam | inappropriate | wrong_species | duplicate | other")
    details: str | None = Field(None, max_length=1000)


class ReportOut(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    observation_id: uuid.UUID
    user_id: uuid.UUID
    reason: str
    details: str | None
    status: str
    created_at: datetime


# =============================================================================
# FAVORITE Schemas
# =============================================================================

class FavoriteOut(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    observation_id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime


class FavoritesListResponse(BaseModel):
    total: int
    items: list[FavoriteOut]


# =============================================================================
# Feed communautaire (liste paginée d'observations publiques enrichies)
# =============================================================================

class CommunityObservationItem(BaseModel):
    """Item allégé pour le Feed communautaire."""
    model_config = {"from_attributes": True}

    id: uuid.UUID
    user_id: uuid.UUID
    observed_at: datetime
    latitude: float | None = None
    longitude: float | None = None
    media_type: str
    thumbnail_url: str | None
    notes: str | None
    comments_count: int = 0
    validations_count: int = 0
    favorites_count: int = 0
    has_protected_species: bool


class CommunityFeedResponse(BaseModel):
    total: int
    page: int
    page_size: int
    items: list[CommunityObservationItem]

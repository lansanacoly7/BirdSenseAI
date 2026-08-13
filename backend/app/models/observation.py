"""
BirdSense AI — Modèles ORM Observation & ObservationItem
Auteur : Pape Alioune Sène
"""
import uuid
from datetime import datetime

from sqlalchemy import (
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    String,
    Text,
    func,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Observation(Base):
    __tablename__ = "observations"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    observed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), index=True
    )

    # Coordonnées GPS réelles (stockage interne — jamais exposées si espèce protégée)
    location: Mapped[str] = mapped_column(String, nullable=False)

    # Coordonnées floutées exposées publiquement (5 km de décalage aléatoire)
    location_public: Mapped[str | None] = mapped_column(String, nullable=True)

    altitude_m: Mapped[float | None] = mapped_column(Float, nullable=True)
    location_accuracy_m: Mapped[float | None] = mapped_column(Float, nullable=True)
    media_type: Mapped[str] = mapped_column(String(10), nullable=False, default="photo")
    media_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    thumbnail_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    weather_conditions: Mapped[str | None] = mapped_column(Text, nullable=True)
    notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    sync_status: Mapped[str] = mapped_column(String(20), nullable=False, default="synced", index=True)
    device_id: Mapped[str | None] = mapped_column(String(255), nullable=True)

    # Flag : True si au moins un item contient une espèce IUCN EN/CR
    has_protected_species: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now()
    )

    # Relations
    user: Mapped["User"] = relationship("User", back_populates="observations")  # noqa: F821
    items: Mapped[list["ObservationItem"]] = relationship(
        "ObservationItem",
        back_populates="observation",
        cascade="all, delete-orphan",
        lazy="selectin",
    )
    comments: Mapped[list["Comment"]] = relationship(  # noqa: F821
        "Comment", back_populates="observation", cascade="all, delete-orphan"
    )
    validations: Mapped[list["Validation"]] = relationship(  # noqa: F821
        "Validation", back_populates="observation", cascade="all, delete-orphan"
    )
    reports: Mapped[list["Report"]] = relationship(  # noqa: F821
        "Report", back_populates="observation", cascade="all, delete-orphan"
    )
    favorited_by: Mapped[list["Favorite"]] = relationship(  # noqa: F821
        "Favorite", back_populates="observation", cascade="all, delete-orphan"
    )

    def __repr__(self) -> str:
        return f"<Observation id={self.id} user_id={self.user_id} observed_at={self.observed_at}>"


class ObservationItem(Base):
    __tablename__ = "observation_items"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    observation_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("observations.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    species_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("species.id", ondelete="SET NULL"),
        nullable=True,
        index=True,
    )
    species_raw_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    count: Mapped[int] = mapped_column(Integer, nullable=False, default=1)
    confidence_score: Mapped[float | None] = mapped_column(Float, nullable=True)

    # Bounding box normalisée format YOLO [x_center, y_center, width, height]
    bbox_x_center: Mapped[float | None] = mapped_column(Float, nullable=True)
    bbox_y_center: Mapped[float | None] = mapped_column(Float, nullable=True)
    bbox_width: Mapped[float | None] = mapped_column(Float, nullable=True)
    bbox_height: Mapped[float | None] = mapped_column(Float, nullable=True)

    # Track ID ByteTrack (anti-double-comptage vidéo)
    track_id: Mapped[int | None] = mapped_column(Integer, nullable=True)

    # Score bayésien fusionné (Score Visuel × Prior Régional eBird)
    bayesian_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    behavior: Mapped[str | None] = mapped_column(String(100), nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )

    # Relations
    observation: Mapped["Observation"] = relationship("Observation", back_populates="items")
    species: Mapped["Species | None"] = relationship(  # noqa: F821
        "Species", back_populates="observation_items"
    )

    def __repr__(self) -> str:
        return f"<ObservationItem id={self.id} species_id={self.species_id} count={self.count}>"

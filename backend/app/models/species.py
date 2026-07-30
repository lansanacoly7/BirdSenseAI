"""
BirdSense AI — Modèle ORM Species
Auteur : Pape Alioune Sène
"""
import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Float, Integer, String, Text, func
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class Species(Base):
    __tablename__ = "species"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), primary_key=True, default=uuid.uuid4
    )
    scientific_name: Mapped[str] = mapped_column(
        String(255), nullable=False, unique=True, index=True
    )
    common_name_fr: Mapped[str] = mapped_column(String(255), nullable=False)
    common_name_en: Mapped[str | None] = mapped_column(String(255), nullable=True)
    family: Mapped[str | None] = mapped_column(String(100), nullable=True)
    order_name: Mapped[str | None] = mapped_column(String(100), nullable=True)

    # Statut IUCN : LC | NT | VU | EN | CR | EW | EX
    iucn_status: Mapped[str] = mapped_column(String(10), nullable=False, default="LC", index=True)

    # True si EN ou CR → coordonnées GPS floutées à 5 km
    is_protected: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False, index=True)

    ebird_code: Mapped[str | None] = mapped_column(String(20), nullable=True)
    gbif_taxon_key: Mapped[int | None] = mapped_column(Integer, nullable=True)
    audio_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    image_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    habitat: Mapped[str | None] = mapped_column(Text, nullable=True)
    yolo_class_id: Mapped[int | None] = mapped_column(Integer, nullable=True, index=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now()
    )

    # Relations
    observation_items: Mapped[list["ObservationItem"]] = relationship(  # noqa: F821
        "ObservationItem", back_populates="species"
    )

    def __repr__(self) -> str:
        return f"<Species id={self.id} scientific_name={self.scientific_name} iucn={self.iucn_status}>"

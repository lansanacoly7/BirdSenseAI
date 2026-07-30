"""
BirdSense AI — Configuration centralisée (Pydantic BaseSettings)
Auteur : Pape Alioune Sène
"""
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Application
    app_name: str = "BirdSense AI"
    app_version: str = "1.0.0"
    debug: bool = False
    environment: str = "development"

    # Base de données
    database_url: str

    # JWT
    secret_key: str
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 7

    # CORS
    allowed_origins: str = "http://localhost:3000,http://localhost:8000"

    @property
    def allowed_origins_list(self) -> list[str]:
        return [origin.strip() for origin in self.allowed_origins.split(",")]

    # Géospatial — Floutage GPS pour espèces protégées
    gps_blur_radius_meters: float = 5000.0  # 5 km


@lru_cache
def get_settings() -> Settings:
    """Retourne les settings en cache (singleton)."""
    return Settings()

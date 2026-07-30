"""
BirdSense AI — Engine SQLAlchemy 2.0 async + Session Factory
Auteur : Pape Alioune Sène
"""
from collections.abc import AsyncGenerator

from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import DeclarativeBase

from app.config import get_settings

settings = get_settings()

# Création de l'engine async PostgreSQL via asyncpg
engine = create_async_engine(
    settings.database_url,
    echo=settings.debug,
    pool_size=10,
    max_overflow=20,
    pool_timeout=30,
    pool_recycle=1800,
    pool_pre_ping=True,  # Vérifie la connexion avant utilisation
)

# Factory de sessions async
AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
    autoflush=False,
    autocommit=False,
)


class Base(DeclarativeBase):
    """Classe de base pour tous les modèles ORM."""
    pass


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependency FastAPI : fournit une session de base de données async.
    La session est automatiquement fermée après la requête.
    """
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()

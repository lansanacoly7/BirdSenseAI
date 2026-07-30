"""
BirdSense AI — Point d'entrée de l'API FastAPI
Auteur : Pape Alioune Sène
"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import get_settings
from app.routers import auth_router, obs_router

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Gestion du cycle de vie de l'application FastAPI.
    - Initialisation (startup) : on pourrait setup Redis, charger le cache, etc.
    - Fermeture (shutdown) : on ferme proprement les connexions DB.
    """
    # Startup
    yield
    # Shutdown
    from app.database import engine
    await engine.dispose()


app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description="Backend API pour l'application mobile BirdSense AI. Détection, comptage et protection des oiseaux.",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# Configuration CORS (Cross-Origin Resource Sharing)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Inscription des routeurs (Endpoints REST)
app.include_router(auth_router)
app.include_router(obs_router)


@app.get("/health", tags=["Système"], summary="Vérification de l'état du serveur")
async def health_check() -> JSONResponse:
    """Endpoint de santé pour les load balancers ou Docker/Kubernetes."""
    return JSONResponse(
        content={
            "status": "ok",
            "app_name": settings.app_name,
            "version": settings.app_version,
            "environment": settings.environment,
        }
    )


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.debug,
    )

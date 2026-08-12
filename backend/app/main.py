"""
BirdSense AI — Point d'entrée de l'API FastAPI
Auteur : Pape Alioune Sène
"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.config import get_settings
from app.routers import auth_router, obs_router, chat_router, stats_router, species_router

settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
)

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
app.include_router(stats_router)
app.include_router(species_router)
app.include_router(chat_router, prefix="/api/v1")


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

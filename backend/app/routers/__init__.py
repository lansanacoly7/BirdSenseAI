"""BirdSense AI — __init__ routers"""
from app.routers.auth import router as auth_router
from app.routers.observations import router as obs_router
from app.routers.chat import router as chat_router
from app.routers.stats import router as stats_router
from app.routers.species import router as species_router

__all__ = ["auth_router", "obs_router", "chat_router", "stats_router", "species_router"]

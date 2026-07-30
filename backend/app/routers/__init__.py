"""BirdSense AI — __init__ routers"""
from app.routers.auth import router as auth_router
from app.routers.observations import router as obs_router
from app.routers.chat import router as chat_router

__all__ = ["auth_router", "obs_router", "chat_router"]

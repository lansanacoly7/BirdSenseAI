"""BirdSense AI — __init__ schemas"""
from app.schemas.auth import (
    UserRegisterRequest,
    UserLoginRequest,
    TokenResponse,
    RefreshTokenRequest,
    UserResponse,
    TokenPayload,
)
from app.schemas.observation import (
    ObservationIn,
    ObservationItemIn,
    BatchSyncRequest,
    BatchSyncResponse,
    BoundingBoxFilter,
    ObservationOut,
    ObservationItemOut,
    ObservationMapPoint,
    MapObservationsResponse,
)
from app.schemas.species import SpeciesResponse, SpeciesListResponse

__all__ = [
    "UserRegisterRequest", "UserLoginRequest", "TokenResponse",
    "RefreshTokenRequest", "UserResponse", "TokenPayload",
    "ObservationIn", "ObservationItemIn", "BatchSyncRequest",
    "BatchSyncResponse", "BoundingBoxFilter", "ObservationOut",
    "ObservationItemOut", "ObservationMapPoint", "MapObservationsResponse",
    "SpeciesResponse", "SpeciesListResponse",
]

"""
BirdSense AI — Schemas Pydantic v2 : Authentification & Utilisateurs
Auteur : Pape Alioune Sène
"""
import uuid
from datetime import datetime

from pydantic import BaseModel, EmailStr, Field, field_validator


# =============================================================================
# Auth : Inscription
# =============================================================================
class UserRegisterRequest(BaseModel):
    email: EmailStr
    username: str = Field(..., min_length=3, max_length=100, pattern=r"^[a-zA-Z0-9_\-]+$")
    password: str = Field(..., min_length=8, max_length=128)
    full_name: str | None = Field(None, max_length=255)

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if not any(c.isalpha() for c in v):
            raise ValueError("Le mot de passe doit contenir au moins une lettre.")
        if not any(c.isdigit() for c in v):
            raise ValueError("Le mot de passe doit contenir au moins un chiffre.")
        return v


# =============================================================================
# Auth : Connexion
# =============================================================================
class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str


# =============================================================================
# Auth : Réponse tokens JWT
# =============================================================================
class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int  # Durée de vie de l'access token en secondes


# =============================================================================
# Auth : Renouvellement du token
# =============================================================================
class RefreshTokenRequest(BaseModel):
    refresh_token: str


# =============================================================================
# User : Réponse publique (sans mot de passe)
# =============================================================================
class UserResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: uuid.UUID
    email: EmailStr
    username: str
    full_name: str | None
    role: str
    is_active: bool
    is_verified: bool
    created_at: datetime


# =============================================================================
# Auth : Payload du token JWT
# =============================================================================
class TokenPayload(BaseModel):
    sub: str          # user_id (UUID sous forme de string)
    exp: int          # Timestamp d'expiration
    type: str         # "access" ou "refresh"
    jti: str | None = None  # JWT ID unique (pour blacklist)

# =============================================================================
# Auth : Google Login
# =============================================================================
from typing import Optional

class GoogleLoginRequest(BaseModel):
    id_token: Optional[str] = None
    access_token: Optional[str] = None


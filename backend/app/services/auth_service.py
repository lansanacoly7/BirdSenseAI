"""
BirdSense AI — Service d'Authentification JWT + bcrypt
Auteur : Pape Alioune Sène

Gestion complète :
- Hachage bcrypt des mots de passe
- Génération et vérification des access tokens (15 min)
- Génération et vérification des refresh tokens (7 jours)
- Révocation des refresh tokens (stockage serveur avec hash SHA256)
"""
import hashlib
import uuid
from datetime import UTC, datetime, timedelta

from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import get_settings
from app.models.user import RefreshToken, User
from app.schemas.auth import TokenPayload, TokenResponse

settings = get_settings()

# Contexte bcrypt pour le hachage des mots de passe
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


# =============================================================================
# Utilitaires mots de passe
# =============================================================================

def hash_password(plain_password: str) -> str:
    """Hache un mot de passe avec bcrypt."""
    return pwd_context.hash(plain_password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifie un mot de passe contre son hash bcrypt."""
    return pwd_context.verify(plain_password, hashed_password)


# =============================================================================
# Utilitaires JWT
# =============================================================================

def _hash_token(token: str) -> str:
    """Retourne le hash SHA256 d'un token brut (stockage sécurisé)."""
    return hashlib.sha256(token.encode()).hexdigest()


def create_access_token(user_id: uuid.UUID) -> tuple[str, datetime]:
    """
    Crée un access token JWT (durée : ACCESS_TOKEN_EXPIRE_MINUTES).
    Retourne (token_string, expiry_datetime).
    """
    now = datetime.now(UTC)
    expiry = now + timedelta(minutes=settings.access_token_expire_minutes)
    payload = {
        "sub": str(user_id),
        "exp": int(expiry.timestamp()),
        "iat": int(now.timestamp()),
        "type": "access",
        "jti": str(uuid.uuid4()),
    }
    token = jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm)
    return token, expiry


def create_refresh_token(user_id: uuid.UUID) -> tuple[str, datetime]:
    """
    Crée un refresh token JWT (durée : REFRESH_TOKEN_EXPIRE_DAYS).
    Retourne (token_string, expiry_datetime).
    """
    now = datetime.now(UTC)
    expiry = now + timedelta(days=settings.refresh_token_expire_days)
    payload = {
        "sub": str(user_id),
        "exp": int(expiry.timestamp()),
        "iat": int(now.timestamp()),
        "type": "refresh",
        "jti": str(uuid.uuid4()),
    }
    token = jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm)
    return token, expiry


def decode_token(token: str) -> TokenPayload:
    """
    Décode et valide un token JWT.
    Lève JWTError si le token est invalide ou expiré.
    """
    payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
    return TokenPayload(**payload)


# =============================================================================
# Service de gestion des utilisateurs
# =============================================================================

async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
    """Récupère un utilisateur par son email."""
    result = await db.execute(select(User).where(User.email == email))
    return result.scalar_one_or_none()


async def get_user_by_id(db: AsyncSession, user_id: uuid.UUID) -> User | None:
    """Récupère un utilisateur par son UUID."""
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()


async def create_user(
    db: AsyncSession,
    email: str,
    username: str,
    plain_password: str,
    full_name: str | None = None,
) -> User:
    """Crée un nouvel utilisateur avec mot de passe haché."""
    user = User(
        email=email,
        username=username,
        hashed_password=hash_password(plain_password),
        full_name=full_name,
    )
    db.add(user)
    await db.flush()  # Obtenir l'ID sans commit définitif
    return user


async def authenticate_user(
    db: AsyncSession, email: str, plain_password: str
) -> User | None:
    """Authentifie un utilisateur. Retourne None si les credentials sont invalides."""
    user = await get_user_by_email(db, email)
    if not user:
        return None
    if not verify_password(plain_password, user.hashed_password):
        return None
    if not user.is_active:
        return None
    return user


# =============================================================================
# Service de gestion des Refresh Tokens
# =============================================================================

async def store_refresh_token(
    db: AsyncSession, user_id: uuid.UUID, raw_token: str, expires_at: datetime
) -> RefreshToken:
    """Stocke le hash SHA256 du refresh token en base."""
    rt = RefreshToken(
        user_id=user_id,
        token_hash=_hash_token(raw_token),
        expires_at=expires_at,
    )
    db.add(rt)
    await db.flush()
    return rt


async def validate_and_rotate_refresh_token(
    db: AsyncSession, raw_token: str
) -> tuple[User, str, str] | None:
    """
    Valide un refresh token, le révoque et génère une nouvelle paire de tokens.
    Stratégie de rotation : chaque refresh token ne peut être utilisé qu'une seule fois.
    Retourne (user, new_access_token, new_refresh_token) ou None si invalide.
    """
    # 1. Décoder le JWT
    try:
        payload = decode_token(raw_token)
    except JWTError:
        return None

    if payload.type != "refresh":
        return None

    user_id = uuid.UUID(payload.sub)
    token_hash = _hash_token(raw_token)

    # 2. Vérifier en base que le token existe, n'est pas révoqué et n'est pas expiré
    result = await db.execute(
        select(RefreshToken).where(
            RefreshToken.token_hash == token_hash,
            RefreshToken.revoked == False,  # noqa: E712
            RefreshToken.expires_at > datetime.now(UTC),
        )
    )
    stored_token = result.scalar_one_or_none()

    if not stored_token:
        return None

    # 3. Révoquer l'ancien token
    stored_token.revoked = True
    await db.flush()

    # 4. Récupérer l'utilisateur
    user = await get_user_by_id(db, user_id)
    if not user or not user.is_active:
        return None

    # 5. Générer et stocker une nouvelle paire de tokens
    new_access_token, _ = create_access_token(user.id)
    new_refresh_token, new_expiry = create_refresh_token(user.id)
    await store_refresh_token(db, user.id, new_refresh_token, new_expiry)

    return user, new_access_token, new_refresh_token


async def build_token_response(
    db: AsyncSession, user: User
) -> TokenResponse:
    """Génère et stocke une paire complète access+refresh tokens."""
    access_token, _ = create_access_token(user.id)
    refresh_token_raw, refresh_expiry = create_refresh_token(user.id)
    await store_refresh_token(db, user.id, refresh_token_raw, refresh_expiry)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token_raw,
        token_type="bearer",
        expires_in=settings.access_token_expire_minutes * 60,
    )


# =============================================================================
# Dependency FastAPI : Utilisateur courant authentifié
# =============================================================================

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.database import get_db

_bearer = HTTPBearer(auto_error=True)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer),
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Dependency FastAPI : valide le Bearer token et retourne l'utilisateur courant.
    Lève HTTP 401 si le token est absent, invalide ou expiré.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Token d'authentification invalide ou expiré.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_token(credentials.credentials)
    except JWTError:
        raise credentials_exception

    if payload.type != "access":
        raise credentials_exception

    user = await get_user_by_id(db, uuid.UUID(payload.sub))
    if not user or not user.is_active:
        raise credentials_exception

    return user

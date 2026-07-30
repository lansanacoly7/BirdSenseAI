"""
BirdSense AI — Routeur Authentification JWT
Auteur : Pape Alioune Sène
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.user import User
from app.schemas.auth import (
    RefreshTokenRequest,
    TokenResponse,
    UserLoginRequest,
    UserRegisterRequest,
    UserResponse,
)
from app.services.auth_service import (
    authenticate_user,
    build_token_response,
    create_user,
    get_current_user,
    get_user_by_email,
    validate_and_rotate_refresh_token,
)

router = APIRouter(prefix="/api/v1/auth", tags=["Authentification"])


@router.post(
    "/register",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Inscription d'un nouvel utilisateur",
)
async def register(
    user_in: UserRegisterRequest, db: AsyncSession = Depends(get_db)
) -> User:
    """
    Inscrit un nouvel utilisateur.
    Vérifie si l'email existe déjà.
    """
    existing_user = await get_user_by_email(db, user_in.email)
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Un utilisateur avec cet email existe déjà.",
        )

    # Note: Dans un environnement de production complet, on vérifierait
    # aussi l'unicité du username avec une requête séparée ou on gérerait
    # l'exception d'intégrité de la BDD.

    user = await create_user(
        db=db,
        email=user_in.email,
        username=user_in.username,
        plain_password=user_in.password,
        full_name=user_in.full_name,
    )
    return user


@router.post(
    "/login",
    response_model=TokenResponse,
    summary="Connexion et récupération des tokens JWT",
)
async def login(
    login_data: UserLoginRequest, db: AsyncSession = Depends(get_db)
) -> TokenResponse:
    """
    Authentifie l'utilisateur avec email/mot de passe.
    Retourne une paire Access Token (15m) + Refresh Token (7j).
    """
    user = await authenticate_user(db, login_data.email, login_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou mot de passe incorrect.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return await build_token_response(db, user)


@router.post(
    "/refresh",
    response_model=TokenResponse,
    summary="Renouvellement de l'Access Token",
)
async def refresh_token(
    refresh_req: RefreshTokenRequest, db: AsyncSession = Depends(get_db)
) -> TokenResponse:
    """
    Échange un Refresh Token valide contre une nouvelle paire de tokens.
    Applique la rotation de refresh tokens (le précédent est révoqué).
    """
    result = await validate_and_rotate_refresh_token(db, refresh_req.refresh_token)
    if not result:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token invalide, expiré ou révoqué. Veuillez vous reconnecter.",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user, new_access_token, new_refresh_token_raw = result
    
    # Note: validate_and_rotate_refresh_token a déjà stocké le nouveau token en base,
    # on reconstruit manuellement la réponse pour éviter de le restocker via build_token_response
    from app.config import get_settings
    settings = get_settings()
    
    return TokenResponse(
        access_token=new_access_token,
        refresh_token=new_refresh_token_raw,
        token_type="bearer",
        expires_in=settings.access_token_expire_minutes * 60,
    )


@router.get(
    "/me",
    response_model=UserResponse,
    summary="Informations de l'utilisateur courant",
)
async def get_me(current_user: User = Depends(get_current_user)) -> User:
    """
    Retourne les informations de l'utilisateur actuellement authentifié.
    Nécessite un Access Token valide.
    """
    return current_user

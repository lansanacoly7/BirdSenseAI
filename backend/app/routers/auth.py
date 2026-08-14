"""
BirdSense AI — Routeur Authentification JWT
Auteur : Pape Alioune Sène
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from google.oauth2 import id_token
from google.auth.transport import requests

from app.database import get_db
from app.models.user import User
from app.schemas.auth import (
    RefreshTokenRequest,
    TokenResponse,
    UserLoginRequest,
    UserRegisterRequest,
    UserResponse,
    GoogleLoginRequest,
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


@router.post(
    "/google",
    response_model=TokenResponse,
    summary="Connexion via Google Sign-In",
)
async def google_login(
    google_data: GoogleLoginRequest, db: AsyncSession = Depends(get_db)
) -> TokenResponse:
    """
    Vérifie le token Google ID, et connecte ou inscrit l'utilisateur.
    """
    from app.config import get_settings
    settings = get_settings()
    client_id = os.environ.get("GOOGLE_CLIENT_ID", "")
    
    try:
        # Si on n'a pas de client ID pour valider, on by-pass la validation strict en mode dev (hackathon)
        # Mais l'idéal est de valider avec client_id
        if google_data.id_token:
            if client_id:
                idinfo = id_token.verify_oauth2_token(google_data.id_token, requests.Request(), client_id)
            else:
                # En mode dev / hackathon si pas de client ID défini, on lit juste les claims (NON SÉCURISÉ EN PROD)
                import jwt as pyjwt
                idinfo = pyjwt.decode(google_data.id_token, options={"verify_signature": False})
                
            email = idinfo.get("email")
            name = idinfo.get("name", "Utilisateur Google")
            
        elif google_data.access_token:
            import httpx
            # Fallback for flutter web which sometimes only provides access_token
            async with httpx.AsyncClient() as client:
                resp = await client.get(
                    "https://www.googleapis.com/oauth2/v3/userinfo",
                    headers={"Authorization": f"Bearer {google_data.access_token}"}
                )
                if resp.status_code != 200:
                    raise ValueError(f"Access token invalide ou expiré: {resp.text}")
                user_info = resp.json()
                email = user_info.get("email")
                name = user_info.get("name", "Utilisateur Google")
        else:
            raise ValueError("Aucun token fourni.")
        
        if not email:
            raise HTTPException(status_code=400, detail="Token Google invalide : email manquant.")
            
        # Chercher l'utilisateur
        user = await get_user_by_email(db, email)
        if not user:
            # Inscription automatique
            # On génère un mot de passe aléatoire car il se connectera toujours via Google
            import secrets
            random_password = secrets.token_urlsafe(16)
            username = email.split('@')[0]
            
            # S'assurer que le nom d'utilisateur est unique, sinon on ajoute un suffixe
            existing = await db.scalars(text("SELECT id FROM users WHERE username = :u"), {"u": username})
            if existing.first():
                username = f"{username}_{secrets.token_hex(4)}"
                
            user = await create_user(
                db=db,
                email=email,
                username=username,
                plain_password=random_password,
                full_name=name,
            )
            
        return await build_token_response(db, user)
        
    except ValueError as e:
        # Invalid token
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Token Google invalide: {str(e)}",
        )

import os

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

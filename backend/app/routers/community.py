"""
BirdSense AI — Routeur Communauté
Auteur : Pape Alioune Sène

Endpoints T3.2 :
  GET    /api/v1/community/feed                           : Feed public paginé des observations
  GET    /api/v1/community/observations/{id}/comments     : Lire les commentaires
  POST   /api/v1/community/observations/{id}/comments     : Ajouter un commentaire
  DELETE /api/v1/community/comments/{id}                  : Supprimer son commentaire
  GET    /api/v1/community/observations/{id}/validations  : Lire les validations
  POST   /api/v1/community/observations/{id}/validations  : Soumettre une validation
  POST   /api/v1/community/observations/{id}/report       : Signaler une observation
  POST   /api/v1/community/observations/{id}/favorite     : Ajouter aux favoris
  DELETE /api/v1/community/observations/{id}/favorite     : Retirer des favoris
  GET    /api/v1/community/me/favorites                   : Mes favoris
"""
import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.community import Comment, Favorite, Report, Validation
from app.models.observation import Observation
from app.models.user import User
from app.schemas.community import (
    CommentIn,
    CommentOut,
    CommentsListResponse,
    CommunityFeedResponse,
    CommunityObservationItem,
    FavoriteOut,
    FavoritesListResponse,
    ReportIn,
    ReportOut,
    ValidationIn,
    ValidationOut,
    ValidationsListResponse,
    VALID_REPORT_REASONS,
)
from app.services.auth_service import get_current_user
from app.services.gps_blur import get_public_coords
from app.services.notification_service import notify_comment, notify_validation

router = APIRouter(prefix="/api/v1/community", tags=["Communauté"])


# =============================================================================
# Helpers internes
# =============================================================================

async def _get_observation_or_404(db: AsyncSession, observation_id: uuid.UUID) -> Observation:
    """Récupère une observation ou lève une 404."""
    result = await db.execute(select(Observation).where(Observation.id == observation_id))
    obs = result.scalar_one_or_none()
    if not obs:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Observation {observation_id} introuvable.",
        )
    return obs


def _public_coords(obs: Observation) -> tuple[float | None, float | None]:
    """
    Délègue au service gps_blur pour obtenir les coordonnées publiques correctes.
    - Espèces protégées sans location_public → (None, None) : masquage complet.
    - Espèces protégées avec location_public → coordonnées floutées.
    - Autres → coordonnées réelles.
    """
    return get_public_coords(
        location=obs.location,
        location_public=obs.location_public,
        has_protected_species=obs.has_protected_species,
    )


# =============================================================================
# Feed Communautaire Public
# =============================================================================

@router.get(
    "/feed",
    response_model=CommunityFeedResponse,
    summary="Feed public des observations communautaires (paginé)",
)
async def get_community_feed(
    page: int = Query(1, ge=1, description="Numéro de la page"),
    page_size: int = Query(20, ge=1, le=100, description="Nombre d'éléments par page"),
    db: AsyncSession = Depends(get_db),
) -> CommunityFeedResponse:
    """
    Retourne le feed public des observations, trié du plus récent au plus ancien.
    Les observations avec espèces protégées ont leurs coordonnées masquées.
    """
    offset = (page - 1) * page_size

    # Compter le total
    total_result = await db.execute(
        select(func.count(Observation.id)).where(Observation.sync_status == "synced")
    )
    total = total_result.scalar_one()

    # Récupérer les observations paginées
    obs_result = await db.execute(
        select(Observation)
        .where(Observation.sync_status == "synced")
        .order_by(Observation.observed_at.desc())
        .offset(offset)
        .limit(page_size)
    )
    observations = obs_result.scalars().all()

    items = []
    for obs in observations:
        lat, lon = _public_coords(obs)

        # Compter commentaires, validations, favoris de manière efficace
        comments_count_res = await db.execute(
            select(func.count(Comment.id)).where(Comment.observation_id == obs.id)
        )
        validations_count_res = await db.execute(
            select(func.count(Validation.id)).where(Validation.observation_id == obs.id)
        )
        favorites_count_res = await db.execute(
            select(func.count(Favorite.id)).where(Favorite.observation_id == obs.id)
        )

        items.append(
            CommunityObservationItem(
                id=obs.id,
                user_id=obs.user_id,
                observed_at=obs.observed_at,
                latitude=lat,
                longitude=lon,
                media_type=obs.media_type,
                thumbnail_url=obs.thumbnail_url,
                notes=obs.notes,
                comments_count=comments_count_res.scalar_one(),
                validations_count=validations_count_res.scalar_one(),
                favorites_count=favorites_count_res.scalar_one(),
                has_protected_species=obs.has_protected_species,
            )
        )

    return CommunityFeedResponse(
        total=total,
        page=page,
        page_size=page_size,
        items=items,
    )


# =============================================================================
# Commentaires
# =============================================================================

@router.get(
    "/observations/{observation_id}/comments",
    response_model=CommentsListResponse,
    summary="Lire les commentaires d'une observation",
)
async def list_comments(
    observation_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
) -> CommentsListResponse:
    """Retourne tous les commentaires d'une observation, triés du plus ancien au plus récent."""
    await _get_observation_or_404(db, observation_id)
    result = await db.execute(
        select(Comment)
        .where(Comment.observation_id == observation_id)
        .order_by(Comment.created_at.asc())
    )
    comments = result.scalars().all()
    return CommentsListResponse(total=len(comments), items=list(comments))


@router.post(
    "/observations/{observation_id}/comments",
    response_model=CommentOut,
    status_code=status.HTTP_201_CREATED,
    summary="Ajouter un commentaire sur une observation",
)
async def create_comment(
    observation_id: uuid.UUID,
    body: CommentIn,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> CommentOut:
    """Crée un commentaire sur une observation. Authentification requise."""
    obs = await _get_observation_or_404(db, observation_id)
    comment = Comment(
        observation_id=observation_id,
        user_id=current_user.id,
        content=body.content,
    )
    db.add(comment)
    await db.flush()

    # Notifier le propriétaire de l'observation (si ce n'est pas lui-même qui commente)
    if obs.user_id != current_user.id:
        await notify_comment(
            observation_owner_id=obs.user_id,
            commenter_username=current_user.username,
            observation_id=observation_id,
            comment_preview=body.content,
        )

    return CommentOut.model_validate(comment)


@router.delete(
    "/comments/{comment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Supprimer son propre commentaire",
)
async def delete_comment(
    comment_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    """Supprime un commentaire. Seul l'auteur peut le supprimer."""
    result = await db.execute(select(Comment).where(Comment.id == comment_id))
    comment = result.scalar_one_or_none()
    if not comment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Commentaire introuvable.")
    if comment.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Vous ne pouvez supprimer que vos propres commentaires.",
        )
    await db.delete(comment)


# =============================================================================
# Validations Communautaires
# =============================================================================

@router.get(
    "/observations/{observation_id}/validations",
    response_model=ValidationsListResponse,
    summary="Lire les validations d'une observation",
)
async def list_validations(
    observation_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
) -> ValidationsListResponse:
    """Retourne toutes les validations (confirmations / contestations) d'une observation."""
    await _get_observation_or_404(db, observation_id)
    result = await db.execute(
        select(Validation)
        .where(Validation.observation_id == observation_id)
        .order_by(Validation.created_at.asc())
    )
    validations = result.scalars().all()
    confirmations = sum(1 for v in validations if v.is_confirmation)
    contestations = len(validations) - confirmations
    return ValidationsListResponse(
        total=len(validations),
        confirmations=confirmations,
        contestations=contestations,
        items=list(validations),
    )


@router.post(
    "/observations/{observation_id}/validations",
    response_model=ValidationOut,
    status_code=status.HTTP_201_CREATED,
    summary="Soumettre une validation communautaire",
)
async def create_validation(
    observation_id: uuid.UUID,
    body: ValidationIn,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ValidationOut:
    """
    Permet à un utilisateur de valider (confirmer ou contester) l'identification IA.
    Un utilisateur ne peut valider qu'une seule fois par observation.
    """
    await _get_observation_or_404(db, observation_id)

    # Vérifier si l'utilisateur a déjà voté
    existing_result = await db.execute(
        select(Validation).where(
            Validation.observation_id == observation_id,
            Validation.user_id == current_user.id,
        )
    )
    if existing_result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Vous avez déjà soumis une validation pour cette observation.",
        )

    # Si contestation, une espèce proposée est recommandée (pas bloquant pour le MVP)
    obs = await _get_observation_or_404(db, observation_id)
    validation = Validation(
        observation_id=observation_id,
        user_id=current_user.id,
        is_confirmation=body.is_confirmation,
        proposed_species_id=body.proposed_species_id,
        comment=body.comment,
    )
    db.add(validation)
    await db.flush()

    # Notifier le propriétaire de l'observation
    if obs.user_id != current_user.id:
        await notify_validation(
            observation_owner_id=obs.user_id,
            validator_username=current_user.username,
            observation_id=observation_id,
            is_confirmation=body.is_confirmation,
        )

    return ValidationOut.model_validate(validation)


# =============================================================================
# Signalements (Reports)
# =============================================================================

@router.post(
    "/observations/{observation_id}/report",
    response_model=ReportOut,
    status_code=status.HTTP_201_CREATED,
    summary="Signaler une observation",
)
async def report_observation(
    observation_id: uuid.UUID,
    body: ReportIn,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> ReportOut:
    """
    Signale une observation comme abusive, incorrecte, ou spam.
    Un utilisateur ne peut signaler qu'une seule fois par observation.
    """
    await _get_observation_or_404(db, observation_id)

    # Valider la raison
    if body.reason not in VALID_REPORT_REASONS:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=f"Raison invalide. Valeurs acceptées : {', '.join(VALID_REPORT_REASONS)}",
        )

    # Vérifier si l'utilisateur a déjà signalé
    existing_result = await db.execute(
        select(Report).where(
            Report.observation_id == observation_id,
            Report.user_id == current_user.id,
        )
    )
    if existing_result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Vous avez déjà signalé cette observation.",
        )

    report = Report(
        observation_id=observation_id,
        user_id=current_user.id,
        reason=body.reason,
        details=body.details,
        status="pending",
    )
    db.add(report)
    await db.flush()
    return ReportOut.model_validate(report)


# =============================================================================
# Favoris
# =============================================================================

@router.post(
    "/observations/{observation_id}/favorite",
    response_model=FavoriteOut,
    status_code=status.HTTP_201_CREATED,
    summary="Ajouter une observation aux favoris",
)
async def add_favorite(
    observation_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> FavoriteOut:
    """Ajoute une observation à la liste des favoris de l'utilisateur courant."""
    await _get_observation_or_404(db, observation_id)

    # Vérifier si déjà en favoris
    existing_result = await db.execute(
        select(Favorite).where(
            Favorite.observation_id == observation_id,
            Favorite.user_id == current_user.id,
        )
    )
    if existing_result.scalar_one_or_none():
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Cette observation est déjà dans vos favoris.",
        )

    favorite = Favorite(observation_id=observation_id, user_id=current_user.id)
    db.add(favorite)
    await db.flush()
    return FavoriteOut.model_validate(favorite)


@router.delete(
    "/observations/{observation_id}/favorite",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Retirer une observation des favoris",
)
async def remove_favorite(
    observation_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> None:
    """Retire une observation de la liste des favoris de l'utilisateur courant."""
    result = await db.execute(
        select(Favorite).where(
            Favorite.observation_id == observation_id,
            Favorite.user_id == current_user.id,
        )
    )
    favorite = result.scalar_one_or_none()
    if not favorite:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Cette observation n'est pas dans vos favoris.",
        )
    await db.delete(favorite)


@router.get(
    "/me/favorites",
    response_model=FavoritesListResponse,
    summary="Mes observations favorites",
)
async def my_favorites(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
) -> FavoritesListResponse:
    """Retourne la liste des observations mises en favoris par l'utilisateur connecté."""
    result = await db.execute(
        select(Favorite)
        .where(Favorite.user_id == current_user.id)
        .order_by(Favorite.created_at.desc())
    )
    favorites = result.scalars().all()
    return FavoritesListResponse(total=len(favorites), items=list(favorites))

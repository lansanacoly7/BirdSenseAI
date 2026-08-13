"""
BirdSense AI — Service de Gamification
Auteur : Pape Alioune Sène
"""
from typing import List, Tuple
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from app.models.user import User
from app.models.community import UserBadge
from app.models.observation import Observation, ObservationItem

# Grille de points
POINTS_OBSERVATION_VALIDATED = 10
POINTS_FIRST_SPECIES = 50

# Seuils de niveaux
LEVELS = [
    (0, "Novice"),
    (100, "Observateur"),
    (500, "Amateur"),
    (1500, "Expert"),
]

# Badges (simplifiés pour l'exemple)
BADGES = ["Observateur", "Amateur", "Expert", "Photographe", "Veilleur"]

async def update_user_points(db: AsyncSession, user_id: str, points_to_add: int):
    """
    Met à jour les points de l'utilisateur et vérifie s'il passe au niveau supérieur
    et débloque les badges correspondants.
    """
    user = await db.get(User, user_id)
    if not user:
        return
        
    user.points += points_to_add
    
    # Détermination du niveau actuel en fonction des points
    new_level = "Novice"
    for threshold, level_name in LEVELS:
        if user.points >= threshold:
            new_level = level_name
            
    if new_level != user.level:
        user.level = new_level
        
    # Vérification des badges
    await check_and_award_badges(db, user)
    
    db.add(user)
    await db.commit()
    
async def check_and_award_badges(db: AsyncSession, user: User):
    """
    Vérifie et attribue les badges (sans doublon).
    """
    # Badges de niveau
    level_badges = ["Observateur", "Amateur", "Expert"]
    
    # Obtenir les badges existants de l'utilisateur
    stmt = select(UserBadge.badge_name).where(UserBadge.user_id == user.id)
    result = await db.execute(stmt)
    existing_badges = set(result.scalars().all())
    
    for lvl in level_badges:
        if user.level == lvl or (user.level == "Expert" and lvl in ["Observateur", "Amateur"]):
            if lvl not in existing_badges:
                new_badge = UserBadge(user_id=user.id, badge_name=lvl)
                db.add(new_badge)
                existing_badges.add(lvl)

async def award_validation_points(db: AsyncSession, observation_id: str):
    """
    Attribue les points pour une observation validée.
    Déclenchée lorsqu'une observation est validée.
    """
    obs = await db.get(Observation, observation_id)
    if not obs:
        return
        
    # Points pour l'observation validée
    await update_user_points(db, obs.user_id, POINTS_OBSERVATION_VALIDATED)
    
    # Vérifier s'il s'agit d'une "première espèce" pour l'utilisateur
    # On récupère toutes les espèces de cette observation
    stmt = select(ObservationItem.species_id).where(ObservationItem.observation_id == obs.id)
    result = await db.execute(stmt)
    species_ids = result.scalars().all()
    
    for sp_id in species_ids:
        if not sp_id:
            continue
            
        # Vérifier combien de fois l'utilisateur a vu cette espèce
        # count(items) join observations where user_id = obs.user_id and species_id = sp_id
        count_stmt = select(func.count()).select_from(ObservationItem).join(Observation).where(
            Observation.user_id == obs.user_id,
            ObservationItem.species_id == sp_id
        )
        count_result = await db.execute(count_stmt)
        times_seen = count_result.scalar()
        
        # Si c'est la seule fois (l'actuelle), c'est une première
        if times_seen == 1:
            await update_user_points(db, obs.user_id, POINTS_FIRST_SPECIES)

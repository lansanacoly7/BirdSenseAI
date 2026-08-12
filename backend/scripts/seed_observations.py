"""backend/scripts/seed_observations.py

Générateur / Seeder de données massives pour BirdSense AI.

Génère des observations réalistes au Sénégal et les insère dans la base SQLite via SQLAlchemy ORM.
Associe toutes les observations à un utilisateur unique "Avancé" pour tester l'isolation.

Usage :
    python -m scripts.seed_observations --count 500
"""

import argparse
import logging
import os
import random
from datetime import datetime, timedelta

from dotenv import load_dotenv
from passlib.context import CryptContext
from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session

from app.database import Base
from app.models.observation import Observation, ObservationItem
from app.models.species import Species
from app.models.user import User

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Espèces communes au Sénégal
SENEGAL_SPECIES = [
    ("Passer domesticus", "Moineau domestique", False),
    ("Corvus albus", "Corbeau pie", False),
    ("Bubulcus ibis", "Héron garde-bœufs", False),
    ("Ardea cinerea", "Héron cendré", False),
    ("Egretta garzetta", "Aigrette garzette", False),
    ("Falco tinnunculus", "Faucon crécerelle", True),
    ("Streptopelia decaocto", "Tourterelle turque", False),
    ("Merops pusillus", "Petit guêpier", False),
    ("Halcyon senegalensis", "Martin-chasseur du Sénégal", False),
    ("Nectarinia senegalensis", "Souimanga du Sénégal", False),
]

REGIONS = {
    "dakar": (14.6, 14.8, -17.5, -17.0),
    "sénégal_complet": (12.3, 16.7, -17.5, -11.5),
}

def seed_database(count: int, region: str, db_url: str):
    engine = create_engine(db_url, echo=False)
    
    with Session(engine) as session:
        # 1. Créer ou récupérer l'utilisateur avancé
        expert_email = "expert@bird.com"
        user = session.scalars(select(User).where(User.email == expert_email)).first()
        if not user:
            logger.info("Création de l'utilisateur avancé (expert@bird.com / Oiseau123)")
            user = User(
                email=expert_email,
                username="expert_birder",
                hashed_password=pwd_context.hash("Oiseau123"),
                full_name="Expert Ornithologue",
                role="admin",
                is_active=True,
                is_verified=True
            )
            session.add(user)
            session.commit()
            session.refresh(user)
        
        # 2. Créer ou récupérer les espèces
        species_map = {}
        for scientific_name, common_name, is_protected in SENEGAL_SPECIES:
            sp = session.scalars(select(Species).where(Species.scientific_name == scientific_name)).first()
            if not sp:
                sp = Species(
                    scientific_name=scientific_name,
                    common_name_fr=common_name,
                    is_protected=is_protected
                )
                session.add(sp)
                session.flush()
            species_map[scientific_name] = sp
        
        session.commit()

        # 3. Générer les observations
        lat_min, lat_max, lon_min, lon_max = REGIONS[region]
        end_date = datetime.now()
        start_date = end_date - timedelta(days=2 * 365)

        logger.info(f"Génération de {count} observations pour l'utilisateur {user.username}...")
        
        inserted = 0
        for _ in range(count):
            lat = random.uniform(lat_min, lat_max)
            lon = random.uniform(lon_min, lon_max)
            obs_date = start_date + timedelta(seconds=random.randint(0, int((end_date - start_date).total_seconds())))
            
            # WKT format pour stocker dans String SQLite local
            location_wkt = f"POINT({lon} {lat})"
            
            # Choisir de 1 à 3 espèces observées dans cette photo
            num_species = random.randint(1, 3)
            chosen_species_list = random.sample(SENEGAL_SPECIES, num_species)
            
            has_protected = any(sp[2] for sp in chosen_species_list)
            
            obs = Observation(
                user_id=user.id,
                observed_at=obs_date,
                location=location_wkt,
                location_public=location_wkt,  # Simplifié pour SQLite
                altitude_m=random.uniform(0, 50),
                location_accuracy_m=random.uniform(2, 20),
                media_type="photo",
                has_protected_species=has_protected,
                sync_status="synced"
            )
            
            for sci_name, com_name, is_prot in chosen_species_list:
                sp_obj = species_map[sci_name]
                item = ObservationItem(
                    observation=obs,
                    species_id=sp_obj.id,
                    species_raw_name=sp_obj.scientific_name,
                    count=random.randint(1, 5),
                    confidence_score=random.uniform(0.70, 0.99),
                )
                session.add(item)
            
            session.add(obs)
            inserted += 1
            
            if inserted % 100 == 0:
                session.commit()
                logger.info(f"{inserted} observations insérées...")

        session.commit()
        logger.info(f"✅ {inserted} observations insérées avec succès pour {expert_email} !")

def main():
    load_dotenv()
    parser = argparse.ArgumentParser()
    parser.add_argument("--count", type=int, default=500)
    parser.add_argument("--region", type=str, default="sénégal_complet")
    
    # Correction pour SQLite synchrone (enlever +aiosqlite)
    db_url = os.environ.get("DATABASE_URL", "sqlite:///./birdsense.db")
    if "aiosqlite" in db_url:
        db_url = db_url.replace("+aiosqlite", "")
        
    args = parser.parse_args()
    seed_database(args.count, args.region, db_url)

if __name__ == "__main__":
    main()

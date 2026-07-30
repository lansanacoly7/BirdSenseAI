"""backend/scripts/seed_observations.py

Générateur / Seeder de données massives pour BirdSense AI (T5.4).

Génère des observations réalistes au Sénégal et les insère dans la base PostGIS.

Usage :
    python -m backend.scripts.seed_observations --count 500
    python -m backend.scripts.seed_observations --count 100 --region dakar --seed 42

Options :
    --count     Nombre d'observations à générer (défaut: 500)
    --region    Région géographique : dakar, thiès, saint-louis, ziguinchor (défaut: sénégal_complet)
    --seed      Graine aléatoire pour reproductibilité (défaut: None)
    --db-url    URL de connexion PostgreSQL (défaut: variable d'env DATABASE_URL)

MOCK — Schéma de Pape Alioune Sène :
    Ce script suppose l'existence de tables `species` et `observations` dans la base PostGIS.
    Si ces tables n'existent pas, les instructions CREATE TABLE ci-dessous créent un mock
    minimal clairement documenté. À remplacer par le vrai schéma de Pape dès livraison.

Critères :
    - Idempotent : relançable sans dupliquer (ON CONFLICT DO NOTHING sur seed_hash)
    - Paramétrable : count, region, seed
    - Log clair du nombre de lignes insérées
"""

import argparse
import hashlib
import logging
import os
import random
from datetime import datetime, timedelta
from typing import List, Dict, Tuple

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# ── Configuration du logging ──────────────────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)

# ── Données de référence ──────────────────────────────────────────────────

# Espèces communes au Sénégal (liste simplifiée pour le MVP)
SENEGAL_SPECIES = [
    ("Passer domesticus", "Moineau domestique"),
    ("Corvus albus", "Corbeau pie"),
    ("Bubulcus ibis", "Héron garde-bœufs"),
    ("Ardea cinerea", "Héron cendré"),
    ("Egretta garzetta", "Aigrette garzette"),
    ("Falco tinnunculus", "Faucon crécerelle"),
    ("Streptopelia decaocto", "Tourterelle turque"),
    ("Merops pusillus", "Petit guêpier"),
    ("Halcyon senegalensis", "Martin-chasseur du Sénégal"),
    ("Nectarinia senegalensis", "Souimanga du Sénégal"),
    ("Lamprotornis caudatus", "Choucador à longue queue"),
    ("Ploceus cucullatus", "Tisserin gendarme"),
    ("Euplectes orix", "Euplecte ignicolore"),
    ("Vidua macroura", "Veuve dominicaine"),
    ("Francolinus bicalcaratus", "Francolin à double éperon"),
]

# Bounding boxes par région [lat_min, lat_max, lon_min, lon_max]
REGIONS: Dict[str, Tuple[float, float, float, float]] = {
    "dakar": (14.6, 14.8, -17.5, -17.0),
    "thiès": (14.5, 15.0, -16.9, -16.2),
    "saint-louis": (15.5, 16.5, -16.5, -15.5),
    "ziguinchor": (12.3, 13.0, -16.5, -15.5),
    "sénégal_complet": (12.3, 16.7, -17.5, -11.5),
}


def _generate_seed_hash(lat: float, lon: float, species_name: str, date: str) -> str:
    """Génère un hash unique pour chaque observation (pour l'idempotence)."""
    raw = f"{lat:.6f}_{lon:.6f}_{species_name}_{date}"
    return hashlib.md5(raw.encode()).hexdigest()


def generate_observations(
    count: int,
    region_bbox: Tuple[float, float, float, float],
    rng: random.Random,
) -> List[Dict]:
    """Génère `count` observations réalistes dans la bounding box donnée."""
    lat_min, lat_max, lon_min, lon_max = region_bbox
    end_date = datetime.now()
    start_date = end_date - timedelta(days=5 * 365)

    observations = []
    for _ in range(count):
        species_name, common_name = rng.choice(SENEGAL_SPECIES)
        lat = rng.uniform(lat_min, lat_max)
        lon = rng.uniform(lon_min, lon_max)
        obs_date = start_date + timedelta(
            seconds=rng.randint(0, int((end_date - start_date).total_seconds()))
        )
        confidence = round(rng.uniform(0.55, 0.99), 2)

        observations.append({
            "species_name": species_name,
            "common_name": common_name,
            "latitude": round(lat, 6),
            "longitude": round(lon, 6),
            "observed_at": obs_date.isoformat(),
            "confidence_score": confidence,
            "seed_hash": _generate_seed_hash(lat, lon, species_name, obs_date.date().isoformat()),
        })

    return observations


def ensure_mock_tables(engine) -> None:
    """
    Crée les tables mock si elles n'existent pas encore.

    MOCK — Ces tables sont une substitution minimale au schéma réel de Pape.
    À supprimer dès que le schéma réel est livré (T3.1).
    """
    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS species (
                id SERIAL PRIMARY KEY,
                scientific_name VARCHAR(255) UNIQUE NOT NULL,
                common_name VARCHAR(255)
            );
        """))
        conn.execute(text("""
            CREATE TABLE IF NOT EXISTS observations (
                id SERIAL PRIMARY KEY,
                species_id INTEGER REFERENCES species(id),
                latitude DOUBLE PRECISION NOT NULL,
                longitude DOUBLE PRECISION NOT NULL,
                observed_at TIMESTAMP NOT NULL,
                confidence_score FLOAT,
                seed_hash VARCHAR(64) UNIQUE  -- Pour l'idempotence
            );
        """))
        conn.commit()
    logger.info("Tables (mock) vérifiées / créées.")


def seed_database(observations: List[Dict], engine) -> int:
    """
    Insère les observations dans la base de données.
    Retourne le nombre de lignes réellement insérées (en excluant les doublons).
    """
    inserted = 0
    with engine.connect() as conn:
        for obs in observations:
            # Upsert de l'espèce
            result = conn.execute(text("""
                INSERT INTO species (scientific_name, common_name)
                VALUES (:scientific_name, :common_name)
                ON CONFLICT (scientific_name) DO NOTHING
                RETURNING id;
            """), {"scientific_name": obs["species_name"], "common_name": obs["common_name"]})
            row = result.fetchone()

            if row is None:
                row = conn.execute(text(
                    "SELECT id FROM species WHERE scientific_name = :name"
                ), {"name": obs["species_name"]}).fetchone()

            species_id = row[0]

            # Insertion de l'observation (idempotente via seed_hash UNIQUE)
            result = conn.execute(text("""
                INSERT INTO observations (species_id, latitude, longitude, observed_at, confidence_score, seed_hash)
                VALUES (:species_id, :latitude, :longitude, :observed_at, :confidence_score, :seed_hash)
                ON CONFLICT (seed_hash) DO NOTHING;
            """), {
                "species_id": species_id,
                "latitude": obs["latitude"],
                "longitude": obs["longitude"],
                "observed_at": obs["observed_at"],
                "confidence_score": obs["confidence_score"],
                "seed_hash": obs["seed_hash"],
            })
            inserted += result.rowcount

        conn.commit()

    return inserted


def main():
    load_dotenv()

    parser = argparse.ArgumentParser(description="Seeder d'observations BirdSense AI")
    parser.add_argument("--count", type=int, default=500, help="Nombre d'observations à générer")
    parser.add_argument(
        "--region",
        type=str,
        default="sénégal_complet",
        choices=list(REGIONS.keys()),
        help="Région géographique",
    )
    parser.add_argument("--seed", type=int, default=None, help="Graine aléatoire")
    parser.add_argument(
        "--db-url",
        type=str,
        default=os.environ.get("DATABASE_URL"),
        help="URL de connexion PostgreSQL",
    )
    args = parser.parse_args()

    if not args.db_url:
        logger.error("DATABASE_URL non défini. Utiliser --db-url ou définir la variable d'environnement.")
        raise SystemExit(1)

    rng = random.Random(args.seed)
    region_bbox = REGIONS[args.region]

    logger.info(f"Génération de {args.count} observations — région: {args.region} — seed: {args.seed}")
    observations = generate_observations(args.count, region_bbox, rng)

    engine = create_engine(args.db_url, echo=False)

    logger.info("Vérification / création des tables mock...")
    ensure_mock_tables(engine)

    logger.info("Insertion en base...")
    inserted = seed_database(observations, engine)

    logger.info(f"✅ {inserted}/{args.count} observations insérées (doublons exclus).")


if __name__ == "__main__":
    main()

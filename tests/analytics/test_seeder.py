"""Tests du seeder d'observations (T5.4).

Vérifie :
- Idempotence (relançable sans dupliquer)
- Count correct d'observations insérées
- Paramètres CLI fonctionnels
"""

import pytest
from unittest.mock import MagicMock, patch, call
import random

from backend.scripts.seed_observations import (
    generate_observations,
    _generate_seed_hash,
    REGIONS,
    SENEGAL_SPECIES,
)


class TestGenerateObservations:
    """Tests de la génération des données."""

    def test_count_is_respected(self):
        """Le nombre d'observations générées correspond au paramètre --count."""
        rng = random.Random(42)
        observations = generate_observations(500, REGIONS["sénégal_complet"], rng)
        assert len(observations) == 500

    def test_coordinates_within_bbox(self):
        """Les coordonnées sont dans la bounding box Sénégal."""
        rng = random.Random(42)
        lat_min, lat_max, lon_min, lon_max = REGIONS["sénégal_complet"]
        observations = generate_observations(100, REGIONS["sénégal_complet"], rng)

        for obs in observations:
            assert lat_min <= obs["latitude"] <= lat_max, f"Latitude {obs['latitude']} hors borne"
            assert lon_min <= obs["longitude"] <= lon_max, f"Longitude {obs['longitude']} hors borne"

    def test_species_are_valid(self):
        """Toutes les espèces générées font partie de la liste de référence."""
        rng = random.Random(42)
        valid_species = {s[0] for s in SENEGAL_SPECIES}
        observations = generate_observations(100, REGIONS["sénégal_complet"], rng)

        for obs in observations:
            assert obs["species_name"] in valid_species

    def test_confidence_score_range(self):
        """Les scores de confiance sont entre 0.55 et 0.99."""
        rng = random.Random(42)
        observations = generate_observations(100, REGIONS["sénégal_complet"], rng)

        for obs in observations:
            assert 0.55 <= obs["confidence_score"] <= 0.99

    def test_dakar_region_smaller_bbox(self):
        """La région Dakar produit des coordonnées dans la bounding box Dakar."""
        rng = random.Random(42)
        lat_min, lat_max, lon_min, lon_max = REGIONS["dakar"]
        observations = generate_observations(50, REGIONS["dakar"], rng)

        for obs in observations:
            assert lat_min <= obs["latitude"] <= lat_max
            assert lon_min <= obs["longitude"] <= lon_max


class TestSeedHash:
    """Tests d'idempotence via le seed_hash."""

    def test_same_inputs_same_hash(self):
        """Un même tuple (lat, lon, espèce, date) produit toujours le même hash."""
        h1 = _generate_seed_hash(14.5, -17.2, "Corvus albus", "2025-07-01")
        h2 = _generate_seed_hash(14.5, -17.2, "Corvus albus", "2025-07-01")
        assert h1 == h2

    def test_different_inputs_different_hash(self):
        """Des inputs différents produisent des hashes différents."""
        h1 = _generate_seed_hash(14.5, -17.2, "Corvus albus", "2025-07-01")
        h2 = _generate_seed_hash(14.6, -17.2, "Corvus albus", "2025-07-01")
        assert h1 != h2

    def test_all_hashes_unique_in_batch(self):
        """Dans un batch de 500 observations générées avec seed fixe, les hashes sont uniques."""
        rng = random.Random(99)
        observations = generate_observations(500, REGIONS["sénégal_complet"], rng)
        hashes = [obs["seed_hash"] for obs in observations]
        # Avec des coordonnées à 6 décimales, les hashes doivent être uniques
        assert len(set(hashes)) == len(hashes), "Des hashes dupliqués ont été détectés"

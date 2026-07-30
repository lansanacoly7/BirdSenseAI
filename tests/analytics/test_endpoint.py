"""Tests d'intégration pour l'endpoint GET /api/v1/analytics/stats (T5.3)."""

import math
import pytest
from fastapi.testclient import TestClient
from fastapi import FastAPI

from backend.app.analytics.router import router
from backend.app.analytics.services import compute_shannon_wiener_index

# ── Création d'une app FastAPI minimale pour les tests ──────────────────────
app = FastAPI()
app.include_router(router)
client = TestClient(app)


class TestAnalyticsEndpoint:
    """Tests de l'endpoint /analytics/stats."""

    def test_endpoint_returns_200(self):
        """L'endpoint répond avec un code 200."""
        response = client.get("/api/v1/analytics/stats")
        assert response.status_code == 200

    def test_response_schema(self):
        """La réponse respecte le schéma Pydantic attendu."""
        response = client.get("/api/v1/analytics/stats")
        data = response.json()

        assert "bird_health_score" in data
        assert "species_diversity" in data
        assert "temporal_volume" in data

        assert isinstance(data["bird_health_score"], float)
        assert isinstance(data["species_diversity"], list)
        assert isinstance(data["temporal_volume"], list)

        # Vérification de la structure des items
        if data["species_diversity"]:
            item = data["species_diversity"][0]
            assert "species_name" in item
            assert "count" in item

        if data["temporal_volume"]:
            item = data["temporal_volume"][0]
            assert "date" in item
            assert "count" in item

    def test_bird_health_score_range(self):
        """Le Bird Health Score doit être positif (H' ≥ 0)."""
        response = client.get("/api/v1/analytics/stats")
        data = response.json()
        assert data["bird_health_score"] >= 0.0


class TestShannonWiener:
    """Tests unitaires de la formule Shannon-Wiener (vérification manuelle)."""

    def test_shannon_known_value(self):
        """
        Vérification sur un cas connu calculé à la main.
        Avec 2 espèces en proportions égales (50/50) :
        H' = -(0.5 * ln(0.5) + 0.5 * ln(0.5)) = ln(2) ≈ 0.6931
        """
        counts = {"espece_A": 50, "espece_B": 50}
        h = compute_shannon_wiener_index(counts)
        assert h == pytest.approx(math.log(2), rel=1e-4)

    def test_shannon_single_species(self):
        """
        Une seule espèce → H' = 0 (diversité nulle).
        """
        counts = {"Passer domesticus": 100}
        h = compute_shannon_wiener_index(counts)
        assert h == pytest.approx(0.0)

    def test_shannon_empty(self):
        """
        Pas d'observations → H' = 0.
        """
        h = compute_shannon_wiener_index({})
        assert h == 0.0

    def test_shannon_multiple_species(self):
        """
        H' augmente avec la diversité — 5 espèces équiréparties > 2 espèces équiréparties.
        """
        two_species = {"A": 50, "B": 50}
        five_species = {"A": 20, "B": 20, "C": 20, "D": 20, "E": 20}
        h2 = compute_shannon_wiener_index(two_species)
        h5 = compute_shannon_wiener_index(five_species)
        assert h5 > h2

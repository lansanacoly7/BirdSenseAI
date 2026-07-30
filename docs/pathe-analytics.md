# Module Analytics — Documentation Technique
# BirdSense AI — Pathé Fall (Membre 5)

## Périmètre

Ce module couvre les tâches T5.1 à T5.4 du sprint hackathon (7 jours). Il est strictement limité aux dossiers autorisés.

---

## T5.1 — Fusion Bayésienne Spatio-Temporelle

**Fichier :** `backend/app/analytics/fusion.py`

**Formule :** `Score Final = Score Visuel × Prior Régional`

| Paramètre | Type | Description |
|-----------|------|-------------|
| `visual_score` | float [0,1] | Score de confiance YOLO/ByteTrack |
| `regional_prior` | float [0,1] ou None | Probabilité a priori eBird/GBIF |

**Comportement de repli :** Si `regional_prior=None` (absence de données), le prior par défaut est **0.5** (neutre). Ceci est documenté dans `test_fusion.py::test_bayesian_fusion_missing_prior`.

```python
from backend.app.analytics.fusion import bayesian_fusion

# Espèce commune : prior élevé
score = bayesian_fusion(0.8, 0.9)   # → 0.72

# Espèce rare : prior faible
score = bayesian_fusion(0.9, 0.1)   # → 0.09

# Absence de données eBird : prior de repli 0.5
score = bayesian_fusion(0.8, None)  # → 0.40
```

---

## T5.2 — Connecteurs API Tierces

**Dossier :** `backend/app/analytics/connectors/`

### eBird
```python
from backend.app.analytics.connectors import EBirdConnector

ebird = EBirdConnector(api_key="VOTRE_CLE")
status = await ebird.fetch_species_status("SN", "strdec")
```

### GBIF
```python
from backend.app.analytics.connectors import GBIFConnector

gbif = GBIFConnector()
occurrences = await gbif.fetch_occurrences("Passer domesticus", "SN", limit=50)
```

### BirdNET
```python
from backend.app.analytics.connectors import BirdNETConnector

birdnet = BirdNETConnector(api_key="VOTRE_CLE")
predictions = await birdnet.fetch_audio_features("chant.wav")
```

**Gestion des erreurs :**  
- Timeout → retry exponentiel (max 3 tentatives)  
- HTTP 429 (rate limiting) → retry exponentiel  
- Exception levée après `max_retries` épuisés

---

## T5.3 — Module Analytics Backend

**Endpoint :** `GET /api/v1/analytics/stats`

**Schéma de réponse (Pydantic) :**

```json
{
  "bird_health_score": 1.4791,
  "species_diversity": [
    {"species_name": "Passer domesticus", "count": 45}
  ],
  "temporal_volume": [
    {"date": "2025-07-01", "count": 10}
  ]
}
```

**Bird Health Score** : Indice de Shannon-Wiener H' = −∑(pᵢ × ln(pᵢ))

**MOCK actif :** Le router retourne des données statiques mockées tant que le schéma PostGIS de Pape n'est pas livré. Voir `router.py` ligne commentée `# MOCK`.

### Module Mobile

| Fichier | Rôle |
|---------|------|
| `analytics_repository.dart` | Appel HTTP et parsing JSON |
| `analytics_state.dart` | ChangeNotifier (loading/loaded/error) |
| `analytics_chart_data.dart` | Conversion vers BarChartData / PieChartData / LineChartData |

---

## T5.4 — Seeder de Données

**Fichier :** `backend/scripts/seed_observations.py`

```bash
# Génération de 500 observations au Sénégal
python -m backend.scripts.seed_observations --count 500

# 100 observations à Dakar, reproducible
python -m backend.scripts.seed_observations --count 100 --region dakar --seed 42
```

**Idempotence :** Chaque observation a un `seed_hash` (MD5 de lat+lon+espèce+date). `ON CONFLICT (seed_hash) DO NOTHING` garantit l'idempotence.

---

## Lancer les tests

```bash
# Tests backend (Python)
pytest tests/analytics/ -v

# Tests Flutter
cd birdsense_mobile
flutter test test/features/analytics/
```

---

## Mocks et dépendances externes

| Dépendance | Statut | Action requise |
|-----------|--------|----------------|
| Schéma PostGIS (Pape) | 🟡 MOCK | Remplacer les CREATE TABLE dans `seed_observations.py` et la requête SQL dans `router.py` |
| Format sortie YOLO (Ibrahima) | ✅ Consommé | `visual_score` est un float 0-1 attendu du pipeline d'inférence |
| Clé API eBird | 🟡 À configurer | Variable d'env `EBIRD_API_KEY` |
| Clé API BirdNET | 🟡 À configurer | Variable d'env `BIRDNET_API_KEY` |

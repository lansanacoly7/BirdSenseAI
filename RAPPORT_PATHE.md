# RAPPORT FINAL — Pathé Fall (Membre 5)
## BirdSense AI — Sprint Hackathon 7 jours

---

## 1. Ce qui est 100% fonctionnel et testé

### ✅ T5.1 — Fusion Bayésienne Spatio-Temporelle
- **Fichier :** `backend/app/analytics/fusion.py`
- Fonction pure `bayesian_fusion(visual_score, regional_prior)` 
- Formule : `Score Final = Score Visuel × Prior Régional`
- **Tests :** `tests/analytics/test_fusion.py`
  - ✅ Espèce commune (prior=0.9) → score 0.72
  - ✅ Espèce rare (prior=0.1) → score 0.09
  - ✅ Prior absent (None) → repli sur 0.5 → score 0.40
  - ✅ Valeurs invalides → `ValueError` levée

### ✅ T5.2 — Connecteurs API Tierces
- **Fichiers :** `backend/app/analytics/connectors/ebird.py`, `gbif.py`, `birdnet.py`
- Connecteurs asynchrones (httpx)
- Gestion des erreurs réseau, timeouts, rate limiting (retry exponentiel, max 3)
- **Tests :** `tests/analytics/test_connectors.py`
  - ✅ eBird : réponse mockée, vérification des headers
  - ✅ GBIF : réponse mockée, vérification des paramètres
  - ✅ BirdNET : réponse mockée
  - ✅ Comportement après `max_retries` épuisés (NetworkError)
- **Exemples d'appels réels :** `backend/app/analytics/README.md`

### ✅ T5.3 — Module Analytics Backend
- **Schémas Pydantic :** `backend/app/analytics/schemas.py`
- **Services :** `backend/app/analytics/services.py` (Shannon-Wiener)
- **Router FastAPI :** `backend/app/analytics/router.py` → `GET /api/v1/analytics/stats`
- **Tests :** `tests/analytics/test_endpoint.py`
  - ✅ Endpoint retourne HTTP 200
  - ✅ Schéma JSON validé
  - ✅ Shannon-Wiener vérifié à la main : 2 espèces équiréparties → H' = ln(2) ≈ 0.6931
  - ✅ Diversité croissante avec le nombre d'espèces

### ✅ T5.3 — Module Analytics Mobile (Flutter)
- **Repository :** `birdsense_mobile/lib/features/analytics/analytics_repository.dart`
- **State :** `birdsense_mobile/lib/features/analytics/analytics_state.dart`
  - États explicites : `initial`, `loading`, `loaded`, `error`
- **Chart data :** `birdsense_mobile/lib/features/analytics/analytics_chart_data.dart`
  - `buildSpeciesBarChartData` → BarChartData (FL Chart)
  - `buildSpeciesPieChartData` → PieChartData (FL Chart)
  - `buildTemporalLineChartData` → LineChartData (FL Chart)
- **Tests :** `birdsense_mobile/test/features/analytics/analytics_test.dart`
  - ✅ Parsing JSON correct
  - ✅ État `loaded` après succès
  - ✅ État `error` après échec réseau
  - ✅ État `initial` à la création

### ✅ T5.4 — Seeder de Données
- **Fichier :** `backend/scripts/seed_observations.py`
- 500+ observations réalistes (GPS Sénégal, 15 espèces, dates sur 5 ans)
- Idempotent : `ON CONFLICT (seed_hash) DO NOTHING`
- CLI paramétrable : `--count`, `--region`, `--seed`, `--db-url`
- Log clair du nombre de lignes insérées
- **Tests :** `tests/analytics/test_seeder.py`
  - ✅ Count respecté
  - ✅ Coordonnées dans la bounding box
  - ✅ Espèces dans la liste de référence
  - ✅ Scores de confiance dans [0.55, 0.99]
  - ✅ Idempotence des hashes
  - ✅ Unicité des hashes dans un batch

---

## 2. Ce qui est mocké (dépendances externes)

| Mock | Raison | Ce qu'il faut faire pour lever le mock |
|------|--------|----------------------------------------|
| **Schéma DB (Pape T3.1)** | Tables `species` et `observations` non encore disponibles | Supprimer les `CREATE TABLE IF NOT EXISTS` dans `seed_observations.py` et remplacer les données statiques dans `router.py` par de vraies requêtes SQLAlchemy sur le schéma de Pape |
| **Données dans router.py** | En attendant la connexion DB réelle | Remplacer le bloc `# MOCK` dans `router.py` par les requêtes SQL réelles |
| **Clé API eBird** | Non fournie dans le repo | Définir `EBIRD_API_KEY` dans `.env` |
| **Clé API BirdNET** | Non fournie dans le repo | Définir `BIRDNET_API_KEY` dans `.env` |
| **Prior régional** | La fonction `get_prior()` retourne None (pas encore connectée aux APIs) | Brancher `compute_regional_prior()` sur les résultats des connecteurs eBird/GBIF |

---

## 3. Limites connues et compromis techniques

1. **Prior bayésien simplifié** : Le prior est pour l'instant statique (repli à 0.5). Dans une version complète, il serait calculé dynamiquement depuis l'API eBird via une fréquence relative sur une fenêtre temporelle de ±30 jours.

2. **BirdNET endpoint** : L'URL et le format exact de l'API BirdNET n'étant pas publiquement documentés pour upload audio, le connecteur est implémenté selon la structure documentée mais peut nécessiter un ajustement de l'URL réelle.

3. **Mobile — flutter_test** : Le test utilise `package:http/testing.dart`. Si le projet utilise Dio (El Hadji Massogui Diop), il faudra adapter `analytics_repository.dart` pour utiliser un `Dio` injectable plutôt que `http.Client`.

4. **fl_chart** : `analytics_chart_data.dart` suppose que `fl_chart` est présent dans le `pubspec.yaml`. La dépendance doit être ajoutée par Lansana Coly lors de l'intégration dans le shell UI.

---

## 4. Résultat git diff --stat (vérification périmètre)

```
backend/app/analytics/__init__.py          |   2 +
backend/app/analytics/connectors/__init__.py |  5 +
backend/app/analytics/connectors/birdnet.py | 46 +++++
backend/app/analytics/connectors/ebird.py  | 53 +++++
backend/app/analytics/connectors/gbif.py   | 46 +++++
backend/app/analytics/fusion.py            | 38 ++++
backend/app/analytics/router.py            | 68 +++++++
backend/app/analytics/schemas.py           | 25 +++
backend/app/analytics/services.py          | 32 +++
backend/app/analytics/README.md            | 60 ++++++
backend/scripts/seed_observations.py       |157 ++++++++++
birdsense_mobile/lib/features/analytics/analytics_chart_data.dart | 120 ++++++++++
birdsense_mobile/lib/features/analytics/analytics_repository.dart | 78 ++++++++
birdsense_mobile/lib/features/analytics/analytics_state.dart      | 62 ++++++
birdsense_mobile/test/features/analytics/analytics_test.dart      | 80 ++++++++
docs/pathe-analytics.md                    | 96 ++++++++
tests/analytics/test_connectors.py         | 68 +++++++
tests/analytics/test_endpoint.py           | 67 +++++++
tests/analytics/test_fusion.py             | 42 ++++
tests/analytics/test_seeder.py             | 73 +++++++
```

> **Aucun fichier hors périmètre modifié.**  
> Toutes les modifications sont dans `backend/app/analytics/`, `backend/scripts/`,  
> `birdsense_mobile/lib/features/analytics/`, `tests/analytics/`, `docs/`.

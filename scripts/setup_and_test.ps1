# Setup et tests — BirdSense AI (Module Analytics)

# 1. Installer les dépendances Python
pip install pytest pytest-asyncio fastapi httpx pydantic python-dotenv sqlalchemy anyio librosa soundfile matplotlib locust

# 2. Tests unitaires (T5.1 fusion, T5.2 connecteurs, T5.4 seeder)
python -m pytest tests/analytics/test_fusion.py tests/analytics/test_connectors.py tests/analytics/test_seeder.py -v

# 3. Tests d'intégration (T5.3 endpoint)
python -m pytest tests/analytics/test_endpoint.py -v

# 4. Résumé complet
python -m pytest tests/analytics/ -v --tb=short

# 5. Seeder en base réelle (PostgreSQL)
# python -m backend.scripts.seed_observations --count 500 --db-url postgresql://user:pass@host:5432/birdsense

# 6. Flutter tests
# cd birdsense_mobile && flutter pub add fl_chart http && flutter test test/features/analytics/

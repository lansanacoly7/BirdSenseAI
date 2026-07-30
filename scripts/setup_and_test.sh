#!/usr/bin/env bash
# scripts/setup_and_test.sh
# Installe les dépendances et lance tous les tests du module analytics.
# Usage : bash scripts/setup_and_test.sh

set -e

echo "=== Installation des dépendances Python ==="
pip install pytest pytest-asyncio fastapi httpx pydantic python-dotenv sqlalchemy anyio

echo ""
echo "=== Lancement des tests unitaires (T5.1, T5.2, T5.4) ==="
python -m pytest tests/analytics/test_fusion.py tests/analytics/test_connectors.py tests/analytics/test_seeder.py -v

echo ""
echo "=== Lancement des tests d'intégration (T5.3 Backend) ==="
python -m pytest tests/analytics/test_endpoint.py -v

echo ""
echo "=== Résumé complet ==="
python -m pytest tests/analytics/ -v --tb=short

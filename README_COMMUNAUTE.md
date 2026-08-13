# Implémentation des Fonctionnalités Communautaires - BirdSense AI

Ce document résume les choix techniques effectués pour l'implémentation des tâches T5.1 à T5.4.

## T5.1 — Moteur de Recherche Avancé (`GET /observations/search`)
- **PostGIS** : L'utilisation de `func.ST_DWithin` permet des requêtes géospatiales très performantes au niveau de la base de données. On a utilisé le SRID 4326 standard pour les coordonnées GPS.
- **Popularité** : Le tri par popularité est géré dynamiquement dans la requête via des sous-requêtes (`favorites * 2 + comments`). Cela évite de recalculer un score à chaque interaction.
- **Floutage GPS** : Si une espèce est protégée (`has_protected_species = True`), l'API renvoie de façon transparente `location_public` (les coordonnées floutées) au lieu de `location`.

## T5.2 — RAG Assistant Communautaire
- **Détection d'intention** : Une simple analyse sémantique (mots-clés type "communauté", "rares", "autour de moi") déclenche le contexte communautaire pour optimiser les appels DB (se fait via `chat.py`).
- **Contexte RAG** : Lorsqu'activé, l'application interroge les 5 dernières observations locales pertinentes via SQLAlchemy et injecte un bloc de contexte spécifique dans le Prompt Système (LLM). L'IA génère ensuite une réponse fondée sur de vraies données communautaires, réduisant les hallucinations.

## T5.3 — Gamification & Profils
- **Grille de points** :
  - `Observation validée` : +10 pts
  - `Première espèce (collection)` : +50 pts (vérifié via un GROUP BY ou un `count()` sur les `ObservationItem` historiques).
- **Seuils et Niveaux** : Novice (0), Observateur (100), Amateur (500), Expert (1500).
- **Badges** : Gérés dans une table `UserBadge`. Lors d'un passage de niveau, on vérifie dynamiquement si le badge existe avant de l'attribuer pour éviter les doublons (`gamification.py`). L'endpoint `/users/{id}/profile` (dans `profiles.py`) agrège les points, le niveau, les badges et la collection unique d'espèces.

## T5.4 — Modération Automatique
- **Seuils** : Fixés à **5 signalements** (Reports) dans une fenêtre de **24 heures**.
- **Mécanisme** : Lors d'un nouveau signalement (`moderation.py`), un service vérifie la volumétrie. Si le seuil est dépassé, le champ `is_hidden` de l'observation passe à `True`. Elle n'est plus renvoyée dans la recherche (T5.1).
- **Administration** : Un endpoint `GET /admin/moderation/pending` permet aux administrateurs de consulter rapidement tous les éléments masqués.

## Remarque sur l'exécution (Base de Données et Tests)
- Les scripts Alembic de migration n'ont pas été exécutés directement car la connexion à la base (PostGIS / clés d'API) n'était pas active en local (Erreur `(ENOTFOUND) tenant/user postgres.VOTRE_PROJECT_REF not found`).
- Les tests unitaires (dans `tests/backend/test_community.py`) sont stubs, car nécessitant une DB ou un mock complet qui dépend fortement de votre outil de test (`pytest-asyncio` avec db en mémoire).

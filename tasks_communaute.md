# Répartition des Tâches : Fonctionnalité Communauté 🌍

Voici le plan de bataille pour implémenter la fonctionnalité "Communauté / Science participative" en répartissant le travail intelligemment entre les 5 membres de l'équipe, selon leurs spécialités.

---

### 1️⃣ Lansana Coly (Lead Mobile UI & Cartographie)
*Mission : Construire toute l'expérience visuelle et l'interface utilisateur de la communauté.*
* **T1.1 - UI Feed & Détails :** Développer la page principale "Communauté" (cartes riches avec badges IA, actions) et l'écran détaillé de l'observation.
* **T1.2 - Carte Communautaire :** Implémenter la vue cartographique avec gestion des clusters (regroupement de points) et filtres visuels.
* **T1.3 - Profil & Collection :** Créer la page de profil public et la section "Ma collection personnelle" (grille d'espèces débloquées).
* **T1.4 - Modales & Interactions :** Créer les interfaces de "Validation communautaire" (je propose une autre espèce) et les modales de filtres de recherche.

### 2️⃣ El Hadji Massogui Diop (Dev Mobile Hardware & SQLite)
*Mission : Gérer le cache local, les données mobiles et les fonctionnalités natives.*
* **T2.1 - Cache Drift :** Créer les tables SQLite locales pour mettre en cache le Feed communautaire, les favoris et la collection personnelle (fonctionnement hors-ligne partiel).
* **T2.2 - Partage Natif :** Implémenter la fonctionnalité "Partager" en générant une belle carte de synthèse native exportable vers d'autres apps (WhatsApp, etc.).
* **T2.3 - Gestion des Médias :** Optimiser le chargement et la mise en cache des images du réseau dans les listes défilantes de la communauté.
* **T2.4 - Synchronisation :** Gérer l'envoi en arrière-plan (WorkManager) des validations communautaires et des signalements.

### 3️⃣ Pape Alioune Sène (Dev Backend Core & Infra)
*Mission : Câbler l'infrastructure serveur, les bases de données et la sécurité.*
* **T3.1 - Architecture BDD :** Créer les migrations (Alembic) pour les nouvelles tables : `Comment`, `Validation`, `Report`, `Favorite` et mettre à jour `Observation`.
* **T3.2 - API Endpoints :** Développer les endpoints FastAPI complets (CRUD public/privé, ajout aux favoris, système de commentaires et signalements).
* **T3.3 - Floutage GPS & Permissions :** Implémenter la logique de protection des espèces sensibles : renvoyer une localisation approximative (ex: "Zone de Dakar") au lieu du GPS précis sur le Feed public.
* **T3.4 - Notifications :** Mettre en place un système de webhooks ou sockets pour alerter l'utilisateur de la validation de ses observations.

### 4️⃣ Ibrahima Khalilou Diallo (Ingénieur Computer Vision & YOLO)
*Mission : Relier la puissance des modèles IA à l'interaction humaine communautaire.*
* **T4.1 - Explicabilité IA :** Développer l'algorithme qui génère le contenu de la section *"Pourquoi cette identification ?"* en extrayant les traits caractéristiques vus par le modèle (bounding boxes et scores).
* **T4.2 - Arbitrage IA vs Humain :** Coder un système qui compare la confiance de l'IA avec la validation communautaire, afin de flagger automatiquement les "anomalies".
* **T4.3 - Validation Experte Automatisée :** Si la communauté conteste une observation, lancer un job asynchrone qui repasse l'image dans un modèle plus lourd pour un "second avis".

### 5️⃣ Pathé Fall (Dev Fullstack Data & Analytics)
*Mission : Intelligence des données, gamification et intégration IA.*
* **T5.1 - Moteur de Recherche Avancé :** Développer les filtres complexes du backend (par proximité géospatiale PostGIS, espèces rares, date, popularité).
* **T5.2 - RAG Assistant Communautaire :** Connecter la base de données communautaire à l'Assistant IA pour qu'il réponde aux questions ("Quelles espèces rares autour de moi ?", "Que fait la communauté ?") sans briser le mode généraliste.
* **T5.3 - Gamification & Profils :** Créer l'algorithme de calcul des niveaux, attribution des badges (observateur, amateur, expert) et le déblocage des collections.
* **T5.4 - Modération Auto :** Script d'analyse des signalements (Report) pour masquer automatiquement le spam.

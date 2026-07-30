# Répartition 100% Technique & Évaluation des Niveaux de Difficulté — BirdSense AI

## 📌 Orientations & Analyse de Complexité
Chaque membre de l'équipe possède un périmètre 100% technique. Afin d'aider l'équipe à anticiper les verrous technologiques et à gérer son temps durant le Sprint de 7 jours, ce document détaille la répartition nominative et le **Niveau de Difficulté (sur 10)** du travail principal (MVP) et des extensions/bonus pour chaque rôle.

---

## 👥 Matrice Récapitulative Nominative (5 Développeurs)

| Membre & Rôle | Difficulté MVP | Difficulté Extensions | Compétences & Périmètre Technique |
| :--- | :---: | :---: | :--- |
| **Lansana Coly (Membre 1)**<br>*Lead Mobile UI & Cartographie* | **6.5 / 10** *(Moyen)* | **8.5 / 10** *(Élevé)* | Design System Material 3 Dark, Navigation Flutter, Mapbox SDK (Clusters/Heatmaps), UI Fiches Espèces & Graphiques FL Chart. |
| **El Hadji Massogui Diop (Membre 2)**<br>*Dev Mobile Hardware, Camera & SQLite* | **8.0 / 10** *(Élevé)* | **9.0 / 10** *(Très Élevé)* | Stream Caméra 30 FPS, Overlays Canvas, Base locale SQLite Drift, Client Dio HTTP & Moteur de Sync Offline. |
| **Pape Alioune Sène (Membre 3)**<br>*Dev Backend Core & Infrastructure* | **7.0 / 10** *(Moyen+)* | **8.5 / 10** *(Élevé)* | Architecture FastAPI Async, PostgreSQL 16 + PostGIS (Supabase), Auth JWT, Routers REST CRUD & Floutage GPS Espèces Protégées. |
| **Ibrahima Khalilou Diallo (Membre 4)**<br>*Ingénieur Computer Vision & YOLO* | **8.5 / 10** *(Élevé)* | **9.5 / 10** *(Expert)* | Fine-Tuning YOLOv8/11 sur Roboflow, Tracking Vidéo ByteTrack (IDs uniques d'oiseaux) & Inférence Pipeline PyTorch/ONNX. |
| **Pathé Fall (Membre 5)**<br>*Dev Fullstack Data, Algorithmes & Analytics* | **7.5 / 10** *(Moyen+)* | **8.5 / 10** *(Élevé)* | Moteur de Fusion Bayésienne Spatio-Temporelle, Ingestion APIs tierces (eBird/GBIF/BirdNET), Endpoints Analytics + Intégration FL Chart (Mobile) & Seeding BDD (500+ points). |

---

## 🔗 Graphe de Dépendances Techniques

```
[Pape Alioune Sène: BDD PostGIS & Auth] ──► [Pape Alioune Sène: API Rest Backend] ──┐
                                                                                     ├──► [El Hadji Massogui Diop: Mobile Sync & Storage]
[Ibrahima Khalilou Diallo: YOLO & Track] ─► [Ibrahima K. Diallo: Inférence Vidéo] ──┤
                                                                                     │
[Pathé Fall: APIs eBird & Prior Bayes] ──► [Pathé Fall: Analytics & Stats] ─────────┘
                                                                                     
[Lansana Coly: Design System & Mapbox] ──► [Lansana Coly: Interface Utilisateur & Navigation]
```

---

## 🔬 Feuille de Route & Analyse par Développeur

---

### 1️⃣ Lansana Coly — Lead Mobile UI & Cartographie

#### 🎯 Périmètre Technique
Interface utilisateur Flutter, charte graphique Material 3 Dark Mode, intégration cartographique géospatiale Mapbox SDK, navigation et vues catalogues/statistiques.

#### 🚀 Tâches de Développement MVP (Difficulté : 6.5/10)
- [ ] **T1.1 — Design System & Theme Dark Material 3 :**
  - Setup des thèmes, typographies (Inter/SF Pro) et composants UI réutilisables (Vert Canopée `#1E3A2B`, Terre Cuite `#E07A5F`, Ambré `#F4A261`).
- [ ] **T1.2 — Structure de Navigation & Vues Principales :**
  - Navigation BottomNavigationBar (4 onglets), Écrans Auth, Historique des détections, Fiche Espèce détaillée avec lecteur audio du chant.
- [ ] **T1.3 — Moteur Cartographique Mapbox SDK :**
  - Implémenter `mapbox_maps_flutter`, gestion des marqueurs d'observation, clustering dynamique et calques de cartes de chaleur (Heatmaps).
- [ ] **T1.4 — Dashboard UI & Visualisations :**
  - Vue Statistiques intégrant les graphiques `FL Chart` (histogrammes et camemberts de répartition des espèces).

#### 🌟 Bonus / Extensions (Difficulté : 8.5/10)
- Téléchargement hors-ligne des tuiles cartographiques vectorielles (`.mbtiles`).
- Animations Lottie/Rive lors des détections validées.

---

### 2️⃣ El Hadji Massogui Diop — Dev Mobile Hardware, Camera & SQLite

#### 🎯 Périmètre Technique
Flux matériel caméra, dessin CustomPainter des Bounding Boxes à 30 FPS, persistence SQLite déconnectée et moteur de synchronisation HTTP.

#### 🚀 Tâches de Développement MVP (Difficulté : 8.0/10)
- [ ] **T2.1 — Flux Caméra & Drawing Overlays :**
  - Traitement du plugin `camera` (30 FPS), conversion des coordonnées de détection et rendu dynamique via `CustomPainter` sans ralentir l'UI.
- [ ] **T2.2 — ORM Drift (SQLite Local Database) :**
  - Codage des schémas Drift (`LocalObservations`, `LocalObservationItems`), opérations CRUD locales hors-ligne.
- [ ] **T2.3 — Client Réseau Dio & Engine de Synchro :**
  - Intercepteurs Dio JWT, sérialisation/désérialisation DTOs, moteur d'envoi par lot (batch sync) déclenché au retour du réseau ou via action utilisateur.

#### 🌟 Bonus / Extensions (Difficulté : 9.0/10)
- Synchronisation automatique d'arrière-plan via `WorkManager`.
- Chiffrement de la base SQLite locale avec `SQLCipher`.

---

### 3️⃣ Pape Alioune Sène — Dev Backend Core & Infrastructure (FastAPI & PostGIS)

#### 🎯 Périmètre Technique
Architecture serveur FastAPI, schéma relationnel géospatial PostgreSQL/PostGIS, authentification JWT, endpoints CRUD et sécurité.

#### 🚀 Tâches de Développement MVP (Difficulté : 7.0/10)
- [ ] **T3.1 — Base Spatiale PostgreSQL 16 / PostGIS (Supabase) :**
  - Écriture et déploiement du DDL SQL (`users`, `species`, `observations`, `observation_items`) avec index spatiaux GiST.
- [ ] **T3.2 — Core API FastAPI & Routers REST :**
  - Setup FastAPI (Python 3.12 async), Pydantic v2 schemas, SQLAlchemy 2.0 ORM, authentification JWT avec refresh tokens.
- [ ] **T3.3 — Endpoints REST /observations & Security :**
  - Route `POST /api/v1/observations/sync` (batch ingestion) et `GET /api/v1/observations/map` (filtrage Bounding Box).
  - Algorithme de floutage GPS (5 km) pour la protection automatique des espèces menacées (IUCN EN/CR).

#### 🌟 Bonus / Extensions (Difficulté : 8.5/10)
- Déploiement de Celery + Redis pour le traitement vidéo asynchrone lourd.

---

### 4️⃣ Ibrahima Khalilou Diallo — Ingénieur Computer Vision & YOLO

#### 🎯 Périmètre Technique
Pipeline de vision par ordinateur : entraînement du détective visuel, suivi vidéo temporel (ByteTrack) et optimisation du modèle.

#### 🚀 Tâches de Développement MVP (Difficulté : 8.5/10)
- [ ] **T4.1 — Dataset & Fine-Tuning YOLOv8n/v11n :**
  - Préparation et augmentation des données sur Roboflow, entraînement de YOLOv8n/v11n sur la classe oiseaux et espèces cibles.
- [ ] **T4.2 — Pipeline Suivi Vidéo Multi-Objets (ByteTrack) :**
  - Implémentation de ByteTrack en Python pour attribuer un `track_id` unique par trajectoire d'oiseau (élimination du sur-comptage vidéo).
- [ ] **T4.3 — Service d'Inférence IA FastAPI :**
  - Module Python d'inférence pour analyser les images reçues et renvoyer les coordonnées normalisées et scores de confiance.

#### 🌟 Bonus / Extensions (Difficulté : 9.5/10)
- Inférence locale C++ ONNX via bindings `dart:ffi` ou modèle BioCLIP-2.

---

### 5️⃣ Pathé Fall — Dev Fullstack Data, Algorithmes & Analytics

#### 🎯 Périmètre Technique
Algorithmes d'IA spatio-temporelle (Fusion Bayésienne), intégration de services d'API tiers (eBird/GBIF/BirdNET), module de statistiques/Analytics mobile & backend, scripts de données.

#### 🚀 Tâches de Développement MVP (Difficulté : 7.5/10)
- [ ] **T5.1 — Algorithme de Fusion Bayésienne Spatio-Temporelle :**
  - Développement de la matrice Python des probabilités de présence régionale eBird/GBIF ($\text{Score Final} = \text{Score Visuel} \times \text{Prior Régional}$).
- [ ] **T5.2 — Integrateur d'APIs Tierces (eBird / GBIF / Audio BirdNET) :**
  - Développement des connecteurs Python asynchrones pour consommer l'API eBird (extraire les chants sonores et statuts d'espèces) et GBIF.
- [ ] **T5.3 — Module Mobile & Backend Analytics (Dashboard & FL Chart) :**
  - **Côté Backend :** Endpoint `GET /api/v1/analytics/stats` (calcul de la diversité des espèces, volume temporel, indice écologie *Bird Health Score* - formule Shannon-Wiener).
  - **Côté Mobile :** Intégration des graphiques `FL Chart` (Bar Chart, Pie Chart) sur l'onglet Dashboard Flutter.
- [ ] **T5.4 — Generator & Seeder de Données Massives :**
  - Écriture d'un script Python de génération et seeding automatique de 500+ observations réalistes dans PostGIS pour alimenter la carte et les stats dès le lancement du projet.

#### 🌟 Bonus / Extensions (Difficulté : 8.5/10)
- Ingestion et traitement de signal audio (spectrogrammes BirdNET) et tests de charge avec Locust.

---

## 📅 Planning Chronologique sur 7 Jours (Sprint Hackathon)

```
Jour 1 - 2 : FONDATIONS & SCHÉMAS
├── Pape Alioune Sène: Setup BDD PostGIS (Supabase) + API Auth JWT
├── Ibrahima Khalilou Diallo: Fine-Tuning YOLO sur Roboflow
├── Pathé Fall: Matrice de Prior Bayésien + Connecteur API eBird
├── Lansana Coly: Design System Material 3 + Squelette Navigation Flutter
└── El Hadji Massogui Diop: Schemas Drift SQLite + Stream Caméra 30FPS

Jour 3 - 4 : INTÉGRATION CORE & ANALYTICS
├── Pape Alioune Sène: Endpoints REST /observations/sync et /map
├── Ibrahima Khalilou Diallo: Pipeline ByteTrack (Tracking Vidéo avec IDs uniques)
├── Pathé Fall: Endpoint Backend /analytics/stats + Integration FL Chart sur Flutter
├── Lansana Coly: Rendu Carte Mapbox avec Clusters et Heatmaps
└── El Hadji Massogui Diop: Dessin Overlays Bounding Box CustomPainter + Client Dio Sync

Jour 5 : INNOVATIONS & PEUPLEMENT DATA
├── Pathé Fall: Script de Seeding BDD (500 points géolocalisés de démo)
├── Pathé Fall & Ibrahima K. Diallo: Couplage Fusion Bayésienne + Inférence YOLO
├── Pape Alioune Sène & Lansana Coly: Floutage GPS Espèces Menacées + Fiche Espèce Audio
└── El Hadji Massogui Diop: Validation du pipeline complet de Synchro Offline (Mode Avion)

Jour 6 - 7 : FINALISATION CODE & GEL DES LIVRABLES
├── TOUS: Corrections de bugs croisés, optimisation des performances et refactoring.
└── TOUS: Dépôt GitHub propre, documentation technique validée et prêt pour livraison !
```

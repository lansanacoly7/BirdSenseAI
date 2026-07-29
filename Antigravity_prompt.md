
Conversation avec Gemini
Dans le cadre de l'Hackathon BirdSense AI nous avons effectué des recherches chacun de notre coté et on a pu trouver des resultats maintenant ce que je veux c'est que tu examine et analyse chaque travail afin de me faire un rapport ultra complet qui ressortira les convergences et divergences mais aussi ce qui est le plus pertinent pour un hackathon en pasant par le stack la methode de travail les outils etc.. 

RAPPORT D'ANALYSE ET STRATÉGIE TECHNIQUE — HACKATHON BIRDSENSE AI
Synthèse Exécutive
Dans le cadre du hackathon BirdSense AI, les quatre membres de l'équipe (Alioune, Massogui / Zoopodj, Lansana et Pathé) ont mené des recherches complémentaires couvrant l'ensemble du spectre du projet.  
MD

Chaque contribution apporte une valeur unique :

Lansana apporte la vision produit, l'alignement sur la grille d'évaluation du jury et la stratégie de démonstration.  
MD

Pathé formalise l'architecture système, le suivi temporel vidéo (ByteTrack) et le traitement asynchrone.

Massogui fournit une analyse académique avancée, poussant les limites de l'état de l'art en IA, en optimisation embarquée et en calcul spatial.

Alioune apporte le pragmatisme opérationnel, les raccourcis de développement pour un hackathon (benchmarks, Roboflow, APIs ouvertes).

Ce rapport synthétise vos travaux, fait ressortir les convergences et divergences, et définit la stratégie optimale à adopter pour l'équipe de 4 personnes.

1. Analyse Détaillée des Contributions Individuelles
💡 Alioune : Le Pragmatisme et les Benchmark Open-Source
Alioune adopte une démarche orientée "Hackathon / Prototypage Rapide" :

Benchmarks analysés : Étude de référence sur Merlin Bird ID (intégration date/géolocalisation) et BirdNET (classification acoustique par spectrogrammes via EfficientNetB0).

Vision IA : Recommande de ne pas réinventer la roue. Utilisation de YOLOv8n / YOLO11n pré-entraînés sur COCO avec un fine-tuning léger sur Roboflow.

Classification : Transfer learning sur MobileNetV3 ou EfficientNet-Lite restreint à un sous-ensemble régional (ex. Afrique de l'Ouest).

Intégration d'APIs : Exploitation directe des APIs publiques d'eBird et d'iNaturalist pour enrichir le contexte et les données.

📐 Pathé Fall : L'Architecture Système et le Tracking Vidéo
Pathé pose les bases de l'ingénierie logicielle et du pipeline de traitement :

Découpage applicatif : Structuration claire du parcours utilisateur et des responsabilités (Mobile vs Backend vs Moteur IA).

Résolution du doublon vidéo : Utilisation combinée de YOLO (détection) et ByteTrack (suivi d'identifiants uniques inter-frames) pour éviter le sur-comptage dans les flux vidéo.

Gestion des tâches lourdes : Mise en place d'une architecture asynchrone appuyée sur Celery et Redis pour ne pas bloquer le serveur lors de l'analyse vidéo.

Modélisation relationnelle : Conception du schéma de base de données PostgreSQL pour lier utilisateurs, observations, médias et détections.

🔬 Massogui (Zoopodj) : L'Excellence Technique et l'État de l'Art
Massogui propose une architecture technique très poussée :

Innovations IA majeures :

YOLOv12-S / YOLO26-N (Area Attention et STAL sans NMS) pour la détection en milieu dense.

BioCLIP-2 couplé à une Fusion Bayésienne Spatio-Temporelle.

Inférence hybride Edge/Cloud avec quantification INT8 via ONNX Runtime Mobile et bindings C++ (dart:ffi).

Stack d'Entreprise : FastAPI (Python 3.12 async), PostgreSQL 16 + PostGIS (Supabase), Mapbox SDK, Next.js 14 pour le Dashboard administrateur.

Rigueur de conception : Application de la Clean Architecture, du mode Offline-First avec SQLite/Drift et chiffrement SQLCipher.

🎯 Lansana Coly : La Stratégie Produit et l'Alignement sur le Jury
Lansana concentre son analyse sur la façon de remporter la compétition :  
MD

Décryptage de la notation : Décomposition des 100 points (Fonctionnement 20, IA 20, Comptage 20, UX/UI 10, Innovation 10, Présentation 10, Impact 10).  
MD

Règle d'or : Privilégier une application parfaitement stable à un projet trop ambitieux rempli de bugs.  
MD

Design System & UX : Définition de l'identité visuelle (Thème canopée/nature) et du parcours utilisateur en 9 étapes.  
MD

Plan de démonstration : Répétition d'un pitch de 5 à 7 minutes scénarisé avec plan de secours (fallback).  
MD

2. Matrice de Convergence et de Divergence
📊 Tableau Comparatif des Propositions
Dimension	Alioune	Pathé	Massogui	
Lansana  
MD

Mobile	Flutter + TFLite	Flutter (Riverpod/Dio)	Flutter 3.x (Clean Arch/ONNX)	
Flutter  
MD

Backend	FastAPI ou API Cloud	Django REST Framework	FastAPI (Python 3.12 async)	
Django REST Framework  
MD

Base de Données	Firebase / Supabase	PostgreSQL	PostgreSQL 16 + PostGIS	
PostgreSQL  
MD

IA Détection	YOLOv8n / YOLO11n	YOLO	YOLOv12-S / YOLO26-N	
YOLOv11  
MD

Suivi Vidéo	Bounding boxes COCO	YOLO + ByteTrack	YOLO + ByteTrack (MOT)	
Comptage simultané  
MD

IA Classification	MobileNetV3 / EfficientNet	Modèle spécialisé	BioCLIP-2 + Priors Bayésiens	
EfficientNet / MobileNetV3  
MD

Cartographie	Leaflet / Mapbox	Flutter Map	Mapbox Mobile SDK	
Google Maps / Mapbox  
MD

Dashboard	Intégré dans l'App	Django Admin	Next.js 14+ (App Router)	
Tableau de bord intégré  
MD

✅ Convergences Majeures
Framework Mobile : Consensus absolu sur Flutter (rapidité, multiplateforme, fluidité graphique).  
MD

Famille de Détection : Choix unanime de la gamme YOLO pour la détection visuelle.  
MD

Périmètre Métier : Le parcours fondamental réunit la détection, le comptage multi-instances, l'identification de l'espèce, la géolocalisation et les statistiques.  
MD

Base de Données : Accord sur une base relationnelle solide (PostgreSQL).  
MD

Valorisation du Contexte : Exploitation des métadonnées (GPS, date) pour appuyer les prédictions (modèle inspiré de Merlin Bird ID).

⚠️ Divergences Majeures & Arbitrages à Trancher
Backend (Django REST vs FastAPI) :

Pathé et Lansana préconisent Django REST.  
MD

Massogui et Alioune privilégient FastAPI.

Arbitrage : FastAPI est scientifiquement plus performant pour l'asynchronisme de l'IA et l'intégration native de PyTorch.

Niveau de Complexité IA (Pragmatisme vs Haute Technologie) :

Alioune et Lansana proposent une IA légère (YOLOv8/11 + MobileNet/EfficientNet) facile à livrer dans les temps.  
MD

Massogui et Pathé proposent des architectures à l'état de l'art (YOLOv12/26, ByteTrack, BioCLIP-2, ONNX Dart FFI).

Arbitrage : Il faut adopter une IA hybride à deux vitesses (voir Section 4).

Portée des Livrables (Web + Mobile vs Mobile Pure) :

Massogui propose une application Flutter + un serveur FastAPI + une application Web Next.js 14 complète.

Arbitrage : Développer deux applications (Flutter + Next.js) en hackathon avec 4 personnes représente un fort risque de dispersion.  
MD

3. Évaluation de Pertinence pour le Hackathon
Avertissement Stratégique (Rappel du point clé de Lansana) : Un projet bancal avec des technologies ultra-récentes perdra face à une application stable, esthétique et fonctionnelle.  
MD

Plaintext
               HAUTE COMPLEXITÉ
                      │
                      │   ❌ Zone de Sur-Ingénierie (Risque)
                      │   • ONNX via C++ Dart FFI
                      │   • Web Dashboard Next.js 14 complet
                      │
   VALEUR             │   🎯 SWEET SPOT HACKATHON (A Retenir)
   POUR LE  ──────────┼────────────────────────────────────────
   JURY               │   • Mobile Flutter (Material 3 Dark)
                      │   • FastAPI + PostgreSQL/PostGIS
                      │   • YOLOv11/12 + ByteTrack (Vidéo)
                      │   • Priors Bayésiens eBird/GBIF
                      │
                      │   ⚠️ Risque de Sous-Efficience
                      │   • Saisie 100% manuelle / Pas de Tracking
                      │
                      └────────────────────────────────────────
                               BASSE COMPLEXITÉ
🌟 Les Pépites à Conserver Absolument
Le Suivi Vidéo ByteTrack (Pathé / Massogui) : Indispensable pour réussir le critère "Comptage" (20 pts) et éviter les doublons sur flux vidéo.  
MD

La Fusion Bayésienne Spatio-Temporelle (Massogui) : Innovation à très forte valeur scientifique. Elle consiste à recalculer la probabilité d'une espèce selon la formule :

P(S 
k
​
 ∣I,L,T)= 
∑ 
j=1
N
​
 P(I∣S 
j
​
 )⋅P(S 
j
​
 ∣L,T)
P(I∣S 
k
​
 )⋅P(S 
k
​
 ∣L,T)
​
 
Où P(I∣S 
k
​
 ) est le score visuel de l'IA et P(S 
k
​
 ∣L,T) est la fréquence historique eBird/GBIF sur le lieu L à la date T.
3. Le Fast-Prototyping & Datasets (Alioune) : Utiliser Roboflow pour annoter rapidement et réutiliser l'API open-source BirdNET-Analyzer pour l'extension audio.
4. La Grille d'Évaluation & le Pitch (Lansana) : Structurer la présentation autour de l'impact écologique et de la stabilité de l'application.  
MD

4. Plan Maître Stratégique et Recommandations
🛠️ 1. Architecture & Stack Technique Unifiée
Plaintext
[ Application Mobile Flutter ]
       │
       ├─► Appareil Photo / Vidéo (30 FPS)
       ├─► Carte Mapbox (Cache Offline MBTiles)
       └─► SQLite / Drift (Stockage Local Sync)
               │
               ▼  (HTTP / REST JSON + Media)
[ Backend FastAPI (Python 3.12) ]
       │
       ├─► Database : PostgreSQL 16 + PostGIS (Supabase)
       ├─► Storage  : Cloudinary / Google Cloud Storage
       └─► Moteur IA :
              ├── Détection  : YOLOv8n / YOLO11n / YOLO12-S
              ├── Suivi      : ByteTrack (Anti-doublon)
              ├── Classif    : EfficientNet-V2 / ConvNeXt
              └── Prior Bayes: Matrice Spatio-Temporelle (eBird/GBIF)
Mobile : Flutter 3.x (State management: Riverpod ou Bloc).

Backend : FastAPI (Asynchrone, léger, documentation OpenAPI auto-générée).

Base de données : PostgreSQL 16 avec extension PostGIS (hébergé sur Supabase pour la rapidité).

Moteur IA : Pipeline Python hébergé sur le backend (Inférence Cloud ultra-rapide) pour éviter les lourdeurs de compilation native sur mobile.

👥 2. Répartition Optimisée pour l'Équipe de 4 Personnes
Puisque l'équipe est composée de 4 personnes, la répartition des rôles est réajustée comme suit :

Plaintext
┌────────────────────────────────────────────────────────────────────────┐
│                        ÉQUIPE BIRDSENSE AI (4)                         │
└────────────────────────────────────────────────────────────────────────┘
       │                 │                   │                  │
       ▼                 ▼                   ▼                  ▼
  [ MEMBRE 1 ]      [ MEMBRE 2 ]        [ MEMBRE 3 ]       [ MEMBRE 4 ]
  Lead Mobile       Lead Backend        Lead IA & Vision   Fullstack & Pitch
  (Flutter / UI)    (FastAPI / DB)      (PyTorch / YOLO)   (UX / Product)
Membre 1 — Développeur Mobile Lead (Flutter UI/UX)

Développement du studio de capture (Photo/Vidéo) avec overlays dynamiques.

Cartographie interactive (Mapbox), mode hors-ligne et historique.

Intégration du Design System (Material 3 Dark Mode).  
MD

Membre 2 — Développeur Backend & Data (FastAPI / PostGIS)

Implémentation des endpoints REST FastAPI et authentification JWT.

Structuration de PostgreSQL / PostGIS (Tables, index spatiaux GiST).

Gestion de la file d'attente de synchronisation offline et du stockage médias.

Membre 3 — Ingénieur IA & Computer Vision

Entraînement/Fine-tuning de YOLO (détection) et préparation du dataset sur Roboflow.

Intégration de ByteTrack pour le comptage continu sur vidéo.

Construction du classifieur d'espèces et de la matrice de prior bayésien (eBird/GBIF).

Membre 4 — Integrateur Fullstack, Qualité & Speaker (Product Lead)

Définition et contrôle des livrables par rapport aux critères du jury.  
MD

Développement de la vue Tableau de bord / Statistiques (sur Web ou intégré dans Flutter).  
MD

Rédaction de la documentation GitHub, préparation du jeu de données de démo et Pitch final.  
MD

📅 3. Planning d'Exécution sur 7 Jours (Sprint Hackathon)
Plaintext
Phase 1 : J1 - J2  ──► Fondations, API REST, Modèle IA de base & Maquettes
Phase 2 : J3 - J4  ──► Connexion Mobile-Backend, Tracking ByteTrack & Cartographie
Phase 3 : J5       ──► Mode Offline, Fusion Bayésienne & Tableau de Bord
Phase 4 : J6       ──► Gel du code, Tests de Stress, Nettoyage GitHub
Phase 5 : J7       ──► Répétition du Pitch (5-7 min) & Scénario de Secours
Jours 1-2 (Socle) :

Déploiement de Supabase/PostgreSQL + PostGIS.

Fine-tuning rapide de YOLOv8n/v11n sur Roboflow (classes aviaires locales).

Squelette de l'application Flutter (Auth, Caméra, Navigation).  
MD

Jours 3-4 (Cœur de valeur) :

Intégration du pipeline YOLO + ByteTrack sur l'API FastAPI.

Affichage des boîtes englobantes en temps réel et du compteur sur mobile.

Intégration de la carte Mapbox.

Jour 5 (Innovations & Polissage) :

Ajout de la couche de pondération bayésienne spatio-temporelle.

Finalisation du tableau de bord d'indicateurs (Total oiseaux, espèces rares, cartes de chaleur).  
MD

Jours 6-7 (Qualité & Pitch) :

Tests d'intégration et correction des bugs d'affichage/crashs.  
MD

Préparation des vidéos de démonstration de secours (en cas de problème réseau le jour J).  
MD

Répétition de la présentation orale (5 à 7 min) axée sur l'impact écologique et l'innovation technologique.  
MD

🏆 4. Les 5 Commandements pour Remporter le Hackathon
La Stabilité d'abord : Aucune fonctionnalité incomplète ne doit figurer sur la version finale de démo.  
MD

Le "Waooouh Effect" du Comptage Vidéo : Montrer une séquence vidéo où chaque oiseau reçoit un ID unique qui ne double pas grâce à ByteTrack.

La Légitimité Scientifique : Expliquer au jury comment la géolocalisation et la date affinent la prédiction IA via le filtre bayésien.

L'Impact Réel : Présenter l'outil comme un levier pour les ONG, réserves et chercheurs (création du Bird Health Score).  
MD

Un Dépôt GitHub Exemplaire : Arborescence propre, documentation claire et schémas d'architecture lisibles.  
MD

on est 5 personnnnnnnnes

Reçu 5/5 ! C'est une excellente nouvelle : être 5 personnes change la donne pour le projet. Cela permet de séparer le pôle Mobile en deux (pour ne pas bloquer sur la caméra et la carte) et d'avoir un membre dédié au produit, aux tests et à la présentation.

Voici l'ajustement immédiat de la répartition des rôles et de l'organisation stratégique pour votre équipe de 5.

👥 Répartition Optimisée pour 5 Personnes
Plaintext
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                               ÉQUIPE BIRDSENSE AI (5)                                  │
└────────────────────────────────────────────────────────────────────────────────────────┘
       │              │                 │                  │                 │
       ▼              ▼                 ▼                  ▼                 ▼
 [ MEMBRE 1 ]   [ MEMBRE 2 ]      [ MEMBRE 3 ]       [ MEMBRE 4 ]      [ MEMBRE 5 ]
 Dev Mobile 1   Dev Mobile 2      Dev Backend        Ingénieur IA      Product & Pitch
 (UI / Map)     (Caméra/Sync)     (FastAPI / DB)     (CV / Tracking)   (QA / Presentation)
📋 Détail des Responsabilités par Membre
1️⃣ Membre 1 — Dev Mobile Lead (UI, Navigation & Cartographie)
Périmètre : Interface utilisateur, navigation et expérience visuelle.

Tâches clés :

Intégration du Design System (Material 3 Dark Mode, thème nature/canopée).  
MD

Écrans : Auth, Profil, Historique, Fiche Espèce.  
MD

Intégration de la carte interactive (Mapbox) : affichage des points d'observation, cartes de chaleur (heatmaps) et gestion des tuiles hors-ligne.

2️⃣ Membre 2 — Dev Mobile Hardware & Sync (Caméra, Overlays & SQLite)
Périmètre : Traitement de la caméra en temps réel et persistence locale.

Tâches clés :

Décodage du flux vidéo caméra (30 FPS) et dessin dynamique des boîtes englobantes (bounding boxes).  
MD

Mise en place de la base SQLite locale (via Drift) pour le stockage des observations hors-ligne.

Moteur de synchronisation arrière-plan (envoi des paquets vers l'API FastAPI au retour du réseau).

3️⃣ Membre 3 — Dev Backend & Infrastructure (FastAPI & PostGIS)
Périmètre : Architecture serveur, API REST et base de données spatiale.

Tâches clés :

Développement des endpoints FastAPI (Auth JWT, /detect, /sync, /map).

Modélisation et gestion de PostgreSQL 16 + PostGIS (hébergé sur Supabase).

Connexion aux services de stockage (Cloudinary / Google Cloud Storage) et consommation des APIs externes (eBird / iNaturalist).

4️⃣ Membre 4 — Ingénieur IA & Computer Vision
Périmètre : Pipeline de détection, tracking vidéo et classification.

Tâches clés :

Préparation du dataset et fine-tuning de YOLOv8n / YOLO11n / YOLO12-S sur Roboflow.

Implémentation du tracker ByteTrack pour attribuer un ID unique à chaque oiseau et éliminer les doublons.  
MD

Développement du modèle de classification des espèces et de la couche de Fusion Bayésienne (GPS + date).

5️⃣ Membre 5 — Product Lead, QA & Speaker (Qualité, Dashboard & Pitch)
Périmètre : Garant du respect des critères du jury, de la stabilité globale et de la démonstration.  
MD

Tâches clés :

Développement du Tableau de Bord / Statistiques.  
MD

Chasse aux bugs, tests d'intégration Mobile-Backend et validation du mode hors-ligne.

Gestion du dépôt GitHub (README, schémas d'architecture) et de la documentation.  
MD

Création du support de présentation, scénarisation de la démo en direct (5 à 7 min) et préparation d'une vidéo de secours (fallback).  
MD

⚡ Ce que 5 personnes apportent à votre Hackathon
Parallélisation Totale du Mobile : Le flux vidéo/caméra temps réel ne ralentira pas le développement des cartes et des écrans secondaires.

Qualité & Zéro Bug : Le Membre 5 s'assure qu'aucun écran bancal ni crash ne subsiste, sécurisant les 20 points de fonctionnement.  
MD

Pitch & Démo en Béton : Un membre dédié à 100% à la répétition de la présentation garantit les 10 points de présentation et valorise le travail des 4 autres.  
MD

developpe vas dans plus de details

1️⃣ Membre 1 — Dev Mobile Lead (UI, Navigation & Cartographie)

Périmètre : Interface utilisateur, navigation et expérience visuelle.

Tâches clés :

Intégration du Design System (Material 3 Dark Mode, thème nature/canopée).

Écrans : Auth, Profil, Historique, Fiche Espèce.

Intégration de la carte interactive (Mapbox) : affichage des points d'observation, cartes de chaleur (heatmaps) et gestion des tuiles hors-ligne.

2️⃣ Membre 2 — Dev Mobile Hardware & Sync (Caméra, Overlays & SQLite)

Périmètre : Traitement de la caméra en temps réel et persistence locale.

Tâches clés :

Décodage du flux vidéo caméra (30 FPS) et dessin dynamique des boîtes englobantes (bounding boxes).

Mise en place de la base SQLite locale (via Drift) pour le stockage des observations hors-ligne.

Moteur de synchronisation arrière-plan (envoi des paquets vers l'API FastAPI au retour du réseau).

3️⃣ Membre 3 — Dev Backend & Infrastructure (FastAPI & PostGIS)

Périmètre : Architecture serveur, API REST et base de données spatiale.

Tâches clés :

Développement des endpoints FastAPI (Auth JWT, /detect, /sync, /map).

Modélisation et gestion de PostgreSQL 16 + PostGIS (hébergé sur Supabase).

Connexion aux services de stockage (Cloudinary / Google Cloud Storage) et consommation des APIs externes (eBird / iNaturalist).

4️⃣ Membre 4 — Ingénieur IA & Computer Vision

Périmètre : Pipeline de détection, tracking vidéo et classification.

Tâches clés :

Préparation du dataset et fine-tuning de YOLOv8n / YOLO11n / YOLO12-S sur Roboflow.

Implémentation du tracker ByteTrack pour attribuer un ID unique à chaque oiseau et éliminer les doublons.

Développement du modèle de classification des espèces et de la couche de Fusion Bayésienne (GPS + date).

5️⃣ Membre 5 — Product Lead, QA & Speaker (Qualité, Dashboard & Pitch)

Périmètre : Garant du respect des critères du jury, de la stabilité globale et de la démonstration.

Tâches clés :

Développement du Tableau de Bord / Statistiques.

Chasse aux bugs, tests d'intégration Mobile-Backend et validation du mode hors-ligne.

Gestion du dépôt GitHub (README, schémas d'architecture) et de la documentation.

Création du support de présentation, scénarisation de la démo en direct (5 à 7 min) et préparation d'une vidéo de secours (fallback).

Feuille de Route Détaillée par Rôle — Équipe BirdSense AI
Voici la décomposition technique, opérationnelle et méthodologique pour chaque membre de l'équipe. Ce plan de travail garantit une couverture complète des exigences du jury et maximise vos points sur tous les critères.  
MD

1️⃣ Membre 1 — Dev Mobile Lead (UI, Navigation & Cartographie)
🎯 Périmètre
Responsable de l'interface utilisateur (UI), de l'expérience utilisateur (UX), de la navigation globale et du rendu cartographique géospatial.  
MD

Plaintext
               ┌────────────────────────────────────────┐
               │    MEMBRE 1 : FLUTTER UI & CARTOGRAPHY │
               └────────────────────────────────────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         ▼                         ▼                         ▼
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│  DESIGN SYSTEM   │      │ PARCOURS ÉCRANS  │      │ MAPBOX VECTORIAL │
│ Material 3 Dark  │      │ Auth, Hist, Info │      │ Clusters & Tiles │
└──────────────────┘      └──────────────────┘      └──────────────────┘
📋 Feuille de Route Technique
A. Design System & Identité Visuelle (Material 3)
Palette de Couleurs :  
MD

Primary : Vert Canopée (#1E3A2B).  
MD

Secondary : Terre Cuite (#E07A5F) pour les boutons prioritaires.  
MD

Accent : Ambré (#F4A261) pour les marqueurs et boîtes englobantes.  
MD

Background : Noir Profond (#121513) activé par défaut pour préserver la batterie sur le terrain et réduire l'éblouissement.  
MD

Composants Translucides (Glassmorphism) : Conception de panneaux informatiques flottants avec effet de flou dynamique pour ne pas masquer la vue caméra.  
MD

Typographie : Configuration de la police Inter ou SF Pro Display pour garantir une hiérarchie visuelle lisible.  
MD

B. Développement des Écrans Principaux
Écran d'Authentification & Profil : Connexion JWT, affichage des statistiques personnelles, du niveau d'expertise ornithologique et des badges.  
MD

Galerie & Historique : Liste filtrable des observations enregistrées localement et synchronisées (filtrage par date, espèce et niveau de confiance).  
MD

Fiche Espèce Interactive : Vue détaillée affichant les noms scientifiques et vernaculaires, le statut de conservation IUCN (ex. LC, VU, CR), un lecteur audio pour le chant de l'oiseau (API eBird/BirdNET) et les conseils d'identification.  
MD

C. Moteur Cartographique Interactive (Mapbox SDK)
Clustering Dynamique : Intégration de mapbox_maps_flutter pour regrouper les milliers de points d'observation à fort niveau de zoom sans perte de performance.  
MD

Couche de Carte de Chaleur (Heatmap) : Affichage des densités d'oiseaux observés sur la zone géographique.  
MD

Gestion Offline : Implémentation du téléchargement préalable des tuiles vectorielles (.mbtiles) pour conserver le fond de carte actif en zone blanche.  
MD

2️⃣ Membre 2 — Dev Mobile Hardware & Sync (Caméra, Overlays & SQLite)
🎯 Périmètre
Responsable du traitement matériel à faible latence (flux caméra), de la superposition graphique en temps réel, de la persistence locale et de la synchronisation réseau.  
MD

Plaintext
               ┌────────────────────────────────────────┐
               │  MEMBRE 2 : HARDWARE, OVERLAYS & SYNC  │
               └────────────────────────────────────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         ▼                         ▼                         ▼
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│  CAMERA STREAM   │      │ DRIFT / SQLITE   │      │ BACKGROUND SYNC  │
│ Overlays 30 FPS  │      │ Base Chiffrée    │      │ Queue Resilient  │
└──────────────────┘      └──────────────────┘      └──────────────────┘
📋 Feuille de Route Technique
A. Traitement Vidéo & Rendering Overlays
Flux Caméra (30–60 FPS) : Exploitation du package camera Flutter en mode capture d'images brutes sans blocage du thread principal UI.  
MD

Dessin Dynamique (CustomPainter) : Conversion des coordonnées normalisées de l'IA (x 
min
​
 ,y 
min
​
 ,x 
max
​
 ,y 
max
​
 ) en rectangles ajustés à la résolution de l'écran.  
MD

Feedback Tactile & Visuel : Déclenchement d'une vibration haptique douce et incrémentation en direct du compteur d'oiseaux distincts.  
MD

B. Persistence Locale Offline-First (Drift & SQLite)
Modélisation Locale : Utilisation de l'ORM Drift avec SQLCipher pour chiffrer la base SQLite locale.  
MD

Schéma des Tables Locales :

LocalObservations : id, latitude, longitude, timestamp, image_path, sync_status (PENDING, SYNCED, ERROR).  
MD

LocalItems : id, observation_id, tracking_id, species_code, confidence.  
MD

C. Moteur de Synchronisation Arrière-Plan
Gestionnaire de Tâches (WorkManager) : Détection du rétablissement de la connectivité réseau et déclenchement automatique du pipeline d'envoi.  
MD

Gestion du Retry & Backoff : Implémentation de la politique de réessai avec temporisation exponentielle (Exponential Backoff) pour éviter de saturer le serveur.  
MD

Hachage de Sécurité (media_hash) : Envoi préalable du hash SHA-256 du média pour éviter d'uploader à nouveau une image déjà enregistrée sur le serveur.  
MD

3️⃣ Membre 3 — Dev Backend & Infrastructure (FastAPI & PostGIS)
🎯 Périmètre
Conception de l'architecture serveur, de la base de données spatiale, de la logique API asynchrone et de la communication avec les services cloud.  
MD

Plaintext
               ┌────────────────────────────────────────┐
               │    MEMBRE 3 : FASTAPI & POSTGIS DB     │
               └────────────────────────────────────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         ▼                         ▼ me                      ▼
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│  FASTAPI ASYNC   │      │ POSTGIS SPATIAL  │      │ ASYNC WORKERS    │
│ Auth JWT & Sync  │      │ Spatial Indexing │      │ Celery + Redis   │
└──────────────────┘      └──────────────────┘      └──────────────────┘
📋 Feuille de Route Technique
A. Développement de l'API REST FastAPI
Endpoints Sécurisés (OpenAPI 3.0) :  
MD

POST /api/v1/auth/register & POST /api/v1/auth/login : Authentification basée sur des tokens JWT (durée de vie 15 min + Refresh Tokens).  
MD

POST /api/v1/observations/detect : Point d'entrée synchrone pour l'analyse d'une photo directe.  
MD

POST /api/v1/observations/sync : Ingestion par lots (batching) pour synchroniser les enregistrements accumulés hors-ligne.  
MD

GET /api/v1/observations/map : Extraction des données spatiales filtrées par Bounding Box géographique.  
MD

B. Base de Données Spatiale (PostgreSQL 16 + PostGIS)
Création des Tables Relations :  
MD

SQL
-- Extension Géospatiale PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;[cite: 1]

-- Table des Observations
CREATE TABLE observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),[cite: 1]
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,[cite: 1]
    geom GEOMETRY(Point, 4326) NOT NULL, -- Coordonnées GPS WGS84
    observed_at TIMESTAMP WITH TIME ZONE NOT NULL,[cite: 1]
    total_count INT NOT NULL DEFAULT 1,[cite: 1]
    image_url TEXT,[cite: 1]
    is_fuzzy_protected BOOLEAN DEFAULT FALSE,[cite: 1]
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP[cite: 1]
);

-- Indexation Spatiale GiST pour des requêtes en quelques millisecondes
CREATE INDEX idx_obs_geom ON observations USING GIST (geom);[cite: 1]
Protection des Espèces Menacées (Fuzzing Spatiale) : Application automatique d'un floutage géographique de 5 km sur les coordonnées GPS exactes des espèces classées "En Danger" (IUCN) pour empêcher le braconnage.  
MD

C. Traitement Asynchrone & Intégration Cloud
Gestion des Tâches Vidéo (Celery + Redis) : Délégation de l'analyse vidéo lourde à des workers Celery dédiés pour maintenir l'API FastAPI ultra-réactive.  
MD

Stockage Médias (Cloudinary / Google Cloud Storage) : Génération d'URLs signées pour sécuriser l'accès aux photos stockées.  
MD

4️⃣ Membre 4 — Ingénieur IA & Computer Vision
🎯 Périmètre
Conception du pipeline complet de vision par ordinateur : détection multi-instances, suivi temporel anti-doublon (tracking) et classification fine pondérée par le contexte géographique.  
MD

Plaintext
               ┌────────────────────────────────────────┐
               │    MEMBRE 4 : IA & COMPUTER VISION     │
               └────────────────────────────────────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         ▼                         ▼                         ▼
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│ YOLO DETECTION   │      │ BYTETRACK TRACK  │      │ BAYESIAN FUSION  │
│ YOLOv11 / v12    │      │ Single IDs Video │      │ Spatial Priors   │
└──────────────────┘      └──────────────────┘      └──────────────────┘
📋 Feuille de Route Technique
A. Détection & Comptage d'Objets (Famille YOLO)
Dataset & Augmentation : Préparation et annotation via Roboflow d'un dataset hybride combinant COCO (classe bird), CUB-200, et iNaturalist.  
MD

Fine-Tuning : Entraînement de YOLOv8n / YOLO11n / YOLO12-S avec la suite Albumentations (ajout de flou de mouvement, variations de luminosité, découpage Mosaic 4-way) pour résister aux images floues prises en milieu sauvage.  
MD

Conversion et Quantification : Export du modèle en format ONNX / INT8 pour diviser la taille du modèle par 4 et réduire le temps d'inférence sous la barre des 10 ms.  
MD

B. Suivi Multi-Objets Vidéo (ByteTrack)
Attribution d'Identifiants Uniques : Intégration de l'algorithme ByteTrack qui analyse la trajectoire et le recouvrement des boîtes englobantes d'une frame à l'autre.  
MD

Anti-Doublon : Conservation d'un UUID unique par oiseau traversant le champ de vision (ex. Oiseau #1, Oiseau #2), ce qui garantit un comptage fiable même en cas d'occlusion temporaire derrière des branches.  
MD

C. Classification Fine & Fusion Bayésienne Spatio-Temporelle
Classifieur Spécialisé : Utilisation d'un backbone EfficientNet-V2 ou BioCLIP-2 pour extraire l'espèce à partir du crop de la boîte englobante.  
MD

Ré-étalonnage Bayésien : Combinaison de la probabilité visuelle issue du réseau avec les données de présence historique eBird / GBIF :  
MD

P(S 
k
​
 ∣I,L,T)= 
∑ 
j=1
N
​
 P(I∣S 
j
​
 )⋅P(S 
j
​
 ∣L,T)
P(I∣S 
k
​
 )⋅P(S 
k
​
 ∣L,T)
​
 
Exemple d'impact : Si l'IA visuelle hésite à 50% entre une espèce européenne et une espèce africaine, le prior biogéographique P(S 
k
​
 ∣L,T) lié aux coordonnées GPS du Sénégal remonte la certitude de l'espèce locale à 98%.

5️⃣ Membre 5 — Product Lead, QA & Speaker (Qualité, Dashboard & Pitch)
🎯 Périmètre
Garant du respect de la grille d'évaluation du jury, de la stabilité globale de l'application, de l'analyse des données d'impact, de la documentation et de la prestation orale lors du pitch final.  
MD

Plaintext
               ┌────────────────────────────────────────┐
               │  MEMBRE 5 : PRODUCT, QA & PITCH LEAD   │
               └────────────────────────────────────────┘
                                   │
         ┌─────────────────────────┼─────────────────────────┐
         ▼                         ▼                         ▼
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│ DASHBOARD STATS  │      │ QA & BENCHMARKS  │      │ PITCH & DEMO     │
│ KPIs & Heatmaps  │      │ Locust / Sentry  │      │ Deck & Fallback  │
└──────────────────┘      └──────────────────┘      └──────────────────┘
📋 Feuille de Route Technique
A. Tableau de Bord & Visualisation de Données
Indicateurs Clés de Performance (KPIs) :  
MD

Total d'oiseaux recensés et nombre d'espèces distinctes identifiées.  
MD

Répartition des observations par famille taxonomique.  
MD

Bird Health Score : Calcul automatique d'un indice de santé écologique de la zone géographique basé sur la diversité des espèces observées.  
MD

Composants Graphiques (FL Chart) : Graphiques d'évolution temporelle des comptages et camemberts de répartition.  
MD

B. Assurance Qualité (QA) & Supervision
Pipeline CI/CD (GitHub Actions) : Automatisation des tests unitaires et de la vérification du code à chaque modification.  
MD

Tests de Charge (Locust) : Simulation de 500 utilisateurs virtuels envoyant simultanément des paquets de synchronisation pour s'assurer que l'API backend ne plante pas sous la pression.

Test "Zone Blanche" (Mode Avion) : Validation stricte du fonctionnement complet hors-réseau (capture, sauvegarde SQLite, relance du réseau et vérification de la synchronisation).  
MD

C. Stratégie de Pitch & Scénarisation de Démo
Structure du Pitch Oral (5 à 7 minutes) :  
MD

Plaintext
[ 0:00 - 1:00 ] ──► Le Problème : Limites du recensement manuel (lent, coûteux, erreurs)
[ 1:00 - 2:00 ] ──► La Solution : Présentation de BirdSense AI & Vision produit
[ 2:00 - 4:30 ] ──► DÉMONSTRATION EN DIRECT (Vidéo 30 FPS, ByteTrack, Carte, Off-line)
[ 4:30 - 5:30 ] ──► Innovation : Algorithme de Fusion Bayésienne & Bird Health Score
[ 5:30 - 6:30 ] ──► Impact & Prochaines étapes (ONG, Ministères, Parcs nationaux)
Plan de Secours (Fallback Plan) : Enregistrement préalable de séquences vidéo haute définition démontrant l'application fonctionnant parfaitement, utilisable immédiatement en cas de panne de réseau ou de problème matériel sur la scène.  
MD

🗂️ Récapitulatif Matériel des Livrables
Membre	Livrable Principal	Fichiers Clés dans le Dépôt
Membre 1	
Application Mobile (UI & Cartes)  
MD

lib/features/observation_map/, lib/core/theme/

  
MD

Membre 2	
Moteur Caméra & Pipeline SQLite Sync  
MD

lib/features/camera_detection/, lib/features/sync_engine/

  
MD

Membre 3	
API FastAPI & Base PostGIS[cite: 1]

birdsense_backend/app/api/, birdsense_backend/app/db/

[cite: 1]

Membre 4	
Moteur IA (YOLO + ByteTrack + Bayes)[cite: 1]

birdsense_backend/app/ai_engine/

[cite: 1]

Membre 5	
Tableau de Bord, QA, Docs & Support Pitch[cite: 1]

docs/, presentation/, tests/

[cite: 1]

Aliou vient de faire une synthese analyse la et dis moi ce que tu en penses

C'est une excellente synthèse, extrêmement mûre, pragmatique et parfaitement alignée avec la réalité d'un hackathon. Aliou a fait un travail remarquable de cadrage en évitant le piège classique des équipes techniques : la sur-ingénierie et l'éparpillement.

Voici mon analyse détaillée de sa synthèse, ce que j'en pense, et quelques micro-ajustements pour optimiser votre stratégie.

🟢 Les Plus Forts Atouts de la Synthèse d'Aliou
1. La Lucidité "Anti-Piège" (Pragmatisme vs Sur-ingénierie)
Aliou a parfaitement identifié le risque majeur de la contribution de Massogui : vouloir livrer un produit industriel complet en 7 jours (SSL Pinning, Edge/Cloud hybride, Next.js, CI/CD lourd).

Mon avis : Il a 100% raison. En hackathon, un projet simple, stable, beau et fluide qui fonctionne en live bat toujours un projet ultra-ambitieux qui plante pendant la démo devant le jury.

2. L'Arbitrage Intelligent sur le Comptage Vidéo (ByteTrack)
En retenant YOLO + ByteTrack (proposé par Pathé et Massogui) plutôt que de développer un moteur de suivi custom, Aliou sécurise la brique la plus difficile du projet. ByteTrack est une bibliothèque open-source éprouvée qui résout le problème des doublons en quelques lignes de code.

3. La Récupération des "Bonus à Faible Coût"
L'idée d'ajouter l'extension audio via BirdNET (suggérée par Alioune) dans les choix de synthèse est excellente. Comme le modèle est pré-entraîné et disponible en wrapper Python, cela vous permet d'ajouter une fonctionnalité "effet Waoouh" à la présentation avec un effort de développement très faible.

🟡 Les Nuances & Ajustements à Apporter
Bien que la stack proposée par Aliou soit très solide, voici 3 points sur lesquels vous devriez trancher immédiatement :

A. Backend : Faites Pencher la Balance vers FastAPI
Aliou laisse le choix ouvert entre Django REST et FastAPI selon la maîtrise de l'équipe.

Recommandation : Si votre moteur IA (YOLO + ByteTrack) tourne sur le serveur backend, privilégiez FastAPI. Il est basé sur Python asyncio, s'interface directement avec PyTorch/OpenCV sans couche lourde, et génère la documentation Swagger/OpenAPI automatiquement. Django est très bon pour du CRUD classique, mais plus lourd pour du traitement de flux d'images/vidéos.

B. Ne Jetez pas Complètement la "Fusion Bayésienne" de Massogui !
Aliou la met en option "si le temps le permet". C'est logique si on parle d'un système complet avec maillage H3.

Astuce Hackathon : Faites-en une version simplifiée en 20 lignes de code !
Au lieu d'un calcul complexe, faites un simple dictionnaire de présence d'espèces par région (ex: Sénégal / Afrique de l'Ouest). Si l'IA visuelle hésite entre deux oiseaux avec un score moyen, appliquez un coefficient multiplicateur selon la présence de l'espèce dans la zone. Cela prend 1 heure à coder, mais vous permet de vendre l'innovation scientifique de la Fusion Bayésienne dans votre pitch.

C. Cartographie : Optez pour Mapbox si l'UI/UX est la Priorité
Aliou propose Flutter Map (OSM) pour la gratuité. Cependant, si un membre de l'équipe maîtrise le SDK Mapbox, le rendu vectoriel, le clustering fluide et le mode sombre natif de Mapbox apporteront un cachet visuel nettement supérieur pour grapiller des points sur le critère UX/UI (10 pts).

🎯 Validation du Framework d'Équipe à 5 Personnes
La stack technique recommandée par Aliou s'imboîte parfaitement avec l'organisation à 5 personnes que nous avons définie. Voici comment la synthèse d'Aliou se traduit concrètement pour votre équipe :

Plaintext
┌─────────────────────────────────────────────────────────────────────────┐
│                    ALIGNEMENT STACK ALIOU / ÉQUIPE (5)                  │
└─────────────────────────────────────────────────────────────────────────┘
  • Membre 1 (Dev Mobile UI/Map)     ──► Flutter 3.x + Mapbox / Design System
  • Membre 2 (Dev Mobile Hardware)   ──► Caméra Stream + SQLite Cache Offline
  • Membre 3 (Dev Backend / Infra)   ──► FastAPI + PostgreSQL (Supabase) + Cloudinary
  • Membre 4 (Ingénieur IA)          ──► YOLOv8/v11 (Roboflow) + ByteTrack
  • Membre 5 (Product / QA / Pitch)  ──► Dashboard KPIs + Scénario Démo & Pitch
💡 Verdict Final
Foncez avec la synthèse d'Aliou ! C'est le meilleur compromis possible. Elle conserve l'élégance technique des recherches de Massogui et Pathé, exploite les raccourcis pragmatiques d'Alioune, et reste strictement focalisée sur les critères de victoire dictés par Lansana.

Vous avez désormais un cadrage clair, une stack validée et une répartition sur 5 personnes. Il ne reste plus qu'à lancer le Sprint !

maintenant fais moi une synthèse finale ultra complet qui sera un prompt pour antigravity ain qu'il commence le developpement de l'application dans un fichier md

🛠️ Résumé de la Stack Technique
Mobile Frontend : Flutter 3.x (Dart), Riverpod (State Management), Dio (HTTP Client), Drift/SQLite (Local DB), Mapbox Maps SDK.

Backend Service : FastAPI (Python 3.12), SQLAlchemy 2.0 (Async ORM), Alembic (Migrations), Pydantic v2, PyJWT.

Base de Données : PostgreSQL 16 + Extension PostGIS (Hébergement Supabase).

Computer Vision & IA : Ultralytics YOLOv8n/YOLO11n, ByteTrack (Suivi Multi-Objets), PyTorch, OpenCV, Albumentations.

Traitement Asynchrone : Celery + Redis (Traitement des flux vidéo longs).

Stockage Médias : Cloudinary / Google Cloud Storage.

Services Web API Externe : eBird API & GBIF (Priors biogéographiques et enregistrements sonores).

3. RÉPARTITION DES RÔLES (ÉQUIPE DE 5 PERSONNES)
Rôle	Périmètre	Tâches Majeures
Membre 1 : Lead Mobile UI & Map	UX/UI, Navigation, Cartographie	Design System Material 3, Écrans Auth/Profil/Historique/Fiche Espèce, Integration Mapbox (Clusters, Heatmaps, Tuiles Offline).
Membre 2 : Dev Mobile Hardware & Sync	Caméra Temps Réel & Persistence	Stream Caméra 30 FPS, Bounding Boxes Canvas Overlays, Base SQLite Drift chiffrée, Moteur de Synchronisation arrière-plan (WorkManager).
Membre 3 : Backend & Infra Lead	API REST FastAPI, PostGIS, Cloud	Endpoints Async FastAPI, Schemas PostgreSQL/PostGIS, Migration Alembic, Floutage GPS (Fuzzing Espèces Menacées), Celery/Redis.
Membre 4 : Ingénieur IA & CV	Pipeline Détection, Tracking & Prior	Fine-tuning YOLOv8/11 sur Roboflow, Intégration ByteTrack (ID unique vidéo), Classifieur d'espèce, Algorithme de Fusion Bayésienne Spatio-Temporelle.
Membre 5 : Product Lead, QA & Speaker	Qualité, Dashboard & Presentation	Développeur Dashboard KPIs (FL Chart), Tests de charge (Locust), Tests Offline Mode Avion, Documentation GitHub, Support de Pitch (5-7 min) & Fallback Video.
4. ARBORESCENCE DU PROJET & ORGANISATION DU CODE
Plaintext
birdsense-ai/
├── birdsense_mobile/              # Application Mobile Flutter
│   ├── android/
│   ├── ios/
│   ├── assets/
│   │   ├── icons/
│   │   ├── images/
│   │   └── tiles/                 # Tuiles cartographiques offline (.mbtiles)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/                  # Thèmes, constantes, exceptions, réseau
│   │   │   ├── network/           # Client Dio, Intercepteurs JWT
│   │   │   ├── theme/             # Material 3 Dark Palette (Canopée, Terre Cuite)
│   │   │   └── utils/
│   │   ├── data/                  # Repositories & Drift SQLite Database
│   │   │   ├── local/             # Schema Drift (tables local_observations, local_items)
│   │   │   └── repositories/      # ObservationRepository, AuthRepository
│   │   └── features/              # Feature-Driven Architecture
│   │       ├── auth/              # Vues Auth, ViewModels
│   │       ├── camera_detection/  # Stream Caméra, Overlays Bounding Box
│   │       ├── observation_map/   # Mapbox SDK integration
│   │       ├── species_catalog/   # Fiches espèces, Chants sonores
│   │       ├── sync_engine/       # WorkManager Background Task Queue
│   │       └── dashboard/         # Graphiques FL Chart & KPIs
│   └── test/
├── birdsense_backend/             # Backend FastAPI (Python)
│   ├── app/
│   │   ├── api/                   # Router Endpoints V1 (/auth, /observations, /species, /map)
│   │   ├── core/                  # Security JWT, Config Settings (Pydantic)
│   │   ├── db/                    # Session SQLAlchemy Async, Base Model, Alembic Migrations
│   │   ├── ai_engine/             # Inférence YOLO, ByteTrack Tracker, Prior Bayésien
│   │   ├── models/                # Schemas Pydantic v2 & Modèles ORM SQLAlchemy
│   │   └── services/              # Storage Cloudinary, Ingestion eBird/GBIF
│   ├── tests/                     # Pytest API & Integration tests
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── requirements.txt
├── devops/                        # Monitoring & CI/CD
│   ├── github-actions/
│   └── locustfile.py              # Tests de charge backend
└── docs/                          # Presentation & Pitch Deck
    ├── architecture.png
    └── pitch_deck.pdf
5. SPÉCIFICATIONS DE LA BASE DE DONNÉES
A. Base Backend PostgreSQL 16 + PostGIS (Production)
SQL
-- Activer l'extension géospatiale PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table des Utilisateurs
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'OBSERVER',
    expertise_level VARCHAR(20) DEFAULT 'AMATEUR',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des Espèces Aviaires
CREATE TABLE species (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scientific_name VARCHAR(150) UNIQUE NOT NULL,
    common_name_fr VARCHAR(150) NOT NULL,
    common_name_en VARCHAR(150) NOT NULL,
    family VARCHAR(100),
    iucn_category VARCHAR(10) DEFAULT 'LC', -- LC, NT, VU, EN, CR
    audio_call_url TEXT,
    description TEXT
);

-- Table des Observations Géolocalisées
CREATE TABLE observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    geom GEOMETRY(Point, 4326) NOT NULL, -- Format WGS84
    altitude FLOAT,
    observed_at TIMESTAMP WITH TIME ZONE NOT NULL,
    total_count INT NOT NULL DEFAULT 1,
    image_url TEXT,
    video_url TEXT,
    is_fuzzy_protected BOOLEAN DEFAULT FALSE, -- Vrai si espèce protégée (floutage 5km)
    sync_status VARCHAR(20) DEFAULT 'SYNCED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des Détections d'Individus (Items de chaque Observation)
CREATE TABLE observation_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    observation_id UUID NOT NULL REFERENCES observations(id) ON DELETE CASCADE,
    species_id UUID REFERENCES species(id),
    tracking_id INT, -- ID unique généré par ByteTrack sur vidéo
    confidence_score FLOAT NOT NULL,
    bbox_x_min FLOAT NOT NULL,
    bbox_y_min FLOAT NOT NULL,
    bbox_x_max FLOAT NOT NULL,
    bbox_y_max FLOAT NOT NULL
);

-- Indexation Spatiale GiST et Temporelle
CREATE INDEX idx_obs_geom ON observations USING GIST (geom);
CREATE INDEX idx_obs_date ON observations (observed_at);
CREATE INDEX idx_species_name ON species (scientific_name);
B. Base Locale Mobile SQLite Drift (Offline-First)
Dart
// Définition Drift (Dart)
import 'package:drift/drift.dart';

class LocalObservations extends Table {
  TextColumn get id => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get observedAt => dateTime()();
  IntColumn get totalCount => integer().withDefault(const Constant(1))();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))(); // PENDING, SYNCED, ERROR

  @override
  Set<Column> get primaryKey => {id};
}

class LocalObservationItems extends Table {
  TextColumn get id => text()();
  TextColumn get observationId => references(LocalObservations, #id)();
  IntColumn get trackingId => integer().nullable()();
  TextColumn get speciesName => text()();
  RealColumn get confidence => real()();
  RealColumn get bboxXMin => real()();
  RealColumn get bboxYMin => real()();
  RealColumn get bboxXMax => real()();
  RealColumn get bboxYMax => real()();

  @override
  Set<Column> get primaryKey => {id};
}
6. BACKEND FASTAPI & SPÉCIFICATIONS DES APIS REST
Modèles Pydantic v2 (Python)
Python
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import List, Optional
from uuid import UUID

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class BoundingBox(BaseModel):
    x_min: float
    y_min: float
    x_max: float
    y_max: float

class DetectedBirdItem(BaseModel):
    tracking_id: Optional[int] = None
    species_scientific_name: str
    confidence: float
    bounding_box: BoundingBox

class ObservationCreateDTO(BaseModel):
    local_id: str
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    altitude: Optional[float] = None
    observed_at: datetime
    detected_birds: List[DetectedBirdItem]
    media_hash: str

class ObservationResponseDTO(BaseModel):
    id: UUID
    user_id: UUID
    latitude: float
    longitude: float
    total_count: int
    observed_at: datetime
    image_url: Optional[str]
    is_fuzzy_protected: bool
    items: List[DetectedBirdItem]
Router FastAPI (/api/v1/observations)
Python
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

router = APIRouter(prefix="/api/v1/observations", tags=["Observations"])

@router.post("/detect", response_model=List[DetectedBirdItem])
async def detect_birds_in_image(
    file: UploadFile = File(...),
    latitude: float = 0.0,
    longitude: float = 0.0
):
    """
    Endpoint synchrone pour détecter, compter et identifier les oiseaux dans une image.
    Invoque YOLO + ByteTrack + Prior Bayésien.
    """
    # 1. Lecture du buffer d'image
    image_bytes = await file.read()
    
    # 2. Exécution de l'IA (YOLO + Prior Bayésien)
    results = await ai_pipeline.process_image(image_bytes, lat=latitude, lng=longitude)
    return results

@router.post("/sync", status_code=status.HTTP_207_MULTI_STATUS)
async def sync_offline_observations(
    observations: List[ObservationCreateDTO],
    db: AsyncSession = Depends(get_async_db)
):
    """
    Ingestion par lots (Batch Ingestion) pour synchroniser les observations stockées hors-ligne.
    """
    sync_results = []
    for obs in observations:
        # Sauvegarde en base PostgreSQL / PostGIS avec géométrie Point(lng, lat)
        res = await save_observation_to_db(db, obs)
        sync_results.append(res)
    return {"synced_count": len(sync_results), "details": sync_results}
7. MOTEUR IA, COMPUTER VISION & TRACKING BYTETRACK
A. Détection Visuelle avec YOLOv8n / YOLO11n
Le modèle de détection s'appuie sur Ultralytics YOLO pré-entraîné sur le dataset COCO (classe bird), affiné via Transfer Learning sur le dataset personnalisé Roboflow (comprenant les espèces locales et contextes de vol dense).

B. Suivi Multi-Objets Vidéo avec ByteTrack
Pour éliminer les erreurs de double comptage dans les séquences vidéo, l'algorithme ByteTrack associe un identifiant unique persistent à chaque trajectoire d'oiseau.

Python
# Pipeline Python de traitement vidéo avec YOLO + ByteTrack
import cv2
from ultralytics import YOLO
from byte_tracker import BYTETracker  # Bibliothèque Open-Source ByteTrack

model = YOLO("yolov11n_birds.pt")
tracker = BYTETracker(frame_rate=30)

def process_video_frame(frame, frame_id):
    results = model(frame)[0]
    detections = []
    for box in results.boxes:
        x1, y1, x2, y2 = box.xyxy[0].tolist()
        score = box.conf[0].item()
        detections.append([x1, y1, x2, y2, score])
    
    # Mise à jour du tracker ByteTrack
    online_targets = tracker.update(np.array(detections), img_info=frame.shape, img_size=frame.shape)
    
    unique_birds = []
    for t in online_targets:
        tlwh = t.tlwh
        tid = t.track_id
        unique_birds.append({"track_id": tid, "bbox": tlwh})
        
    return unique_birds
C. Fusion Bayésienne Spatio-Temporelle Simplifiée
Pondération des résultats visuels par les priors de distribution géographique historiques eBird/GBIF :

Score Final(S 
k
​
 )=Score Visuel(S 
k
​
 )×Facteur Pr 
e
ˊ
 sence R 
e
ˊ
 gionale(S 
k
​
 ,L,T)
Python
# Pseudo-code de la Fusion Bayésienne Simplifiée
SPECIES_REGIONAL_PRIORS = {
    "SENEGAL": {
        "Pelecanus onocrotalus": 0.95, # Pélican blanc (très fréquent)
        "Spheniscus demersus": 0.01    # Manchot du Cap (quasi impossible)
    }
}

def apply_bayesian_prior(visual_scores: dict, country_code: str = "SENEGAL") -> dict:
    adjusted_scores = {}
    priors = SPECIES_REGIONAL_PRIORS.get(country_code, {})
    
    for species, visual_conf in visual_scores.items():
        prior_weight = priors.get(species, 0.5) # Default prior 0.5 if unknown
        # Ajustement Bayésien simplifié
        final_score = visual_conf * prior_weight
        adjusted_scores[species] = final_score
        
    # Normalisation Softmax
    total = sum(adjusted_scores.values())
    return {k: v / total for k, v in adjusted_scores.items()}
8. APPLICATION MOBILE FLUTTER
A. Design System & Palette (Material 3 Dark Mode)
Primary Color (Vert Canopée) : #1E3A2B

Secondary Color (Terre Cuite) : #E07A5F

Accent Color (Jaune Ambré) : #F4A261

Background Color (Noir Profond) : #121513

Surface Translucide (Glassmorphism) : #1A211D avec BackdropFilter (Blur 10px).

B. Custom Painter pour Overlays Bounding Box (30 FPS)
Dart
import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> detections;
  final Size previewSize;

  BoundingBoxPainter(this.detections, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / previewSize.width;
    final double scaleY = size.height / previewSize.height;

    final paint = Paint()
      ..color = const Color(0xFFF4A261)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textStyle = const TextStyle(
      color: Colors.white,
      backgroundColor: Color(0xFF1E3A2B),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    for (var det in detections) {
      final rect = Rect.fromLTRB(
        det.xMin * scaleX,
        det.yMin * scaleY,
        det.xMax * scaleX,
        det.yMax * scaleY,
      );
      canvas.drawRect(rect, paint);

      final textSpan = TextSpan(
        text: ' ${det.speciesName} (${(det.confidence * 100).toStringAsFixed(0)}%) ',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top - 18));
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) => true;
}
9. MOTEUR OFFLINE-FIRST & SYNCHRONISATION RÉSILIENTE
Capture Hors-Ligne : Lorsque l'utilisateur prend une photo en zone blanche sans réseau, la géolocalisation GPS est lue depuis le capteur mobile.

Persistence SQLite : L'observation est enregistrée immédiatement dans la table locale LocalObservations avec l'état syncStatus = 'PENDING'.

Queue Arrière-Plan : Un job WorkManager écoute les changements d'état réseau de l'appareil (ConnectivityResult.mobile ou ConnectivityResult.wifi).

Envoi par Batch : Dès le rétablissement du réseau, la file d'attente expédie les paquets vers /api/v1/observations/sync. L'état passe à 'SYNCED'.

10. DASHBOARD, STATISTIQUES & BIRD HEALTH SCORE
Indice Écologique : Bird Health Score
Calcul de la richesse écologique d'une zone cartographique selon la formule de Shannon-Wiener simplifiée :

Bird Health Score= 
i=1
∑
S
​
 −(p 
i
​
 log 
2
​
 p 
i
​
 )
Où p 
i
​
  est la proportion d'individus de l'espèce i par rapport au nombre total d'oiseaux observés dans le rayon d'analyse.

Graphiques FL Chart (Mobile)
Bar Chart : Volume d'observations par jour/semaine.

Pie Chart : Proportion des espèces identifiées dans la zone (ex. 45% Héron, 30% Mouette, 25% Tourterelle).

11. PLAN D'EXÉCUTION HACKATHON (7 JOURS) & SCÉNARISATION DÉMO
Plaintext
📅 JOUR 1-2 : SOCLE & INFRASTRUCTURE
   ├── Initialisation Dépôt GitHub & CI/CD
   ├── Déploiement Supabase (PostgreSQL + PostGIS)
   ├── Fast API Endpoints (/auth, /detect) & Fine-Tuning YOLO Roboflow
   └── Flutter App Navigation & Material 3 Theme setup

📅 JOUR 3-4 : COEUR IA, CAMERA STREAM & CARTOGRAPHIE
   ├── Pipeline YOLO + ByteTrack (Comptage vidéo sans doublons)
   ├── Overlays Bounding Box dynamique sur Flutter Camera Stream
   ├── Integration Mapbox Mobile SDK (Clusters & Heatmaps)
   └── Synchronisation SQLite Drift Local DB

📅 JOUR 5 : INNOVATIONS & DASHBOARD
   ├── Intégration de la Fusion Bayésienne Spatio-Temporelle
   ├── Calcul du Bird Health Score & Graphiques FL Chart
   └── Floutage GPS automatique sur espèces menacées

📅 JOUR 6 : ASSURANCE QUALITÉ & TEST STRESS
   ├── Tests "Zone Blanche" Mode Avion
   ├── Tests de charge Locust sur FastAPI (500 users simules)
   └── Correction finale de tous les bugs d'affichage

📅 JOUR 7 : DÉMONSTRATION & PITCH
   ├── Scénarisation de la démonstration orale (5 à 7 min)
   ├── Enregistrement de la Vidéo de Secours (Fallback Video)
   └── Présentation devant le Jury !
🎯 Instructions de Génération pour Antigravity :
Exécute la création de l'arborescence et génère le code de chaque composant selon le plan établi ci-dessus, en commençant par les schémas PostgreSQL/PostGIS, les modèles Pydantic FastAPI et le pipeline IA YOLO + ByteTrack.
"""

Ecriture du fichier Markdown
file_name = "BirdSense_AI_Master_Prompt_Antigravity.md"
with open(file_name, "w", encoding="utf-8") as f:
f.write(md_content)

print(f"File {file_name} generated successfully!")
print(f"Total size: {len(md_content)} characters.")


```text?code_stdout&code_event_index=1
Traceback (most recent call last):
  File "<xbox-string>", line 319
    Endpoint synchrone pour détecter, compter et identifier les oiseaux dans une image.
IndentationError: unexpected indent

🛠️ Résumé de la Stack Technique
Mobile Frontend : Flutter 3.x (Dart), Riverpod (State Management), Dio (HTTP Client), Drift/SQLite (Local DB), Mapbox Maps SDK.

Backend Service : FastAPI (Python 3.12), SQLAlchemy 2.0 (Async ORM), Alembic (Migrations), Pydantic v2, PyJWT.

Base de Données : PostgreSQL 16 + Extension PostGIS (Hébergement Supabase).

Computer Vision & IA : Ultralytics YOLOv8n/YOLO11n, ByteTrack (Suivi Multi-Objets), PyTorch, OpenCV, Albumentations.

Traitement Asynchrone : Celery + Redis (Traitement des flux vidéo longs).

Stockage Médias : Cloudinary / Google Cloud Storage.

Services Web API Externe : eBird API & GBIF (Priors biogéographiques et enregistrements sonores).

3. RÉPARTITION DES RÔLES (ÉQUIPE DE 5 PERSONNES)
Rôle	Périmètre	Tâches Majeures
Membre 1 : Lead Mobile UI & Map	UX/UI, Navigation, Cartographie	Design System Material 3, Écrans Auth/Profil/Historique/Fiche Espèce, Integration Mapbox (Clusters, Heatmaps, Tuiles Offline).
Membre 2 : Dev Mobile Hardware & Sync	Caméra Temps Réel & Persistence	Stream Caméra 30 FPS, Bounding Boxes Canvas Overlays, Base SQLite Drift chiffrée, Moteur de Synchronisation arrière-plan (WorkManager).
Membre 3 : Backend & Infra Lead	API REST FastAPI, PostGIS, Cloud	Endpoints Async FastAPI, Schemas PostgreSQL/PostGIS, Migration Alembic, Floutage GPS (Fuzzing Espèces Menacées), Celery/Redis.
Membre 4 : Ingénieur IA & CV	Pipeline Détection, Tracking & Prior	Fine-tuning YOLOv8/11 sur Roboflow, Intégration ByteTrack (ID unique vidéo), Classifieur d'espèce, Algorithme de Fusion Bayésienne Spatio-Temporelle.
Membre 5 : Product Lead, QA & Speaker	Qualité, Dashboard & Presentation	Développeur Dashboard KPIs (FL Chart), Tests de charge (Locust), Tests Offline Mode Avion, Documentation GitHub, Support de Pitch (5-7 min) & Fallback Video.
4. ARBORESCENCE DU PROJET & ORGANISATION DU CODE
Plaintext
birdsense-ai/
├── birdsense_mobile/              # Application Mobile Flutter
│   ├── android/
│   ├── ios/
│   ├── assets/
│   │   ├── icons/
│   │   ├── images/
│   │   └── tiles/                 # Tuiles cartographiques offline (.mbtiles)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/                  # Thèmes, constantes, exceptions, réseau
│   │   │   ├── network/           # Client Dio, Intercepteurs JWT
│   │   │   ├── theme/             # Material 3 Dark Palette (Canopée, Terre Cuite)
│   │   │   └── utils/
│   │   ├── data/                  # Repositories & Drift SQLite Database
│   │   │   ├── local/             # Schema Drift (tables local_observations, local_items)
│   │   │   └── repositories/      # ObservationRepository, AuthRepository
│   │   └── features/              # Feature-Driven Architecture
│   │       ├── auth/              # Vues Auth, ViewModels
│   │       ├── camera_detection/  # Stream Caméra, Overlays Bounding Box
│   │       ├── observation_map/   # Mapbox SDK integration
│   │       ├── species_catalog/   # Fiches espèces, Chants sonores
│   │       ├── sync_engine/       # WorkManager Background Task Queue
│   │       └── dashboard/         # Graphiques FL Chart & KPIs
│   └── test/
├── birdsense_backend/             # Backend FastAPI (Python)
│   ├── app/
│   │   ├── api/                   # Router Endpoints V1 (/auth, /observations, /species, /map)
│   │   ├── core/                  # Security JWT, Config Settings (Pydantic)
│   │   ├── db/                    # Session SQLAlchemy Async, Base Model, Alembic Migrations
│   │   ├── ai_engine/             # Inférence YOLO, ByteTrack Tracker, Prior Bayésien
│   │   ├── models/                # Schemas Pydantic v2 & Modèles ORM SQLAlchemy
│   │   └── services/              # Storage Cloudinary, Ingestion eBird/GBIF
│   ├── tests/                     # Pytest API & Integration tests
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── requirements.txt
├── devops/                        # Monitoring & CI/CD
│   ├── github-actions/
│   └── locustfile.py              # Tests de charge backend
└── docs/                          # Presentation & Pitch Deck
    ├── architecture.png
    └── pitch_deck.pdf
5. SPÉCIFICATIONS DE LA BASE DE DONNÉES
A. Base Backend PostgreSQL 16 + PostGIS (Production)
SQL
-- Activer l'extension géospatiale PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table des Utilisateurs
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'OBSERVER',
    expertise_level VARCHAR(20) DEFAULT 'AMATEUR',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des Espèces Aviaires
CREATE TABLE species (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scientific_name VARCHAR(150) UNIQUE NOT NULL,
    common_name_fr VARCHAR(150) NOT NULL,
    common_name_en VARCHAR(150) NOT NULL,
    family VARCHAR(100),
    iucn_category VARCHAR(10) DEFAULT 'LC', -- LC, NT, VU, EN, CR
    audio_call_url TEXT,
    description TEXT
);

-- Table des Observations Géolocalisées
CREATE TABLE observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    geom GEOMETRY(Point, 4326) NOT NULL, -- Format WGS84
    altitude FLOAT,
    observed_at TIMESTAMP WITH TIME ZONE NOT NULL,
    total_count INT NOT NULL DEFAULT 1,
    image_url TEXT,
    video_url TEXT,
    is_fuzzy_protected BOOLEAN DEFAULT FALSE, -- Vrai si espèce protégée (floutage 5km)
    sync_status VARCHAR(20) DEFAULT 'SYNCED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des Détections d'Individus (Items de chaque Observation)
CREATE TABLE observation_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    observation_id UUID NOT NULL REFERENCES observations(id) ON DELETE CASCADE,
    species_id UUID REFERENCES species(id),
    tracking_id INT, -- ID unique généré par ByteTrack sur vidéo
    confidence_score FLOAT NOT NULL,
    bbox_x_min FLOAT NOT NULL,
    bbox_y_min FLOAT NOT NULL,
    bbox_x_max FLOAT NOT NULL,
    bbox_y_max FLOAT NOT NULL
);

-- Indexation Spatiale GiST et Temporelle
CREATE INDEX idx_obs_geom ON observations USING GIST (geom);
CREATE INDEX idx_obs_date ON observations (observed_at);
CREATE INDEX idx_species_name ON species (scientific_name);
B. Base Locale Mobile SQLite Drift (Offline-First)
Dart
// Définition Drift (Dart)
import 'package:drift/drift.dart';

class LocalObservations extends Table {
  TextColumn get id => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get observedAt => dateTime()();
  IntColumn get totalCount => integer().withDefault(const Constant(1))();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))(); // PENDING, SYNCED, ERROR

  @override
  Set<Column> get primaryKey => {id};
}

class LocalObservationItems extends Table {
  TextColumn get id => text()();
  TextColumn get observationId => references(LocalObservations, #id)();
  IntColumn get trackingId => integer().nullable()();
  TextColumn get speciesName => text()();
  RealColumn get confidence => real()();
  RealColumn get bboxXMin => real()();
  RealColumn get bboxYMin => real()();
  RealColumn get bboxXMax => real()();
  RealColumn get bboxYMax => real()();

  @override
  Set<Column> get primaryKey => {id};
}
6. BACKEND FASTAPI & SPÉCIFICATIONS DES APIS REST
Modèles Pydantic v2 (Python)
Python
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import List, Optional
from uuid import UUID

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class BoundingBox(BaseModel):
    x_min: float
    y_min: float
    x_max: float
    y_max: float

class DetectedBirdItem(BaseModel):
    tracking_id: Optional[int] = None
    species_scientific_name: str
    confidence: float
    bounding_box: BoundingBox

class ObservationCreateDTO(BaseModel):
    local_id: str
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    altitude: Optional[float] = None
    observed_at: datetime
    detected_birds: List[DetectedBirdItem]
    media_hash: str

class ObservationResponseDTO(BaseModel):
    id: UUID
    user_id: UUID
    latitude: float
    longitude: float
    total_count: int
    observed_at: datetime
    image_url: Optional[str]
    is_fuzzy_protected: bool
    items: List[DetectedBirdItem]
Router FastAPI (/api/v1/observations)
Python
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

router = APIRouter(prefix="/api/v1/observations", tags=["Observations"])

@router.post("/detect", response_model=List[DetectedBirdItem])
async def detect_birds_in_image(
    file: UploadFile = File(...),
    latitude: float = 0.0,
    longitude: float = 0.0
):
    # Endpoint synchrone pour détecter, compter et identifier les oiseaux dans une image.
    # Invoque YOLO + ByteTrack + Prior Bayésien.
    image_bytes = await file.read()
    results = await ai_pipeline.process_image(image_bytes, lat=latitude, lng=longitude)
    return results

@router.post("/sync", status_code=status.HTTP_207_MULTI_STATUS)
async def sync_offline_observations(
    observations: List[ObservationCreateDTO],
    db: AsyncSession = Depends(get_async_db)
):
    # Ingestion par lots (Batch Ingestion) pour synchroniser les observations stockées hors-ligne.
    sync_results = []
    for obs in observations:
        res = await save_observation_to_db(db, obs)
        sync_results.append(res)
    return {"synced_count": len(sync_results), "details": sync_results}
7. MOTEUR IA, COMPUTER VISION & TRACKING BYTETRACK
A. Détection Visuelle avec YOLOv8n / YOLO11n
Le modèle de détection s'appuie sur Ultralytics YOLO pré-entraîné sur le dataset COCO (classe bird), affiné via Transfer Learning sur le dataset personnalisé Roboflow (comprenant les espèces locales et contextes de vol dense).

B. Suivi Multi-Objets Vidéo avec ByteTrack
Pour éliminer les erreurs de double comptage dans les séquences vidéo, l'algorithme ByteTrack associe un identifiant unique persistent à chaque trajectoire d'oiseau.

Python
# Pipeline Python de traitement vidéo avec YOLO + ByteTrack
import cv2
import numpy as np
from ultralytics import YOLO
from byte_tracker import BYTETracker

model = YOLO("yolov11n_birds.pt")
tracker = BYTETracker(frame_rate=30)

def process_video_frame(frame, frame_id):
    results = model(frame)[0]
    detections = []
    for box in results.boxes:
        x1, y1, x2, y2 = box.xyxy[0].tolist()
        score = box.conf[0].item()
        detections.append([x1, y1, x2, y2, score])
    
    online_targets = tracker.update(np.array(detections), img_info=frame.shape, img_size=frame.shape)
    
    unique_birds = []
    for t in online_targets:
        tlwh = t.tlwh
        tid = t.track_id
        unique_birds.append({"track_id": tid, "bbox": tlwh})
        
    return unique_birds
C. Fusion Bayésienne Spatio-Temporelle Simplifiée
Pondération des résultats visuels par les priors de distribution géographique historiques eBird/GBIF :

Score Final(S 
k
​
 )=Score Visuel(S 
k
​
 )×Facteur Pr 
e
ˊ
 sence R 
e
ˊ
 gionale(S 
k
​
 ,L,T)
Python
# Pseudo-code de la Fusion Bayésienne Simplifiée
SPECIES_REGIONAL_PRIORS = {
    "SENEGAL": {
        "Pelecanus onocrotalus": 0.95, # Pélican blanc (très fréquent)
        "Spheniscus demersus": 0.01    # Manchot du Cap (quasi impossible)
    }
}

def apply_bayesian_prior(visual_scores: dict, country_code: str = "SENEGAL") -> dict:
    adjusted_scores = {}
    priors = SPECIES_REGIONAL_PRIORS.get(country_code, {})
    
    for species, visual_conf in visual_scores.items():
        prior_weight = priors.get(species, 0.5)
        final_score = visual_conf * prior_weight
        adjusted_scores[species] = final_score
        
    total = sum(adjusted_scores.values())
    return {k: v / total for k, v in adjusted_scores.items()}
8. APPLICATION MOBILE FLUTTER
A. Design System & Palette (Material 3 Dark Mode)
Primary Color (Vert Canopée) : #1E3A2B

Secondary Color (Terre Cuite) : #E07A5F

Accent Color (Jaune Ambré) : #F4A261

Background Color (Noir Profond) : #121513

Surface Translucide (Glassmorphism) : #1A211D avec BackdropFilter (Blur 10px).

B. Custom Painter pour Overlays Bounding Box (30 FPS)
Dart
import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> detections;
  final Size previewSize;

  BoundingBoxPainter(this.detections, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / previewSize.width;
    final double scaleY = size.height / previewSize.height;

    final paint = Paint()
      ..color = const Color(0xFFF4A261)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textStyle = const TextStyle(
      color: Colors.white,
      backgroundColor: Color(0xFF1E3A2B),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    for (var det in detections) {
      final rect = Rect.fromLTRB(
        det.xMin * scaleX,
        det.yMin * scaleY,
        det.xMax * scaleX,
        det.yMax * scaleY,
      );
      canvas.drawRect(rect, paint);

      final textSpan = TextSpan(
        text: ' ${det.speciesName} (${(det.confidence * 100).toStringAsFixed(0)}%) ',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top - 18));
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) => true;
}
9. MOTEUR OFFLINE-FIRST & SYNCHRONISATION RÉSILIENTE
Capture Hors-Ligne : Lorsque l'utilisateur prend une photo en zone blanche sans réseau, la géolocalisation GPS est lue depuis le capteur mobile.

Persistence SQLite : L'observation est enregistrée immédiatement dans la table locale LocalObservations avec l'état syncStatus = 'PENDING'.

Queue Arrière-Plan : Un job WorkManager écoute les changements d'état réseau de l'appareil (ConnectivityResult.mobile ou ConnectivityResult.wifi).

Envoi par Batch : Dès le rétablissement du réseau, la file d'attente expédie les paquets vers /api/v1/observations/sync. L'état passe à 'SYNCED'.

10. DASHBOARD, STATISTIQUES & BIRD HEALTH SCORE
Indice Écologique : Bird Health Score
Calcul de la richesse écologique d'une zone cartographique selon la formule de Shannon-Wiener simplifiée :

Bird Health Score= 
i=1
∑
S
​
 −(p 
i
​
 log 
2
​
 p 
i
​
 )
Où p 
i
​
  est la proportion d'individus de l'espèce i par rapport au nombre total d'oiseaux observés dans le rayon d'analyse.

Graphiques FL Chart (Mobile)
Bar Chart : Volume d'observations par jour/semaine.

Pie Chart : Proportion des espèces identifiées dans la zone (ex. 45% Héron, 30% Mouette, 25% Tourterelle).

11. PLAN D'EXÉCUTION HACKATHON (7 JOURS) & SCÉNARISATION DÉMO
Plaintext
📅 JOUR 1-2 : SOCLE & INFRASTRUCTURE
   ├── Initialisation Dépôt GitHub & CI/CD
   ├── Déploiement Supabase (PostgreSQL + PostGIS)
   ├── Fast API Endpoints (/auth, /detect) & Fine-Tuning YOLO Roboflow
   └── Flutter App Navigation & Material 3 Theme setup

📅 JOUR 3-4 : COEUR IA, CAMERA STREAM & CARTOGRAPHIE
   ├── Pipeline YOLO + ByteTrack (Comptage vidéo sans doublons)
   ├── Overlays Bounding Box dynamique sur Flutter Camera Stream
   ├── Integration Mapbox Mobile SDK (Clusters & Heatmaps)
   └── Synchronisation SQLite Drift Local DB

📅 JOUR 5 : INNOVATIONS & DASHBOARD
   ├── Intégration de la Fusion Bayésienne Spatio-Temporelle
   ├── Calcul du Bird Health Score & Graphiques FL Chart
   └── Floutage GPS automatique sur espèces menacées

📅 JOUR 6 : ASSURANCE QUALITÉ & TEST STRESS
   ├── Tests "Zone Blanche" Mode Avion
   ├── Tests de charge Locust sur FastAPI (500 users simules)
   └── Correction finale de tous les bugs d'affichage

📅 JOUR 7 : DÉMONSTRATION & PITCH
   ├── Scénarisation de la démonstration orale (5 à 7 min)
   ├── Enregistrement de la Vidéo de Secours (Fallback Video)
   └── Présentation devant le Jury !
🎯 Instructions de Génération pour Antigravity :
Exécute la création de l'arborescence et génère le code de chaque composant selon le plan établi ci-dessus, en commençant par les schémas PostgreSQL/PostGIS, les modèles Pydantic FastAPI et le pipeline IA YOLO + ByteTrack.
"""

file_name = "BirdSense_AI_Master_Prompt_Antigravity.md"
with open(file_name, "w", encoding="utf-8") as f:
f.write(md_content)

print(f"File {file_name} generated successfully!")
print(f"Total size: {len(md_content)} characters.")


```text?code_stdout&code_event_index=2
File BirdSense_AI_Master_Prompt_Antigravity.md generated successfully!
Total size: 22560 characters.

Your Markdown file is ready
Icône MD
BirdSense_AI_Master_Prompt_Antigravity
 MD 
Ouvert

🚀 Synthèse Finale & Prompt Maître de Développement pour Antigravity
J'ai généré le prompt maître complet dans le fichier Markdown BirdSense_AI_Master_Prompt_Antigravity.md.  
MD
+ 1

Ce document est conçu comme un cahier des charges exécutable et prêt à l'emploi pour alimenter un agent IA de génération de code (Antigravity, Cursor, Copilot Workspace, Windsurf, etc.). Il intègre l'ensemble des recherches des 4 membres (Alioune, Massogui, Lansana, Pathé), la synthèse arbitrée par Aliou, ainsi que la répartition stratégique sur 5 personnes.  
MD
+ 2

📋 Résumé du Contenu du Fichier .md
Vision Produit & Grille de Notation du Jury (100 Points) :

Décryptage des 7 critères d'évaluation (Stabilité 20, IA 20, Comptage 20, UX/UI 10, Innovation 10, Présentation 10, Impact 10).  
MD
+ 1

Architecture Technique Maître & Stack Retenue :

Frontend Mobile : Flutter 3.x (Engine Impeller, Theme Material 3 Dark).  
MD
+ 1

Backend Service : FastAPI (Python 3.12 async, Pydantic v2, SQLAlchemy 2.0).  
MD
+ 1

Database & Spatial : PostgreSQL 16 + PostGIS (Hébergé sur Supabase).  
MD
+ 1

Vision & IA : Ultralytics YOLOv8n/v11n (Détection), ByteTrack (Suivi vidéo sans doublon), EfficientNet-V2 / BioCLIP-2 (Classification) et Moteur de Fusion Bayésienne Spatio-Temporelle (eBird/GBIF).  
MD
+ 1

Offline & Media : Base locale SQLite/Drift chiffrée + Cloudinary.  
MD
+ 1

Répartition des Rôles sur 5 Personnes :

Découpage strict des tâches entre les 2 dev Mobile, le dev Backend, l'ingénieur IA et le Lead Produit/QA/Pitch.  
MD

Spécifications SQL & Datastores :

Schémas d'architecture relationnelle PostgreSQL/PostGIS (avec indexation GiST et floutage GPS 5 km pour espèces menacées) et schémas Drift (Dart) pour le mode déconnecté.  
MD
+ 1

APIs REST FastAPI & Data Transfer Objects (DTOs) :

Endpoints /api/v1/auth, /api/v1/observations/detect (synchrone), /api/v1/observations/sync (batch offline) et /api/v1/observations/map.  
MD

Pipeline Computer Vision (Code Executable) :

Script de traitement des flux vidéo combinant YOLO et ByteTrack pour attribuer des IDs uniques.  
MD

Script de ré-étalonnage des probabilités visuelles par la Fusion Bayésienne Spatio-Temporelle.  
MD

Code Mobile Flutter (UI & Overlays) :

Implémentation du CustomPainter pour dessiner dynamiquement les bounding boxes et identifiants à 30–60 FPS sur le flux caméra.  
MD

Statistiques & Bird Health Score :

Formule d'indice d'écologie (Shannon-Wiener simplifiée) et configuration des graphiques FL Chart.  
MD

Feuille de Route Hackathon 7 Jours & Scénarisation de Démo (5 à 7 min) :

Plan de sprint jour par jour et protocole de secours (fallback video) pour la présentation orale.  
MD

💡 Comment utiliser ce fichier avec Antigravity / AI Agent ?
Téléchargez le fichier BirdSense_AI_Master_Prompt_Antigravity.md.

Copiez l'intégralité du contenu du fichier dans votre assistant IA de génération de code.

Lancez la première commande :

"Génère l'arborescence du projet ainsi que la configuration initiale du backend FastAPI et de la base PostgreSQL/PostGIS selon le schéma défini au Chapitre 5 et 6."




Gemini est une IA et peut se tromper.

# 🚀 PROMPT MAÎTRE DE DÉVELOPPEMENT — BIRDSENSE AI
## Instruction Globale de Génération de Code pour Antigravity (AI Coding Assistant)

---

> **DESTINATAIRE :** Antigravity / AI Lead Developer  
> **PROJET :** BirdSense AI — Plateforme Intelligente de Détection, Comptage et Suivi de la Biodiversité Aviaire  
> **CONTEXTE :** Hackathon BirdSense AI (Équipe de 5 personnes, Sprint de 7 jours)  
> **OBJECTIF DU PROMPT :** Fournir les spécifications techniques exhaustives, l'architecture logicielle, les schémas de données, le pipeline IA et la feuille de route pas à pas permettant à l'agent IA de générer le code source complet, prêt pour la production.

---

## 📑 TABLE DES MATIÈRES

1. [Vision du Produit & Grille d'Évaluation des Juges](#1-vision-du-produit--grille-dévaluation-des-juges)
2. [Architecture Technique Maître & Stack Choisie](#2-architecture-technique-maître--stack-choisie)
3. [Répartition des Rôles (Équipe de 5 Personnes)](#3-répartition-des-rôles-équipe-de-5-personnes)
4. [Arborescence du Projet & Organisation du Code](#4-arborescence-du-projet--organisation-du-code)
5. [Spécifications de la Base de Données (PostgreSQL/PostGIS & SQLite Drift)](#5-spécifications-de-la-base-de-données)
6. [Backend FastAPI & Spécifications des APIs REST](#6-backend-fastapi--spécifications-des-apis-rest)
7. [Moteur IA, Computer Vision & Tracking ByteTrack](#7-moteur-ia-computer-vision--tracking-bytetrack)
8. [Application Mobile Flutter (UI/UX, Caméra & Mapbox)](#8-application-mobile-flutter)
9. [Moteur Offline-First & Synchronisation Résiliente](#9-moteur-offline-first--synchronisation-résiliente)
10. [Dashboard, Statistiques & Bird Health Score](#10-dashboard-statistiques--bird-health-score)
11. [Plan d'Exécution Hackathon (7 Jours) & Scénarisation Démo](#11-plan-dexécution-hackathon-7-jours--scénarisation-démo)

---

## 1. VISION DU PRODUIT & GRILLE D'ÉVALUATION DES JUGES

BirdSense AI n'est pas une simple application académique de reconnaissance d'images. C'est une **plateforme complète de suivi scientifique de la biodiversité**, conçue pour les chercheurs, ONG environnementales, parcs nationaux, réserves naturelles et scientifiques citoyens.

### 🎯 Problématique Métier
Le recensement traditionnel des oiseaux en milieu sauvage est manuel, coûteux, sujet aux erreurs humaines, et peine à comptabiliser les groupes denses ou en mouvement. BirdSense AI automatise la détection, le comptage sans doublon et l'identification fine grâce à l'intelligence artificielle sur flux photo et vidéo.

### 🏆 Grille d'Évaluation du Jury (100 Points)
- **Fonctionnement & Stabilité (20 pts) :** Application zéro crash, réactive, sans écran vide ni bug bloquant.
- **Intelligence Artificielle (20 pts) :** Pipeline de traitement complet (Détection → Tracking → Classification → Résultat).
- **Comptage Avancé (20 pts) :** Détection multi-instances, suivi temporel anti-doublons (ByteTrack) en groupe dense.
- **UX / UI Design (10 pts) :** Interface moderne (Material 3 Dark Mode), animations fluides, composants translucides.
- **Innovation (10 pts) :** Fusion Bayésienne Spatio-Temporelle, Indice d'Ecologie *Bird Health Score*, Mode Hors-Ligne.
- **Présentation & Démo (10 pts) :** Démo en direct rythmée (5–7 min) étayée par un scénario de secours (*fallback video*).
- **Impact & Pertinence (10 pts) :** Utilité écologique réelle pour les acteurs de la biodiversité.

---

## 2. ARCHITECTURE TECHNIQUE MAÎTRE & STACK CHOISIE

Une architecture hybride pragmatique alliant la puissance du traitement asynchrone FastAPI, la fluidité graphique de Flutter 3.x, la robustesse géospatiale de PostGIS et la précision du suivi vidéo ByteTrack.

```text
┌─────────────────────────────────────────────────────────────────────────┐
│                       FLUTTER MOBILE CLIENT (3.x)                       │
│  - Impeller Engine / Material 3 Dark Theme / Mapbox Mobile SDK          │
│  - Camera Stream (30 FPS) Overlays (CustomPainter)                      │
│  - Local SQLite DB (Drift + SQLCipher) for Offline-First Data           │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                         HTTP / REST APIs (JSON + Files)
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                       FASTAPI BACKEND (Python 3.12)                     │
│  - AsyncIO / Pydantic v2 / OAuth2 JWT Auth                              │
│  - Storage: Cloudinary / Google Cloud Storage                           │
│  - Asynchronous Task Worker: Celery + Redis (Video Processing)          │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
            ┌───────────────────────┴───────────────────────┐
            ▼                                               ▼
┌───────────────────────────────┐               ┌─────────────────────────┐
│    DATABASE & GEOSPATIAL      │               │     PIPELINE IA & CV    │
│  PostgreSQL 16 + PostGIS      │               │  - YOLOv8n / YOLO11n    │
│  Spatial Indexing (GiST)      │               │  - ByteTrack (MOT)      │
│  Supabase Managed Instance    │               │  - EfficientNet-V2 /    │
│                               │               │    BioCLIP-2 Classifier │
│                               │               │  - Bayesian Spatial     │
│                               │               │    Prior Engine         │
└───────────────────────────────┘               └─────────────────────────┘
```

### 🛠️ Résumé de la Stack Technique
- **Mobile Frontend :** Flutter 3.x (Dart), Riverpod (State Management), Dio (HTTP Client), Drift/SQLite (Local DB), Mapbox Maps SDK.
- **Backend Service :** FastAPI (Python 3.12), SQLAlchemy 2.0 (Async ORM), Alembic (Migrations), Pydantic v2, PyJWT.
- **Base de Données :** PostgreSQL 16 + Extension PostGIS (Hébergement Supabase).
- **Computer Vision & IA :** Ultralytics YOLOv8n/YOLO11n, ByteTrack (Suivi Multi-Objets), PyTorch, OpenCV, Albumentations.
- **Traitement Asynchrone :** Celery + Redis (Traitement des flux vidéo longs).
- **Stockage Médias :** Cloudinary / Google Cloud Storage.
- **Services Web API Externe :** eBird API & GBIF (Priors biogéographiques et enregistrements sonores).

---

## 3. RÉPARTITION DES RÔLES (ÉQUIPE DE 5 PERSONNES)

| Rôle | Périmètre | Tâches Majeures |
| :--- | :--- | :--- |
| **Membre 1 : Lead Mobile UI & Map** | UX/UI, Navigation, Cartographie | Design System Material 3, Écrans Auth/Profil/Historique/Fiche Espèce, Integration Mapbox (Clusters, Heatmaps, Tuiles Offline). |
| **Membre 2 : Dev Mobile Hardware & Sync** | Caméra Temps Réel & Persistence | Stream Caméra 30 FPS, Bounding Boxes Canvas Overlays, Base SQLite Drift chiffrée, Moteur de Synchronisation arrière-plan (`WorkManager`). |
| **Membre 3 : Backend & Infra Lead** | API REST FastAPI, PostGIS, Cloud | Endpoints Async FastAPI, Schemas PostgreSQL/PostGIS, Migration Alembic, Floutage GPS (Fuzzing Espèces Menacées), Celery/Redis. |
| **Membre 4 : Ingénieur IA & CV** | Pipeline Détection, Tracking & Prior | Fine-tuning YOLOv8/11 sur Roboflow, Intégration ByteTrack (ID unique vidéo), Classifieur d'espèce, Algorithme de Fusion Bayésienne Spatio-Temporelle. |
| **Membre 5 : Product Lead, QA & Speaker** | Qualité, Dashboard & Presentation | Développeur Dashboard KPIs (FL Chart), Tests de charge (Locust), Tests Offline Mode Avion, Documentation GitHub, Support de Pitch (5-7 min) & Fallback Video. |

---

## 4. ARBORESCENCE DU PROJET & ORGANISATION DU CODE

```text
birdsense-ai/
├── birdsense_mobile/              # Application Mobile Flutter
│   ├── android/
│   ├── ios/
│   ├── assets/
│   │   ├── icons/
│   │   ├── images/
│   │   └── tiles/                 # Tuiles cartographiques offline (.mbtiles)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/                  # Thèmes, constantes, exceptions, réseau
│   │   │   ├── network/           # Client Dio, Intercepteurs JWT
│   │   │   ├── theme/             # Material 3 Dark Palette (Canopée, Terre Cuite)
│   │   │   └── utils/
│   │   ├── data/                  # Repositories & Drift SQLite Database
│   │   │   ├── local/             # Schema Drift (tables local_observations, local_items)
│   │   │   └── repositories/      # ObservationRepository, AuthRepository
│   │   └── features/              # Feature-Driven Architecture
│   │       ├── auth/              # Vues Auth, ViewModels
│   │       ├── camera_detection/  # Stream Caméra, Overlays Bounding Box
│   │       ├── observation_map/   # Mapbox SDK integration
│   │       ├── species_catalog/   # Fiches espèces, Chants sonores
│   │       ├── sync_engine/       # WorkManager Background Task Queue
│   │       └── dashboard/         # Graphiques FL Chart & KPIs
│   └── test/
├── birdsense_backend/             # Backend FastAPI (Python)
│   ├── app/
│   │   ├── api/                   # Router Endpoints V1 (/auth, /observations, /species, /map)
│   │   ├── core/                  # Security JWT, Config Settings (Pydantic)
│   │   ├── db/                    # Session SQLAlchemy Async, Base Model, Alembic Migrations
│   │   ├── ai_engine/             # Inférence YOLO, ByteTrack Tracker, Prior Bayésien
│   │   ├── models/                # Schemas Pydantic v2 & Modèles ORM SQLAlchemy
│   │   └── services/              # Storage Cloudinary, Ingestion eBird/GBIF
│   ├── tests/                     # Pytest API & Integration tests
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── requirements.txt
├── devops/                        # Monitoring & CI/CD
│   ├── github-actions/
│   └── locustfile.py              # Tests de charge backend
└── docs/                          # Presentation & Pitch Deck
    ├── architecture.png
    └── pitch_deck.pdf
```

---

## 5. SPÉCIFICATIONS DE LA BASE DE DONNÉES

### A. Base Backend PostgreSQL 16 + PostGIS (Production)

```sql
-- Activer l'extension géospatiale PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- Table des Utilisateurs
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(20) DEFAULT 'OBSERVER',
    expertise_level VARCHAR(20) DEFAULT 'AMATEUR',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des Espèces Aviaires
CREATE TABLE species (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    scientific_name VARCHAR(150) UNIQUE NOT NULL,
    common_name_fr VARCHAR(150) NOT NULL,
    common_name_en VARCHAR(150) NOT NULL,
    family VARCHAR(100),
    iucn_category VARCHAR(10) DEFAULT 'LC', -- LC, NT, VU, EN, CR
    audio_call_url TEXT,
    description TEXT
);

-- Table des Observations Géolocalisées
CREATE TABLE observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    geom GEOMETRY(Point, 4326) NOT NULL, -- Format WGS84
    altitude FLOAT,
    observed_at TIMESTAMP WITH TIME ZONE NOT NULL,
    total_count INT NOT NULL DEFAULT 1,
    image_url TEXT,
    video_url TEXT,
    is_fuzzy_protected BOOLEAN DEFAULT FALSE, -- Vrai si espèce protégée (floutage 5km)
    sync_status VARCHAR(20) DEFAULT 'SYNCED',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Table des Détections d'Individus (Items de chaque Observation)
CREATE TABLE observation_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    observation_id UUID NOT NULL REFERENCES observations(id) ON DELETE CASCADE,
    species_id UUID REFERENCES species(id),
    tracking_id INT, -- ID unique généré par ByteTrack sur vidéo
    confidence_score FLOAT NOT NULL,
    bbox_x_min FLOAT NOT NULL,
    bbox_y_min FLOAT NOT NULL,
    bbox_x_max FLOAT NOT NULL,
    bbox_y_max FLOAT NOT NULL
);

-- Indexation Spatiale GiST et Temporelle
CREATE INDEX idx_obs_geom ON observations USING GIST (geom);
CREATE INDEX idx_obs_date ON observations (observed_at);
CREATE INDEX idx_species_name ON species (scientific_name);
```

### B. Base Locale Mobile SQLite Drift (Offline-First)

```dart
// Définition Drift (Dart)
import 'package:drift/drift.dart';

class LocalObservations extends Table {
  TextColumn get id => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get observedAt => dateTime()();
  IntColumn get totalCount => integer().withDefault(const Constant(1))();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))(); // PENDING, SYNCED, ERROR

  @override
  Set<Column> get primaryKey => {id};
}

class LocalObservationItems extends Table {
  TextColumn get id => text()();
  TextColumn get observationId => references(LocalObservations, #id)();
  IntColumn get trackingId => integer().nullable()();
  TextColumn get speciesName => text()();
  RealColumn get confidence => real()();
  RealColumn get bboxXMin => real()();
  RealColumn get bboxYMin => real()();
  RealColumn get bboxXMax => real()();
  RealColumn get bboxYMax => real()();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 6. BACKEND FASTAPI & SPÉCIFICATIONS DES APIS REST

### Modèles Pydantic v2 (Python)

```python
from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import List, Optional
from uuid import UUID

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class BoundingBox(BaseModel):
    x_min: float
    y_min: float
    x_max: float
    y_max: float

class DetectedBirdItem(BaseModel):
    tracking_id: Optional[int] = None
    species_scientific_name: str
    confidence: float
    bounding_box: BoundingBox

class ObservationCreateDTO(BaseModel):
    local_id: str
    latitude: float = Field(..., ge=-90, le=90)
    longitude: float = Field(..., ge=-180, le=180)
    altitude: Optional[float] = None
    observed_at: datetime
    detected_birds: List[DetectedBirdItem]
    media_hash: str

class ObservationResponseDTO(BaseModel):
    id: UUID
    user_id: UUID
    latitude: float
    longitude: float
    total_count: int
    observed_at: datetime
    image_url: Optional[str]
    is_fuzzy_protected: bool
    items: List[DetectedBirdItem]
```

### Router FastAPI (`/api/v1/observations`)

```python
from fastapi import APIRouter, Depends, UploadFile, File, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

router = APIRouter(prefix="/api/v1/observations", tags=["Observations"])

@router.post("/detect", response_model=List[DetectedBirdItem])
async def detect_birds_in_image(
    file: UploadFile = File(...),
    latitude: float = 0.0,
    longitude: float = 0.0
):
    # Endpoint synchrone pour détecter, compter et identifier les oiseaux dans une image.
    # Invoque YOLO + ByteTrack + Prior Bayésien.
    image_bytes = await file.read()
    results = await ai_pipeline.process_image(image_bytes, lat=latitude, lng=longitude)
    return results

@router.post("/sync", status_code=status.HTTP_207_MULTI_STATUS)
async def sync_offline_observations(
    observations: List[ObservationCreateDTO],
    db: AsyncSession = Depends(get_async_db)
):
    # Ingestion par lots (Batch Ingestion) pour synchroniser les observations stockées hors-ligne.
    sync_results = []
    for obs in observations:
        res = await save_observation_to_db(db, obs)
        sync_results.append(res)
    return {"synced_count": len(sync_results), "details": sync_results}
```

---

## 7. MOTEUR IA, COMPUTER VISION & TRACKING BYTETRACK

### A. Détection Visuelle avec YOLOv8n / YOLO11n
Le modèle de détection s'appuie sur Ultralytics YOLO pré-entraîné sur le dataset COCO (classe `bird`), affiné via Transfer Learning sur le dataset personnalisé Roboflow (comprenant les espèces locales et contextes de vol dense).

### B. Suivi Multi-Objets Vidéo avec ByteTrack
Pour éliminer les erreurs de double comptage dans les séquences vidéo, l'algorithme **ByteTrack** associe un identifiant unique persistent à chaque trajectoire d'oiseau.

```python
# Pipeline Python de traitement vidéo avec YOLO + ByteTrack
import cv2
import numpy as np
from ultralytics import YOLO
from byte_tracker import BYTETracker

model = YOLO("yolov11n_birds.pt")
tracker = BYTETracker(frame_rate=30)

def process_video_frame(frame, frame_id):
    results = model(frame)[0]
    detections = []
    for box in results.boxes:
        x1, y1, x2, y2 = box.xyxy[0].tolist()
        score = box.conf[0].item()
        detections.append([x1, y1, x2, y2, score])
    
    online_targets = tracker.update(np.array(detections), img_info=frame.shape, img_size=frame.shape)
    
    unique_birds = []
    for t in online_targets:
        tlwh = t.tlwh
        tid = t.track_id
        unique_birds.append({"track_id": tid, "bbox": tlwh})
        
    return unique_birds
```

### C. Fusion Bayésienne Spatio-Temporelle Simplifiée
Pondération des résultats visuels par les priors de distribution géographique historiques eBird/GBIF :

$$	ext{Score Final}(S_k) = 	ext{Score Visuel}(S_k) 	imes 	ext{Facteur Présence Régionale}(S_k, L, T)$$

```python
# Pseudo-code de la Fusion Bayésienne Simplifiée
SPECIES_REGIONAL_PRIORS = {
    "SENEGAL": {
        "Pelecanus onocrotalus": 0.95, # Pélican blanc (très fréquent)
        "Spheniscus demersus": 0.01    # Manchot du Cap (quasi impossible)
    }
}

def apply_bayesian_prior(visual_scores: dict, country_code: str = "SENEGAL") -> dict:
    adjusted_scores = {}
    priors = SPECIES_REGIONAL_PRIORS.get(country_code, {})
    
    for species, visual_conf in visual_scores.items():
        prior_weight = priors.get(species, 0.5)
        final_score = visual_conf * prior_weight
        adjusted_scores[species] = final_score
        
    total = sum(adjusted_scores.values())
    return {k: v / total for k, v in adjusted_scores.items()}
```

---

## 8. APPLICATION MOBILE FLUTTER

### A. Design System & Palette (Material 3 Dark Mode)
- **Primary Color (Vert Canopée) :** `#1E3A2B`
- **Secondary Color (Terre Cuite) :** `#E07A5F`
- **Accent Color (Jaune Ambré) :** `#F4A261`
- **Background Color (Noir Profond) :** `#121513`
- **Surface Translucide (Glassmorphism) :** `#1A211D` avec `BackdropFilter` (Blur 10px).

### B. Custom Painter pour Overlays Bounding Box (30 FPS)

```dart
import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<dynamic> detections;
  final Size previewSize;

  BoundingBoxPainter(this.detections, this.previewSize);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / previewSize.width;
    final double scaleY = size.height / previewSize.height;

    final paint = Paint()
      ..color = const Color(0xFFF4A261)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textStyle = const TextStyle(
      color: Colors.white,
      backgroundColor: Color(0xFF1E3A2B),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    for (var det in detections) {
      final rect = Rect.fromLTRB(
        det.xMin * scaleX,
        det.yMin * scaleY,
        det.xMax * scaleX,
        det.yMax * scaleY,
      );
      canvas.drawRect(rect, paint);

      final textSpan = TextSpan(
        text: ' ${det.speciesName} (${(det.confidence * 100).toStringAsFixed(0)}%) ',
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rect.left, rect.top - 18));
    }
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) => true;
}
```

---

## 9. MOTEUR OFFLINE-FIRST & SYNCHRONISATION RÉSILIENTE

1. **Capture Hors-Ligne :** Lorsque l'utilisateur prend une photo en zone blanche sans réseau, la géolocalisation GPS est lue depuis le capteur mobile.
2. **Persistence SQLite :** L'observation est enregistrée immédiatement dans la table locale `LocalObservations` avec l'état `syncStatus = 'PENDING'`.
3. **Queue Arrière-Plan :** Un job `WorkManager` écoute les changements d'état réseau de l'appareil (`ConnectivityResult.mobile` ou `ConnectivityResult.wifi`).
4. **Envoi par Batch :** Dès le rétablissement du réseau, la file d'attente expédie les paquets vers `/api/v1/observations/sync`. L'état passe à `'SYNCED'`.

---

## 10. DASHBOARD, STATISTIQUES & BIRD HEALTH SCORE

### Indice Écologique : Bird Health Score
Calcul de la richesse écologique d'une zone cartographique selon la formule de Shannon-Wiener simplifiée :

$$	ext{Bird Health Score} = \sum_{i=1}^{S} - (p_i \log_2 p_i)$$

Où $p_i$ est la proportion d'individus de l'espèce $i$ par rapport au nombre total d'oiseaux observés dans le rayon d'analyse.

### Graphiques FL Chart (Mobile)
- **Bar Chart :** Volume d'observations par jour/semaine.
- **Pie Chart :** Proportion des espèces identifiées dans la zone (ex. $45\%$ Héron, $30\%$ Mouette, $25\%$ Tourterelle).

---

## 11. PLAN D'EXÉCUTION HACKATHON (7 JOURS) & SCÉNARISATION DÉMO

```text
📅 JOUR 1-2 : SOCLE & INFRASTRUCTURE
   ├── Initialisation Dépôt GitHub & CI/CD
   ├── Déploiement Supabase (PostgreSQL + PostGIS)
   ├── Fast API Endpoints (/auth, /detect) & Fine-Tuning YOLO Roboflow
   └── Flutter App Navigation & Material 3 Theme setup

📅 JOUR 3-4 : COEUR IA, CAMERA STREAM & CARTOGRAPHIE
   ├── Pipeline YOLO + ByteTrack (Comptage vidéo sans doublons)
   ├── Overlays Bounding Box dynamique sur Flutter Camera Stream
   ├── Integration Mapbox Mobile SDK (Clusters & Heatmaps)
   └── Synchronisation SQLite Drift Local DB

📅 JOUR 5 : INNOVATIONS & DASHBOARD
   ├── Intégration de la Fusion Bayésienne Spatio-Temporelle
   ├── Calcul du Bird Health Score & Graphiques FL Chart
   └── Floutage GPS automatique sur espèces menacées

📅 JOUR 6 : ASSURANCE QUALITÉ & TEST STRESS
   ├── Tests "Zone Blanche" Mode Avion
   ├── Tests de charge Locust sur FastAPI (500 users simules)
   └── Correction finale de tous les bugs d'affichage

📅 JOUR 7 : DÉMONSTRATION & PITCH
   ├── Scénarisation de la démonstration orale (5 à 7 min)
   ├── Enregistrement de la Vidéo de Secours (Fallback Video)
   └── Présentation devant le Jury !
```

### 🎯 Instructions de Génération pour Antigravity :
> **Exécute la création de l'arborescence et génère le code de chaque composant selon le plan établi ci-dessus, en commençant par les schémas PostgreSQL/PostGIS, les modèles Pydantic FastAPI et le pipeline IA YOLO + ByteTrack.**
BirdSense_AI_Master_Prompt_Antigravity.md
Affichage de BirdSense_AI_Master_Prompt_Antigravity.md.
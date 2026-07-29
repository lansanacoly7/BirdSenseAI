# 📝 Suivi des Travaux — Ibrahima Khalilou Diallo (Membre 4)

**Rôle :** Ingénieur Computer Vision & YOLO  
**Branche Git :** `Kalz`  
**Périmètre Technique :** Fine-Tuning YOLOv8/v11, Suivi Vidéo Multi-Objets (ByteTrack), Pipeline & Service d'Inférence IA FastAPI.

---

## 🎯 Périmètre et Feuille de Route Technique

### 🚀 Tâches MVP

| ID | Tâche | Difficulté | Statut | Description |
| :--- | :--- | :---: | :---: | :--- |
| **T4.1** | **Dataset & Fine-Tuning YOLOv8n/v11n** | `8.5 / 10` | ✅ **Terminé** | Dataset preparer (`src/vision/dataset_prep.py`), validation de structure, génération de `data.yaml` et script automatisé de Fine-Tuning & Export ONNX (`src/vision/train_yolo.py`). |
| **T4.2** | **Pipeline Suivi Vidéo Multi-Objets (ByteTrack)** | `8.5 / 10` | ✅ **Terminé** | Implémentation du tracker ByteTrack (`src/vision/tracker.py`) attribuant un `track_id` unique par trajectoire d'oiseau (élimination du sur-comptage). |
| **T4.3** | **Service d'Inférence IA FastAPI** | `8.5 / 10` | ✅ **Terminé** | Engine d'inférence (`src/vision/detector.py`), API REST FastAPI avec routeur vision (`src/api/vision_router.py`), point d'entrée (`src/main.py`) et endpoints `/health`, `/detect` et `/track`. |

### 🌟 Bonus / Extensions

| Tâche | Difficulté | Statut | Description |
| :--- | :---: | :---: | :--- |
| **Ext 4.1** | **Inférence Locale & Optimisation Modèle** | `9.5 / 10` | ⏳ *À venir* | Inférence locale C++ ONNX via bindings `dart:ffi` ou intégration BioCLIP-2. |

---

## 📅 Journal des Réalisations & Mises à Jour

### [2026-07-29] — Réalisation complète des Tâches T4.1, T4.2 et T4.3 (Core Vision Engine)
- ✅ **Implémentation de T4.1 (Dataset & Training Pipeline) :**
  - Fichier [src/vision/dataset_prep.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/src/vision/dataset_prep.py) : Gestion des dossiers, validation des splits et génération automatique du `data.yaml`.
  - Fichier [src/vision/train_yolo.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/src/vision/train_yolo.py) : Pipeline de Fine-Tuning YOLOv8/v11 avec export des poids au format `.pt` et `.onnx`.
- ✅ **Implémentation de T4.2 (Pipeline ByteTrack Video Tracking) :**
  - Fichier [src/vision/tracker.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/src/vision/tracker.py) : Suivi multi-objets sur séquences vidéo avec association `track_id` unique pour annuler le sur-comptage d'oiseaux.
- ✅ **Implémentation de T4.3 (Moteur & Endpoints REST FastAPI) :**
  - Fichier [src/vision/detector.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/src/vision/detector.py) : Moteur d'inférence d'images avec Bounding Boxes pixels & normalisées [0-1].
  - Fichier [src/api/vision_router.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/src/api/vision_router.py) & [src/main.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/src/main.py) : Endpoints REST `GET /api/v1/vision/health`, `POST /api/v1/vision/detect` et `POST /api/v1/vision/track`.
- ✅ **Tests Automatisés & Validation :**
  - Fichier [tests/test_vision.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/tests/test_vision.py) : 8/8 tests passés avec succès sous `pytest`.

### [2026-07-29] — Initialisation de la branche `Kalz`
- ✅ **Lecture et analyse des 3 documents de cadrage :** `antigravity_behaviour.md`, `repartition_taches_birdsense_ai.md`, `Projet_Hackathon_BirdSense_AI.pdf`.
- ✅ **Création et bascule sur la branche Git `Kalz`**.
- ✅ **Création du fichier de documentation et de suivi des tâches `suivi_taches_ibrahima_diallo.md`**.

---

## 📌 Prochaines Étapes
- [ ] Réalisation de la tâche **Ext 4.1** (Optimisation d'inférence ONNX locale / bindings).

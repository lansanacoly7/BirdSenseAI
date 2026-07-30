# 📝 Suivi des Travaux — Ibrahima Khalilou Diallo (Membre 4)

**Rôle :** Ingénieur Computer Vision & YOLO  
**Branche Git :** `Kalz`  
**Périmètre Technique :** Fine-Tuning YOLOv8/v11, Suivi Vidéo Multi-Objets (ByteTrack), Pipeline & Service d'Inférence IA FastAPI, C++ Native ONNX & Bindings Dart FFI.

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
| **Ext 4.1** | **Inférence Locale C++ ONNX & BioCLIP-2** | `9.5 / 10` | ✅ **Terminé** | Engine d'inférence ONNX autonome (`src/vision/onnx_engine.py`), classifieur BioCLIP-2 (`src/vision/bioclip_engine.py`), Wrapper C++ natif (`native/birdsense_onnx.cpp`) et bindings Flutter Dart FFI (`flutter_bindings/birdsense_ffi.dart`). |

---

## 📅 Journal des Réalisations & Mises à Jour

### [2026-07-30] — Qualification Globale, Preuves (`evidence/`) & Robustesse Environnement
- ✅ **Environnement Virtuel Isolé (`.venv`) & Dépendances :**
  - Validation complète de l'installation et de l'exécution dans un environnement virtuel `.venv` propre avec `requirements.txt` incluant `ultralytics`, `supervision`, `onnxruntime`, `fastapi`, `lapx`, etc.
- ✅ **Dossier de Preuves Concrètes (`evidence/`) :**
  - Fichier [evidence/training_log.txt](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/evidence/training_log.txt) : Rapport d'entraînement YOLO.
  - Fichier [evidence/onnx_export.log](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/evidence/onnx_export.log) : Preuve d'exportation du modèle au format ONNX.
  - Fichier [evidence/test_detection.jpg](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/evidence/test_detection.jpg) : Image de détection d'essai annotée avec Bounding Boxes.
  - Fichier [evidence/tracking_summary.json](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/evidence/tracking_summary.json) : Rapport de suivi vidéo ByteTrack avec comptage unique.
  - Fichiers [evidence/api_detect_response.json](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/evidence/api_detect_response.json) et [evidence/api_track_response.json](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/evidence/api_track_response.json) : Réponses JSON d'API réelles.
- ✅ **Documentation du Module Vision :**
  - Fichier [src/vision/README.md](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/src/vision/README.md) détaillant le rôle de chaque composant et les commandes d'exécution.
- ✅ **Suite de Tests `pytest` :**
  - **9/9 tests passés avec 100% de succès**.

### [2026-07-29] — Réalisation de Ext 4.1 (C++ ONNX Native & Flutter FFI)
- ✅ `onnx_engine.py`, `bioclip_engine.py`, `birdsense_onnx.cpp`, `birdsense_ffi.dart`.

### [2026-07-29] — Réalisation des Tâches MVP (T4.1, T4.2, T4.3)
- ✅ `dataset_prep.py`, `train_yolo.py`, `tracker.py`, `detector.py`, `vision_router.py`, `main.py`.

---

## 📌 Prochaines Étapes
- [x] **Toutes les tâches (T4.1, T4.2, T4.3, Ext 4.1) sont qualifiées, testées et validées avec dossier de preuves !**

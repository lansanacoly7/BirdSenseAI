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

### [2026-07-29] — Réalisation complète de la Tâche Bonus Ext 4.1 (C++ ONNX Native & Flutter FFI)
- ✅ **Moteur d'Inférence ONNX Runtime Autonome :**
  - Fichier [src/vision/onnx_engine.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/src/vision/onnx_engine.py) : Moteur d'inférence ultralight sans dépendance PyTorch pour l'exécution d'ONNX.
- ✅ **Classifieur BioCLIP-2 d'Espèces Rares :**
  - Fichier [src/vision/bioclip_engine.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/src/vision/bioclip_engine.py) : Classification zéro-shot et calcul de similarité pour l'identification fine d'oiseaux menacés.
- ✅ **Wrapper C++ Natif pour Mobile & Cross-Platform :**
  - Fichiers [native/birdsense_onnx.h](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/native/birdsense_onnx.h), [native/birdsense_onnx.cpp](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/native/birdsense_onnx.cpp) et [native/CMakeLists.txt](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/native/CMakeLists.txt) : Export de l'API C natif (`birdsense_init_model`, `birdsense_detect_frame`, `birdsense_free_result`).
- ✅ **Bindings Flutter Dart FFI :**
  - Fichier [flutter_bindings/birdsense_ffi.dart](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/flutter_bindings/birdsense_ffi.dart) : Interface Dart FFI prête pour l'intégration directe dans l'application mobile Flutter par les autres membres de l'équipe (Lansana Coly & El Hadji Massogui Diop).
- ✅ **Validation par Tests Automatisés :**
  - Fichier [tests/test_vision.py](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/tests/test_vision.py) : **9/9 tests passés avec succès (100% vert)**.

### [2026-07-29] — Réalisation complète des Tâches T4.1, T4.2 et T4.3 (Core Vision Engine)
- ✅ **Implémentation de T4.1 (Dataset & Training Pipeline) :** `dataset_prep.py` & `train_yolo.py`.
- ✅ **Implémentation de T4.2 (Pipeline ByteTrack Video Tracking) :** `tracker.py`.
- ✅ **Implémentation de T4.3 (Moteur & Endpoints REST FastAPI) :** `detector.py`, `vision_router.py`, `main.py`.

### [2026-07-29] — Initialisation de la branche `Kalz`
- ✅ **Lecture et analyse des 3 documents de cadrage.**
- ✅ **Création et bascule sur la branche Git `Kalz`**.
- ✅ **Création du fichier de documentation et de suivi des tâches `suivi_taches_ibrahima_diallo.md`**.

---

## 📌 Prochaines Étapes
- [x] **Toutes les tâches MVP (T4.1, T4.2, T4.3) et l'Extension (Ext 4.1) sont 100% terminées et testées !**

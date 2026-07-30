# 📝 Suivi des Travaux — Ibrahima Khalilou Diallo (Membre 4)

**Rôle :** Ingénieur Computer Vision & YOLO  
**Branche Git :** `Kalz`  
**Périmètre Technique :** Fine-Tuning YOLOv8/v11 sur Dataset Réel, Suivi Vidéo Multi-Objets (ByteTrack), Service d'Inférence IA FastAPI, Classifieur Multimodal BioCLIP / OpenCLIP, C++ Native ONNX & Bindings Dart FFI.

---

## 🎯 Périmètre et Feuille de Route Technique (Audit & Corrections Effectuées)

### 🚀 Tâches MVP

| ID | Tâche | Difficulté | Statut | Description |
| :--- | :--- | :---: | :---: | :--- |
| **T4.1** | **Dataset & Fine-Tuning YOLOv8n/v11n** | `8.5 / 10` | ✅ **Terminé** | Ingestion de 13+ vraies images d'oiseaux d'espèces cibles (`src/vision/download_birds.py`), `data.yaml`, entraînement effectif (`src/vision/train_yolo.py`) avec mAP50 jusqu'à 0.995 et export `.onnx`. |
| **T4.2** | **Pipeline Suivi Vidéo Multi-Objets (ByteTrack)** | `8.5 / 10` | ✅ **Terminé** | Implémentation du tracker ByteTrack (`src/vision/tracker.py`) avec attribution de `track_id` uniques par trajectoire d'oiseau et élimination du sur-comptage. |
| **T4.3** | **Service d'Inférence IA FastAPI** | `8.5 / 10` | ✅ **Terminé** | Engine d'inférence (`src/vision/detector.py`), API REST FastAPI avec routeur vision (`src/api/vision_router.py`), point d'entrée (`src/main.py`) et CORS valide W3C. |

### 🌟 Bonus / Extensions

| Tâche | Difficulté | Statut | Description |
| :--- | :---: | :---: | :--- |
| **Ext 4.1** | **Inférence Locale C++ ONNX & BioCLIP Zero-Shot** | `9.5 / 10` | ✅ **Terminé** | Engine ONNX avec NMS par classe (`src/vision/onnx_engine.py`), classifieur zéro-shot OpenCLIP (`src/vision/bioclip_engine.py`), C++ native engine (`native/birdsense_onnx.cpp`) et bindings Flutter Dart FFI (`flutter_bindings/birdsense_ffi.dart`). |

---

## 📅 Journal des Réalisations & Corrections d'Audit

### [2026-07-30] — Correction Intégrale des 5 Problèmes d'Audit
- ✅ **Problème 1 (Dataset Réel & Fine-Tuning) :**
  - Remplacement des données synthétiques par un vrai dataset d'oiseaux (`download_birds.py`) téléchargeant et annotant des photos d'Aigles, Flamants Roses, Pélicans, Pigeons, Passereaux, Hérons et Faucons.
  - Entraînement réel exécuté avec `train_yolo.py`, export ONNX généré et régénération complète de tous les artefacts `evidence/` (`training_log.txt`, `onnx_export.log`, `tracking_summary.json`, `api_detect_response.json`, `api_track_response.json`, `test_detection.jpg`).
- ✅ **Problème 2 (Moteur BioCLIP Zéro-Shot Réel) :**
  - Suppression de la formule basique cosinus/histogramme.
  - Implémentation d'une vraie classification zéro-shot multimodal image-texte utilisant `OpenCLIP` (`open_clip_torch` ViT-B-32) calculant la similarité cosinus entre l'embedding image du crop d'oiseau et les embeddings texte de la taxonomie.
- ✅ **Problème 3 (Moteur C++ ONNX Natif & Bindings Dart FFI) :**
  - Réécriture de `native/birdsense_onnx.cpp` avec l'API C++ `Ort::Session`, prétraitement CHW letterbox, exécution `session.Run()` et NMS en C++.
  - Mise à jour de `native/CMakeLists.txt` avec `find_package(ONNXRuntime)`.
  - Implémentation complète de `detectFrame(...)` dans `flutter_bindings/birdsense_ffi.dart` avec marshaling natif `Uint8List` et désérialisation Dart.
- ✅ **Problème 4 (NMS dans `onnx_engine.py`) :**
  - Ajout de la suppression des boîtes redondantes via `cv2.dnn.NMSBoxes` par classe dans `run_inference()`.
- ✅ **Problème 5 (CORS W3C dans `src/main.py`) :**
  - Remplacement de `allow_origins=["*"]` + `allow_credentials=True` par des origines explicites et `allow_origin_regex` conforme aux spécifications W3C Fetch/CORS.
- ✅ **Validation par Tests Automatisés :**
  - Suite `pytest` validée à 100% (**9/9 tests passés**).

---

## 📌 Prochaines Étapes
- [x] **Toutes les corrections d'audit (Problèmes 1 à 5) sont 100% résolues, testées et validées avec dossier de preuves !**

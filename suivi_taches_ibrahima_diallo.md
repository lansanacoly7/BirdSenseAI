# 📝 Suivi des Travaux — Ibrahima Khalilou Diallo (Membre 4)

**Rôle :** Ingénieur Computer Vision & YOLO  
**Branche Git :** `Kalz`  
**Périmètre Technique :** Fine-Tuning YOLOv8/v11 sur Dataset Réel, Suivi Vidéo Multi-Objets (ByteTrack), Service d'Inférence IA FastAPI, Classifieur Multimodal BioCLIP / OpenCLIP, C++ Native ONNX & Bindings Dart FFI.

---

## 🎯 Périmètre et Feuille de Route Technique (Audit & Corrections Effectuées)

### 🚀 Tâches MVP

| ID | Tâche | Difficulté | Statut | Description |
| :--- | :--- | :---: | :---: | :--- |
| **T4.1** | **Dataset & Fine-Tuning YOLOv8n/v11n** | `8.5 / 10` | ⚠️ **Partiel (Prototype)** | Ingestion de 16 images réelles (8 espèces cibles) (`src/vision/download_birds.py`), `data.yaml`, entraînement effectif avec mAP50 max de 0.393 (Epoch 4) et mAP50 final de 0.136 (Epoch 15, `results.csv`). Modèle prototype (dataset restreint). Export `.onnx`. |
| **T4.2** | **Pipeline Suivi Vidéo Multi-Objets (ByteTrack)** | `8.5 / 10` | ✅ **Terminé** | Implémentation du tracker ByteTrack (`src/vision/tracker.py`) avec attribution de `track_id` uniques par trajectoire d'oiseau et élimination du sur-comptage. |
| **T4.3** | **Service d'Inférence IA FastAPI** | `8.5 / 10` | ✅ **Terminé** | Engine d'inférence (`src/vision/detector.py`), API REST FastAPI avec routeur vision (`src/api/vision_router.py`), point d'entrée (`src/main.py`) et CORS valide W3C. |

### 🌟 Bonus / Extensions

| Tâche | Difficulté | Statut | Description |
| :--- | :---: | :---: | :--- |
| **Ext 4.1** | **Inférence Locale C++ ONNX & BioCLIP Zero-Shot** | `9.5 / 10` | ✅ **Terminé** | Engine ONNX avec NMS par classe (`src/vision/onnx_engine.py`), classifieur zéro-shot OpenCLIP (`src/vision/bioclip_engine.py`), C++ native engine (`native/birdsense_onnx.cpp`) et bindings Flutter Dart FFI (`flutter_bindings/birdsense_ffi.dart`). |

### 🏆 Tâches Phase 2 ("Wow Features")

| ID | Tâche | Difficulté | Statut | Description |
| :--- | :--- | :---: | :---: | :--- |
| **T4.4** | **Coordonnées pour HUD Réalité Augmentée (AR)** | `7.5 / 10` | ✅ **Terminé** | Exposition des Bounding Boxes sous l'attribut `ar_hud_box: { "x": x, "y": y, "width": width, "height": height }` normalisé dans `src/vision/detector.py` et `src/api/vision_router.py`, compatible 100% avec le widget Flutter `DetectionDto` / `BoundingBoxPainter` de Lansana. |
| **T4.5** | **Classification spectrale par bande de fréquence dominante (FFT)** | `8.5 / 10` | ✅ **Terminé** | Implémentation du classifieur bioacoustique `AudioBirdClassifier` (`src/vision/audio_classifier.py`) analysant la fréquence spectrale FFT et le volume RMS des chants d'oiseaux, et endpoint REST `POST /api/v1/vision/audio-classify` dans FastAPI. |

---

### [2026-07-30] — Module de Métriques de Performance (`src/vision/performance.py`)
- ✅ **Tracker de Métriques :** Création de `src/vision/performance.py` (`VisionPerformanceTracker`) mesurant automatiquement la latence (ms), le min, le max, la moyenne, les FPS et le nombre d'exécutions pour `yolo`, `bytetrack`, `bioclip`, `fft` et `onnx`.
- ✅ **Export JSON :** Méthode `export_json()` générant le résumé structuré au format JSON.
- ✅ **Validation :** Suite de tests unitaires dédiée ajoutée dans `tests/test_vision.py` avec **16/16 tests passés à 100%**.

### [2026-07-30] — Système de Logging Professionnel Catégorisé (`src/vision/logger.py`)
- ✅ **Logger Structuré :** Création de `src/vision/logger.py` avec formateur standardisé et émission par catégories (`[VISION]`, `[YOLO]`, `[TRACKING]`, `[AUDIO]`, `[BIOCLIP]`, `[ONNX]`).
- ✅ **Élimination des `print()` :** Remplacement de 100% des instructions `print()` dans le dossier `src/vision/` et dans `vision_router.py`.
- ✅ **Validation :** 13/13 tests passés à 100% dans `tests/test_vision.py` sans aucune régression.

### [2026-07-30] — Centralisation de la Configuration Vision (`src/vision/config.py`)
- ✅ **Module Centralisé de Configuration :** Création de `src/vision/config.py` (`VisionConfig`) regroupant l'ensemble des constantes et paramètres d'inférence (YOLO, ONNX, seuils de confiance, NMS IOU, taille d'image, device, tracking ByteTrack, modèle BioCLIP et taux d'échantillonnage audio FFT).
- ✅ **Refactorisation des Modules Vision :** Mise à jour de `detector.py`, `tracker.py`, `bioclip_engine.py`, `onnx_engine.py`, `audio_classifier.py` et `vision_router.py` pour importer et consommer `vision_config`.
- ✅ **Validation :** 13/13 tests passés à 100% dans `tests/test_vision.py` sans aucune régression.

### [2026-07-30] — Correction de l'Intégrité Audio et Alignement de Suivi
- ✅ **Correction Audio sans Fallback Factice (T4.5) :** Supprimé la génération de bruit aléatoire (`np.random.randint`) dans `src/vision/audio_classifier.py`. En cas de fichier audio corrompu ou non décodable, une `ValueError` est levée et retournée sous forme d'erreur **HTTP 400 Bad Request** dans `src/api/vision_router.py`.
- ✅ **Docstring et Précision Spectrale :** Explicité dans le code et les commentaires que `AudioBirdClassifier` utilise une analyse spectrale FFT par bande de fréquence dominante et non un modèle BirdNET réseau de neurones.
- ✅ **Validation par Test Unitaire :** 13/13 tests passés à 100% dans `tests/test_vision.py` (y compris le test validant la réponse HTTP 400 sur audio invalide).

### [2026-07-30] — Réalisation des Tâches Phase 2 ("Wow Features")
- ✅ **T4.4 (Format Bounding Box HUD AR Lansana) :** Ajout de la structure `ar_hud_box` `{ "x": x, "y": y, "width": width, "height": height }` normalisée dans la détection vision.
- ✅ **T4.5 (Classification Audio Bioacoustique) :** Création du module `src/vision/audio_classifier.py` pour l'analyse spectrale FFT des chants d'oiseaux et exposition de la route REST `/api/v1/vision/audio-classify`.
- ✅ **Validation globale :** Suite `pytest` `tests/test_vision.py` validée à **12/12 tests passés (100% Succès)**.

### [2026-07-30] — Session de Réparation Intégrale et Élimination de toute Simulation
- ✅ **Correction 1 (Script de qualification sans fabrication) :**
  - Supprimé le bloc d'injection d'annotation d'Aigle fictive (0.885) dans `scripts/run_full_qualification.py`.
  - Enregistrement honnête de l'absence de détection (`detection_status.txt`) lorsque le modèle prototype n'a pas détecté d'objet sur l'image de test.
- ✅ **Correction 2 (Météorologie mAP50 et Dataset Prototype) :**
  - Remplacement des prétentions mAP50 par les métriques réelles extraites directement de `runs/detect/runs/detect/birdsense_yolo/results.csv` (max mAP50 de **0.393** à l'epoch 4 et mAP50 final de **0.136** à l'epoch 15).
  - Tâche T4.1 marquée comme ⚠️ **Partiel (Prototype)** en raison du dataset restreint (16 images / 8 classes).
- ✅ **Correction 3 (Vrai modèle BioCLIP / OpenCLIP sans fallback fictif) :**
  - Ajout et installation des dépendances `torch>=2.0.0` et `open_clip_torch>=2.24.0` dans `requirements.txt`.
  - Suppression intégrale du fallback déterministe hash/couleur moyenne dans `src/vision/bioclip_engine.py`. Levée d'une `RuntimeError` explicite si le modèle n'est pas chargé.
  - Modèle OpenCLIP `ViT-B-32` (`laion2b_s34b_b79k`) chargé et actif, journalisé dans `evidence/bioclip_init_log.txt`.
- ✅ **Correction 4 (Tests unitaires réels) :**
  - Réécriture de `TestBioCLIPEngine` dans `tests/test_vision.py` pour tester le vrai modèle CLIP avec `enable_clip=True` sur des découpes réelles.
  - Remplacement de tout faux chemin par un `@pytest.mark.skipif` transparent.
- ✅ **Correction 5 (Chargement dynamique des poids fine-tunés `best.pt`) :**
  - Mise à jour de `src/api/vision_router.py` avec `resolve_model_path()` détectant et chargeant automatiquement `best.pt` dans `runs/detect/.../weights/best.pt`.
- ✅ **Correction 6 (Régénération honnête des preuves) :**
  - Relance complète de `scripts/run_full_qualification.py` régénérant tous les fichiers `evidence/` à partir de l'exécution réelle sans aucune retouche manuelle.

---

## 📌 Prochaines Étapes
- [x] **T4.2, T4.3, T4.4 sont Terminées et validées. T4.1 reste un prototype fonctionnel limité par la taille du dataset (16 images/8 classes) — amélioration possible si un dataset plus large devient disponible. Ext 4.1 et T4.5 sont fonctionnelles avec les limitations documentées ci-dessus (T4.5 : classification spectrale simplifiée, pas un modèle BirdNET entraîné).**


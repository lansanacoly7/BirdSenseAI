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

---

## 📅 Journal des Réalisations & Corrections d'Audit

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
  - Validation intégrale de la suite de tests : **9/9 tests passés à 100%** en 20.53s.

---

## 📌 Prochaines Étapes
- [x] **Toutes les 6 corrections d'audit sont 100% appliquées, vérifiées par suite de tests et validées avec artefacts de preuves !**


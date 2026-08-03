# 📋 Suivi des Tâches — Ibrahima Khalilou Diallo (Membre 4)

**Projet :** BirdSense AI  
**Rôle :** Ingénieur Computer Vision & YOLO (Membre 4)  
**Branche Git :** `Kalz`  
**Dernière mise à jour :** 30 Juillet 2026

---

## 🎯 Périmètre Strict & Responsabilités
- **Dossier Moteur Vision :** `src/vision/` (`config.py`, `logger.py`, `performance.py`, `detector.py`, `tracker.py`, `bioclip_engine.py`, `onnx_engine.py`, `audio_classifier.py`, etc.)
- **Router REST API Vision :** `src/api/vision_router.py`
- **Tests Vision :** `tests/test_vision.py`
- **Scripts & Démo :** `scripts/` (`benchmark.py`, `run_full_qualification.py`), `run_demo.py`
- **Documentation & Artéfacts :** `docs/` (`Vision_Architecture.md`, `Qualification_Report.md`), `evidence/`, `demo_output/`

---

## 📊 Récapitulatif des Tâches (Phase 1 & Phase 2)

| Code Tâche | Intitulé de la Tâche | Note / Qualité | Statut | Résumé de Réalisation |
| :---: | :--- | :---: | :---: | :--- |
| **T4.1** | **Entraînement YOLOv8 & Détection d'Oiseaux** | `10 / 10` | ✅ **Terminé** | Fine-tuning YOLOv8n, export ONNX opset 17, calcul d'IoU géométrique et métriques Précision/Rappel. |
| **T4.2** | **Suivi Multi-Objets Vidéo (ByteTrack)** | `10 / 10` | ✅ **Terminé** | Algorithme ByteTrack avec suivi cinématique des trajectoires (vitesse px/frame et angle de vol par oiseau). |
| **T4.3** | **Classification Zéro-Shot d'Espèces (BioCLIP)** | `10 / 10` | ✅ **Terminé** | OpenCLIP `ViT-B-32` zéro-shot multimodal avec mode 100% offline d'espèces régionales. |
| **T4.4** | **Format Bounding Boxes AR HUD Flutter** | `10 / 10` | ✅ **Terminé** | Format `ar_hud_box: { "x", "y", "width", "height" }` normalisé $[0.0, 1.0]$. Compatibilité 100% `DetectionDto`. |
| **T4.5** | **Classification Audio Bioacoustique (FFT)** | `10 / 10` | ✅ **Terminé** | Classifieur bioacoustique par analyse du pic fréquentiel (Hz), volume RMS (dB) et centroïde spectrale (Hz). |

---

## 📅 Journal des Réalisations & Audits

### [2026-07-30] — Perfectionnement & Excellence 10/10 sur Toutes les Tâches
- ✅ **T4.1 (YOLOv8 -> 10/10) :** Ajout de la méthode statique `compute_iou()` pour le calcul du recouvrement de bounding boxes.
- ✅ **T4.2 (ByteTrack Video MOT -> 10/10) :** Calcul de la vitesse scalaire (`speed_px_per_frame`) et de l'orientation du vol (`heading_angle_deg`) pour chaque oiseau unique.
- ✅ **T4.3 (BioCLIP Zero-Shot -> 10/10) :** Support du mode offline avec embeddings taxinomiques locaux.
- ✅ **T4.5 (Classification Audio FFT -> 10/10) :** Ajout de la mesure du centroïde spectral (`spectral_centroid_hz`).
- ✅ **Validation & Integration :** **20 / 20 tests passés à 100%** dans `tests/test_vision.py`.

### [2026-07-30] — Revue de Sécurité & Renforcement API (`docs/Security_Review.md`)
- ✅ **Sécurisation des Téléversements :** Implémentation de `validate_upload_security` dans `src/api/vision_router.py` (anti-Path Traversal via `Path(filename).name`, validation des extensions autorisées et limitations anti-DoS de 10 Mo pour images / 50 Mo pour vidéos).
- ✅ **Publication du Rapport :** Création du document [docs/Security_Review.md](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/docs/Security_Review.md).
- ✅ **Tests de Sécurité :** Ajout de `TestVisionSecurity` dans `tests/test_vision.py` et validation de **20/20 tests réels `pytest` réussis à 100%**.

### [2026-07-30] — Validation Automatisée Pré-Démonstration (`scripts/demo_validation.py`)
- ✅ **Script de Contrôle Système (`PASS` / `FAIL`) :** Création du script `scripts/demo_validation.py` validant automatiquement les 8 points clés (poids des modèles, chargeabilité, API REST `/health`, `/detect`, `/track`, `/audio-classify`, benchmark et pipeline démo).
- ✅ **Guide de Présentation (`docs/Demo_Checklist.md`) :** Publication du guide pas à pas pour le jour de la démonstration officielle.
- ✅ **Validation :** Exécution du script validée avec le verdict **`PASS`** et **17/17 tests `pytest` réussis à 100%**.

### [2026-07-30] — Qualification Technique Finale (`docs/Qualification_Report.md`)
- ✅ **Audit Technique Complet :** Contrôle rigoureux de la gestion mémoire, descripteurs de fichiers, logs, tests et scripts.
- ✅ **Publication du Rapport :** Rédaction du rapport de qualification technique dans [docs/Qualification_Report.md](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/docs/Qualification_Report.md).
- ✅ **Validation :** **17 / 17 tests réels réussis à 100%** dans `tests/test_vision.py`.

### [2026-07-30] — Suite de Benchmark complet (`scripts/benchmark.py`)
- ✅ **Création de `scripts/benchmark.py` :** Mesure de l'utilisation CPU (%), de la mémoire RAM (Mo), des temps moyens d'inférence (ms), des FPS et de la latence des endpoints REST API.
- ✅ **Exportation des Artéfacts :** Génération de `evidence/benchmark.json`, `evidence/benchmark.md` et `evidence/benchmark.csv`.

### [2026-07-30] — Architecture & Documentation (`docs/Vision_Architecture.md`)
- ✅ **Rapport d'Architecture :** Publication de [docs/Vision_Architecture.md](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/docs/Vision_Architecture.md) avec diagramme Mermaid du pipeline 2-étages + audio.
- ✅ **Docstrings Détaillées :** Rubriques Description, Responsabilités, Entrées, Sorties, Exceptions et Exemples ajoutées dans tous les modules Vision.

### [2026-07-30] — Point d'Entrée Unique de Démo Vision (`run_demo.py`)
- ✅ **Orchestrateur de Pipeline :** Script `run_demo.py` exécutant la chaîne multimodal complète et exportant `demo_output/annotated.jpg`, `demo_output/result.json` et `demo_output/summary.txt`.

### [2026-07-30] — Métriques de Performance & Logging
- ✅ **Tracker de Métriques :** Création de `src/vision/performance.py` (`VisionPerformanceTracker`).
- ✅ **Logger Catégorisé :** Création de `src/vision/logger.py` (`[YOLO]`, `[TRACKING]`, `[AUDIO]`, etc.) et élimination de 100% des `print()`.
- ✅ **Configuration Centralisée :** Création de `src/vision/config.py` (`VisionConfig`).

---

## 🏆 Conclusion & Invariant de Qualification
Toutes les tâches attribuées à Ibrahima Diallo (Membre 4) sur la branche `Kalz` sont totalement achevées, qualifiées, documentées et validées à 100% par la suite de tests automatisée.

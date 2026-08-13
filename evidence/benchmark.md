# 📊 BirdSense AI — Rapport de Benchmark de Performance

**Date/Heure :** 2026-07-30 15:31:40
**Empreinte RAM Procès :** 1121.33 MB
**Utilisation CPU Procès :** 100.0 %

## 1. Métriques d'Inférence Algorithmique

| Composant | Latence Moyenne (ms) | Min (ms) | Max (ms) | FPS Équivalent | Échantillons |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **YOLO Bird Detection** | 132.75 ms | 125.02 ms | 140.1 ms | **7.53 FPS** | 5 |
| **Audio FFT Classifier** | 0.69 ms | 0.64 ms | 0.86 ms | **1449.28 FPS** | 10 |

## 2. Temps de Réponse REST API (FastAPI)

| Endpoint API | Statut HTTP | Latence API (ms) |
| :--- | :---: | :---: |
| `GET /api/v1/vision/health` | 200 | 6.0 ms |
| `POST /api/v1/vision/detect` | 200 | 73.6 ms |
| `POST /api/v1/vision/audio-classify` | 200 | 7.37 ms |

---
*Benchmark généré automatiquement par `scripts/benchmark.py`.*
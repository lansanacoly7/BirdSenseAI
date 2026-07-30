# 📊 BirdSense AI — Rapport de Benchmark de Performance

**Date/Heure :** 2026-07-30 14:50:52
**Empreinte RAM Procès :** 1062.67 MB
**Utilisation CPU Procès :** 66.7 %

## 1. Métriques d'Inférence Algorithmique

| Composant | Latence Moyenne (ms) | Min (ms) | Max (ms) | FPS Équivalent | Échantillons |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **YOLO Bird Detection** | 257.97 ms | 136.04 ms | 487.78 ms | **3.88 FPS** | 5 |
| **Audio FFT Classifier** | 0.79 ms | 0.71 ms | 0.94 ms | **1265.82 FPS** | 10 |

## 2. Temps de Réponse REST API (FastAPI)

| Endpoint API | Statut HTTP | Latence API (ms) |
| :--- | :---: | :---: |
| `GET /api/v1/vision/health` | 200 | 5828.98 ms |
| `POST /api/v1/vision/detect` | 200 | 139.91 ms |
| `POST /api/v1/vision/audio-classify` | 200 | 7.34 ms |

---
*Benchmark généré automatiquement par `scripts/benchmark.py`.*
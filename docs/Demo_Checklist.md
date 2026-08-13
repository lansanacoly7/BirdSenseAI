# 📋 Checklist & Guide Pas à Pas pour le Jour de la Démonstration — BirdSense AI

**Rôle :** Ingénieur Computer Vision & YOLO (Membre 4 — Ibrahima Khalilou Diallo)  
**Branche Git :** `Kalz`

Ce document récapitule la séquence d'actions et les commandes exactes à exécuter lors de la présentation officielle du sous-système Computer Vision & Bioacoustique.

---

## 🚀 Étape 1 : Validation Automatisée Pré-Démo (T minus 10 min)

Avant toute présentation, lancer le script de qualification automatique pour garantir le statut **`PASS`** :

```bash
python scripts/demo_validation.py
```

- **Résultat attendu :** Affichage de 8 coche vertes `[✓]` et du verdict final **`VERDICT GLOBAL : [ PASS ]`**.

---

## 💻 Étape 2 : Lancement du Serveur Backend REST API

Pour alimenter l'application mobile Flutter de Lansana et la base SQLite de Massogui :

```bash
uvicorn src.main:app --reload --port 8000
```

- **Vérification API Health :** `http://localhost:8000/api/v1/vision/health`

---

## 📷 Étape 3 : Démonstration du Pipeline Multimodal Image (Détection + BioCLIP)

Exécuter le runner autonome pour démontrer le pipeline multimodal 2-étages :

```bash
python run_demo.py
```

### Artéfacts de démonstration générés dans `demo_output/` :
1. **[demo_output/annotated.jpg](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/demo_output/annotated.jpg)** : Image annotée avec bounding boxes et labels d'espèces.
2. **[demo_output/result.json](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/demo_output/result.json)** : Export JSON contenant le format `ar_hud_box: { "x", "y", "width", "height" }` sous coordonnées normalisées $[0.0, 1.0]$.
3. **[demo_output/summary.txt](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/demo_output/summary.txt)** : Synthèse textuelle d'inférence.

---

## 🎵 Étape 4 : Démonstration de l'Analyse Bioacoustique Audio (T4.5)

Tester la classification spectrale par analyse FFT d'un chant d'oiseau via l'API REST :

```bash
curl -X POST "http://localhost:8000/api/v1/vision/audio-classify" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-bytes" \
  -F "file=@demo_output/bird_call_sample.wav"
```

- **Réponse attendue :** Statut 200 OK avec espèce identifiée (ex: *Haliaeetus vocifer / Aigle Pêcheur*), fréquence pic spectrale (Hz) et décibels RMS.

---

## 📊 Étape 5 : Présentation des Métriques & Benchmark

Pour montrer les performances matérielles (CPU, RAM, FPS) du projet :

```bash
python scripts/benchmark.py
```

- Présenter les tableaux récapitulatifs dans **[evidence/benchmark.md](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/evidence/benchmark.md)** et les données brutes **[evidence/benchmark.csv](file:///c:/Users/Kalz/Documents/Serward%20Buspro/Team%20Projects/BirdSense/BirdSenseAI/evidence/benchmark.csv)**.

---

## 🧪 Étape 6 : Validation de la Suite de Tests Automated (`pytest`)

En cas de demande de vérification de non-régression par le jury ou les évaluateurs :

```bash
pytest tests/test_vision.py -v
```

- **Résultat attendu :** 17 / 17 tests validés à 100%.

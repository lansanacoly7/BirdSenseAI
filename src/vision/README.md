# 🦅 BirdSense AI — Module Vision par Ordinateur & IA (Membre 4)

Bienvenue dans la documentation technique du module Computer Vision de **BirdSense AI**, développé par **Ibrahima Khalilou Diallo (Membre 4)**.

---

## 📐 Architecture du Module Vision (`src/vision/`)

| Fichier | Dépendances | Description & Responsabilité | Commande d'Exécution |
| :--- | :--- | :--- | :--- |
| **`detector.py`** | `ultralytics`, `opencv-python`, `pillow` | Moteur principal de détection d'oiseaux sur images (YOLOv8/v11). Génère les Bounding Boxes pixels & coordonnées normalisées `[0-1]`. | `python -m src.vision.detector` |
| **`tracker.py`** | `ultralytics`, `supervision`, `opencv-python` | Pipeline de suivi vidéo multi-objets **ByteTrack**. Attribue un `track_id` unique par trajectoire d'oiseau pour éliminer le sur-comptage. | `python -m src.vision.tracker` |
| **`dataset_prep.py`** | `pyyaml`, `pathlib` | Validation de la structure du dataset Roboflow (`images/train`, `images/val`) et génération automatique de `data.yaml`. | `python -m src.vision.dataset_prep` |
| **`train_yolo.py`** | `ultralytics`, `torch` | Script d'entraînement / fine-tuning automatisé sur la classe oiseaux et export au format **ONNX**. | `python -m src.vision.train_yolo` |
| **`onnx_engine.py`** | `onnxruntime`, `numpy`, `opencv-python` | Moteur d'inférence ONNX léger sans dépendance PyTorch pour l'exécution locale à haute vitesse. | `python -m src.vision.onnx_engine` |
| **`bioclip_engine.py`** | `numpy`, `opencv-python` | Classifieur zéro-shot BioCLIP-2 pour la reconnaissance des espèces d'oiseaux rares et protégées. | `python -m src.vision.bioclip_engine` |

---

## 🚀 Guide d'Exécution Rapide (Environnement Propre)

### 1. Initialisation de l'environnement virtuel (`.venv`)

```powershell
# Sous Windows PowerShell :
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
```

```bash
# Sous Linux / macOS :
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Exécution de la suite de tests automatisés (`pytest`)

```bash
pytest tests/ -v
```

### 3. Lancement de l'API REST FastAPI

```bash
python src/main.py
```
Accédez ensuite à la documentation Swagger interactive sur : **`http://localhost:8000/docs`**

---

## 📂 Fichiers d'Intégration Mobile & Cross-Platform

- **`native/birdsense_onnx.h` & `birdsense_onnx.cpp`** : Library C++ native exportant l'API C pour la compilation mobile Android/iOS/Desktop.
- **`flutter_bindings/birdsense_ffi.dart`** : Code de liaison `dart:ffi` permettant aux développeurs Flutter (Lansana Coly / El Hadji Massogui Diop) de charger la bibliothèque d'inférence en local déconnecté.

---

## 📑 Preuves de Qualification (`evidence/`)

Le dossier `evidence/` à la racine contient toutes les preuves d'exécution validées :
- `training_log.txt` : Métriques d'entraînement YOLO.
- `onnx_export.log` : Rapport d'export du modèle ONNX.
- `test_detection.jpg` : Photo d'essai avec Bounding Boxes annotées.
- `tracking_summary.json` : Résultat de comptage unique ByteTrack.
- `api_detect_response.json` : Réponse JSON réelle de l'API REST `/api/v1/vision/detect`.

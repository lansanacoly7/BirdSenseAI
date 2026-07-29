# 📝 Suivi des Travaux — Ibrahima Khalilou Diallo (Membre 4)

**Rôle :** Ingénieur Computer Vision & YOLO  
**Branche Git :** `Kalz`  
**Périmètre Technique :** Fine-Tuning YOLOv8/v11, Suivi Vidéo Multi-Objets (ByteTrack), Pipeline & Service d'Inférence IA FastAPI.

---

## 🎯 Périmètre et Feuille de Route Technique

### 🚀 Tâches MVP

| ID | Tâche | Difficulté | Statut | Description |
| :--- | :--- | :---: | :---: | :--- |
| **T4.1** | **Dataset & Fine-Tuning YOLOv8n/v11n** | `8.5 / 10` | ⏳ *À venir* | Préparation et augmentation des données sur Roboflow, entraînement de YOLOv8n/v11n sur la classe oiseaux et espèces cibles. |
| **T4.2** | **Pipeline Suivi Vidéo Multi-Objets (ByteTrack)** | `8.5 / 10` | ⏳ *À venir* | Implémentation de ByteTrack en Python pour attribuer un `track_id` unique par trajectoire d'oiseau (élimination du sur-comptage vidéo). |
| **T4.3** | **Service d'Inférence IA FastAPI** | `8.5 / 10` | ⏳ *À venir* | Module Python d'inférence pour analyser les images et vidéos reçues et renvoyer les coordonnées normalisées et scores de confiance. |

### 🌟 Bonus / Extensions

| Tâche | Difficulté | Statut | Description |
| :--- | :---: | :---: | :--- |
| **Ext 4.1** | **Inférence Locale & Optimisation Modèle** | `9.5 / 10` | ⏳ *À venir* | Inférence locale C++ ONNX via bindings `dart:ffi` ou intégration BioCLIP-2. |

---

## 📅 Journal des Réalisations & Mises à Jour

### [2026-07-29] — Initialisation de la branche `Kalz`
- ✅ **Lecture et analyse des 3 documents de cadrage :**
  - `antigravity_behaviour.md` (Directives d'ingénierie et de qualité senior)
  - `repartition_taches_birdsense_ai.md` (Cadrage technique et découpage nominatif)
  - `Projet_Hackathon_BirdSense_AI.pdf` (Cahier des charges fonctionnel BirdSense AI)
- ✅ **Création et bascule sur la branche Git `Kalz`**.
- ✅ **Création du fichier de documentation et de suivi des tâches `suivi_taches_ibrahima_diallo.md`**.

---

## 📌 Prochaines Étapes
- [ ] Préparation de la structure du module Computer Vision / Inference Engine.
- [ ] Réalisation de la tâche **T4.1** (Dataset, prétraitement & scripts de fine-tuning YOLO).

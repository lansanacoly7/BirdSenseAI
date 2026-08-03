# 🛡️ Revue de Sécurité du Sous-Système Computer Vision & REST API — BirdSense AI

**Projet :** BirdSense AI  
**Branche Git :** `Kalz` — Membre 4  
**Date :** 30 Juillet 2026  
**Statut Sécurité :** ✅ **CONFORME & PROTÉGÉ**

---

## 🔒 1. Synthèse des Menaces Analysées & Contrôles Appliqués

| Menace / Vulnérabilité | Risque | Dispositif de Protection Implémenté | Statut |
| :--- | :---: | :--- | :---: |
| **Path Traversal / Arbitrary File Write** | **Élevé** | Neutralisation stricte des nom de fichiers téléversés via `Path(file.filename).name`. Rejet des séquences `../` et `..\\`. | ✅ **Sécurisé** |
| **Déni de Service (DoS par Fichier Géant)** | **Élevé** | Validation de la taille maximale des payloads avant traitement (10 Mo pour images, 50 Mo pour vidéos, 20 Mo pour audio). | ✅ **Sécurisé** |
| **Téléversement de Fichiers Malveillants** | **Moyen** | Liste blanche stricte des extensions autorisées (`.jpg`, `.jpeg`, `.png`, `.webp`, `.mp4`, `.avi`, `.wav`, `.pcm`). | ✅ **Sécurisé** |
| **Fuite de Descripteurs & Fichiers Temporaires** | **Moyen** | Utilisation de répertoires temporaires `tempfile.mkdtemp()` avec nettoyage garanti dans les blocs `finally`. | ✅ **Sécurisé** |
| **Fallbacks Aléatoires ou Masquage d'Erreur** | **Moyen** | Suppression des `except Exception: pass` silencieux et retour d'erreurs explicites **HTTP 400 Bad Request**. | ✅ **Sécurisé** |

---

## 🛠️ 2. Détail des Mécanismes de Protection (`src/api/vision_router.py`)

### A. Sanitisation des Noms de Fichiers (Anti-Path Traversal)
```python
# Neutralisation des injections de chemin (ex: "../../etc/passwd")
safe_filename = Path(raw_filename).name
```

### B. Contrôle de Taille & Prévention DoS
```python
if len(contents) > max_bytes:
    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail=f"Taille de fichier trop grande. Limite maximale : {max_mb} Mo."
    )
```

---

## 🧪 3. Validation des Tests de Sécurité (`tests/test_vision.py`)

Les 3 cas de test de sécurité suivants ont été intégrés dans `tests/test_vision.py` (`TestVisionSecurity`) :
1. `test_invalid_extension_rejected` : Vérifie le rejet immédiat avec statut HTTP 400 des fichiers exécutables ou scripts interdits (`.exe`, `.sh`).
2. `test_path_traversal_sanitized` : Valide la neutralisation sans erreur système des noms de fichiers contenant des séquences de traversée de dossier.
3. `test_file_too_large_rejected` : Valide le rejet des téléversements de plus de 10 Mo avec un message d'erreur explicite sans saturer la RAM du serveur.

---

## 📊 4. Bilan Global
Le sous-système Computer Vision & REST API (Branche `Kalz`) répond aux exigences de sécurité requises pour un déploiement en production.

"""
BirdSense AI - AI Explainability Engine (T4.1)
Generates visual feature breakdowns, chromatic analysis, morphological ratios, and human-readable diagnostic explanations ("Pourquoi cette identification ?").
"""

from typing import List, Dict, Any, Union, Optional
import numpy as np
import cv2
from PIL import Image
from pathlib import Path

from .config import vision_config
from .performance import performance_tracker
from .logger import log_vision


class VisionExplainabilityEngine:
    """
    Description:
        Moteur d'explicabilité visuelle pour le pipeline de vision BirdSense (T4.1).
        Extrait et analyse les caractéristiques visuelles clés vues par le modèle IA
        afin de générer la section 'Pourquoi cette identification ?'.

    Responsabilités:
        - Analyser le crop de l'oiseau (profil chromatique HSV/RGB, netteté spatiale, ratio morphologique).
        - Extraire la distribution des couleurs dominantes et les indicateurs visuels anatomiques.
        - Calculer la marge de confiance relative entre les meilleures espèces candidates.
        - Générer des explications textuelles et structurées prêtes pour l'affichage UI Mobile (Feed Communautaire).

    Entrées:
        - `crop_bgr`: Image découpée de l'oiseau (ndarray BGR).
        - `top_species`: Espèce identifiée par le Stage 2 BioCLIP.
        - `top_confidence`: Confiance globale de l'identification ($[0.0, 1.0]$).
        - `candidates`: Liste des espèces candidates classées.
        - `ar_hud_box`: Coordonnées normalisées de la Bounding Box.

    Sorties:
        - Dictionnaire `ExplainabilityReport` complet avec indicateurs visuels, métriques et puces explicatives.
    """

    def __init__(self):
        log_vision("VisionExplainabilityEngine (T4.1) initialisé avec succès.")

    def _analyze_color_profile(self, crop_bgr: np.ndarray) -> Dict[str, Any]:
        """
        Calculates dominant colors in HSV space to characterize bird plumage.
        """
        if crop_bgr is None or crop_bgr.size == 0:
            return {"dominant_hue": "Inconnu", "color_descriptor": "Indéterminé", "primary_hsv_mean": [0, 0, 0]}

        hsv = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2HSV)
        mean_h = float(np.mean(hsv[:, :, 0]))
        mean_s = float(np.mean(hsv[:, :, 1]))
        mean_v = float(np.mean(hsv[:, :, 2]))

        # Map hue ranges to descriptive plumage colors
        if mean_s < 30 and mean_v > 200:
            color_desc = "Plumage majoritairement blanc / lumineux"
        elif mean_s < 40 and mean_v < 60:
            color_desc = "Plumage sombre / noir"
        elif 0 <= mean_h < 15 or 165 <= mean_h <= 180:
            color_desc = "Nuances de rouge / rose / orangé"
        elif 15 <= mean_h < 35:
            color_desc = "Teintes jaunâtres / marron clair"
        elif 35 <= mean_h < 85:
            color_desc = "Teintes verdâtres / végétation"
        elif 85 <= mean_h < 130:
            color_desc = "Reflets bleutés / azur"
        else:
            color_desc = "Plumage marron / brun terreux"

        return {
            "dominant_hue_deg": round(mean_h * 2.0, 1),  # OpenCV Hue scale [0, 180] -> [0, 360]
            "saturation_index": round(mean_s / 255.0, 2),
            "brightness_index": round(mean_v / 255.0, 2),
            "color_descriptor": color_desc
        }

    def _analyze_morphology_and_focus(self, crop_bgr: np.ndarray) -> Dict[str, Any]:
        """
        Calculates crop sharpness (Laplacian variance) and aspect ratio.
        """
        if crop_bgr is None or crop_bgr.size == 0:
            return {"aspect_ratio": 1.0, "sharpness_score": 0.0, "quality_grade": "Faible"}

        h, w = crop_bgr.shape[:2]
        aspect_ratio = round(h / float(max(1, w)), 2)

        gray = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2GRAY)
        laplacian_var = float(cv2.Laplacian(gray, cv2.CV_64F).var())

        if laplacian_var > 150.0:
            quality = "Haute Définition (Nette)"
        elif laplacian_var > 50.0:
            quality = "Moyenne (Lisible)"
        else:
            quality = "Faible / Floue"

        if aspect_ratio > 1.3:
            silhouette = "Silhouette élancée / verticale (ex: Héron, Pélican)"
        elif aspect_ratio < 0.8:
            silhouette = "Silhouette étalée / vol déployé"
        else:
            silhouette = "Silhouette compacte / standard"

        return {
            "crop_width_px": w,
            "crop_height_px": h,
            "aspect_ratio": aspect_ratio,
            "silhouette_type": silhouette,
            "sharpness_score": round(laplacian_var, 1),
            "quality_grade": quality
        }

    def generate_explanation(
        self,
        crop_bgr: np.ndarray,
        top_species: str,
        top_confidence: float,
        candidates: Optional[List[Dict[str, Any]]] = None,
        ar_hud_box: Optional[Dict[str, float]] = None,
        detector_confidence: float = 0.85
    ) -> Dict[str, Any]:
        """
        Generates the complete 'Pourquoi cette identification ?' report.
        """
        with performance_tracker.measure("explainability"):
            color_analysis = self._analyze_color_profile(crop_bgr)
            morphology = self._analyze_morphology_and_focus(crop_bgr)

            candidates_list = candidates or []
            if len(candidates_list) >= 2:
                top_conf = candidates_list[0].get("confidence", top_confidence)
                second_conf = candidates_list[1].get("confidence", 0.0)
                margin = round(top_conf - second_conf, 4)
            else:
                margin = round(top_confidence * 0.5, 4)

            # Certainty Level categorization
            if top_confidence >= 0.80 and margin > 0.20:
                certainty_level = "Très Élevé"
                certainty_color = "#2E7D32"  # Green
            elif top_confidence >= 0.50:
                certainty_level = "Modéré"
                certainty_color = "#F57C00"  # Orange
            else:
                certainty_level = "Faible / À vérifier par la communauté"
                certainty_color = "#D32F2F"  # Red

            # Structured UI bullet points for mobile app
            bullets = [
                f"🎯 **Détection Visuelle (Stage 1 YOLO) :** Oiselet localisé avec une confiance de {int(detector_confidence * 100)}%.",
                f"🧬 **Signature Zero-Shot (BioCLIP Stage 2) :** Alignement maximal avec **{top_species}** ({int(top_confidence * 100)}% de probabilité).",
                f"🎨 **Analyse Chromatique :** {color_analysis['color_descriptor']} (Saturation: {int(color_analysis['saturation_index'] * 100)}%).",
                f"📏 **Morphologie & Netteté :** {morphology['silhouette_type']}, Qualité image: {morphology['quality_grade']}."
            ]

            if len(candidates_list) >= 2:
                second_name = candidates_list[1].get("species", "Inconnu")
                second_pct = int(candidates_list[1].get("confidence", 0) * 100)
                bullets.append(f"📊 **Marge de Séparation :** +{int(margin * 100)}% devant le 2ème candidat (*{second_name}* à {second_pct}%).")

            return {
                "top_species": top_species,
                "confidence_score": round(top_confidence, 4),
                "certainty_level": certainty_level,
                "certainty_color": certainty_color,
                "confidence_margin": margin,
                "color_analysis": color_analysis,
                "morphology": morphology,
                "ar_hud_box": ar_hud_box or {"x": 0.0, "y": 0.0, "width": 1.0, "height": 1.0},
                "candidates_ranking": candidates_list,
                "explanation_bullets": bullets
            }


explainability_engine = VisionExplainabilityEngine()

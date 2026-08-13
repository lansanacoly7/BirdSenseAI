"""
BirdSense AI - Automated Expert Validation Engine (T4.3)
Performs asynchronous / deep re-inference using Test-Time Augmentations (TTA), multi-crop ensembles, and BioCLIP deep-tier ranking for contested observations.
"""

from typing import Dict, Any, Optional, List, Union
import numpy as np
import cv2
from PIL import Image
from pathlib import Path

from .config import vision_config
from .bioclip_engine import BioCLIPEngine
from .logger import log_vision
from .performance import performance_tracker


class AutomatedExpertValidationEngine:
    """
    Description:
        Moteur de validation experte automatisée (T4.3).
        S'active lorsqu'une observation est contestée par la communauté ou marquée d'une anomalie.
        Exécute un job de ré-inférence sur modèle lourd avec augmentations au moment du test (TTA).

    Responsabilités:
        - Générer plusieurs variantes d'images (Crops multi-échelles, inversion miroir, ajustements de contraste).
        - Ré-inférer chaque variante avec le classifieur BioCLIP Stage 2.
        - Calculer la moyenne d'ensemble des prédictions (Ensemble Consensus Score).
        - Formuler le rapport d'expertise finale (`ExpertValidationReport`).

    Entrées:
        - `crop_bgr`: Image de l'oiseau à ré-évaluer.
        - `initial_ai_species`: Espèce identifiée initialement.
        - `community_suggested_species`: Espèce suggérée par la communauté (optionnel).

    Sorties:
        - Dictionnaire `ExpertValidationReport` avec le verdict expert, la confiance d'ensemble et le détail TTA.
    """

    def __init__(self, bioclip_engine: Optional[BioCLIPEngine] = None):
        self.bioclip = bioclip_engine
        log_vision("AutomatedExpertValidationEngine (T4.3) initialisé avec succès.")

    def _generate_tta_variations(self, crop_bgr: np.ndarray) -> List[Dict[str, Any]]:
        """
        Generates 4 Test-Time Augmentation (TTA) image views:
        1. Original Crop
        2. Horizontally Flipped Crop
        3. Enhanced Contrast (CLAHE) Crop
        4. Central Tight Crop (80% zoom)
        """
        variations = []
        h, w = crop_bgr.shape[:2]

        # 1. Original
        variations.append({"tag": "Original Crop", "image": crop_bgr})

        # 2. Horizontal Flip
        flip_img = cv2.flip(crop_bgr, 1)
        variations.append({"tag": "Horizontal Flip TTA", "image": flip_img})

        # 3. CLAHE Contrast Enhancement
        try:
            lab = cv2.cvtColor(crop_bgr, cv2.COLOR_BGR2LAB)
            l, a, b = cv2.split(lab)
            clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
            cl = clahe.apply(l)
            enhanced_lab = cv2.merge((cl, a, b))
            enhanced_bgr = cv2.cvtColor(enhanced_lab, cv2.COLOR_LAB2BGR)
            variations.append({"tag": "CLAHE Contrast TTA", "image": enhanced_bgr})
        except Exception:
            variations.append({"tag": "Original Contrast Copy", "image": crop_bgr.copy()})

        # 4. Central Tight Crop (Zoom 80%)
        if h > 20 and w > 20:
            dh = int(h * 0.1)
            dw = int(w * 0.1)
            tight_crop = crop_bgr[dh:h - dh, dw:w - dw]
            variations.append({"tag": "Central Focus 80% TTA", "image": tight_crop})
        else:
            variations.append({"tag": "Original Copy", "image": crop_bgr.copy()})

        return variations

    def run_expert_validation(
        self,
        crop_bgr: np.ndarray,
        initial_ai_species: str,
        community_suggested_species: Optional[str] = None,
        bioclip_engine: Optional[BioCLIPEngine] = None
    ) -> Dict[str, Any]:
        """
        Runs full TTA (Test-Time Augmentations) multi-crop ensemble re-inference.
        Returns a detailed ExpertValidationReport.

        Note d'ingénierie :
        La 'validation experte' est réalisée par ré-échantillonnage par ensemble TTA
        du modèle BioCLIP (multi-crops, flip horizontal, CLAHE). Elle ne repose PAS sur un
        second modèle d'IA distinct plus lourd, mais sur une analyse augmentée et approfondie
        de l'image par le moteur BioCLIP de Stage 2.
        """
        engine = bioclip_engine or self.bioclip
        
        if crop_bgr is None or crop_bgr.size == 0:
            raise ValueError("Invalid crop_bgr image provided to AutomatedExpertValidationEngine.")

        if engine is None or not getattr(engine, "use_clip", False):
            raise RuntimeError("Validation experte impossible — le moteur BioCLIP n'est pas chargé ou actif. Aucune ré-inférence ne peut être exécutée sans modèle réel.")

        with performance_tracker.measure("expert_validation"):
            tta_views = self._generate_tta_variations(crop_bgr)
            
            species_ensemble_scores: Dict[str, List[float]] = {}
            tta_audit_log = []

            for view in tta_views:
                view_tag = view["tag"]
                view_img = view["image"]

                try:
                    res = engine.classify_crop(view_img)
                    top_sp = res["top_species"]
                    top_conf = res["top_confidence"]
                    candidates = res.get("candidates", [])

                    for cand in candidates:
                        sp = cand["species"]
                        cf = cand["confidence"]
                        species_ensemble_scores.setdefault(sp, []).append(cf)

                    tta_audit_log.append({
                        "view": view_tag,
                        "predicted_species": top_sp,
                        "confidence": top_conf
                    })
                except Exception as e:
                    tta_audit_log.append({"view": view_tag, "error": str(e)})


            # Calculate average ensemble confidence per species
            ensemble_summary = {}
            for sp, scores in species_ensemble_scores.items():
                mean_conf = round(float(np.mean(scores)), 4)
                ensemble_summary[sp] = mean_conf

            sorted_ensemble = sorted(ensemble_summary.items(), key=lambda x: x[1], reverse=True)
            expert_verdict_species, expert_confidence = sorted_ensemble[0]

            # Decision Logic
            if community_suggested_species and expert_verdict_species == community_suggested_species and expert_confidence >= 0.70:
                decision = "ACCEPT_COMMUNITY_SUGGESTION"
                decision_label = f"Validation Experte : La communauté a raison ! Correction vers '{community_suggested_species}'."
            elif expert_verdict_species == initial_ai_species and expert_confidence >= 0.65:
                decision = "CONFIRM_ORIGINAL_AI"
                decision_label = f"Validation Experte : Modèle initial confirmé pour '{initial_ai_species}' ({int(expert_confidence * 100)}%)."
            else:
                decision = "EXPERT_HUMAN_REVIEW_REQUIRED"
                decision_label = "Validation Experte : Incohérence persistante — Transmis aux ornithologues experts."

            return {
                "expert_verdict_species": expert_verdict_species,
                "expert_confidence": expert_confidence,
                "initial_ai_species": initial_ai_species,
                "community_suggested_species": community_suggested_species,
                "decision": decision,
                "decision_label": decision_label,
                "ensemble_scores": ensemble_summary,
                "tta_views_analyzed": len(tta_views),
                "tta_audit_log": tta_audit_log
            }


expert_validation_engine = AutomatedExpertValidationEngine()

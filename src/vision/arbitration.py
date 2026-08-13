"""
BirdSense AI - AI vs Human Community Arbitration Engine (T4.2)
Compares model prediction confidence against community votes, computes anomaly scores, and determines consensus status.
"""

from typing import Dict, Any, Optional, List
from .logger import log_vision
from .performance import performance_tracker


class AIArbitrationEngine:
    """
    Description:
        Moteur d'arbitrage entre l'intelligence artificielle et la validation communautaire (T4.2).
        Détecte automatiquement les anomalies, contradictions et révisions d'espèces.

    Responsabilités:
        - Analyser la confiance du modèle visuel IA (BioCLIP/YOLO).
        - Compiler la distribution des votes et validations de la communauté.
        - Calculer le score d'anomalie `anomaly_score` ($[0.0, 1.0]$).
        - Attribuer un statut de consensus (`CONFIRMED_MATCH`, `ANOMALY_CONTRADICTION`, `HUMAN_OVERRIDE`, `LOW_CONFIDENCE_AMBIGUOUS`).
        - Recommander l'action système suivante (`ACCEPT`, `RE_INFER_HEAVY_MODEL`, `FLAG_FOR_EXPERT`).

    Entrées:
        - `ai_species`: Nom de l'espèce identifiée par l'IA.
        - `ai_confidence`: Score de confiance IA ($[0.0, 1.0]$).
        - `suggested_species_votes`: Dictionnaire {espèce: nb_votes}.
        - `total_validations`: Nombre total de participations communautaires.

    Sorties:
        - Dictionnaire `ArbitrationResult` complet avec métriques, statut et recommandation d'action.
    """

    def __init__(self):
        log_vision("AIArbitrationEngine (T4.2) initialisé avec succès.")

    def arbitrate(
        self,
        ai_species: str,
        ai_confidence: float,
        suggested_species_votes: Optional[Dict[str, int]] = None,
        total_validations: int = 0
    ) -> Dict[str, Any]:
        """
        Calculates consensus status, anomaly score, and next recommended action.
        """
        with performance_tracker.measure("arbitration"):
            votes = suggested_species_votes or {}
            
            # Count agreement with AI species
            agreed_votes = votes.get(ai_species, 0)
            calculated_total = sum(votes.values())
            effective_total = max(total_validations, calculated_total)

            if effective_total > 0:
                agreement_rate = round(agreed_votes / float(effective_total), 4)
            else:
                agreement_rate = 1.0  # Default if no votes yet (no contradiction)

            # Determine top species selected by community
            if votes:
                top_community_species = max(votes, key=votes.get)
                top_community_votes = votes[top_community_species]
                top_community_share = round(top_community_votes / float(effective_total), 4)
            else:
                top_community_species = ai_species
                top_community_votes = 0
                top_community_share = 1.0

            is_community_aligned = (top_community_species == ai_species)

            # Anomaly Score & Status Calculation
            if effective_total == 0:
                # No human votes yet
                if ai_confidence >= 0.70:
                    consensus_status = "CONFIRMED_MATCH"
                    anomaly_score = 0.05
                    recommended_action = "ACCEPT"
                else:
                    consensus_status = "LOW_CONFIDENCE_AMBIGUOUS"
                    anomaly_score = 0.35
                    recommended_action = "RE_INFER_HEAVY_MODEL"

            elif is_community_aligned:
                if agreement_rate >= 0.60:
                    consensus_status = "CONFIRMED_MATCH"
                    anomaly_score = round(max(0.0, 0.10 - (ai_confidence * 0.05)), 4)
                    recommended_action = "ACCEPT"
                else:
                    consensus_status = "LOW_CONFIDENCE_AMBIGUOUS"
                    anomaly_score = 0.40
                    recommended_action = "RE_INFER_HEAVY_MODEL"

            else:  # Community prefers a different species than AI!
                if ai_confidence >= 0.75 and top_community_share >= 0.50:
                    # Strong contradiction: AI is confident, but human community unifies on another species!
                    consensus_status = "ANOMALY_CONTRADICTION"
                    anomaly_score = round(0.85 + (0.15 * top_community_share), 4)
                    recommended_action = "RE_INFER_HEAVY_MODEL"

                elif top_community_share >= 0.70 and ai_confidence < 0.75:
                    # Community override: Human experts strongly agree on another species
                    consensus_status = "HUMAN_OVERRIDE"
                    anomaly_score = 0.60
                    recommended_action = "FLAG_FOR_EXPERT"

                else:
                    consensus_status = "LOW_CONFIDENCE_AMBIGUOUS"
                    anomaly_score = 0.50
                    recommended_action = "RE_INFER_HEAVY_MODEL"

            # Formulate clear rationale summary
            rationale = (
                f"Statut '{consensus_status}' (Score d'anomalie: {anomaly_score:.2f}). "
                f"IA = '{ai_species}' ({int(ai_confidence * 100)}%), "
                f"Communauté = '{top_community_species}' ({int(top_community_share * 100)}% sur {effective_total} votes). "
                f"Action recommandée : {recommended_action}."
            )

            return {
                "ai_species": ai_species,
                "ai_confidence": round(ai_confidence, 4),
                "top_community_species": top_community_species,
                "top_community_share": top_community_share,
                "total_validations": effective_total,
                "human_agreement_rate": agreement_rate,
                "anomaly_score": min(1.0, anomaly_score),
                "consensus_status": consensus_status,
                "recommended_action": recommended_action,
                "arbitration_rationale": rationale
            }


arbitration_engine = AIArbitrationEngine()

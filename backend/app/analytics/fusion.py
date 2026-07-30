"""
Module fournissant la fonction de fusion bayésienne spatio-temporelle utilisée dans le MVP d'Analytics.

Fonction principale : `bayesian_fusion`.

Cette fonction est pure (sans dépendances externes) et peut être testée indépendamment.
"""

from typing import Optional

__all__ = ["bayesian_fusion"]


def bayesian_fusion(visual_score: float, regional_prior: Optional[float] = None) -> float:
    """Calcul du *Score Final* selon la formule :

    Score Final = Score Visuel × Prior Régional

    Paramètres
    ----------
    visual_score: float
        Score provenant du modèle d'inférence (ex. YOLO/ByteTrack). Doit être entre 0.0 et 1.0.
    regional_prior: Optional[float]
        Probabilité a priori de présence de l'espèce dans la région et période donnée (entre 0.0 et 1.0).
        Si `None` (ex: absence de données eBird), la fonction utilise un *prior* par défaut 
        pour ne pas pénaliser complètement le score (par exemple 0.1 ou 0.5 selon la stratégie, ici 0.5 par défaut).

    Retourne
    -------
    float
        Le score final après fusion, borné entre 0.0 et 1.0.
    """
    # Validation du score visuel
    if not (0.0 <= visual_score <= 1.0):
        raise ValueError("visual_score doit être compris entre 0.0 et 1.0")

    # Gestion du prior régional
    if regional_prior is None:
        # Cas où aucune donnée eBird/GBIF n'est disponible (repli documenté)
        prior = 0.5
    else:
        if not (0.0 <= regional_prior <= 1.0):
            raise ValueError("regional_prior doit être compris entre 0.0 et 1.0")
        prior = regional_prior

    final_score = visual_score * prior
    
    return max(0.0, min(1.0, final_score))

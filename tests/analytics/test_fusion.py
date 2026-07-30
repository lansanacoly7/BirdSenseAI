import pytest
from backend.app.analytics.fusion import bayesian_fusion

def test_bayesian_fusion_common_species():
    """
    Cas 1: Espèce commune (prior élevé).
    Le score visuel est conservé en grande partie car le prior est fort.
    """
    visual_score = 0.8
    regional_prior = 0.9  # Très fréquent dans la région
    
    result = bayesian_fusion(visual_score, regional_prior)
    
    # 0.8 * 0.9 = 0.72
    assert result == pytest.approx(0.72)

def test_bayesian_fusion_rare_species():
    """
    Cas 2: Espèce rare (prior faible).
    Le score final est fortement pénalisé par le prior faible, 
    réduisant les faux positifs.
    """
    visual_score = 0.9
    regional_prior = 0.1  # Rare dans la région
    
    result = bayesian_fusion(visual_score, regional_prior)
    
    # 0.9 * 0.1 = 0.09
    assert result == pytest.approx(0.09)

def test_bayesian_fusion_missing_prior():
    """
    Cas 3: Absence de donnée eBird/GBIF (repli documenté).
    Le comportement de repli doit appliquer un prior neutre (ici 0.5)
    pour ne pas annuler le score visuel tout en restant prudent.
    """
    visual_score = 0.8
    # prior = None simule l'absence de données
    result = bayesian_fusion(visual_score, None)
    
    # Avec le prior de repli par défaut de 0.5 : 0.8 * 0.5 = 0.4
    assert result == pytest.approx(0.4)

def test_bayesian_fusion_invalid_visual_score():
    """Vérifie que la fonction rejette un score visuel invalide."""
    with pytest.raises(ValueError):
        bayesian_fusion(1.5, 0.5)
        
    with pytest.raises(ValueError):
        bayesian_fusion(-0.1, 0.5)

def test_bayesian_fusion_invalid_prior():
    """Vérifie que la fonction rejette un prior invalide."""
    with pytest.raises(ValueError):
        bayesian_fusion(0.5, 1.2)
        
    with pytest.raises(ValueError):
        bayesian_fusion(0.5, -0.2)

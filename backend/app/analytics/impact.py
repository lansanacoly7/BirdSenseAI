"""
T5.6 - Formule Impact Écologique et Génération Heatmap GeoJSON
"""
from typing import List, Dict, Any

def calculate_impact_score(observations: List[Dict[str, Any]]) -> float:
    """
    Calcule l'indice d'impact écologique du joueur.
    Formule: Somme des (10 / frequence_espece) * multiplicateur_diversité
    
    Pour simplifier dans ce MVP, on attribue:
    - 5 pts par observation standard
    - Bonus de diversité : +2 pts par espèce unique
    """
    if not observations:
        return 0.0
        
    unique_species = set(obs.get("species_name") for obs in observations)
    base_score = len(observations) * 5.0
    diversity_bonus = len(unique_species) * 2.0
    
    return base_score + diversity_bonus

def generate_heatmap_geojson(observations: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Transforme une liste d'observations en GeoJSON pour le calque Heatmap de Mapbox.
    """
    features = []
    
    for obs in observations:
        if "latitude" not in obs or "longitude" not in obs:
            continue
            
        feature = {
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": [obs["longitude"], obs["latitude"]]
            },
            "properties": {
                "weight": obs.get("confidence_score", 0.8),
                "species": obs.get("species_name", "Unknown")
            }
        }
        features.append(feature)
        
    return {
        "type": "FeatureCollection",
        "features": features
    }

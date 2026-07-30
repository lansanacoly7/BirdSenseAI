import pytest
from backend.app.analytics.impact import calculate_impact_score, generate_heatmap_geojson

def test_calculate_impact_score():
    """Vérifie le calcul du score d'impact avec diversité"""
    
    obs = [
        {"species_name": "Passer domesticus", "confidence_score": 0.9},
        {"species_name": "Passer domesticus", "confidence_score": 0.8},
        {"species_name": "Corvus corax", "confidence_score": 0.85},
    ]
    
    # 3 observations * 5 = 15
    # 2 espèces uniques * 2 = 4
    # Score attendu = 19.0
    
    score = calculate_impact_score(obs)
    assert score == 19.0

def test_calculate_impact_score_empty():
    """Vérifie le score si aucune observation"""
    assert calculate_impact_score([]) == 0.0

def test_generate_heatmap_geojson():
    """Vérifie le format GeoJSON attendu par Mapbox"""
    
    obs = [
        {"species_name": "Passer domesticus", "latitude": 14.7, "longitude": -17.4, "confidence_score": 0.9},
    ]
    
    geojson = generate_heatmap_geojson(obs)
    
    assert geojson["type"] == "FeatureCollection"
    assert len(geojson["features"]) == 1
    
    feature = geojson["features"][0]
    assert feature["type"] == "Feature"
    assert feature["geometry"]["type"] == "Point"
    assert feature["geometry"]["coordinates"] == [-17.4, 14.7]
    assert feature["properties"]["weight"] == 0.9
    assert feature["properties"]["species"] == "Passer domesticus"

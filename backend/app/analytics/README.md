# Module Analytics - BirdSense AI

Ce module gère la logique métier d'analyse, incluant la fusion bayésienne des scores et la collecte de données via des APIs tierces.

## 1. Fusion Bayésienne Spatio-Temporelle (T5.1)
Le module `fusion.py` contient l'algorithme pur pour pondérer le score du modèle d'inférence avec la probabilité de présence régionale de l'espèce.

```python
from backend.app.analytics.fusion import bayesian_fusion

# Exemple: Espèce très probable dans la région
score_final = bayesian_fusion(visual_score=0.85, regional_prior=0.90)
print(score_final) # 0.765
```

## 2. Connecteurs API Tierces (T5.2)
Le sous-module `connectors` permet d'interagir de manière asynchrone avec eBird, GBIF et BirdNET. Les erreurs de réseau, les timeouts et le rate-limiting (eBird) sont gérés avec des stratégies d'exponential backoff.

### Exemple d'appel réel

Voici comment initialiser et utiliser les connecteurs dans une boucle asynchrone :

```python
import asyncio
from backend.app.analytics.connectors import EBirdConnector, GBIFConnector, BirdNETConnector

async def main():
    # 1. eBird - Statut récent d'une espèce
    ebird = EBirdConnector(api_key="VOTRE_CLE_API_EBIRD")
    try:
        # Code région "SN" (Sénégal), Espèce "strdec" (Tourterelle turque par ex.)
        status = await eBird.fetch_species_status("SN", "strdec")
        print("Statut eBird:", status)
    except Exception as e:
        print("Erreur eBird:", e)

    # 2. GBIF - Occurrences
    gbif = GBIFConnector()
    try:
        # Recherche des occurrences du Moineau domestique au Sénégal
        occurrences = await gbif.fetch_occurrences("Passer domesticus", "SN")
        print(f"{len(occurrences)} occurrences trouvées sur GBIF.")
    except Exception as e:
        print("Erreur GBIF:", e)

    # 3. BirdNET - Analyse audio
    birdnet = BirdNETConnector(api_key="VOTRE_CLE_API_BIRDNET")
    try:
        predictions = await birdnet.fetch_audio_features("chant_oiseau.wav")
        print("Prédictions BirdNET:", predictions)
    except Exception as e:
        print("Erreur BirdNET:", e)

if __name__ == "__main__":
    asyncio.run(main())
```

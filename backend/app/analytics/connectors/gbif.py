import httpx
import asyncio
from typing import Dict, Any, List

class GBIFConnector:
    """Connecteur asynchrone pour l'API GBIF."""
    
    BASE_URL = "https://api.gbif.org/v1"
    
    def __init__(self, timeout: float = 5.0, max_retries: int = 3):
        self.timeout = timeout
        self.max_retries = max_retries

    async def fetch_occurrences(self, scientific_name: str, country_code: str = "SN", limit: int = 100) -> List[Dict[str, Any]]:
        """
        Récupère les occurrences récentes d'une espèce au Sénégal (SN par défaut).
        """
        # Résolution du nom scientifique vers un taxonKey (simplifié pour l'exemple)
        # Dans un cas réel on chercherait le taxonKey d'abord
        url = f"{self.BASE_URL}/occurrence/search"
        params = {
            "scientificName": scientific_name,
            "country": country_code,
            "limit": limit
        }
        
        for attempt in range(self.max_retries):
            try:
                async with httpx.AsyncClient(timeout=self.timeout) as client:
                    response = await client.get(url, params=params)
                    response.raise_for_status()
                    
                    data = response.json()
                    return data.get("results", [])
                    
            except (httpx.TimeoutException, httpx.NetworkError) as e:
                if attempt == self.max_retries - 1:
                    raise RuntimeError(f"Erreur réseau GBIF après {self.max_retries} tentatives: {str(e)}")
                await asyncio.sleep(2 ** attempt)
            except httpx.HTTPStatusError as e:
                if attempt == self.max_retries - 1:
                    raise RuntimeError(f"Erreur HTTP GBIF: {e.response.status_code}")
                await asyncio.sleep(2 ** attempt)
                
        return []

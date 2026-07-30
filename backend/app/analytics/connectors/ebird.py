import httpx
import asyncio
from typing import Dict, Any, Optional

class EBirdConnector:
    """Connecteur asynchrone pour l'API eBird."""
    
    BASE_URL = "https://api.ebird.org/v2"
    
    def __init__(self, api_key: str, timeout: float = 5.0, max_retries: int = 3):
        self.api_key = api_key
        self.timeout = timeout
        self.max_retries = max_retries

    async def fetch_species_status(self, region_code: str, species_code: str) -> Optional[Dict[str, Any]]:
        """
        Récupère le statut (observations récentes) d'une espèce dans une région donnée.
        """
        url = f"{self.BASE_URL}/data/obs/{region_code}/recent/{species_code}"
        headers = {"X-eBirdApiToken": self.api_key}
        
        for attempt in range(self.max_retries):
            try:
                async with httpx.AsyncClient(timeout=self.timeout) as client:
                    response = await client.get(url, headers=headers)
                    response.raise_for_status()
                    
                    data = response.json()
                    return data[0] if data else None
                    
            except (httpx.TimeoutException, httpx.NetworkError) as e:
                if attempt == self.max_retries - 1:
                    raise RuntimeError(f"Erreur réseau eBird après {self.max_retries} tentatives: {str(e)}")
                await asyncio.sleep(2 ** attempt)  # Exponential backoff
            except httpx.HTTPStatusError as e:
                if e.response.status_code == 429: # Rate limiting
                    if attempt == self.max_retries - 1:
                        raise RuntimeError("Rate limit eBird dépassé.")
                    await asyncio.sleep(2 ** attempt)
                else:
                    raise RuntimeError(f"Erreur HTTP eBird: {e.response.status_code}")
                    
        return None

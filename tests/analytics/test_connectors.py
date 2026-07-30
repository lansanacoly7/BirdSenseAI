import pytest
import httpx
from unittest.mock import patch, MagicMock
from backend.app.analytics.connectors.ebird import EBirdConnector
from backend.app.analytics.connectors.gbif import GBIFConnector
from backend.app.analytics.connectors.birdnet import BirdNETConnector

@pytest.mark.asyncio
async def test_ebird_connector():
    """Test du connecteur eBird avec réponse mockée."""
    connector = EBirdConnector(api_key="TEST_KEY")
    
    mock_response = MagicMock()
    mock_response.json.return_value = [{"speciesCode": "test_species", "howMany": 5}]
    mock_response.raise_for_status.return_value = None
    
    with patch("httpx.AsyncClient.get", return_value=mock_response) as mock_get:
        result = await connector.fetch_species_status("SN", "test_species")
        
        # Vérifie qu'on a bien appelé l'API avec les bons headers
        mock_get.assert_called_once()
        args, kwargs = mock_get.call_args
        assert kwargs["headers"]["X-eBirdApiToken"] == "TEST_KEY"
        
        # Vérifie que le premier élément est retourné
        assert result == {"speciesCode": "test_species", "howMany": 5}

@pytest.mark.asyncio
async def test_gbif_connector():
    """Test du connecteur GBIF avec réponse mockée."""
    connector = GBIFConnector()
    
    mock_response = MagicMock()
    mock_response.json.return_value = {"results": [{"scientificName": "Passer domesticus"}]}
    mock_response.raise_for_status.return_value = None
    
    with patch("httpx.AsyncClient.get", return_value=mock_response) as mock_get:
        result = await connector.fetch_occurrences("Passer domesticus", "SN")
        
        mock_get.assert_called_once()
        args, kwargs = mock_get.call_args
        assert kwargs["params"]["country"] == "SN"
        assert kwargs["params"]["scientificName"] == "Passer domesticus"
        
        assert len(result) == 1
        assert result[0]["scientificName"] == "Passer domesticus"

@pytest.mark.asyncio
async def test_birdnet_connector():
    """Test du connecteur BirdNET avec réponse mockée."""
    connector = BirdNETConnector(api_key="TEST_KEY")
    
    mock_response = MagicMock()
    mock_response.json.return_value = {"predictions": [{"species": "Corvus corax", "confidence": 0.95}]}
    mock_response.raise_for_status.return_value = None
    
    with patch("httpx.AsyncClient.post", return_value=mock_response) as mock_post:
        result = await connector.fetch_audio_features("dummy_path.wav")
        
        mock_post.assert_called_once()
        args, kwargs = mock_post.call_args
        assert kwargs["headers"]["Authorization"] == "Bearer TEST_KEY"
        
        assert len(result) == 1
        assert result[0]["confidence"] == 0.95

@pytest.mark.asyncio
async def test_connector_network_error():
    """Vérifie le comportement de retry et de TimeoutException (levée après max_retries)."""
    connector = GBIFConnector(timeout=0.1, max_retries=2)
    
    with patch("httpx.AsyncClient.get", side_effect=httpx.TimeoutException("Timeout simulate")) as mock_get:
        # Patch sleep pour ne pas vraiment attendre pendant le test
        with patch("asyncio.sleep"):
            with pytest.raises(RuntimeError, match="Erreur réseau GBIF après 2 tentatives"):
                await connector.fetch_occurrences("Test", "SN")
            
            # Vérifie qu'on a bien fait 2 tentatives
            assert mock_get.call_count == 2

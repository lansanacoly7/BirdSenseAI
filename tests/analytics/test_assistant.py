import pytest
from backend.app.analytics.llm_assistant import get_bird_assistant_response
from unittest.mock import AsyncMock, patch

@pytest.mark.asyncio
async def test_get_bird_assistant_response():
    """Test du module RAG (Assistant) avec un mock de l'API OpenAI"""
    
    mock_response = AsyncMock()
    mock_response.choices = [AsyncMock()]
    mock_response.choices[0].message.content = "Bonjour, voici un conseil sur les passereaux !"
    
    # On patche la fonction create du client OpenAI
    with patch("backend.app.analytics.llm_assistant.client.chat.completions.create", return_value=mock_response):
        reply = await get_bird_assistant_response(
            user_message="Quels oiseaux je peux voir ici ?",
            local_species=["Passer domesticus"],
            user_stats={"total_scans": 10, "impact_score": 50}
        )
        
    assert "Bonjour" in reply
    assert "passereaux" in reply

@pytest.mark.asyncio
async def test_get_bird_assistant_response_fallback():
    """Test du comportement en cas d'erreur API (ex: clé manquante)"""
    
    with patch("backend.app.analytics.llm_assistant.client.chat.completions.create", side_effect=Exception("API Error")):
        reply = await get_bird_assistant_response(
            user_message="Hello",
            local_species=[],
            user_stats={}
        )
        
    assert "Piou piou" in reply
    assert "Erreur ou clé manquante" in reply

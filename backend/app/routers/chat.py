"""
BirdSense AI — Router Chat (WebSockets)
Auteur : Pape Alioune Sène
"""
import asyncio
import json
import logging
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from app.analytics.llm_assistant import get_bird_assistant_response

from app.analytics.llm_assistant import get_bird_assistant_response

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/chat", tags=["Chat & IA"])


@router.websocket("/stream")
async def chat_stream(websocket: WebSocket):
    """
    Endpoint WebSocket pour la Phase 2 :
    Permet de recevoir un message et de streamer la réponse
    mot par mot (effet machine à écrire) à partir du RAG/LLM (Groq/Gemini).
    """
    await websocket.accept()
    logger.info("Nouvelle connexion WebSocket acceptée sur /chat/stream")
    
    # Initialisation de l'historique de conversation pour cette session WebSocket
    history = []
    
    try:
        while True:
            # Réception du message de l'utilisateur
            data = await websocket.receive_text()
            logger.info(f"Message reçu via WS: {data}")
            
            # Valeurs contextuelles (en prod, à récupérer via un appel DB ou le token)
            local_species = ["Aigle royal", "Héron garde-bœufs"]
            user_stats = {"total_scans": 5, "impact_score": 120}
            
            # Appel asynchrone au LLM (RAG développé par Pathé Fall / Groq/Gemini)
            llm_response = await get_bird_assistant_response(data, local_species, user_stats, history)
            
            # Mise à jour de l'historique
            history.append({"role": "user", "content": data})
            
            # Streaming de la réponse (chunking simulé pour l'instant)sponse})
            
            # Limiter l'historique aux 20 derniers messages pour éviter de saturer le token limit
            if len(history) > 20:
                history = history[-20:]
            
            history.append({"role": "assistant", "content": llm_response})

            # Streaming de la réponse en simulant un délai de calcul LLM
>>>>>>> 7f270642fd47218a73ee12e0223334765b266e64
            words = llm_response.split(" ")
            for word in words:
                chunk = {"chunk": word + " "}
                await websocket.send_text(json.dumps(chunk))
                await asyncio.sleep(0.05)  # 50ms entre chaque mot
            
            # Signal de fin de message
            await websocket.send_text(json.dumps({"done": True}))
            
    except WebSocketDisconnect:
        logger.info("Connexion WebSocket fermée par le client.")
    except Exception as e:
        logger.error(f"Erreur WebSocket: {str(e)}")
        await websocket.close(code=1011)

"""
BirdSense AI — Router Chat (WebSockets)
Auteur : Pape Alioune Sène
"""
import asyncio
import json
import logging
from fastapi import APIRouter, WebSocket, WebSocketDisconnect

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/chat", tags=["Chat & IA"])


@router.websocket("/stream")
async def chat_stream(websocket: WebSocket):
    """
    Endpoint WebSocket pour la Phase 2 :
    Permet de recevoir un message et de streamer la réponse
    mot par mot (effet machine à écrire).
    """
    await websocket.accept()
    logger.info("Nouvelle connexion WebSocket acceptée sur /chat/stream")
    
    try:
        while True:
            # Réception du message de l'utilisateur
            data = await websocket.receive_text()
            logger.info(f"Message reçu via WS: {data}")
            
            # Simulation d'une réponse de l'IA (en attendant l'intégration RAG de Pathé)
            mock_response = (
                f"Je suis l'Assistant Ornithologue. Vous m'avez dit : '{data}'. "
                "Ceci est une réponse streamée mot par mot pour valider la fonctionnalité "
                "de la Phase 2. Bientôt, je serai connecté au LLM."
            )
            
            # Streaming de la réponse en simulant un délai de calcul LLM
            words = mock_response.split(" ")
            for word in words:
                # On renvoie chaque mot sous forme de JSON (ou texte brut)
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

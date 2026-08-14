"""
BirdSense AI — Router Chat (WebSockets)
Auteur : Pape Alioune Sène
"""
import asyncio
import json
import logging
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from sqlalchemy import select
from sqlalchemy.orm import selectinload

from app.analytics.llm_assistant import get_bird_assistant_response
from app.database import AsyncSessionLocal
from app.models.observation import Observation, ObservationItem
from app.models.species import Species

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
            
            # Détection d'intention communautaire
            community_keywords = ["communauté", "autour de moi", "rares", "récent", "autres"]
            is_community = any(kw in data.lower() for kw in community_keywords)
            
            community_context = ""
            if is_community:
                logger.info("Intention communautaire détectée, récupération du contexte.")
                try:
                    async with AsyncSessionLocal() as session:
                        stmt = select(Observation).where(Observation.is_hidden == False).order_by(Observation.observed_at.desc()).limit(5)
                        stmt = stmt.options(selectinload(Observation.items).selectinload(ObservationItem.species))
                        result = await session.execute(stmt)
                        recent_obs = result.scalars().all()
                        
                        obs_list = []
                        for o in recent_obs:
                            species_names = [i.species.common_name if i.species else i.species_raw_name for i in o.items]
                            sp_str = ", ".join(filter(None, species_names)) or "Espèce inconnue"
                            obs_list.append(f"- Le {o.observed_at.strftime('%Y-%m-%d %H:%M')}: {sp_str}")
                        
                        community_context = "Observations récentes de la communauté:\n" + "\n".join(obs_list) if obs_list else "Aucune observation récente trouvée."
                except Exception as e:
                    logger.error(f"Erreur DB RAG: {e}")
                    community_context = "La base de données communautaire est temporairement indisponible."
            
            # Appel asynchrone au LLM (Groq/Gemini/OpenAI)
            llm_response = await get_bird_assistant_response(data, local_species, user_stats, history, community_context)
            
            # Mise à jour de l'historique
            history.append({"role": "user", "content": data})
            
            # Streaming de la réponse (chunking simulé pour l'instant)sponse})
            
            # Limiter l'historique aux 20 derniers messages pour éviter de saturer le token limit
            if len(history) > 20:
                history = history[-20:]
            
            history.append({"role": "assistant", "content": llm_response})

            # Streaming de la réponse en simulant un délai de calcul LLM
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

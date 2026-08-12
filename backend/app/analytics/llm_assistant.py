"""
T5.5 - Prompt Engineering RAG (Assistant Ornithologue avec Groq ou Gemini)
Auteur : BirdSense AI Team
"""
import os
import logging
import httpx
from typing import List, Dict
from pathlib import Path

from app.config import get_settings

logger = logging.getLogger(__name__)

# Chemin dynamique vers le fichier de personnalité (remonte à la racine du projet)
BASE_DIR = Path(__file__).resolve().parent.parent.parent.parent
PERSONALITY_FILE = BASE_DIR / "BirdSense_Personality.md"

def get_base_personality() -> str:
    """Charge la personnalité dynamiquement depuis le fichier Markdown."""
    if PERSONALITY_FILE.exists():
        try:
            with open(PERSONALITY_FILE, "r", encoding="utf-8") as f:
                return f.read()
        except Exception as e:
            logger.error(f"Erreur lors de la lecture de la personnalité: {e}")
    
    # Fallback par défaut si le fichier n'est pas trouvé
    return "Tu es un ornithologue expert et un assistant virtuel pour l'application BirdSense AI."


async def get_bird_assistant_response(
    user_message: str, 
    local_species: List[str], 
    user_stats: Dict[str, int],
    history: List[Dict[str, str]] = None
) -> str:
    """
    Interroge l'assistant via Groq ou Gemini sans dépendance externe lourde.
    """
    base_prompt = get_base_personality()
    
    context_prompt = f"""
---
[CONTEXTE UTILISATEUR DYNAMIQUE - NE PAS IGNORER]
Voici les informations spécifiques à l'utilisateur actuel pour t'aider à personnaliser ta réponse :
- Espèces récemment vues dans la zone : {', '.join(local_species) if local_species else 'Aucune pour le moment.'}
- Scan réussis : {user_stats.get('total_scans', 0)}
- Score d'impact : {user_stats.get('impact_score', 0)}
---
"""

    system_prompt = f"{base_prompt}\n{context_prompt}"

    settings = get_settings()
    current_groq_key = settings.groq_api_key
    current_gemini_key = settings.gemini_api_key

    if current_groq_key:
        url = "https://api.groq.com/openai/v1/chat/completions"
        headers = {"Authorization": f"Bearer {current_groq_key}"}
        model = "llama-3.3-70b-versatile"
    elif current_gemini_key:
        url = "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
        headers = {"Authorization": f"Bearer {current_gemini_key}"}
        model = "gemini-1.5-flash"
    else:
        logger.warning("Aucune clé GROQ_API_KEY ni GEMINI_API_KEY trouvée.")
        return "Piou piou ! L'assistant IA a besoin d'une clé GROQ_API_KEY ou GEMINI_API_KEY configurée dans le fichier backend/.env pour vous répondre."

    if history is None:
        history = []
        
    messages = [{"role": "system", "content": system_prompt}]
    messages.extend(history)
    messages.append({"role": "user", "content": user_message})

    payload = {
        "model": model,
        "messages": messages,
        "temperature": 0.7,
        "max_tokens": 400
    }

    try:
        async with httpx.AsyncClient(timeout=15.0) as client:
            resp = await client.post(url, headers=headers, json=payload)
            if resp.status_code == 200:
                data = resp.json()
                return data["choices"][0]["message"]["content"]
            else:
                logger.error(f"Erreur API LLM HTTP {resp.status_code}: {resp.text}")
                return f"Piou piou ! Une erreur HTTP {resp.status_code} est survenue lors du traitement avec l'IA."
    except Exception as e:
        logger.error(f"LLM Error: {e}")
        return "Piou piou ! Mon cerveau IA n'a pas pu traiter la demande. Vérifiez votre connexion et les clés d'API."

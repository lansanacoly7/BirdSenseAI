"""
T5.5 - Prompt Engineering RAG (Assistant Ornithologue)
"""
import os
from openai import AsyncOpenAI
from typing import List, Dict

# On initialise le client asynchrone (attendra une clé dans l'env)
client = AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY", "dummy-key-for-tests"))

async def get_bird_assistant_response(
    user_message: str, 
    local_species: List[str], 
    user_stats: Dict[str, int]
) -> str:
    """
    Interroge le LLM avec un contexte métier (RAG simplifié).
    
    Args:
        user_message: La question de l'utilisateur.
        local_species: Liste des oiseaux récemment détectés dans la région.
        user_stats: Les statistiques d'impact du joueur (ex: total_scans, score).
        
    Returns:
        La réponse textuelle de l'assistant (avec l'effet machine à écrire géré côté frontend).
    """
    
    # Prompt System (System Instructions)
    system_prompt = f"""Tu es un ornithologue expert et un assistant virtuel pour l'application BirdSense AI.
Ta mission est d'aider les passionnés d'oiseaux avec des conseils de terrain, des faits écologiques et des recommandations de conservation.

Contexte actuel du joueur :
- Espèces récemment vues dans la zone : {', '.join(local_species) if local_species else 'Aucune pour le moment.'}
- Scan réussis : {user_stats.get('total_scans', 0)}
- Score d'impact : {user_stats.get('impact_score', 0)}

Directives :
1. Sois encourageant et éducatif (utilise un ton enthousiaste).
2. Fais référence au contexte actuel si pertinent (ex: féliciter pour le score ou évoquer une espèce vue).
3. Reste concis (maximum 3 paragraphes).
4. Si la question n'a rien à voir avec la nature, les oiseaux ou le jeu, recadre poliment la conversation.
"""

    messages = [
        {"role": "system", "content": system_prompt},
        {"role": "user", "content": user_message}
    ]

    try:
        response = await client.chat.completions.create(
            model="gpt-4o-mini",
            messages=messages,
            temperature=0.7,
            max_tokens=400
        )
        return response.choices[0].message.content
    except Exception as e:
        # Fallback pour le hackathon si pas de clé API OpenAI ou erreur
        return "Piou piou ! Mon cerveau IA n'est pas encore connecté à l'API. (Erreur ou clé manquante). Mais continuez à explorer !"

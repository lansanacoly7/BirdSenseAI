"""
BirdSense AI — Routeur Notifications WebSocket (T3.4)
Auteur : Pape Alioune Sène

Endpoints:
  WS  /api/v1/notifications/ws/{user_id}  : Canal WebSocket temps-réel par utilisateur
  GET /api/v1/notifications/status         : Statut des connexions actives (admin debug)
"""
import uuid

from fastapi import APIRouter, Depends, HTTPException, Query, WebSocket, WebSocketDisconnect, status
from jose import JWTError

from app.services.auth_service import decode_token, get_user_by_id
from app.services.notification_service import manager
from app.database import get_db
from sqlalchemy.ext.asyncio import AsyncSession

router = APIRouter(prefix="/api/v1/notifications", tags=["Notifications"])


@router.websocket("/ws/{user_id}")
async def websocket_notifications(
    user_id: uuid.UUID,
    websocket: WebSocket,
    token: str = Query(..., description="Bearer access token pour authentification"),
    db: AsyncSession = Depends(get_db),
) -> None:
    """
    Canal WebSocket de notifications en temps réel.

    Le client mobile se connecte ainsi :
        ws://HOST/api/v1/notifications/ws/{user_id}?token=<access_token>

    Messages reçus (JSON) :
    ```json
    {
      "type": "validation_received" | "comment_received" | "report_reviewed" | ...,
      "timestamp": "2026-08-13T20:00:00Z",
      "payload": { ... }
    }
    ```

    Le canal reste ouvert jusqu'à déconnexion du client.
    Un ping "heartbeat" est envoyé toutes les 30 secondes pour maintenir la connexion.
    """
    # 1. Valider le token JWT avant d'accepter la connexion
    try:
        payload = decode_token(token)
        if payload.type != "access":
            await websocket.close(code=4001)
            return
        token_user_id = uuid.UUID(payload.sub)
    except (JWTError, ValueError):
        await websocket.close(code=4001)
        return

    # 2. S'assurer que l'utilisateur ne peut écouter que son propre canal
    if token_user_id != user_id:
        await websocket.close(code=4003)
        return

    # 3. Vérifier que l'utilisateur existe et est actif
    user = await get_user_by_id(db, user_id)
    if not user or not user.is_active:
        await websocket.close(code=4004)
        return

    # 4. Connecter l'utilisateur
    await manager.connect(user_id, websocket)
    try:
        # Envoyer un message de bienvenue
        import json
        await websocket.send_text(json.dumps({
            "type": "connected",
            "payload": {
                "user_id": str(user_id),
                "message": f"Bienvenue {user.username} ! Notifications activées.",
            }
        }))

        # Maintenir la connexion ouverte — attendre les messages clients (ping/pong)
        while True:
            try:
                data = await websocket.receive_text()
                # Le client peut envoyer un ping pour maintenir la connexion
                if data == "ping":
                    await websocket.send_text('{"type":"pong"}')
            except WebSocketDisconnect:
                break

    finally:
        manager.disconnect(user_id, websocket)


@router.get(
    "/status",
    summary="[Debug] Statut des connexions WebSocket actives",
)
async def notifications_status() -> dict:
    """
    Endpoint de diagnostic — retourne le nombre d'utilisateurs connectés.
    À protéger ou retirer en production.
    """
    return {
        "active_users": manager.active_users_count,
        "status": "ok",
    }

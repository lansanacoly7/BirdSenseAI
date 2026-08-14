"""
BirdSense AI — Service de Notifications WebSocket (T3.4)
Auteur : Pape Alioune Sène

Architecture :
- ConnectionManager : Gère les connexions WebSocket actives par user_id.
- Notification types : validation, comment, report_reviewed.
- Les clients mobiles se connectent à /api/v1/notifications/ws/{user_id}
  avec leur Bearer token pour recevoir des alertes en temps réel.
"""
import json
import logging
import uuid
from datetime import datetime
from enum import Enum

from fastapi import WebSocket

logger = logging.getLogger(__name__)


# =============================================================================
# Types de Notifications
# =============================================================================

class NotificationType(str, Enum):
    """Types d'événements pouvant déclencher une notification."""
    VALIDATION_RECEIVED   = "validation_received"    # Quelqu'un a validé mon observation
    COMMENT_RECEIVED      = "comment_received"       # Quelqu'un a commenté mon observation
    REPORT_REVIEWED       = "report_reviewed"        # Mon signalement a été traité
    OBSERVATION_FLAGGED   = "observation_flagged"    # Mon observation a été flaggée (trop de reports)
    BADGE_UNLOCKED        = "badge_unlocked"         # Gamification — badge débloqué (future T5.3)


# =============================================================================
# Gestionnaire de Connexions WebSocket (In-Process)
# =============================================================================

class ConnectionManager:
    """
    Gère les connexions WebSocket actives.
    
    Pour un MVP Hackathon, on utilise un dictionnaire in-process.
    En production, on remplacerait par Redis Pub/Sub pour le multi-worker.
    """

    def __init__(self) -> None:
        # user_id → liste de WebSocket actifs (un user peut avoir plusieurs onglets)
        self._connections: dict[uuid.UUID, list[WebSocket]] = {}

    async def connect(self, user_id: uuid.UUID, websocket: WebSocket) -> None:
        """Accepte et enregistre une nouvelle connexion WebSocket."""
        await websocket.accept()
        if user_id not in self._connections:
            self._connections[user_id] = []
        self._connections[user_id].append(websocket)
        logger.info(f"WS connecté : user_id={user_id} (total={len(self._connections[user_id])})")

    def disconnect(self, user_id: uuid.UUID, websocket: WebSocket) -> None:
        """Retire une connexion WebSocket fermée."""
        if user_id in self._connections:
            try:
                self._connections[user_id].remove(websocket)
            except ValueError:
                pass
            if not self._connections[user_id]:
                del self._connections[user_id]
        logger.info(f"WS déconnecté : user_id={user_id}")

    async def send_notification(
        self,
        user_id: uuid.UUID,
        notification_type: NotificationType,
        payload: dict,
    ) -> int:
        """
        Envoie une notification JSON à toutes les connexions actives d'un utilisateur.

        Returns:
            Nombre de connexions qui ont reçu le message.
        """
        connections = self._connections.get(user_id, [])
        if not connections:
            return 0

        message = json.dumps({
            "type": notification_type.value,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "payload": payload,
        }, ensure_ascii=False)

        sent = 0
        dead_sockets: list[WebSocket] = []

        for ws in connections:
            try:
                await ws.send_text(message)
                sent += 1
            except Exception as exc:
                logger.warning(f"Impossible d'envoyer à {user_id}: {exc}")
                dead_sockets.append(ws)

        # Nettoyage des sockets mortes
        for ws in dead_sockets:
            self.disconnect(user_id, ws)

        return sent

    def is_connected(self, user_id: uuid.UUID) -> bool:
        """Vérifie si un utilisateur a au moins une connexion active."""
        return bool(self._connections.get(user_id))

    @property
    def active_users_count(self) -> int:
        """Retourne le nombre d'utilisateurs actuellement connectés."""
        return len(self._connections)


# Singleton — partagé dans tout le process FastAPI
manager = ConnectionManager()


# =============================================================================
# Helpers de notification métier
# =============================================================================

async def notify_validation(
    observation_owner_id: uuid.UUID,
    validator_username: str,
    observation_id: uuid.UUID,
    is_confirmation: bool,
    proposed_species_name: str | None = None,
) -> None:
    """Notifie le propriétaire d'une observation qu'une validation a été soumise."""
    if is_confirmation:
        message = f"{validator_username} a confirmé votre identification."
    else:
        species_part = f" ({proposed_species_name})" if proposed_species_name else ""
        message = f"{validator_username} propose une autre espèce{species_part} pour votre observation."

    await manager.send_notification(
        user_id=observation_owner_id,
        notification_type=NotificationType.VALIDATION_RECEIVED,
        payload={
            "observation_id": str(observation_id),
            "validator": validator_username,
            "is_confirmation": is_confirmation,
            "proposed_species": proposed_species_name,
            "message": message,
        },
    )


async def notify_comment(
    observation_owner_id: uuid.UUID,
    commenter_username: str,
    observation_id: uuid.UUID,
    comment_preview: str,
) -> None:
    """Notifie le propriétaire d'une observation qu'un commentaire a été ajouté."""
    await manager.send_notification(
        user_id=observation_owner_id,
        notification_type=NotificationType.COMMENT_RECEIVED,
        payload={
            "observation_id": str(observation_id),
            "commenter": commenter_username,
            "preview": comment_preview[:100],
            "message": f"{commenter_username} a commenté votre observation.",
        },
    )


async def notify_report_reviewed(
    reporter_id: uuid.UUID,
    observation_id: uuid.UUID,
    new_status: str,
) -> None:
    """Notifie l'auteur d'un signalement que son rapport a été traité."""
    status_labels = {
        "reviewed": "pris en compte",
        "dismissed": "classé sans suite",
    }
    label = status_labels.get(new_status, new_status)
    await manager.send_notification(
        user_id=reporter_id,
        notification_type=NotificationType.REPORT_REVIEWED,
        payload={
            "observation_id": str(observation_id),
            "status": new_status,
            "message": f"Votre signalement a été {label}.",
        },
    )

import asyncio
import json
import websockets

async def test_chat():
    uri = "ws://localhost:8000/api/v1/chat/stream"
    try:
        async with websockets.connect(uri) as websocket:
            print("Connecté au WebSocket !")
            
            message = "Salut l'ornithologue, as-tu vu un aigle ?"
            print(f"Envoi du message : {message}")
            await websocket.send(message)
            
            print("Réception de la réponse en streaming :")
            while True:
                response = await websocket.recv()
                data = json.loads(response)
                
                if "done" in data and data["done"]:
                    print("\n--- Fin du streaming ---")
                    break
                    
                if "chunk" in data:
                    print(data["chunk"], end="", flush=True)
                    
    except Exception as e:
        print(f"Erreur lors du test: {e}")

if __name__ == "__main__":
    asyncio.run(test_chat())

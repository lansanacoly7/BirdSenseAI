"""
BirdSense AI - Backend API Main Entrypoint
FastAPI application mounting computer vision services, routers, and CORS configuration.
"""

import sys
from pathlib import Path

# Ensure project root is in Python path for direct execution
ROOT_DIR = Path(__file__).resolve().parent.parent
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.api.vision_router import router as vision_router

app = FastAPI(
    title="BirdSense AI - API Engine",
    description="Application backend d'identification, de comptage et de suivi d'oiseaux par Vision par Ordinateur et IA.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS for Flutter Mobile Client integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register Vision API Router
app.include_router(vision_router)


@app.get("/", tags=["Health"])
def root_status():
    return {
        "status": "online",
        "app": "BirdSense AI Core Service",
        "version": "1.0.0",
        "documentation": "/docs"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from app.models.observation import Observation
import random

BIRD_IMAGES = [
    "https://images.unsplash.com/photo-1555169062-013468b47731?w=800&q=80",
    "https://images.unsplash.com/photo-1605092676920-8ac5aece0e8c?w=800&q=80",
    "https://images.unsplash.com/photo-1552728089-571ed927bdf1?w=800&q=80",
    "https://images.unsplash.com/photo-1574068468668-a05a11f871da?w=800&q=80",
    "https://images.unsplash.com/photo-1522926193341-e9eb1b36bb86?w=800&q=80"
]

engine = create_engine("sqlite:///./birdsense.db")
with Session(engine) as session:
    observations = session.query(Observation).all()
    count = 0
    for obs in observations:
        if not obs.media_url:
            img = random.choice(BIRD_IMAGES)
            obs.media_url = img
            obs.thumbnail_url = img
            count += 1
    session.commit()
    print(f"{count} images mises à jour !")

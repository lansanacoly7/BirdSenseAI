from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from app.models.species import Species

SPECIES_IMAGES = {
    "Passer domesticus": "https://images.unsplash.com/photo-1620959085955-467b4c91d4e2?w=800&q=80", 
    "Corvus albus": "https://images.unsplash.com/photo-1590457632616-0e1ce5b50f7f?w=800&q=80", 
    "Bubulcus ibis": "https://images.unsplash.com/photo-1587635639144-88db09a96ea8?w=800&q=80", 
    "Ardea cinerea": "https://images.unsplash.com/photo-1549479361-ec880bf5952d?w=800&q=80", 
    "Egretta garzetta": "https://images.unsplash.com/photo-1614088514931-15551f1f7d1b?w=800&q=80", 
    "Falco tinnunculus": "https://images.unsplash.com/photo-1534062060645-0d049fc1d51c?w=800&q=80", 
    "Streptopelia decaocto": "https://images.unsplash.com/photo-1589311234771-46c05d76d8da?w=800&q=80", 
    "Merops pusillus": "https://images.unsplash.com/photo-1586616422896-e630ffbbaee2?w=800&q=80", 
    "Halcyon senegalensis": "https://images.unsplash.com/photo-1552728089-571ed927bdf1?w=800&q=80", 
    "Nectarinia senegalensis": "https://images.unsplash.com/photo-1574068468668-a05a11f871da?w=800&q=80", 
}

engine = create_engine("sqlite:///./birdsense.db")
with Session(engine) as session:
    species_list = session.query(Species).all()
    count = 0
    for sp in species_list:
        if sp.scientific_name in SPECIES_IMAGES:
            sp.image_url = SPECIES_IMAGES[sp.scientific_name]
            count += 1
    session.commit()
    print(f"{count} images d'especes mises a jour !")

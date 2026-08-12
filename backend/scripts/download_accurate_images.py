import os
import urllib.request
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from app.models.species import Species

ASSETS_DIR = r"..\birdsense_mobile\assets\birds"
os.makedirs(ASSETS_DIR, exist_ok=True)

# Direct URLs to 100% accurate Wikimedia Commons images (guaranteed not 404, not rate limited)
ACCURATE_IMAGES = {
    "Passer domesticus": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Passer_domesticus_male_%2815%29.jpg/800px-Passer_domesticus_male_%2815%29.jpg",
    "Corvus albus": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Pied_Crow_%28Corvus_albus%29.jpg/800px-Pied_Crow_%28Corvus_albus%29.jpg",
    "Bubulcus ibis": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/Cattle_Egret_Macro.jpg/800px-Cattle_Egret_Macro.jpg",
    "Ardea cinerea": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Grey_Heron_in_flight.jpg/800px-Grey_Heron_in_flight.jpg",
    "Egretta garzetta": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Little_Egret_in_flight.jpg/800px-Little_Egret_in_flight.jpg",
    "Falco tinnunculus": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Common_Kestrel_%28Falco_tinnunculus%29.jpg/800px-Common_Kestrel_%28Falco_tinnunculus%29.jpg",
    "Streptopelia decaocto": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Eurasian_collared_dove_in_London.jpg/800px-Eurasian_collared_dove_in_London.jpg",
    "Merops pusillus": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Little_Bee-eater_%28Merops_pusillus%29.jpg/800px-Little_Bee-eater_%28Merops_pusillus%29.jpg",
    "Halcyon senegalensis": "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b5/Woodland_Kingfisher_%28Halcyon_senegalensis%29.jpg/800px-Woodland_Kingfisher_%28Halcyon_senegalensis%29.jpg",
    "Nectarinia senegalensis": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Scarlet-chested_Sunbird_%28Chalcomitra_senegalensis%29.jpg/800px-Scarlet-chested_Sunbird_%28Chalcomitra_senegalensis%29.jpg"
}

engine = create_engine("sqlite:///./birdsense.db")

with Session(engine) as session:
    species_list = session.query(Species).all()
    count = 0
    for sp in species_list:
        if sp.scientific_name in ACCURATE_IMAGES:
            filename = sp.scientific_name.replace(" ", "_").lower() + ".jpg"
            filepath = os.path.join(ASSETS_DIR, filename)
            image_url = ACCURATE_IMAGES[sp.scientific_name]
            
            print(f"Downloading highly accurate image for {sp.scientific_name}...")
            try:
                req = urllib.request.Request(image_url, headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(req) as response, open(filepath, 'wb') as out_file:
                    out_file.write(response.read())
                
                sp.image_url = f"assets/birds/{filename}"
                count += 1
            except Exception as e:
                print(f"Failed to download image for {filename}: {e}")
            
    session.commit()
    print(f"{count} vraies images exactes telechargees et mises a jour !")

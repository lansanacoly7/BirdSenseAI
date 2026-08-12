import os
import urllib.request
import json
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from app.models.species import Species

ASSETS_DIR = r"..\birdsense_mobile\assets\birds"
os.makedirs(ASSETS_DIR, exist_ok=True)

engine = create_engine("sqlite:///./birdsense.db")

def get_wiki_image(scientific_name):
    # Use Wikipedia REST API
    url = f"https://fr.wikipedia.org/api/rest_v1/page/summary/{scientific_name.replace(' ', '_')}"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'BirdSenseAI/1.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
            if 'originalimage' in data:
                return data['originalimage']['source']
            elif 'thumbnail' in data:
                return data['thumbnail']['source']
    except Exception as e:
        print(f"Error fetching from fr.wikipedia for {scientific_name}: {e}")
        
    url_en = f"https://en.wikipedia.org/api/rest_v1/page/summary/{scientific_name.replace(' ', '_')}"
    try:
        req = urllib.request.Request(url_en, headers={'User-Agent': 'BirdSenseAI/1.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
            if 'originalimage' in data:
                return data['originalimage']['source']
            elif 'thumbnail' in data:
                return data['thumbnail']['source']
    except Exception as e:
        print(f"Error fetching from en.wikipedia for {scientific_name}: {e}")
    
    return None

with Session(engine) as session:
    species_list = session.query(Species).all()
    count = 0
    for sp in species_list:
        filename = sp.scientific_name.replace(" ", "_").lower() + ".jpg"
        filepath = os.path.join(ASSETS_DIR, filename)
        
        image_url = get_wiki_image(sp.scientific_name)
        if image_url:
            print(f"Downloading real image for {sp.scientific_name} from {image_url}...")
            try:
                req = urllib.request.Request(image_url, headers={'User-Agent': 'BirdSenseAI/1.0'})
                with urllib.request.urlopen(req) as response, open(filepath, 'wb') as out_file:
                    out_file.write(response.read())
                
                sp.image_url = f"assets/birds/{filename}"
                count += 1
            except Exception as e:
                print(f"Failed to download image for {filename}: {e}")
        else:
            print(f"No Wikipedia image found for {sp.scientific_name}")
            
    session.commit()
    print(f"{count} vraies images exactes telechargees et mises a jour !")

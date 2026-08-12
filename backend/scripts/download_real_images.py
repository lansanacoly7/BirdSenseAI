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
    # Try French Wikipedia first
    url = f"https://fr.wikipedia.org/w/api.php?action=query&titles={scientific_name.replace(' ', '_')}&prop=pageimages&format=json&pithumbsize=800"
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
            pages = data['query']['pages']
            for page_id in pages:
                if 'thumbnail' in pages[page_id]:
                    return pages[page_id]['thumbnail']['source']
    except Exception as e:
        print(f"Error fetching from fr.wikipedia for {scientific_name}: {e}")
        
    # Fallback to English Wikipedia
    url_en = f"https://en.wikipedia.org/w/api.php?action=query&titles={scientific_name.replace(' ', '_')}&prop=pageimages&format=json&pithumbsize=800"
    try:
        req = urllib.request.Request(url_en, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read())
            pages = data['query']['pages']
            for page_id in pages:
                if 'thumbnail' in pages[page_id]:
                    return pages[page_id]['thumbnail']['source']
    except Exception as e:
        pass
    
    return None

with Session(engine) as session:
    species_list = session.query(Species).all()
    count = 0
    for sp in species_list:
        filename = sp.scientific_name.replace(" ", "_").lower() + ".jpg"
        filepath = os.path.join(ASSETS_DIR, filename)
        
        image_url = get_wiki_image(sp.scientific_name)
        if image_url:
            print(f"Downloading real image for {sp.scientific_name}...")
            try:
                req = urllib.request.Request(image_url, headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(req) as response, open(filepath, 'wb') as out_file:
                    out_file.write(response.read())
                
                sp.image_url = f"assets/birds/{filename}"
                count += 1
            except Exception as e:
                print(f"Failed to download image for {filename}: {e}")
        else:
            print(f"No Wikipedia image found for {sp.scientific_name}")
            
    session.commit()
    print(f"{count} vraies images telechargees et mises a jour !")

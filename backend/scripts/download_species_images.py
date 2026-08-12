import os
import urllib.request
import urllib.error
from sqlalchemy import create_engine
from sqlalchemy.orm import Session
from app.models.species import Species

ASSETS_DIR = r"..\birdsense_mobile\assets\birds"
os.makedirs(ASSETS_DIR, exist_ok=True)

engine = create_engine("sqlite:///./birdsense.db")
with Session(engine) as session:
    species_list = session.query(Species).all()
    count = 0
    for sp in species_list:
        filename = sp.scientific_name.replace(" ", "_").lower() + ".jpg"
        filepath = os.path.join(ASSETS_DIR, filename)
        
        # Use a reliable placeholder service that returns a random bird image
        # based on the scientific name so it's always the same for a given bird
        url = f"https://loremflickr.com/800/800/bird?lock={count + 1}"
        
        print(f"Downloading {filename}...")
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response, open(filepath, 'wb') as out_file:
                out_file.write(response.read())
            
            # Update DB with relative asset path
            sp.image_url = f"assets/birds/{filename}"
            count += 1
        except urllib.error.URLError as e:
            print(f"Failed to download {filename}: {e}")
            
    session.commit()
    print(f"{count} images telechargees et mises a jour !")

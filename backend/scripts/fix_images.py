import urllib.request, json, time, os

failed = ['Ardea cinerea', 'Egretta garzetta', 'Streptopelia decaocto', 'Merops pusillus', 'Halcyon senegalensis']
for name in failed:
    url = f'https://fr.wikipedia.org/api/rest_v1/page/summary/{name.replace(" ", "_")}'
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'BirdSenseAI/2.0'})
        response_data = urllib.request.urlopen(req).read()
        data = json.loads(response_data)
        
        img_url = data.get('originalimage', data.get('thumbnail', {})).get('source')
        if img_url:
            path = r'..\birdsense_mobile\assets\birds\\' + name.replace(' ', '_').lower() + '.jpg'
            print(f'Downloading {name} from {img_url}')
            with open(path, 'wb') as f:
                f.write(urllib.request.urlopen(urllib.request.Request(img_url, headers={'User-Agent': 'BirdSenseAI/2.0'})).read())
    except Exception as e:
        print(f'Failed {name}: {e}')
    time.sleep(3)
print('Done!')

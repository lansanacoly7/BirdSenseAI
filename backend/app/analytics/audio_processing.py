"""
Traitement de signal audio pour BirdNET.
Ce module fournit des fonctions pour ingérer un fichier audio (.wav)
et générer un spectrogramme (Mel-Spectrogramme) sous forme d'image.
"""

import librosa
import numpy as np
import io
import matplotlib.pyplot as plt
from typing import Union

def generate_mel_spectrogram(
    audio_path_or_bytes: Union[str, bytes],
    sr: int = 48000,
    n_fft: int = 2048,
    hop_length: int = 512,
    n_mels: int = 128
) -> bytes:
    """
    Génère un spectrogramme Mel à partir d'un fichier audio
    et retourne l'image générée sous forme d'octets (PNG).
    
    Args:
        audio_path_or_bytes: Chemin vers le fichier WAV ou octets bruts.
        sr: Fréquence d'échantillonnage (48kHz recommandé pour BirdNET).
        n_fft: Taille de la fenêtre de FFT.
        hop_length: Décalage entre chaque fenêtre.
        n_mels: Nombre de bandes de fréquences Mel.
        
    Returns:
        bytes: Image PNG contenant le spectrogramme.
    """
    # Chargement de l'audio avec librosa
    if isinstance(audio_path_or_bytes, bytes):
        y, sr_orig = librosa.load(io.BytesIO(audio_path_or_bytes), sr=sr)
    else:
        y, sr_orig = librosa.load(audio_path_or_bytes, sr=sr)
        
    # Calcul du spectrogramme Mel
    S = librosa.feature.melspectrogram(
        y=y, 
        sr=sr, 
        n_fft=n_fft, 
        hop_length=hop_length, 
        n_mels=n_mels
    )
    
    # Conversion en décibels (échelle log)
    S_dB = librosa.power_to_db(S, ref=np.max)
    
    # Création du plot sans axes (juste l'image)
    fig, ax = plt.subplots(figsize=(10, 4))
    
    # Note : librosa.display.specshow n'est importé qu'en cas de besoin si on a librosa.display
    import librosa.display
    librosa.display.specshow(
        S_dB, 
        x_axis='time', 
        y_axis='mel', 
        sr=sr, 
        fmax=8000, 
        ax=ax
    )
    ax.axis('off')
    
    # Sauvegarde dans un buffer
    buf = io.BytesIO()
    plt.savefig(buf, format='png', bbox_inches='tight', pad_inches=0)
    plt.close(fig)
    
    return buf.getvalue()

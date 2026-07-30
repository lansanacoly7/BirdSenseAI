import pytest
import numpy as np
import soundfile as sf
import io
from backend.app.analytics.audio_processing import generate_mel_spectrogram

@pytest.fixture
def dummy_audio_bytes():
    """Génère un son pur (sinusoïde) de 1 seconde à 440 Hz."""
    sr = 22050
    t = np.linspace(0, 1, sr)
    y = 0.5 * np.sin(2 * np.pi * 440 * t)
    
    buf = io.BytesIO()
    sf.write(buf, y, sr, format='WAV')
    return buf.getvalue()

def test_generate_mel_spectrogram(dummy_audio_bytes):
    """Vérifie que la fonction génère bien une image PNG."""
    png_bytes = generate_mel_spectrogram(dummy_audio_bytes, sr=22050)
    
    # Vérification des magic bytes du format PNG
    assert png_bytes.startswith(b'\x89PNG\r\n\x1a\n')
    assert len(png_bytes) > 1000  # L'image doit contenir des données

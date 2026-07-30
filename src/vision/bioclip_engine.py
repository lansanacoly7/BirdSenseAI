"""
BirdSense AI - BioCLIP / OpenCLIP Fine Species Zero-Shot Classifier (Ext 4.1 & Problem 2 Fix)
Performs real multimodal image-text zero-shot classification using OpenCLIP / ResNet vision feature embeddings.
"""

from typing import List, Dict, Any, Optional
import numpy as np
import cv2
import torch
from PIL import Image

try:
    import open_clip
    HAS_OPEN_CLIP = True
except ImportError:
    HAS_OPEN_CLIP = False

_HF_NETWORK_CHECKED = False
_HF_NETWORK_AVAILABLE = False
_HF_NETWORK_ERROR = ""


def _check_hf_network() -> tuple[bool, str]:
    global _HF_NETWORK_CHECKED, _HF_NETWORK_AVAILABLE, _HF_NETWORK_ERROR
    if _HF_NETWORK_CHECKED:
        return _HF_NETWORK_AVAILABLE, _HF_NETWORK_ERROR

    _HF_NETWORK_CHECKED = True
    try:
        import urllib.request
        req = urllib.request.Request(
            "https://huggingface.co/laion/CLIP-ViT-B-32-laion2B-s34B-b79K/resolve/main/open_clip_pytorch_model.bin",
            headers={"User-Agent": "Mozilla/5.0"},
            method="HEAD"
        )
        with urllib.request.urlopen(req, timeout=1.0) as resp:
            pass
        _HF_NETWORK_AVAILABLE = True
    except Exception as net_err:
        _HF_NETWORK_AVAILABLE = False
        _HF_NETWORK_ERROR = f"Network constraint in sandbox: HuggingFace checkpoint download unreachable ({type(net_err).__name__}). Real CLIP requires network access on Ibrahima's machine."

    return _HF_NETWORK_AVAILABLE, _HF_NETWORK_ERROR


from .config import vision_config
from .logger import log_bioclip
from .performance import performance_tracker

class BioCLIPEngine:
    """
    Description:
        Moteur d'identification fine d'espèces d'oiseaux zéro-shot basé sur OpenCLIP (Stage 2).
        Utilise des embeddings multimodaux image-texte pour faire correspondre le visuel aux noms scientifiques/communs.

    Responsabilités:
        - Charger le modèle OpenCLIP (`ViT-B-32`, checkpoint `laion2b_s34b_b79k`).
        - Pré-calculer les embeddings textuels de la taxonomie des espèces cibles.
        - Classer la découpe (*crop*) BGR d'un oiseau en calculant la similarité cosinus avec les vecteurs d'espèces.

    Entrées:
        - `bird_crop`: Tableau NumPy (BGR) de l'oiseau découpé à partir de la bounding box.

    Sorties:
        - Dictionnaire contenant `top_species`, `top_confidence` et la liste classée des `candidates`.

    Exceptions:
        - `ValueError`: Si l'image découpée est invalide, `None` ou vide (`crop.size == 0`).
        - `RuntimeError`: Si le modèle OpenCLIP n'est pas chargé ou accessible.

    Exemple d'utilisation:
        >>> from src.vision.bioclip_engine import BioCLIPEngine
        >>> engine = BioCLIPEngine(enable_clip=True)
        >>> res = engine.classify_crop(bird_crop_numpy)
        >>> print(res["top_species"])
        'Haliaeetus vocifer (Aigle Pêcheur)'
    """

    def __init__(
        self,
        species_taxonomy: Optional[List[str]] = None,
        model_name: Optional[str] = None,
        pretrained: Optional[str] = None,
        enable_clip: bool = True
    ):
        model_name = model_name if model_name is not None else vision_config.bioclip_model_name
        pretrained = pretrained if pretrained is not None else vision_config.bioclip_pretrained
        self.species_taxonomy = species_taxonomy or [
            "Phoenicopterus roseus (Flamant Rose)",
            "Pelecanus onocrotalus (Pélican Blanc)",
            "Haliaeetus vocifer (Aigle Pêcheur)",
            "Ardea goliath (Héron Goliath)",
            "Columba livia (Pigeon)",
            "Passer domesticus (Passereau / Moineau)",
            "Falco tinnunculus (Faucon Crécerelle)"
        ]

        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        self.use_clip = False
        self.model = None
        self.preprocess = None
        self.tokenizer = None
        self.text_features = None

        self.init_error: Optional[str] = None
        if HAS_OPEN_CLIP and enable_clip:
            avail, err_msg = _check_hf_network()
            if not avail:
                self.init_error = err_msg
                log_bioclip(f"{self.init_error}")
                return

            try:
                self.model, _, self.preprocess = open_clip.create_model_and_transforms(
                    model_name, pretrained=pretrained
                )
                self.model = self.model.to(self.device).eval()
                self.tokenizer = open_clip.get_tokenizer(model_name)
                
                prompts = [f"a photo of a {species}, a bird species" for species in self.species_taxonomy]
                text_tokens = self.tokenizer(prompts).to(self.device)
                
                with torch.no_grad():
                    text_embeds = self.model.encode_text(text_tokens)
                    self.text_features = text_embeds / text_embeds.norm(dim=-1, keepdim=True)
                
                self.use_clip = True
                log_bioclip(f"Initialized real OpenCLIP model '{model_name}' zero-shot classifier.")
            except Exception as e:
                self.init_error = f"{type(e).__name__}: {str(e)}"
                log_bioclip(f"OpenCLIP init error: {self.init_error}")

    def classify_crop(self, bird_crop: np.ndarray) -> Dict[str, Any]:
        """
        Classifies a cropped bounding box of a bird using real multimodal embeddings.
        Returns candidate species ranked by real cosine similarity / softmax confidence.
        Raises RuntimeError if OpenCLIP is not loaded.
        """
        if bird_crop is None or bird_crop.size == 0:
            raise ValueError("Invalid bird crop input provided to BioCLIPEngine.")

        if not self.use_clip or self.model is None or self.text_features is None:
            err_msg = f"CLIP model unavailable — real classification cannot run. Detail: {self.init_error or 'OpenCLIP package not loaded or disabled'}"
            raise RuntimeError(err_msg)

        with performance_tracker.measure("bioclip"):
            rgb_img = cv2.cvtColor(bird_crop, cv2.COLOR_BGR2RGB)
            pil_img = Image.fromarray(rgb_img)

            img_tensor = self.preprocess(pil_img).unsqueeze(0).to(self.device)
            with torch.no_grad():
                img_embed = self.model.encode_image(img_tensor)
                img_embed = img_embed / img_embed.norm(dim=-1, keepdim=True)

                similarities = (img_embed @ self.text_features.T).squeeze(0)
                probs = (100.0 * similarities).softmax(dim=-1).cpu().numpy()
                scores = similarities.cpu().numpy()

        candidates = []
        for idx, species in enumerate(self.species_taxonomy):
            candidates.append({
                "species": species,
                "confidence": round(float(probs[idx]), 4),
                "similarity": round(float(scores[idx]), 4)
            })

        candidates.sort(key=lambda x: x["confidence"], reverse=True)
        top_match = candidates[0]

        return {
            "top_species": top_match["species"],
            "top_confidence": top_match["confidence"],
            "is_rare_protected": top_match["confidence"] > 0.70,
            "candidates": candidates[:3]
        }

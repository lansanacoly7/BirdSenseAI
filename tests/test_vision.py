"""
BirdSense AI - Automated Unit & Integration Tests for 2-Stage Vision Engine & FastAPI Endpoints
"""

import io
import os
import shutil
import tempfile
from pathlib import Path
import numpy as np
import cv2
from PIL import Image
import pytest
from fastapi.testclient import TestClient

from src.main import app
from src.vision.dataset_prep import DatasetPreparer
from src.vision.detector import BirdDetector
from src.vision.tracker import ByteTrackTracker
from src.vision.bioclip_engine import BioCLIPEngine
from src.vision.onnx_engine import ONNXInferenceEngine

client = TestClient(app)


class TestDatasetPrep:
    """Tests dataset preparation structure."""

    def test_setup_directories_and_yaml(self):
        with tempfile.TemporaryDirectory() as tmp_dir:
            preparer = DatasetPreparer(dataset_dir=tmp_dir)
            yaml_path = preparer.create_yaml_config()
            
            assert yaml_path.exists()
            assert (Path(tmp_dir) / "images" / "train").exists()
            assert (Path(tmp_dir) / "images" / "val").exists()
            assert (Path(tmp_dir) / "labels" / "train").exists()
            assert (Path(tmp_dir) / "labels" / "val").exists()

            stats = preparer.validate_dataset()
            assert stats["train_images"] >= 0


class TestBirdDetector:
    """Tests Stage 1 BirdDetector generic bird detection."""

    @pytest.fixture
    def detector(self):
        return BirdDetector(model_path="yolov8n.pt", confidence_threshold=0.25)

    def test_detector_initialization(self, detector):
        assert detector.model is not None
        assert detector.target_classes == [14]  # COCO bird class ID

    def test_detect_synthetic_numpy_array(self, detector):
        canvas = np.zeros((480, 640, 3), dtype=np.uint8)
        res = detector.detect(canvas)
        
        assert res["width"] == 640
        assert res["height"] == 480
        assert "count" in res
        assert "detections" in res
        assert isinstance(res["detections"], list)

    def test_draw_detections(self, detector):
        canvas = np.zeros((480, 640, 3), dtype=np.uint8)
        fake_detections = [{
            "class_id": 14,
            "class_name": "bird",
            "confidence": 0.89,
            "box_pixel": [50.0, 50.0, 200.0, 200.0],
            "box_normalized": [0.0781, 0.1042, 0.3125, 0.4167],
            "species_identification": {
                "top_species": "Phoenicopterus roseus (Flamant Rose)",
                "top_confidence": 0.92
            }
        }]
        annotated = detector.draw_detections(canvas, fake_detections)
        assert annotated.shape == (480, 640, 3)
        assert not np.array_equal(annotated, canvas)


class TestByteTrackTracker:
    """Tests ByteTrack tracker initialization."""

    def test_tracker_init(self):
        tracker = ByteTrackTracker(model_path="yolov8n.pt")
        assert tracker.model is not None
        assert tracker.target_classes == [14]
        assert tracker.tracker_type == "bytetrack.yaml"


class TestBioCLIPEngine:
    """Tests BioCLIP-2 fine species zero-shot identification & ranking consistency (Stage 2)."""

    def test_bioclip_classification_structure(self):
        engine = BioCLIPEngine(enable_clip=False)
        crop = np.ones((100, 100, 3), dtype=np.uint8) * 150
        res = engine.classify_crop(crop)
        
        assert "top_species" in res
        assert "top_confidence" in res
        assert "is_rare_protected" in res
        assert len(res["candidates"]) == 3

    def test_bioclip_species_reproducibility_and_ranking(self):
        """Verifies ranking consistency across crops and distinct species separation."""
        engine = BioCLIPEngine(enable_clip=False)
        
        # Pinkish crop 1 (simulating flamingo)
        flamingo_crop1 = np.full((120, 120, 3), (180, 100, 220), dtype=np.uint8)
        # Pinkish crop 2 (simulating flamingo with slight variation)
        flamingo_crop2 = np.full((120, 120, 3), (170, 95, 215), dtype=np.uint8)
        
        # Dark raptor crop (simulating eagle)
        eagle_crop = np.full((120, 120, 3), (30, 40, 50), dtype=np.uint8)

        res_flam1 = engine.classify_crop(flamingo_crop1)
        res_flam2 = engine.classify_crop(flamingo_crop2)
        res_eagle = engine.classify_crop(eagle_crop)

        # 1. Reproducibility test: similar crops yield top species consistency
        assert res_flam1["top_species"] == res_flam2["top_species"]
        assert abs(res_flam1["top_confidence"] - res_flam2["top_confidence"]) < 0.15

        # 2. Distinct species test: different crops yield distinct ranking candidates
        assert res_flam1["candidates"] != res_eagle["candidates"]


class TestVisionAPI:
    """Tests FastAPI 2-Stage Vision Router REST endpoints."""

    def test_root_endpoint(self):
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "online"

    def test_vision_health_endpoint(self):
        response = client.get("/api/v1/vision/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "online"
        assert "stage_1_detector" in data
        assert "stage_2_classifier" in data

    def test_detect_image_endpoint(self):
        img = Image.new("RGB", (300, 300), color=(73, 109, 137))
        img_byte_arr = io.BytesIO()
        img.save(img_byte_arr, format="PNG")
        img_byte_arr.seek(0)

        files = {"file": ("test_bird.png", img_byte_arr, "image/png")}
        response = client.post("/api/v1/vision/detect?conf=0.2", files=files)
        
        assert response.status_code == 200
        json_resp = response.json()
        assert json_resp["success"] is True
        assert "data" in json_resp
        assert json_resp["data"]["width"] == 300
        assert json_resp["data"]["height"] == 300

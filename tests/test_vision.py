"""
BirdSense AI - Automated Unit & Integration Tests for Vision Engine & FastAPI Endpoints
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

client = TestClient(app)


class TestDatasetPrep:
    """Tests dataset preparation and structure validation (T4.1)."""

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
            assert stats["train_images"] == 4
            assert stats["val_images"] == 2


class TestBirdDetector:
    """Tests BirdDetector YOLO model loading, image processing, and drawing (T4.1 & T4.3)."""

    @pytest.fixture
    def detector(self):
        return BirdDetector(model_path="yolov8n.pt", confidence_threshold=0.25)

    def test_detector_initialization(self, detector):
        assert detector.model is not None
        assert detector.confidence_threshold == 0.25

    def test_detect_synthetic_numpy_array(self, detector):
        # Create synthetic 480x640 image
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
            "box_normalized": [0.0781, 0.1042, 0.3125, 0.4167]
        }]
        annotated = detector.draw_detections(canvas, fake_detections)
        assert annotated.shape == (480, 640, 3)
        assert not np.array_equal(annotated, canvas)


class TestByteTrackTracker:
    """Tests ByteTrack tracker initialization (T4.2)."""

    def test_tracker_init(self):
        tracker = ByteTrackTracker(model_path="yolov8n.pt")
        assert tracker.model is not None
        assert tracker.tracker_type == "bytetrack.yaml"


class TestBioCLIPEngine:
    """Tests BioCLIP-2 fine species identification (Ext 4.1)."""

    def test_bioclip_classification(self):
        engine = BioCLIPEngine()
        crop = np.zeros((100, 100, 3), dtype=np.uint8)
        res = engine.classify_crop(crop)
        
        assert "top_species" in res
        assert "top_confidence" in res
        assert "is_rare_protected" in res
        assert len(res["candidates"]) == 3


class TestVisionAPI:
    """Tests FastAPI Vision Router REST endpoints."""

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
        assert "backend" in data

    def test_detect_image_endpoint(self):
        # Generate a PNG image in memory
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

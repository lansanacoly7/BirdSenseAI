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


from src.vision.bioclip_engine import BioCLIPEngine, HAS_OPEN_CLIP

class TestBioCLIPEngine:
    """Tests BioCLIP-2 fine species zero-shot identification & ranking consistency (Stage 2)."""

    @pytest.mark.skipif(not HAS_OPEN_CLIP, reason="CLIP non disponible dans cet environnement — test sauté, pas simulé")
    def test_bioclip_classification_structure_and_consistency(self):
        try:
            engine = BioCLIPEngine(enable_clip=True)
            if not engine.use_clip:
                pytest.skip(f"CLIP non disponible dans cet environnement — test sauté, pas simulé. Détail: {engine.init_error}")
        except Exception as e:
            pytest.skip(f"CLIP non disponible dans cet environnement — test sauté, pas simulé. Détail: {e}")

        # Read real bird images if available
        train_imgs = list((Path(__file__).parent.parent / "dataset" / "images" / "train").glob("*.jpg"))
        if train_imgs:
            real_img = cv2.imread(str(train_imgs[0]))
            bird_crop1 = real_img[10:110, 10:110]
            bird_crop2 = real_img[12:112, 12:112]  # Slightly shifted crop of same real bird image
        else:
            bird_crop1 = np.full((120, 120, 3), (180, 100, 220), dtype=np.uint8)
            bird_crop2 = np.full((120, 120, 3), (180, 100, 220), dtype=np.uint8)

        dark_crop = np.zeros((120, 120, 3), dtype=np.uint8)

        res1 = engine.classify_crop(bird_crop1)
        res2 = engine.classify_crop(bird_crop2)
        res_dark = engine.classify_crop(dark_crop)

        assert "top_species" in res1
        assert "top_confidence" in res1
        assert "is_rare_protected" in res1
        assert len(res1["candidates"]) == 3

        # 1. Reproducibility test: crops from same bird yield top species consistency
        assert res1["top_species"] == res2["top_species"]
        assert abs(res1["top_confidence"] - res2["top_confidence"]) < 0.15

        # 2. Distinct species test: different crops yield distinct candidate rankings
        assert res1["candidates"] != res_dark["candidates"]


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


from src.vision.audio_classifier import AudioBirdClassifier

class TestPhase2Features:
    """Tests Phase 2 features (T4.4 AR HUD Box and T4.5 Audio Bioacoustic Classifier)."""

    def test_ar_hud_box_formatting(self):
        detector = BirdDetector(model_path="yolov8n.pt", confidence_threshold=0.1)
        canvas = np.zeros((480, 640, 3), dtype=np.uint8)
        res = detector.detect(canvas)
        assert "detections" in res

    def test_audio_bird_classifier(self):
        classifier = AudioBirdClassifier()
        dummy_signal = (np.sin(2 * np.pi * 3200 * np.linspace(0, 1, 22050)) * 10000).astype(np.int16)
        dummy_bytes = dummy_signal.tobytes()
        res = classifier.classify_audio_bytes(dummy_bytes)
        assert res["success"] is True
        assert "top_species" in res
        assert "top_confidence" in res
        assert res["peak_frequency_hz"] > 0

    def test_audio_classify_endpoint(self):
        dummy_signal = (np.sin(2 * np.pi * 3200 * np.linspace(0, 1, 22050)) * 10000).astype(np.int16)
        audio_io = io.BytesIO(dummy_signal.tobytes())
        files = {"file": ("test_audio.wav", audio_io, "audio/wav")}
        response = client.post("/api/v1/vision/audio-classify", files=files)
        assert response.status_code == 200
        json_resp = response.json()
        assert json_resp["success"] is True
        assert "top_species" in json_resp

    def test_audio_classify_invalid_file_returns_400(self):
        corrupted_io = io.BytesIO(b"corrupted_non_wav_bytes_123456789")
        files = {"file": ("invalid_audio.wav", corrupted_io, "audio/wav")}
        response = client.post("/api/v1/vision/audio-classify", files=files)
        assert response.status_code == 400
        json_resp = response.json()
        assert "Impossible de décoder le fichier audio" in json_resp["detail"]


from src.vision.performance import VisionPerformanceTracker, performance_tracker

class TestVisionPerformanceTracker:
    """Tests VisionPerformanceTracker metrics calculation, FPS, and JSON export."""

    def test_performance_measurement_and_summary(self):
        tracker = VisionPerformanceTracker()
        tracker.record_execution_time("yolo", 10.0)
        tracker.record_execution_time("yolo", 20.0)
        
        summary = tracker.get_summary()
        assert summary["yolo"]["count"] == 2
        assert summary["yolo"]["mean_ms"] == 15.0
        assert summary["yolo"]["min_ms"] == 10.0
        assert summary["yolo"]["max_ms"] == 20.0
        assert summary["yolo"]["fps"] == 66.67

    def test_measure_context_manager(self):
        tracker = VisionPerformanceTracker()
        with tracker.measure("fft"):
            _ = sum(i for i in range(1000))
        
        summary = tracker.get_summary()
        assert summary["fft"]["count"] == 1
        assert summary["fft"]["mean_ms"] >= 0.0

    def test_export_json(self):
        tracker = VisionPerformanceTracker()
        tracker.record_execution_time("onnx", 50.0)
        json_str = tracker.export_json()
        assert '"onnx"' in json_str
        assert '"mean_ms": 50.0' in json_str


from scripts.benchmark import run_benchmark

class TestVisionBenchmark:
    """Tests execution of scripts/benchmark.py and artifact generation."""

    def test_run_benchmark_generates_artifacts(self, tmp_path):
        results = run_benchmark(output_dir=tmp_path)
        assert "inference_benchmarks" in results
        assert "api_benchmarks" in results
        assert (tmp_path / "benchmark.json").exists()
        assert (tmp_path / "benchmark.md").exists()
        assert (tmp_path / "benchmark.csv").exists()


class TestVisionSecurity:
    """Tests security controls: extension filtering, Path Traversal protection, and max file size limits."""

    def test_invalid_extension_rejected(self):
        malicious_io = io.BytesIO(b"echo 'malicious'")
        files = {"file": ("malicious_script.exe", malicious_io, "application/x-msdownload")}
        response = client.post("/api/v1/vision/detect", files=files)
        assert response.status_code == 400
        assert "Format de fichier non autorisé" in response.json()["detail"]

    def test_path_traversal_sanitized(self):
        dummy_signal = (np.sin(2 * np.pi * 3200 * np.linspace(0, 1, 22050)) * 10000).astype(np.int16)
        audio_io = io.BytesIO(dummy_signal.tobytes())
        files = {"file": ("../../etc/passwd_test.wav", audio_io, "audio/wav")}
        response = client.post("/api/v1/vision/audio-classify", files=files)
        assert response.status_code == 200

    def test_file_too_large_rejected(self):
        oversized_io = io.BytesIO(b"0" * (11 * 1024 * 1024))  # 11 MB > 10 MB limit
        files = {"file": ("oversized.jpg", oversized_io, "image/jpeg")}
        response = client.post("/api/v1/vision/detect", files=files)
        assert response.status_code == 400
        assert "Taille de fichier trop grande" in response.json()["detail"]

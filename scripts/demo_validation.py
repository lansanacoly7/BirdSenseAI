"""
BirdSense AI - Pre-Demo Automated System Validation Script
Verifies system readiness prior to presentation day:
1. YOLO & ONNX Model presence
2. Model loading capability
3. FastAPI REST API readiness
4. POST /api/v1/vision/detect endpoint
5. POST /api/v1/vision/track endpoint
6. POST /api/v1/vision/audio-classify endpoint
7. Benchmark suite execution
8. Demo pipeline execution
Outputs PASS or FAIL with detailed diagnosis.
"""

import io
import sys
import time
from pathlib import Path
import numpy as np
import cv2

# Ensure project root is in sys.path
ROOT_DIR = Path(__file__).resolve().parent.parent
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

from src.vision.config import vision_config
from src.vision.logger import log_vision
from src.vision.detector import BirdDetector
from src.vision.tracker import ByteTrackTracker
from src.vision.audio_classifier import AudioBirdClassifier
from scripts.benchmark import run_benchmark
from run_demo import run_full_pipeline_demo
from fastapi.testclient import TestClient
from src.main import app


def validate_demo_system() -> bool:
    print("\n==========================================================================")
    print(" 🦅 BIRD SENSE AI — PRE-DEMO SYSTEM AUTOMATED VALIDATION SUITE")
    print("==========================================================================\n")

    steps_results = []

    # Check 1: Model Presence
    try:
        yolo_path = vision_config.resolve_yolo_weights()
        if Path(yolo_path).exists():
            print(f" [✓] CHECK 1: YOLO Model Weights Present ({yolo_path})")
            steps_results.append(True)
        else:
            print(f" [✗] CHECK 1: YOLO Model Weights Missing at {yolo_path}")
            steps_results.append(False)
    except Exception as e:
        print(f" [✗] CHECK 1 FAILED: {e}")
        steps_results.append(False)

    # Check 2: Model Loading Capability
    try:
        detector = BirdDetector()
        audio_clf = AudioBirdClassifier()
        print(" [✓] CHECK 2: Vision & Audio Models Successfully Loaded into Memory")
        steps_results.append(True)
    except Exception as e:
        print(f" [✗] CHECK 2 FAILED: {e}")
        steps_results.append(False)

    # Check 3: REST API Server Readiness
    try:
        client = TestClient(app)
        resp_health = client.get("/api/v1/vision/health")
        if resp_health.status_code == 200:
            print(" [✓] CHECK 3: FastAPI REST API Server Operational (/health -> 200 OK)")
            steps_results.append(True)
        else:
            print(f" [✗] CHECK 3 FAILED: Health endpoint returned HTTP {resp_health.status_code}")
            steps_results.append(False)
    except Exception as e:
        print(f" [✗] CHECK 3 FAILED: {e}")
        steps_results.append(False)

    # Check 4: Endpoint /detect
    try:
        sample_imgs = list((ROOT_DIR / "dataset" / "images" / "train").glob("*.jpg"))
        if sample_imgs:
            with open(sample_imgs[0], "rb") as f:
                img_bytes = f.read()
        else:
            dummy_img = np.zeros((320, 320, 3), dtype=np.uint8)
            _, buffer = cv2.imencode(".jpg", dummy_img)
            img_bytes = buffer.tobytes()

        resp_detect = client.post("/api/v1/vision/detect?conf=0.1", files={"file": ("test.jpg", img_bytes, "image/jpeg")})
        if resp_detect.status_code == 200 and resp_detect.json().get("success") is True and "data" in resp_detect.json():
            print(" [✓] CHECK 4: POST /api/v1/vision/detect Operational (YOLO & AR HUD Format Supported)")
            steps_results.append(True)
        else:
            print(f" [✗] CHECK 4 FAILED: Detect status {resp_detect.status_code}")
            steps_results.append(False)
    except Exception as e:
        print(f" [✗] CHECK 4 FAILED: {e}")
        steps_results.append(False)

    # Check 5: Endpoint /track
    try:
        temp_video = ROOT_DIR / "evidence" / "sample_test_video.mp4"
        if not temp_video.exists():
            temp_video.parent.mkdir(parents=True, exist_ok=True)
            writer = cv2.VideoWriter(str(temp_video), cv2.VideoWriter_fourcc(*"mp4v"), 10, (160, 120))
            for _ in range(5):
                writer.write(np.zeros((120, 160, 3), dtype=np.uint8))
            writer.release()

        with open(temp_video, "rb") as vf:
            resp_track = client.post("/api/v1/vision/track?conf=0.1", files={"file": ("sample.mp4", vf, "video/mp4")})
        if resp_track.status_code == 200:
            print(" [✓] CHECK 5: POST /api/v1/vision/track Operational (ByteTrack Video MOT)")
            steps_results.append(True)
        else:
            print(f" [✗] CHECK 5 FAILED: Track status {resp_track.status_code}")
            steps_results.append(False)
    except Exception as e:
        print(f" [✗] CHECK 5 FAILED: {e}")
        steps_results.append(False)

    # Check 6: Endpoint /audio-classify
    try:
        dummy_signal = (np.sin(2 * np.pi * 3200 * np.linspace(0, 1, 22050)) * 10000).astype(np.int16)
        audio_io = io.BytesIO(dummy_signal.tobytes())
        resp_audio = client.post("/api/v1/vision/audio-classify", files={"file": ("bird.wav", audio_io, "audio/wav")})
        if resp_audio.status_code == 200 and resp_audio.json().get("success") is True:
            print(" [✓] CHECK 6: POST /api/v1/vision/audio-classify Operational (FFT Bioacoustic Analysis)")
            steps_results.append(True)
        else:
            print(f" [✗] CHECK 6 FAILED: Audio classify status {resp_audio.status_code}")
            steps_results.append(False)
    except Exception as e:
        print(f" [✗] CHECK 6 FAILED: {e}")
        steps_results.append(False)

    # Check 7: Benchmark Suite Execution
    try:
        _ = run_benchmark(output_dir=ROOT_DIR / "evidence")
        print(" [✓] CHECK 7: Benchmark Suite Executable (benchmark.json, benchmark.md, benchmark.csv generated)")
        steps_results.append(True)
    except Exception as e:
        print(f" [✗] CHECK 7 FAILED: Benchmark execution failed ({e})")
        steps_results.append(False)

    # Check 8: Demo Pipeline Runner Execution
    try:
        _ = run_full_pipeline_demo(output_dir=ROOT_DIR / "demo_output")
        print(" [✓] CHECK 8: Demo Pipeline Runner Executable (annotated.jpg, result.json, summary.txt generated)")
        steps_results.append(True)
    except Exception as e:
        print(f" [✗] CHECK 8 FAILED: Demo pipeline runner failed ({e})")
        steps_results.append(False)

    print("\n--------------------------------------------------------------------------")
    all_passed = all(steps_results)
    if all_passed:
        print(" VERDICT GLOBAL : [ PASS ] — Le système BirdSense AI est 100% prêt pour la démo !")
    else:
        failed_count = steps_results.count(False)
        print(f" VERDICT GLOBAL : [ FAIL ] — {failed_count} vérification(s) ont échoué.")
    print("--------------------------------------------------------------------------\n")

    return all_passed


if __name__ == "__main__":
    success = validate_demo_system()
    sys.exit(0 if success else 1)

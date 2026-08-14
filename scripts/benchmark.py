"""
BirdSense AI - Comprehensive Performance & REST API Benchmark Suite
Measures CPU utilization, RAM memory footprint, inference latency (ms), FPS, and FastAPI REST API response times.
Exports benchmark.json, benchmark.md, and benchmark.csv into evidence/ directory.
"""

import csv
import io
import json
import os
import sys
import time
from pathlib import Path
from typing import Dict, Any, List
import numpy as np
import cv2

# Ensure project root is in sys.path
ROOT_DIR = Path(__file__).resolve().parent.parent
if str(ROOT_DIR) not in sys.path:
    sys.path.insert(0, str(ROOT_DIR))

try:
    import psutil
    HAS_PSUTIL = True
except ImportError:
    HAS_PSUTIL = False

from src.vision.config import vision_config
from src.vision.logger import log_vision
from src.vision.detector import BirdDetector
from src.vision.tracker import ByteTrackTracker
from src.vision.bioclip_engine import BioCLIPEngine
from src.vision.audio_classifier import AudioBirdClassifier
from src.vision.performance import performance_tracker
from fastapi.testclient import TestClient
from src.main import app

EVIDENCE_DIR = ROOT_DIR / "evidence"


def get_system_resources() -> Dict[str, float]:
    """Returns current process CPU usage (%) and RAM memory usage (MB)."""
    if HAS_PSUTIL:
        process = psutil.Process(os.getpid())
        ram_mb = round(process.memory_info().rss / (1024 * 1024), 2)
        cpu_percent = round(psutil.cpu_percent(interval=0.1), 1)
        return {"cpu_percent": cpu_percent, "ram_mb": ram_mb}
    return {"cpu_percent": 0.0, "ram_mb": 0.0}


def run_benchmark(output_dir: Path = EVIDENCE_DIR) -> Dict[str, Any]:
    """
    Executes benchmark measurements across all Vision & REST API components.
    Exports benchmark.json, benchmark.md, and benchmark.csv into output_dir.
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    log_vision(f"Starting BirdSense AI Benchmark Suite. Output directory: {output_dir}")

    initial_resources = get_system_resources()
    results: Dict[str, Any] = {
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "system_resources": initial_resources,
        "inference_benchmarks": {},
        "api_benchmarks": {}
    }

    # 1. Image YOLO Inferences Benchmark
    sample_imgs = list((ROOT_DIR / "dataset" / "images" / "train").glob("*.jpg"))
    test_img_path = sample_imgs[0] if sample_imgs else (output_dir / "test_detection.jpg")
    img = cv2.imread(str(test_img_path))
    if img is None:
        img = np.zeros((480, 640, 3), dtype=np.uint8)

    detector = BirdDetector(confidence_threshold=0.10)
    # Warmup
    _ = detector.detect(img)

    yolo_times = []
    for _ in range(5):
        t0 = time.perf_counter()
        _ = detector.detect(img)
        t1 = time.perf_counter()
        yolo_times.append((t1 - t0) * 1000.0)

    yolo_avg = round(sum(yolo_times) / len(yolo_times), 2)
    yolo_fps = round(1000.0 / yolo_avg, 2) if yolo_avg > 0 else 0.0

    results["inference_benchmarks"]["yolo_detection"] = {
        "mean_latency_ms": yolo_avg,
        "min_latency_ms": round(min(yolo_times), 2),
        "max_latency_ms": round(max(yolo_times), 2),
        "fps": yolo_fps,
        "iterations": len(yolo_times)
    }

    # 2. Bioacoustic Audio Classifier Benchmark
    audio_classifier = AudioBirdClassifier()
    dummy_wav = np.sin(2 * np.pi * 3200 * np.linspace(0, 1, 22050)).astype(np.float32)
    dummy_bytes = (dummy_wav * 15000).astype(np.int16).tobytes()

    audio_times = []
    for _ in range(10):
        t0 = time.perf_counter()
        _ = audio_classifier.classify_audio_bytes(dummy_bytes)
        t1 = time.perf_counter()
        audio_times.append((t1 - t0) * 1000.0)

    audio_avg = round(sum(audio_times) / len(audio_times), 2)
    results["inference_benchmarks"]["audio_fft"] = {
        "mean_latency_ms": audio_avg,
        "min_latency_ms": round(min(audio_times), 2),
        "max_latency_ms": round(max(audio_times), 2),
        "fps": round(1000.0 / audio_avg, 2) if audio_avg > 0 else 0.0,
        "iterations": len(audio_times)
    }

    # 3. REST API Latency Benchmark (FastAPI TestClient)
    client = TestClient(app)

    # API /health
    t0 = time.perf_counter()
    resp_health = client.get("/api/v1/vision/health")
    t1 = time.perf_counter()
    health_ms = round((t1 - t0) * 1000.0, 2)
    results["api_benchmarks"]["GET /api/v1/vision/health"] = {
        "status_code": resp_health.status_code,
        "latency_ms": health_ms
    }

    # API /detect
    img_io = io.BytesIO()
    is_success, buffer = cv2.imencode(".jpg", img)
    img_bytes = buffer.tobytes() if is_success else b"fake_img"

    t0 = time.perf_counter()
    resp_detect = client.post("/api/v1/vision/detect?conf=0.1", files={"file": ("test.jpg", img_bytes, "image/jpeg")})
    t1 = time.perf_counter()
    detect_ms = round((t1 - t0) * 1000.0, 2)
    results["api_benchmarks"]["POST /api/v1/vision/detect"] = {
        "status_code": resp_detect.status_code,
        "latency_ms": detect_ms
    }

    # API /audio-classify
    audio_io = io.BytesIO(dummy_bytes)
    t0 = time.perf_counter()
    resp_audio = client.post("/api/v1/vision/audio-classify", files={"file": ("sample.wav", audio_io, "audio/wav")})
    t1 = time.perf_counter()
    audio_api_ms = round((t1 - t0) * 1000.0, 2)
    results["api_benchmarks"]["POST /api/v1/vision/audio-classify"] = {
        "status_code": resp_audio.status_code,
        "latency_ms": audio_api_ms
    }

    # Final Resource Reading
    final_resources = get_system_resources()
    results["final_system_resources"] = final_resources

    # --- EXPORT 1: benchmark.json ---
    json_path = output_dir / "benchmark.json"
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
    log_vision(f"Saved benchmark JSON to {json_path}")

    # --- EXPORT 2: benchmark.md ---
    md_path = output_dir / "benchmark.md"
    md_content = [
        "# 📊 BirdSense AI — Rapport de Benchmark de Performance",
        "",
        f"**Date/Heure :** {results['timestamp']}",
        f"**Empreinte RAM Procès :** {final_resources['ram_mb']} MB",
        f"**Utilisation CPU Procès :** {final_resources['cpu_percent']} %",
        "",
        "## 1. Métriques d'Inférence Algorithmique",
        "",
        "| Composant | Latence Moyenne (ms) | Min (ms) | Max (ms) | FPS Équivalent | Échantillons |",
        "| :--- | :---: | :---: | :---: | :---: | :---: |",
        f"| **YOLO Bird Detection** | {yolo_avg} ms | {results['inference_benchmarks']['yolo_detection']['min_latency_ms']} ms | {results['inference_benchmarks']['yolo_detection']['max_latency_ms']} ms | **{yolo_fps} FPS** | {results['inference_benchmarks']['yolo_detection']['iterations']} |",
        f"| **Audio FFT Classifier** | {audio_avg} ms | {results['inference_benchmarks']['audio_fft']['min_latency_ms']} ms | {results['inference_benchmarks']['audio_fft']['max_latency_ms']} ms | **{results['inference_benchmarks']['audio_fft']['fps']} FPS** | {results['inference_benchmarks']['audio_fft']['iterations']} |",
        "",
        "## 2. Temps de Réponse REST API (FastAPI)",
        "",
        "| Endpoint API | Statut HTTP | Latence API (ms) |",
        "| :--- | :---: | :---: |",
        f"| `GET /api/v1/vision/health` | {resp_health.status_code} | {health_ms} ms |",
        f"| `POST /api/v1/vision/detect` | {resp_detect.status_code} | {detect_ms} ms |",
        f"| `POST /api/v1/vision/audio-classify` | {resp_audio.status_code} | {audio_api_ms} ms |",
        "",
        "---",
        "*Benchmark généré automatiquement par `scripts/benchmark.py`.*"
    ]
    with open(md_path, "w", encoding="utf-8") as f:
        f.write("\n".join(md_content))
    log_vision(f"Saved benchmark Markdown to {md_path}")

    # --- EXPORT 3: benchmark.csv ---
    csv_path = output_dir / "benchmark.csv"
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Category", "Metric", "Value", "Unit"])
        writer.writerow(["System", "RAM_Footprint", final_resources["ram_mb"], "MB"])
        writer.writerow(["System", "CPU_Utilization", final_resources["cpu_percent"], "%"])
        writer.writerow(["Inference", "YOLO_Mean_Latency", yolo_avg, "ms"])
        writer.writerow(["Inference", "YOLO_FPS", yolo_fps, "fps"])
        writer.writerow(["Inference", "Audio_FFT_Mean_Latency", audio_avg, "ms"])
        writer.writerow(["API", "GET_Health_Latency", health_ms, "ms"])
        writer.writerow(["API", "POST_Detect_Latency", detect_ms, "ms"])
        writer.writerow(["API", "POST_AudioClassify_Latency", audio_api_ms, "ms"])
    log_vision(f"Saved benchmark CSV to {csv_path}")

    return results


if __name__ == "__main__":
    res = run_benchmark()
    print(f"\n[BENCHMARK COMPLETE] Output files created in evidence/:\n - evidence/benchmark.json\n - evidence/benchmark.md\n - evidence/benchmark.csv")

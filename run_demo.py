"""
BirdSense AI - Single Point of Entry Demo Pipeline Script
Orchestrates the entire Computer Vision & Bioacoustic pipeline:
YOLO Detection -> Tracking -> BioCLIP Zero-Shot -> Audio FFT Classification -> Output Artifacts
"""

import json
import os
import time
from pathlib import Path
from typing import Dict, Any, Optional
import cv2
import numpy as np

from src.vision.config import vision_config
from src.vision.logger import log_vision
from src.vision.detector import BirdDetector
from src.vision.tracker import ByteTrackTracker
from src.vision.bioclip_engine import BioCLIPEngine
from src.vision.audio_classifier import AudioBirdClassifier
from src.vision.performance import performance_tracker


def run_full_pipeline_demo(
    image_path: Optional[Path] = None,
    output_dir: Path = Path("demo_output")
) -> Dict[str, Any]:
    """
    Executes end-to-end BirdSense AI multimodal vision & bioacoustic demo pipeline.
    Saves annotated.jpg, result.json, and summary.txt into demo_output/.
    """
    output_dir.mkdir(parents=True, exist_ok=True)
    log_vision(f"Starting BirdSense AI Full Demo Pipeline. Output directory: {output_dir.resolve()}")

    # 1. Image Resolution
    if image_path is None or not image_path.exists():
        # Look for real dataset image or fallback to sample
        sample_imgs = list(Path("dataset/images/train").glob("*.jpg"))
        if sample_imgs:
            image_path = sample_imgs[0]
        else:
            image_path = Path("evidence/test_detection.jpg")

    log_vision(f"Processing input image: {image_path}")
    raw_img = cv2.imread(str(image_path))
    if raw_img is None:
        raw_img = np.zeros((480, 640, 3), dtype=np.uint8)

    # 2. Stage 1 YOLO Bird Detection & AR HUD Box
    detector = BirdDetector(model_path=vision_config.resolve_yolo_weights(), confidence_threshold=0.10)
    detection_res = detector.detect(raw_img)
    detections = detection_res.get("detections", [])
    log_vision(f"Stage 1 YOLO Detection: {len(detections)} birds detected.")

    # 3. Stage 2 BioCLIP Species Zero-Shot Classification
    bioclip_active = False
    bioclip_status = "Not initialized"
    try:
        bioclip = BioCLIPEngine(enable_clip=True)
        if bioclip.use_clip and len(detections) > 0:
            bioclip_active = True
            h_img, w_img = raw_img.shape[:2]
            for det in detections:
                x1, y1, x2, y2 = [int(v) for v in det["box_pixel"]]
                x1_c, y1_c = max(0, x1), max(0, y1)
                x2_c, y2_c = min(w_img, x2), min(h_img, y2)
                crop = raw_img[y1_c:y2_c, x1_c:x2_c]
                if crop.size > 0:
                    species_res = bioclip.classify_crop(crop)
                    det["species_identification"] = species_res
                    det["class_name"] = species_res["top_species"]
            bioclip_status = "Active OpenCLIP ViT-B-32 Zero-Shot"
        else:
            bioclip_status = bioclip.init_error or "BioCLIP inactive"
    except Exception as e:
        bioclip_status = f"BioCLIP unavailable: {str(e)}"

    # 4. Bioacoustic Audio Classification
    audio_classifier = AudioBirdClassifier()
    dummy_wav = np.sin(2 * np.pi * 3200 * np.linspace(0, 1, 22050)).astype(np.float32)
    dummy_bytes = (dummy_wav * 15000).astype(np.int16).tobytes()
    audio_res = audio_classifier.classify_audio_bytes(dummy_bytes, filename="bird_call_sample.wav")
    log_vision(f"Bioacoustic Audio Classification complete. Top species: {audio_res['top_species']}")

    # 5. Image Annotation & Saving
    annotated_img = detector.draw_detections(raw_img, detections)
    annotated_jpg_path = output_dir / "annotated.jpg"
    cv2.imwrite(str(annotated_jpg_path), annotated_img)
    log_vision(f"Saved annotated image to {annotated_jpg_path}")

    # 6. JSON Result Structuring & Export
    final_result = {
        "timestamp": time.strftime("%Y-%m-%d %H:%M:%S"),
        "input_image": str(image_path),
        "pipeline": "YOLOv8 Detection -> AR HUD Bounding Boxes -> BioCLIP Zero-Shot -> Audio FFT",
        "vision_summary": {
            "image_width": detection_res["width"],
            "image_height": detection_res["height"],
            "detected_birds_count": len(detections),
            "bioclip_status": bioclip_status,
            "detections": detections
        },
        "audio_summary": audio_res,
        "performance_metrics": performance_tracker.get_summary()
    }

    result_json_path = output_dir / "result.json"
    with open(result_json_path, "w", encoding="utf-8") as f:
        json.dump(final_result, f, indent=2, ensure_ascii=False)
    log_vision(f"Saved JSON result to {result_json_path}")

    # 7. Summary Text Generation
    summary_txt_path = output_dir / "summary.txt"
    summary_lines = [
        "==================================================",
        " BIRD SENSE AI — COMPUTER VISION & AUDIO DEMO SUMMARY",
        "==================================================",
        f"Date/Time         : {final_result['timestamp']}",
        f"Input Image       : {image_path}",
        f"Birds Detected    : {len(detections)}",
        f"YOLO Model Weights: {detector.model_path}",
        f"BioCLIP Status    : {bioclip_status}",
        f"Audio Top Species : {audio_res['top_species']} ({audio_res['top_confidence']*100:.1f}%)",
        f"Audio Peak Freq   : {audio_res['peak_frequency_hz']} Hz",
        "--------------------------------------------------",
        " PERFORMANCE METRICS SUMMARY (MS & FPS):",
        json.dumps(performance_tracker.get_summary(), indent=2),
        "=================================================="
    ]

    with open(summary_txt_path, "w", encoding="utf-8") as f:
        f.write("\n".join(summary_lines))
    log_vision(f"Saved summary text to {summary_txt_path}")

    return final_result


if __name__ == "__main__":
    from typing import Dict, Any, Optional
    res = run_full_pipeline_demo()
    print(f"\n[DEMO COMPLETE] Output artifacts generated in demo_output/:\n - demo_output/annotated.jpg\n - demo_output/result.json\n - demo_output/summary.txt")

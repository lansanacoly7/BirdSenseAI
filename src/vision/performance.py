"""
BirdSense AI - Vision Performance Metrics Tracker Engine
Measures execution latency (ms), min, max, average, FPS, and sample counts across Vision components.
"""

import json
import time
from contextlib import contextmanager
from typing import Dict, List, Any, Optional, Generator


class VisionPerformanceTracker:
    """
    Tracks, calculates, and exports performance metrics for YOLO, ByteTrack, BioCLIP, Audio FFT, and ONNX engines.
    """

    SUPPORTED_CATEGORIES = {"yolo", "bytetrack", "bioclip", "fft", "onnx"}

    def __init__(self):
        self._timings: Dict[str, List[float]] = {cat: [] for cat in self.SUPPORTED_CATEGORIES}

    def record_execution_time(self, category: str, duration_ms: float) -> None:
        """Records an execution duration in milliseconds for a specified category."""
        cat_key = category.lower()
        if cat_key not in self._timings:
            self._timings[cat_key] = []
        self._timings[cat_key].append(duration_ms)

    @contextmanager
    def measure(self, category: str) -> Generator[None, None, None]:
        """Context manager to measure execution time of a code block in milliseconds."""
        start_time = time.perf_counter()
        try:
            yield
        finally:
            elapsed_ms = (time.perf_counter() - start_time) * 1000.0
            self.record_execution_time(category, elapsed_ms)

    def get_summary(self) -> Dict[str, Dict[str, float]]:
        """
        Calculates and returns mean, min, max, fps, and count metrics for all recorded categories.
        """
        summary: Dict[str, Dict[str, float]] = {}

        for category, times in self._timings.items():
            if not times:
                summary[category] = {
                    "count": 0,
                    "mean_ms": 0.0,
                    "min_ms": 0.0,
                    "max_ms": 0.0,
                    "fps": 0.0
                }
            else:
                count = len(times)
                mean_ms = sum(times) / count
                min_ms = min(times)
                max_ms = max(times)
                fps = round(1000.0 / mean_ms, 2) if mean_ms > 0 else 0.0

                summary[category] = {
                    "count": count,
                    "mean_ms": round(mean_ms, 2),
                    "min_ms": round(min_ms, 2),
                    "max_ms": round(max_ms, 2),
                    "fps": fps
                }

        return summary

    def export_json(self, indent: int = 2) -> str:
        """Exports the performance summary as a formatted JSON string."""
        return json.dumps(self.get_summary(), indent=indent)

    def reset(self) -> None:
        """Resets all recorded performance metrics."""
        self._timings = {cat: [] for cat in self.SUPPORTED_CATEGORIES}


# Global singleton instance for performance tracking
performance_tracker = VisionPerformanceTracker()

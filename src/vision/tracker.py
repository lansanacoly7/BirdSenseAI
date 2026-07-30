"""
BirdSense AI - Video Multi-Object Tracking Module using ByteTrack (Stage 1 Pipeline)
Tracks individual generic birds across video frames, assigns unique track_ids, and calculates exact unique bird count.
"""

from pathlib import Path
from typing import List, Dict, Any, Union, Optional
import numpy as np
import cv2
from ultralytics import YOLO

COCO_BIRD_CLASS_ID = 14


from .config import vision_config


class ByteTrackTracker:
    """
    ByteTrackTracker runs YOLO object detection integrated with ByteTrack algorithm
    to track object trajectories across video frames and eliminate over-counting.
    """

    def __init__(
        self,
        model_path: Optional[str] = None,
        tracker_type: Optional[str] = None,
        confidence_threshold: Optional[float] = None,
        target_classes: Optional[List[int]] = None
    ):
        """
        :param model_path: Path to YOLO weights (defaults to vision_config.yolo_model_path).
        :param tracker_type: Tracker configuration file ('bytetrack.yaml' or 'botsort.yaml').
        :param confidence_threshold: Minimum detection confidence threshold.
        :param target_classes: Target class IDs (defaults to [14] for generic COCO bird detection).
        """
        self.model_path = model_path if model_path is not None else vision_config.yolo_model_path
        self.tracker_type = tracker_type if tracker_type is not None else vision_config.tracker_config
        self.confidence_threshold = confidence_threshold if confidence_threshold is not None else vision_config.tracking_threshold
        self.target_classes = target_classes if target_classes is not None else [COCO_BIRD_CLASS_ID]
        self.model = YOLO(self.model_path)

    def track_video(
        self,
        video_path: Union[str, Path],
        output_path: Optional[Union[str, Path]] = None,
        conf: Optional[float] = None
    ) -> Dict[str, Any]:
        """
        Processes a video file using YOLO + ByteTrack.
        Returns unique bird count, frame metadata, and track trajectories.
        Optionally saves annotated output video.
        """
        video_path = Path(video_path)
        if not video_path.exists():
            raise FileNotFoundError(f"Video file not found at {video_path}")

        confidence = conf if conf is not None else self.confidence_threshold

        cap = cv2.VideoCapture(str(video_path))
        fps = int(cap.get(cv2.CAP_PROP_FPS)) or 30
        width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
        height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
        total_frames_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))

        writer = None
        if output_path:
            output_path = str(output_path)
            fourcc = cv2.VideoWriter_fourcc(*"mp4v")
            writer = cv2.VideoWriter(output_path, fourcc, fps, (width, height))

        tracks_summary: Dict[int, Dict[str, Any]] = {}
        frame_idx = 0

        results = self.model.track(
            source=str(video_path),
            conf=confidence,
            classes=self.target_classes,
            tracker=self.tracker_type,
            stream=True,
            verbose=False
        )

        for result in results:
            frame_idx += 1
            frame_img = result.orig_img.copy() if writer else None

            if result.boxes is not None and result.boxes.is_track:
                boxes = result.boxes
                for box in boxes:
                    if box.id is None:
                        continue

                    track_id = int(box.id[0].cpu().numpy())
                    cls_id = int(box.cls[0].cpu().numpy())
                    cls_name = "bird" if cls_id == COCO_BIRD_CLASS_ID else self.model.names.get(cls_id, f"class_{cls_id}")
                    conf_score = float(box.conf[0].cpu().numpy())
                    xyxy = box.xyxy[0].cpu().numpy().tolist()

                    center_x = (xyxy[0] + xyxy[2]) / 2.0
                    center_y = (xyxy[1] + xyxy[3]) / 2.0

                    if track_id not in tracks_summary:
                        tracks_summary[track_id] = {
                            "track_id": track_id,
                            "class_id": cls_id,
                            "class_name": cls_name,
                            "max_confidence": conf_score,
                            "first_frame": frame_idx,
                            "last_frame": frame_idx,
                            "positions": []
                        }

                    tracks_summary[track_id]["last_frame"] = frame_idx
                    if conf_score > tracks_summary[track_id]["max_confidence"]:
                        tracks_summary[track_id]["max_confidence"] = conf_score

                    tracks_summary[track_id]["positions"].append({
                        "frame": frame_idx,
                        "center": [round(center_x, 1), round(center_y, 1)],
                        "box": [round(c, 2) for c in xyxy]
                    })

                    if writer and frame_img is not None:
                        x1, y1, x2, y2 = [int(v) for v in xyxy]
                        label = f"ID:{track_id} {cls_name}"
                        cv2.rectangle(frame_img, (x1, y1), (x2, y2), (224, 122, 95), 2)  # Terracotta BGR
                        cv2.putText(frame_img, label, (x1, max(15, y1 - 5)), cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

            if writer and frame_img is not None:
                writer.write(frame_img)

        cap.release()
        if writer:
            writer.release()

        formatted_tracks = []
        for track_id, data in sorted(tracks_summary.items()):
            formatted_tracks.append({
                "track_id": track_id,
                "class_name": data["class_name"],
                "confidence": round(data["max_confidence"], 4),
                "duration_frames": data["last_frame"] - data["first_frame"] + 1,
                "first_frame": data["first_frame"],
                "last_frame": data["last_frame"],
                "trajectory_length": len(data["positions"])
            })

        return {
            "total_frames": frame_idx,
            "fps": fps,
            "width": width,
            "height": height,
            "unique_birds_count": len(tracks_summary),
            "tracks": formatted_tracks,
            "annotated_video_path": str(output_path) if output_path else None
        }


from .logger import log_tracking

if __name__ == "__main__":
    tracker = ByteTrackTracker()
    log_tracking(f"ByteTrack Tracker initialized on generic bird detection (COCO class 14).")

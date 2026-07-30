import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/radar_pulse_animation.dart';
import '../../core/widgets/radar_scanner_overlay.dart';
import '../../core/widgets/detection_success_dialog.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../local_observations/presentation/pages/local_observations_page.dart';
import 'presentation/widgets/bounding_box_painter.dart';
import 'providers/camera_provider.dart';
import '../../impact_sync/presentation/widgets/live_audio_level_gauge.dart';

/// Écran principal de capture caméra avec overlay IA.
///
/// Responsabilités :
/// - Afficher le flux vidéo en temps réel.
/// - Dessiner les bounding boxes des détections IA via [BoundingBoxPainter].
/// - Permettre la capture photo (sauvegarde offline via [ObservationRepository]).
/// - Permettre l'enregistrement vidéo MP4.
/// - Naviguer vers la page [LocalObservationsPage] pour consulter/synchro.
class CameraViewScreen extends ConsumerWidget {
  const CameraViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);

    // Comptage des oiseaux uniques (par trackId, ou par label en fallback).
    final uniqueBirdCount = cameraState.detections
        .map((d) => d.trackId ?? d.label)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: Colors.black, // Camera should always have black background
      body: Stack(
        children: [
          // Simulated Camera Preview
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const RadarPulseAnimation(size: 250),
                Positioned(
                  bottom: 120,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'AI VISION SCANNER • 60 FPS',
                      style: TextStyle(
                        color: AppColors.primaryAction,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                // Simulated Overlays (Bounding Boxes)
                CustomPaint(
                  size: Size.infinite,
                  painter: MockBoundingBoxPainter(),
                ),
                // AR HUD Radar Sweep
                const RadarScannerOverlay(),
                // Audio Level Gauge on the right
                if (cameraState.isRecordingVideo)
                  const Positioned(
                    right: 16,
                    bottom: 150,
                    child: LiveAudioLevelGauge(),
                  ),
              ],
            ),
          ),

          // Safe Area HUD (Head-Up Display)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Status Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.blur_circular, color: AppColors.primaryAction, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '$_birdCount Cibles',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAction.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryAction.withOpacity(0.5)),
                        ),
                        child: const Text(
                          'ONNX ACTIVE',
                          style: TextStyle(
                            color: AppColors.primaryAction, 
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bottom Controls (Action Bar)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Flash Button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.flash_auto, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                        
                        // Shutter Button
                        GestureDetector(
                          onTap: () {
                            DetectionSuccessDialog.show(
                              context,
                              speciesName: 'Pélican blanc',
                              scientificName: 'Pelecanus onocrotalus',
                              confidence: 0.94,
                              iucnCategory: 'LC',
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        
                        // Switch Camera Button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.cameraswitch_outlined, color: Colors.white),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Barre inférieure : bouton vidéo, shutter photo, bouton observations.
  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    CameraState cameraState,
  ) {
    final notifier = ref.read(cameraProvider.notifier);

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton vidéo
          FloatingActionButton.small(
            heroTag: 'video_btn',
            backgroundColor: cameraState.isRecordingVideo
                ? Colors.red
                : AppColors.surfaceDark,
            onPressed: ref.read(cameraProvider.notifier).toggleVideoRecording,
            child: Icon(
              cameraState.isRecordingVideo ? Icons.stop : Icons.videocam,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class MockBoundingBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryAction
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = AppColors.primaryAction.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Mock bounding box 1
    final rect1 = Rect.fromLTWH(size.width * 0.2, size.height * 0.3, 140, 100);
    _drawARBox(canvas, rect1, paint, fillPaint);
    _drawLabel(canvas, rect1, 'Pélican blanc', '94%');

    // Mock bounding box 2
    final rect2 = Rect.fromLTWH(size.width * 0.55, size.height * 0.45, 120, 90);
    _drawARBox(canvas, rect2, paint, fillPaint);
    _drawLabel(canvas, rect2, 'Flamant rose', '88%');
  }

  void _drawARBox(Canvas canvas, Rect rect, Paint strokePaint, Paint fillPaint) {
    canvas.drawRect(rect, fillPaint);
    // Draw corners only for AR effect
    final double cornerSize = 15.0;
    
    // Top-Left
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(cornerSize, 0), strokePaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, cornerSize), strokePaint);
    
    // Top-Right
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-cornerSize, 0), strokePaint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, cornerSize), strokePaint);
    
    // Bottom-Left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(cornerSize, 0), strokePaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -cornerSize), strokePaint);
    
    // Bottom-Right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-cornerSize, 0), strokePaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -cornerSize), strokePaint);
  }

  void _drawLabel(Canvas canvas, Rect rect, String title, String conf) {
    final titleStyle = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    
    final bgPaint = Paint()..color = AppColors.primaryAction;

    final textSpan = TextSpan(text: ' $title $conf ', style: titleStyle);
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    
    final labelRect = Rect.fromLTWH(rect.left, rect.top - 16, tp.width, 16);
    canvas.drawRect(labelRect, bgPaint);
    
    tp.paint(canvas, Offset(rect.left, rect.top - 15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

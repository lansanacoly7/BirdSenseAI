import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/radar_pulse_animation.dart';
import '../../core/widgets/detection_success_dialog.dart';

class CameraViewScreen extends StatefulWidget {
  const CameraViewScreen({super.key});

  @override
  State<CameraViewScreen> createState() => _CameraViewScreenState();
}

class _CameraViewScreenState extends State<CameraViewScreen> {
  final int _birdCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview Viewport Placeholder
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const RadarPulseAnimation(size: 220),
                      const SizedBox(height: 16),
                      const Text(
                        'Scanner IA Radar en direct (30 FPS)',
                        style: TextStyle(color: AppColors.accentAmber, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Simulated Overlays (CustomPainter integration point)
                CustomPaint(
                  size: Size.infinite,
                  painter: MockBoundingBoxPainter(),
                ),
              ],
            ),
          ),

          // Top Header Overlay Counter
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentAmber.withAlpha(100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flutter_dash, color: AppColors.accentAmber),
                      const SizedBox(width: 8),
                      Text(
                        'Oiseaux Détectés : $_birdCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCanopy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'IA Active',
                      style: TextStyle(color: AppColors.accentAmber, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Shutter & Action Bar
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.small(
                  heroTag: 'flash_btn',
                  backgroundColor: AppColors.surfaceDark,
                  child: const Icon(Icons.flash_off, color: Colors.white),
                  onPressed: () {},
                ),
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
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryTerracotta,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: const Icon(Icons.camera, size: 36, color: Colors.white),
                  ),
                ),
                FloatingActionButton.small(
                  heroTag: 'switch_cam_btn',
                  backgroundColor: AppColors.surfaceDark,
                  child: const Icon(Icons.flip_camera_ios, color: Colors.white),
                  onPressed: () {},
                ),
              ],
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
      ..color = const Color(0xFFF4A261)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final textStyle = const TextStyle(
      color: Colors.white,
      backgroundColor: Color(0xFF1E3A2B),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    // Mock bounding box 1
    final rect1 = Rect.fromLTWH(size.width * 0.2, size.height * 0.3, 140, 100);
    canvas.drawRect(rect1, paint);
    _drawLabel(canvas, rect1, 'Pélican blanc (94%)', textStyle);

    // Mock bounding box 2
    final rect2 = Rect.fromLTWH(size.width * 0.55, size.height * 0.45, 120, 90);
    canvas.drawRect(rect2, paint);
    _drawLabel(canvas, rect2, 'Flamant rose (88%)', textStyle);
  }

  void _drawLabel(Canvas canvas, Rect rect, String text, TextStyle style) {
    final span = TextSpan(text: ' $text ', style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(rect.left, rect.top - 18));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

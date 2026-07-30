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
                // Simulated Overlays
                CustomPaint(
                  size: Size.infinite,
                  painter: MockBoundingBoxPainter(),
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
    canvas.drawRect(rect1, fillPaint);
    canvas.drawRect(rect1, paint);
    _drawLabel(canvas, rect1, 'Pélican blanc', '94%');

    // Mock bounding box 2
    final rect2 = Rect.fromLTWH(size.width * 0.55, size.height * 0.45, 120, 90);
    canvas.drawRect(rect2, fillPaint);
    canvas.drawRect(rect2, paint);
    _drawLabel(canvas, rect2, 'Flamant rose', '88%');
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

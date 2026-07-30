import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RadarScannerOverlay extends StatefulWidget {
  const RadarScannerOverlay({super.key});

  @override
  State<RadarScannerOverlay> createState() => _RadarScannerOverlayState();
}

class _RadarScannerOverlayState extends State<RadarScannerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _animation = Tween<double>(begin: -0.2, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _RadarScannerPainter(_animation.value),
        );
      },
    );
  }
}

class _RadarScannerPainter extends CustomPainter {
  final double progress;

  _RadarScannerPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final yPos = size.height * progress;
    
    // Draw the scanning line
    final linePaint = Paint()
      ..color = AppColors.primaryAction.withOpacity(0.8)
      ..strokeWidth = 2.0;
      
    canvas.drawLine(
      Offset(0, yPos),
      Offset(size.width, yPos),
      linePaint,
    );

    // Draw the gradient shadow above the line
    final gradientRect = Rect.fromLTWH(0, yPos - 60, size.width, 60);
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryAction.withOpacity(0.0),
          AppColors.primaryAction.withOpacity(0.3),
        ],
      ).createShader(gradientRect);
      
    canvas.drawRect(gradientRect, gradientPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarScannerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

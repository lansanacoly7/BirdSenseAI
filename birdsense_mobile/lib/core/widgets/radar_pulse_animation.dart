import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';

class RadarPulseAnimation extends StatefulWidget {
  final double size;

  const RadarPulseAnimation({super.key, this.size = 200.0});

  @override
  State<RadarPulseAnimation> createState() => _RadarPulseAnimationState();
}

class _RadarPulseAnimationState extends State<RadarPulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RadarPainter(_controller.value),
        );
      },
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;

  _RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Expanding Pulse Waves
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + i * 0.33) % 1.0;
      final radius = waveProgress * maxRadius;
      final opacity = (1.0 - waveProgress).clamp(0.0, 1.0);

      final wavePaint = Paint()
        ..color = AppColors.primaryAction.withAlpha((opacity * 120).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, wavePaint);
    }

    // Concentric Target Rings
    final ringPaint = Paint()
      ..color = AppColors.primaryAction.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, maxRadius * 0.4, ringPaint);
    canvas.drawCircle(center, maxRadius * 0.75, ringPaint);
    canvas.drawCircle(center, maxRadius, ringPaint);

    // Rotating Radar Line
    final angle = progress * 2 * math.pi;
    final linePaint = Paint()
      ..color = AppColors.primaryAction.withAlpha(180)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final lineEnd = Offset(
      center.dx + maxRadius * math.cos(angle),
      center.dy + maxRadius * math.sin(angle),
    );

    canvas.drawLine(center, lineEnd, linePaint);

    // Center Core Dot
    final corePaint = Paint()
      ..color = AppColors.primaryAction
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5.0, corePaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

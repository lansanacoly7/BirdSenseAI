import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ObservationMapScreen extends StatefulWidget {
  const ObservationMapScreen({super.key});

  @override
  State<ObservationMapScreen> createState() => _ObservationMapScreenState();
}

class _ObservationMapScreenState extends State<ObservationMapScreen> {
  bool _showHeatmap = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des Observations (Mapbox)'),
        actions: [
          IconButton(
            icon: Icon(
              _showHeatmap ? Icons.map : Icons.local_fire_department,
              color: AppColors.accentAmber,
            ),
            tooltip: _showHeatmap ? 'Vue Marqueurs' : 'Vue Carte de Chaleur',
            onPressed: () {
              setState(() {
                _showHeatmap = !_showHeatmap;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map Background Placeholder (Simulating Dark Mapbox Layer)
          Container(
            color: const Color(0xFF0F1713),
            width: double.infinity,
            height: double.infinity,
            child: CustomPaint(
              painter: MapGridPainter(showHeatmap: _showHeatmap),
            ),
          ),

          // Map Control Floating Buttons
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'btn_zoom_in',
                  backgroundColor: AppColors.surfaceGlass,
                  child: const Icon(Icons.add, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'btn_zoom_out',
                  backgroundColor: AppColors.surfaceGlass,
                  child: const Icon(Icons.remove, color: AppColors.textPrimary),
                  onPressed: () {},
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'btn_my_location',
                  backgroundColor: AppColors.primaryCanopy,
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.accentAmber,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Bottom Info Card
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Card(
              color: AppColors.surfaceGlass,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryCanopy,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.accentAmber,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Zone : Parc National des Oiseaux du Djoudj',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '142 observations enregistrées cette semaine',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapGridPainter extends CustomPainter {
  final bool showHeatmap;

  MapGridPainter({required this.showHeatmap});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..strokeWidth = 1.0;

    // Draw Map Grid Lines
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double j = 0; j < size.height; j += 40) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j), gridPaint);
    }

    if (showHeatmap) {
      // Heatmap gradient spots
      final heatPaints = [
        Offset(size.width * 0.4, size.height * 0.35),
        Offset(size.width * 0.65, size.height * 0.5),
        Offset(size.width * 0.3, size.height * 0.65),
      ];

      for (var center in heatPaints) {
        final gradient = RadialGradient(
          colors: [
            const Color(0xFFE07A5F).withAlpha(180),
            const Color(0xFFF4A261).withAlpha(100),
            Colors.transparent,
          ],
        );
        final rect = Rect.fromCircle(center: center, radius: 80);
        final paint = Paint()..shader = gradient.createShader(rect);
        canvas.drawCircle(center, 80, paint);
      }
    } else {
      // Marker Pin Points
      final pins = [
        Offset(size.width * 0.4, size.height * 0.35),
        Offset(size.width * 0.65, size.height * 0.5),
        Offset(size.width * 0.3, size.height * 0.65),
        Offset(size.width * 0.5, size.height * 0.2),
      ];

      final pinPaint = Paint()..color = const Color(0xFFF4A261);
      final borderPaint = Paint()
        ..color = const Color(0xFF1E3A2B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      for (var pin in pins) {
        canvas.drawCircle(pin, 10, pinPaint);
        canvas.drawCircle(pin, 10, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MapGridPainter oldDelegate) =>
      oldDelegate.showHeatmap != showHeatmap;
}

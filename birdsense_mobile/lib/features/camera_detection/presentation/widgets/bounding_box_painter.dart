import 'package:flutter/material.dart';

import '../../models/detection_dto.dart';
import '../../../../core/theme/app_colors.dart';

/// Dessine les bounding boxes des détections IA par-dessus le flux caméra.
///
/// Les coordonnées de chaque [DetectionDto] sont normalisées (0.0 → 1.0).
/// Ce painter les convertit en coordonnées écran en tenant compte
/// du [BoxFit] utilisé par le [CameraPreview].
///
/// Règles d'affichage :
/// - Confiance < 50 % → masqué.
/// - Confiance ≥ 70 % → bordure verte ([AppColors.primaryAction]).
/// - Confiance 50–69 % → bordure ambre ([AppColors.accent]).
class BoundingBoxPainter extends CustomPainter {
  /// Liste des détections à dessiner.
  final List<DetectionDto> detections;

  /// Mode d'ajustement du preview caméra.
  final BoxFit boxFit;

  /// Taille du widget qui contient le preview.
  final Size previewSize;

  /// Résolution native de la caméra (largeur × hauteur).
  final Size imageSize;

  BoundingBoxPainter({
    required this.detections,
    required this.boxFit,
    required this.previewSize,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (detections.isEmpty || imageSize == Size.zero) return;

    final paintHigh = Paint()
      ..color = AppColors.primaryAction
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final paintMedium = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const labelStyle = TextStyle(
      color: Colors.white,
      backgroundColor: AppColors.background,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    // Calculer la transformation de coordonnées selon le BoxFit.
    final transform = _computeTransform(size);

    for (final detection in detections) {
      // Règle : masquer les détections sous 50 % de confiance.
      if (detection.confidence < 0.50) continue;

      final paint = detection.confidence >= 0.70 ? paintHigh : paintMedium;

      // Convertir les coordonnées normalisées en pixels écran.
      final rect = Rect.fromLTWH(
        transform.offsetX + (detection.x * transform.scaleX),
        transform.offsetY + (detection.y * transform.scaleY),
        detection.width * transform.scaleX,
        detection.height * transform.scaleY,
      );

      canvas.drawRect(rect, paint);
      _drawLabel(canvas, rect, detection, labelStyle);
    }
  }

  /// Dessine le label de l'espèce au-dessus de la bounding box.
  void _drawLabel(
    Canvas canvas,
    Rect rect,
    DetectionDto detection,
    TextStyle style,
  ) {
    final percent = (detection.confidence * 100).toStringAsFixed(0);
    final span = TextSpan(
      text: ' ${detection.label} ($percent%) ',
      style: style,
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(rect.left, rect.top - 18));
  }

  /// Calcule les facteurs d'échelle et les offsets pour la transformation.
  _BoxFitTransform _computeTransform(Size canvasSize) {
    double scaleX;
    double scaleY;
    double offsetX = 0.0;
    double offsetY = 0.0;

    if (boxFit == BoxFit.cover) {
      final ratioW = canvasSize.width / imageSize.width;
      final ratioH = canvasSize.height / imageSize.height;
      final scale = ratioW > ratioH ? ratioW : ratioH;

      scaleX = imageSize.width * scale;
      scaleY = imageSize.height * scale;

      offsetX = (canvasSize.width - scaleX) / 2;
      offsetY = (canvasSize.height - scaleY) / 2;
    } else {
      // BoxFit.fill — mapping direct.
      scaleX = canvasSize.width;
      scaleY = canvasSize.height;
    }

    return _BoxFitTransform(
      scaleX: scaleX,
      scaleY: scaleY,
      offsetX: offsetX,
      offsetY: offsetY,
    );
  }

  @override
  bool shouldRepaint(covariant BoundingBoxPainter oldDelegate) {
    if (oldDelegate.detections.length != detections.length) return true;
    for (int i = 0; i < detections.length; i++) {
      final oldDet = oldDelegate.detections[i];
      final newDet = detections[i];
      if (oldDet.trackId != newDet.trackId ||
          oldDet.x != newDet.x ||
          oldDet.y != newDet.y ||
          oldDet.confidence != newDet.confidence) {
        return true;
      }
    }
    return false;
  }
}

/// Résultat du calcul de transformation BoxFit → coordonnées écran.
class _BoxFitTransform {
  final double scaleX;
  final double scaleY;
  final double offsetX;
  final double offsetY;

  const _BoxFitTransform({
    required this.scaleX,
    required this.scaleY,
    required this.offsetX,
    required this.offsetY,
  });
}


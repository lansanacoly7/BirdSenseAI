import 'package:flutter/material.dart';

import '../../services/cv_upload_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Dialog premium affichant les résultats de la détection CV
/// après upload d'une image vers `/api/v1/cv/detect`.
class CvResultDialog extends StatelessWidget {
  final CvDetectResponse result;

  const CvResultDialog({super.key, required this.result});

  /// Affiche le dialog à partir d'une [CvDetectResponse].
  static Future<void> show(
    BuildContext context,
    CvDetectResponse result,
  ) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'cv_result_dialog',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => CvResultDialog(result: result),
      transitionBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(scale: curved, child: child);
      },
    );
  }

  Color _confidenceColor(double conf) {
    if (conf >= 0.85) return const Color(0xFF4ADE80); // vert
    if (conf >= 0.70) return const Color(0xFFFBBF24); // jaune
    return const Color(0xFFF87171); // rouge
  }

  String _confidenceLabel(double conf) {
    if (conf >= 0.85) return 'Élevée';
    if (conf >= 0.70) return 'Moyenne';
    return 'Faible';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2F4A)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryAction.withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAction.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primaryAction.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAction.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.radar,
                      color: AppColors.primaryAction,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Analyse IA complète',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${result.birdCount} oiseau${result.birdCount > 1 ? 'x' : ''} détecté${result.birdCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: AppColors.primaryAction,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── Liste des détections
            Flexible(
              child: result.detections.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'Aucun oiseau détecté.',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      shrinkWrap: true,
                      itemCount: result.detections.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final d = result.detections[i];
                        final confColor = _confidenceColor(d.confidence);
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: confColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Icône espèce
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: confColor.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.flutter_dash,
                                  color: confColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Infos espèce
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.species,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Confiance : ${_confidenceLabel(d.confidence)}',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Badge confidence
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: confColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: confColor.withOpacity(0.5),
                                  ),
                                ),
                                child: Text(
                                  '${(d.confidence * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: confColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // ── Footer — nom du fichier
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: Colors.white38,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      result.filename,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
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
}

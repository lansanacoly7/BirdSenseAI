import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DetectionSuccessDialog extends StatefulWidget {
  final String speciesName;
  final String scientificName;
  final double confidence;
  final String iucnCategory;

  const DetectionSuccessDialog({
    super.key,
    required this.speciesName,
    required this.scientificName,
    required this.confidence,
    required this.iucnCategory,
  });

  static void show(
    BuildContext context, {
    required String speciesName,
    required String scientificName,
    required double confidence,
    required String iucnCategory,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) => DetectionSuccessDialog(
        speciesName: speciesName,
        scientificName: scientificName,
        confidence: confidence,
        iucnCategory: iucnCategory,
      ),
    );
  }

  @override
  State<DetectionSuccessDialog> createState() => _DetectionSuccessDialogState();
}

class _DetectionSuccessDialogState extends State<DetectionSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getIucnColor(String category) {
    switch (category) {
      case 'LC':
        return AppColors.iucnLeastConcern;
      case 'NT':
        return AppColors.iucnNearThreatened;
      case 'VU':
        return AppColors.iucnVulnerable;
      case 'EN':
        return AppColors.iucnEndangered;
      case 'CR':
        return AppColors.iucnCriticallyEndangered;
      default:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryAction.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.primaryAction,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                widget.speciesName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.scientificName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Metrics Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricBox(
                    label: 'Confiance IA',
                    value: '${(widget.confidence * 100).toStringAsFixed(0)}%',
                    color: AppColors.primaryAction,
                  ),
                  _buildMetricBox(
                    label: 'Statut UICN',
                    value: widget.iucnCategory,
                    color: _getIucnColor(widget.iucnCategory),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

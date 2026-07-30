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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
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
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentAmber, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentAmber.withAlpha(40),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated Check Icon / Circle
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryCanopy,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.accentAmber,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Espèce Identifiée avec Succès !',
            style: TextStyle(
              color: AppColors.accentAmber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            widget.speciesName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            widget.scientificName,
            style: const TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Confidence & Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMetricChip(
                label: 'Confiance IA',
                value: '${(widget.confidence * 100).toStringAsFixed(0)}%',
                color: AppColors.primaryCanopy,
              ),
              _buildMetricChip(
                label: 'Statut UICN',
                value: widget.iucnCategory,
                color: _getIucnColor(widget.iucnCategory),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Enregistrer dans l\'Historique'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color == AppColors.primaryCanopy ? AppColors.accentAmber : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

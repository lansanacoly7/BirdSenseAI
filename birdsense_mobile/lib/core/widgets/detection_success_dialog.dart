import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Premium Detection Success Dialog — Full-screen bottom sheet
/// Shows detected bird with HD image, rich info, "Le saviez-vous?",
/// physical specs, and action buttons.
class DetectionSuccessDialog extends StatefulWidget {
  final String speciesName;
  final String scientificName;
  final double confidence;
  final String iucnCategory;
  final String? imageUrl;
  final String? didYouKnow;
  final String? habitat;
  final String? wingspan;
  final String? weight;
  final String? diet;

  const DetectionSuccessDialog({
    super.key,
    required this.speciesName,
    required this.scientificName,
    required this.confidence,
    required this.iucnCategory,
    this.imageUrl,
    this.didYouKnow,
    this.habitat,
    this.wingspan,
    this.weight,
    this.diet,
  });

  static void show(
    BuildContext context, {
    required String speciesName,
    required String scientificName,
    required double confidence,
    required String iucnCategory,
    String? imageUrl,
    String? didYouKnow,
    String? habitat,
    String? wingspan,
    String? weight,
    String? diet,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => DetectionSuccessDialog(
        speciesName: speciesName,
        scientificName: scientificName,
        confidence: confidence,
        iucnCategory: iucnCategory,
        imageUrl: imageUrl,
        didYouKnow: didYouKnow,
        habitat: habitat,
        wingspan: wingspan,
        weight: weight,
        diet: diet,
      ),
    );
  }

  @override
  State<DetectionSuccessDialog> createState() => _DetectionSuccessDialogState();
}

class _DetectionSuccessDialogState extends State<DetectionSuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Color _getIucnColor(String category) {
    switch (category) {
      case 'LC': return AppColors.iucnLeastConcern;
      case 'NT': return AppColors.iucnNearThreatened;
      case 'VU': return AppColors.iucnVulnerable;
      case 'EN': return AppColors.iucnEndangered;
      case 'CR': return AppColors.iucnCriticallyEndangered;
      default: return AppColors.lightTextMuted;
    }
  }

  String _getIucnFullName(String category) {
    switch (category) {
      case 'LC': return 'Préoccupation mineure';
      case 'NT': return 'Quasi menacé';
      case 'VU': return 'Vulnérable';
      case 'EN': return 'En danger';
      case 'CR': return 'En danger critique';
      default: return 'Non évalué';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iucnColor = _getIucnColor(widget.iucnCategory);
    final confidencePercent = (widget.confidence * 100).toStringAsFixed(0);

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── Handle Bar ───
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white24 : Colors.black12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // ─── Success Banner ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAction.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.primaryAction, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Espèce identifiée avec succès !',
                                  style: TextStyle(
                                    color: AppColors.primaryAction,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── Hero Image ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                _buildHeroImage(textSecondary),
                                // Gradient overlay at bottom
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 80,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Species name overlay on image
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  right: 16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.speciesName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -0.8,
                                          shadows: [
                                            Shadow(
                                              offset: Offset(0, 1),
                                              blurRadius: 6,
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        widget.scientificName,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 15,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Confidence & IUCN Metrics ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // Confidence
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.psychology_rounded,
                                              size: 18, color: AppColors.primaryAction),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Confiance IA',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '$confidencePercent%',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryAction,
                                          letterSpacing: -1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Progress bar
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: widget.confidence,
                                          minHeight: 6,
                                          backgroundColor: AppColors.primaryAction.withOpacity(0.12),
                                          valueColor: const AlwaysStoppedAnimation(AppColors.primaryAction),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // IUCN Status
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: borderColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.shield_rounded,
                                              size: 18, color: iucnColor),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Statut UICN',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: iucnColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: iucnColor.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          widget.iucnCategory,
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w900,
                                            color: iucnColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _getIucnFullName(widget.iucnCategory),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ─── Quick Facts Row (Wingspan, Weight, Diet) ───
                        if (widget.wingspan != null || widget.weight != null || widget.diet != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fiche Rapide',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (widget.wingspan != null)
                                    _buildQuickFactRow(
                                      Icons.straighten_rounded,
                                      'Envergure',
                                      widget.wingspan!,
                                      textPrimary,
                                      textSecondary,
                                    ),
                                  if (widget.weight != null) ...[
                                    Divider(color: borderColor, height: 20),
                                    _buildQuickFactRow(
                                      Icons.scale_rounded,
                                      'Poids',
                                      widget.weight!,
                                      textPrimary,
                                      textSecondary,
                                    ),
                                  ],
                                  if (widget.habitat != null) ...[
                                    Divider(color: borderColor, height: 20),
                                    _buildQuickFactRow(
                                      Icons.landscape_rounded,
                                      'Habitat',
                                      widget.habitat!,
                                      textPrimary,
                                      textSecondary,
                                    ),
                                  ],
                                  if (widget.diet != null) ...[
                                    Divider(color: borderColor, height: 20),
                                    _buildQuickFactRow(
                                      Icons.restaurant_rounded,
                                      'Alimentation',
                                      widget.diet!,
                                      textPrimary,
                                      textSecondary,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                        // ─── Le Saviez-Vous ? ───
                        if (widget.didYouKnow != null) ...[
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.accent.withOpacity(0.12),
                                    AppColors.accent.withOpacity(0.06),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.accent.withOpacity(0.25)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.accent.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.lightbulb_rounded,
                                            color: AppColors.accent, size: 20),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Le Saviez-Vous ?',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.accent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    widget.didYouKnow!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.6,
                                      color: textPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),

                        // ─── Action Buttons ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              // Correct button
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.edit_rounded, size: 18, color: textSecondary),
                                  label: Text(
                                    'Corriger',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    side: BorderSide(color: borderColor),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Save button
                              Expanded(
                                flex: 2,
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.save_rounded, size: 18, color: Colors.white),
                                  label: const Text(
                                    'Enregistrer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryAction,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ─── Ask AI Button ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              // Could navigate to ChatScreen with initial question
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.primaryAction, AppColors.secondaryAction],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryAction.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Interroger l\'IA sur ${widget.speciesName}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickFactRow(
    IconData icon,
    String label,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryAction),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              color: textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage(Color textSecondary) {
    final url = widget.imageUrl ?? '';
    final isAsset = url.startsWith('assets/');
    
    final fallback = Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryAction.withOpacity(0.15),
            AppColors.secondaryAction.withOpacity(0.15),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_camera_rounded,
              size: 48, color: AppColors.primaryAction),
          const SizedBox(height: 12),
          Text(
            'Photo capturée',
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    
    if (isAsset) {
      return Image.asset(
        url,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }
    
    if (url.isEmpty) return fallback;
    
    return Image.network(
      url,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}

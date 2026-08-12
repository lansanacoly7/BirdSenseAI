import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../chat/chat_screen.dart';

import 'species_catalog_screen.dart';

class SpeciesDetailScreen extends ConsumerStatefulWidget {
  final SpeciesItem species;

  const SpeciesDetailScreen({super.key, required this.species});

  @override
  ConsumerState<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends ConsumerState<SpeciesDetailScreen> with SingleTickerProviderStateMixin {
  bool _isPlayingAudio = false;
  late TabController _mediaTabController;

  @override
  void initState() {
    super.initState();
    _mediaTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mediaTabController.dispose();
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
        return AppColors.lightTextMuted;
    }
  }

  void _showIucnExplanationModal(BuildContext context, bool isDark) {
    final iucnColor = _getIucnColor(widget.species.iucnCategory);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statut de Conservation UICN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iucnColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: iucnColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: iucnColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.species.iucnCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.species.iucnDescription,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'La Liste rouge de l\'UICN est le répertoire mondial le plus complet sur l\'état de conservation global des espèces végétales et animales.',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iucnColor = _getIucnColor(widget.species.iucnCategory);
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        slivers: [
          // Header Media (HD Photo & Illustration Switcher)
          SliverAppBar(
            expandedHeight: 380.0,
            pinned: true,
            elevation: 0,
            backgroundColor: cardBg,
            leading: CircleAvatar(
              backgroundColor: cardBg.withOpacity(0.8),
              child: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: cardBg.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.share_rounded, color: AppColors.primaryAction),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  TabBarView(
                    controller: _mediaTabController,
                    children: [
                      // Photo HD
                      widget.species.imageUrl.isNotEmpty
                          ? (widget.species.imageUrl.startsWith('assets/')
                              ? Image.asset(
                                  widget.species.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
                                    child: const Icon(Icons.flutter_dash, size: 80, color: AppColors.primaryAction),
                                  ),
                                )
                              : Image.network(
                                  widget.species.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
                                    child: const Icon(Icons.flutter_dash, size: 80, color: AppColors.primaryAction),
                                  ),
                                ))
                          : Image.asset(
                              widget.species.assetImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
                                child: const Icon(Icons.flutter_dash, size: 80, color: AppColors.primaryAction),
                              ),
                            ),
                      // Illustration Scientifique
                      widget.species.imageUrl.isNotEmpty
                          ? (widget.species.imageUrl.startsWith('assets/')
                              ? Image.asset(
                                  widget.species.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
                                    child: const Icon(Icons.palette_rounded, size: 80, color: AppColors.primaryAction),
                                  ),
                                )
                              : Image.network(
                                  widget.species.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
                                    child: const Icon(Icons.palette_rounded, size: 80, color: AppColors.primaryAction),
                                  ),
                                ))
                          : Image.asset(
                              widget.species.assetImage,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
                                child: const Icon(Icons.palette_rounded, size: 80, color: AppColors.primaryAction),
                              ),
                            ),
                    ],
                  ),
                  // Gradient Vignette overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            cardBg,
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.4],
                        ),
                      ),
                    ),
                  ),
                  // Tab Switcher Overlay (Photo / Illustration)
                  Positioned(
                    top: 80,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cardBg.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _mediaTabController.animateTo(0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _mediaTabController.index == 0 ? AppColors.primaryAction : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Photo 4K',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _mediaTabController.index == 0 ? Colors.white : textSecondary,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _mediaTabController.animateTo(1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _mediaTabController.index == 1 ? AppColors.primaryAction : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Illustration',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _mediaTabController.index == 1 ? Colors.white : textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content Details
          SliverToBoxAdapter(
            child: Container(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Common Name & Scientific Name & IUCN Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.species.commonNameFr,
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                                letterSpacing: -1.0,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.species.scientificName,
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showIucnExplanationModal(context, isDark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: iucnColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: iucnColor.withOpacity(0.4)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'UICN',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: iucnColor,
                                ),
                              ),
                              Text(
                                widget.species.iucnCategory,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: iucnColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ask AI Quick Action Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            initialQuestion: 'Dis-moi tout sur le ${widget.species.commonNameFr} (${widget.species.scientificName})',
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryAction, AppColors.secondaryAction],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryAction.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Interroger l\'IA sur cet oiseau',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Posez une question sur le ${widget.species.commonNameFr}...',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.85),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Audio Player Bar
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isPlayingAudio = !_isPlayingAudio;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              color: AppColors.secondaryAction,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chant & Signature Bioacoustique',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Fréquence: ${widget.species.acousticFreq}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Section: "Le Saviez-Vous ?" (Did You Know?)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_rounded, color: AppColors.accent, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Le Saviez-Vous ?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.species.didYouKnow,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Physical Specs (Wingspan, Weight, Lifespan) Grid
                  Text(
                    'Caractéristiques Physiques',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSpecCard(
                          icon: Icons.straighten_rounded,
                          title: 'Envergure',
                          value: widget.species.wingspan,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSpecCard(
                          icon: Icons.scale_rounded,
                          title: 'Poids',
                          value: widget.species.weight,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSpecCard(
                          icon: Icons.timer_rounded,
                          title: 'Longévité',
                          value: widget.species.lifespan,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Description & Habitat
                  Text(
                    'Description & Habitat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.species.description,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailTile(
                    icon: Icons.landscape_rounded,
                    title: 'Habitat Naturel',
                    content: widget.species.habitat,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailTile(
                    icon: Icons.restaurant_rounded,
                    title: 'Régime Alimentaire',
                    content: widget.species.diet,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailTile(
                    icon: Icons.flight_takeoff_rounded,
                    title: 'Statut Migratoire',
                    content: widget.species.migrationStatus,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailTile(
                    icon: Icons.nature_people_rounded,
                    title: 'Rôle Écologique',
                    content: widget.species.ecologicalRole,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 28),

                  // Taxonomy Classification
                  Text(
                    'Classification Taxonomique',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        _buildTaxonomyRow('Règne', 'Animalia', isDark),
                        const Divider(height: 16),
                        _buildTaxonomyRow('Classe', 'Aves', isDark),
                        const Divider(height: 16),
                        _buildTaxonomyRow('Ordre', widget.species.order, isDark),
                        const Divider(height: 16),
                        _buildTaxonomyRow('Famille', widget.species.family, isDark),
                        const Divider(height: 16),
                        _buildTaxonomyRow('Nom Scientifique', widget.species.scientificName, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding for floating navbar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryAction, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
  }) {
    final cardBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryAction, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxonomyRow(String label, String value, bool isDark) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

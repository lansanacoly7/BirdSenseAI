import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'species_catalog_screen.dart';

class SpeciesDetailScreen extends StatefulWidget {
  final SpeciesItem species;

  const SpeciesDetailScreen({super.key, required this.species});

  @override
  State<SpeciesDetailScreen> createState() => _SpeciesDetailScreenState();
}

class _SpeciesDetailScreenState extends State<SpeciesDetailScreen> {
  bool _isPlayingAudio = false;

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
    return Scaffold(
      appBar: AppBar(title: Text(widget.species.commonNameFr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Placeholder / Icon
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryCanopy.withAlpha(120),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentAmber.withAlpha(80)),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flutter_dash,
                    size: 80,
                    color: AppColors.accentAmber,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Photo d\'illustration',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Names & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.species.commonNameFr,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.species.scientificName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getIucnColor(widget.species.iucnCategory),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Statut: ${widget.species.iucnCategory}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Audio Player Mock Card (BirdNET / eBird audio call)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      iconSize: 40,
                      color: AppColors.secondaryTerracotta,
                      icon: Icon(
                        _isPlayingAudio
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_fill,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPlayingAudio = !_isPlayingAudio;
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Chant & Cri de l\'espèce',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isPlayingAudio
                                ? 'Lecture en cours (API eBird/BirdNET)...'
                                : 'Appuyez pour écouter',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
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

            // Description
            const Text(
              'Description & Habitat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accentAmber,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.species.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Family Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.category, color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  Text(
                    'Famille taxonomique : ${widget.species.family}',
                    style: const TextStyle(color: AppColors.textSecondary),
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

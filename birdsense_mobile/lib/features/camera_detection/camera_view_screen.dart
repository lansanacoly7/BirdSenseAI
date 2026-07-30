import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../local_observations/presentation/pages/local_observations_page.dart';
import 'presentation/widgets/bounding_box_painter.dart';
import 'providers/camera_provider.dart';

/// Écran principal de capture caméra avec overlay IA.
///
/// Responsabilités :
/// - Afficher le flux vidéo en temps réel.
/// - Dessiner les bounding boxes des détections IA via [BoundingBoxPainter].
/// - Permettre la capture photo (sauvegarde offline via [ObservationRepository]).
/// - Permettre l'enregistrement vidéo MP4.
/// - Naviguer vers la page [LocalObservationsPage] pour consulter/synchro.
class CameraViewScreen extends ConsumerWidget {
  const CameraViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);

    // Comptage des oiseaux uniques (par trackId, ou par label en fallback).
    final uniqueBirdCount = cameraState.detections
        .map((d) => d.trackId ?? d.label)
        .toSet()
        .length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildCameraPreview(cameraState),
          _buildBoundingBoxOverlay(cameraState),
          _buildTopCounter(cameraState, uniqueBirdCount),
          _buildBottomBar(context, ref, cameraState),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets privés
  // ---------------------------------------------------------------------------

  /// Aperçu caméra ou indicateur de chargement.
  Widget _buildCameraPreview(CameraState cameraState) {
    if (cameraState.isInitialized && cameraState.controller != null) {
      return SizedBox.expand(child: CameraPreview(cameraState.controller!));
    }
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primaryCanopy),
    );
  }

  /// Overlay des bounding boxes (masqué pendant l'enregistrement vidéo).
  Widget _buildBoundingBoxOverlay(CameraState cameraState) {
    if (!cameraState.isInitialized ||
        cameraState.controller == null ||
        cameraState.isRecordingVideo) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            painter: BoundingBoxPainter(
              detections: cameraState.detections,
              boxFit: BoxFit.cover,
              previewSize: Size(constraints.maxWidth, constraints.maxHeight),
              imageSize: cameraState.controller!.value.previewSize ?? Size.zero,
            ),
          );
        },
      ),
    );
  }

  /// Bandeau supérieur : compteur d'oiseaux et badge IA.
  Widget _buildTopCounter(CameraState cameraState, int birdCount) {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accentAmber.withAlpha(100)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.flutter_dash, color: AppColors.accentAmber),
                const SizedBox(width: 8),
                Text(
                  'Oiseaux Détectés : $birdCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: cameraState.isRecordingVideo
                    ? Colors.red
                    : AppColors.primaryCanopy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                cameraState.isRecordingVideo ? 'REC' : 'IA Active',
                style: const TextStyle(
                  color: AppColors.accentAmber,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Barre inférieure : bouton vidéo, shutter photo, bouton observations.
  Widget _buildBottomBar(
    BuildContext context,
    WidgetRef ref,
    CameraState cameraState,
  ) {
    final notifier = ref.read(cameraProvider.notifier);

    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Bouton vidéo
          FloatingActionButton.small(
            heroTag: 'video_btn',
            backgroundColor: cameraState.isRecordingVideo
                ? Colors.red
                : AppColors.surfaceDark,
            onPressed: notifier.toggleVideoRecording,
            child: Icon(
              cameraState.isRecordingVideo ? Icons.stop : Icons.videocam,
              color: Colors.white,
            ),
          ),

          // Shutter photo
          GestureDetector(
            onTap: cameraState.isRecordingVideo
                ? null
                : () => _onCapture(context, ref, cameraState),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cameraState.isRecordingVideo
                    ? Colors.grey
                    : AppColors.secondaryTerracotta,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: const Icon(Icons.camera, size: 36, color: Colors.white),
            ),
          ),

          // Bouton observations locales
          FloatingActionButton.small(
            heroTag: 'observations_btn',
            backgroundColor: AppColors.surfaceDark,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LocalObservationsPage(),
                ),
              );
            },
            child: const Icon(Icons.cloud_upload, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Capture une photo, sauvegarde en base locale via le repository.
  Future<void> _onCapture(
    BuildContext context,
    WidgetRef ref,
    CameraState cameraState,
  ) async {
    HapticFeedback.lightImpact(); // Retour tactile premium
    final notifier = ref.read(cameraProvider.notifier);
    final path = await notifier.takePicture();

    if (!context.mounted || path == null) return;

    try {
      final repo = ref.read(observationRepositoryProvider);
      final userId = ref.read(authUserIdProvider);

      await repo.saveObservation(
        userId: userId,
        photoPath: path,
        detections: cameraState.detections,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Observation sauvegardée (Pending)'),
            backgroundColor: AppColors.primaryCanopy,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de sauvegarde : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

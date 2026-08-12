import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../models/detection_dto.dart';
import '../services/detection_service.dart';
import '../services/fake_detection_service.dart';
import '../../impact_sync/services/audio_level_service.dart';
import '../../impact_sync/data/impact_score_repository.dart';
import '../../impact_sync/models/impact_score_dto.dart';
import '../../impact_sync/providers/audio_level_provider.dart';
import '../../impact_sync/providers/impact_score_repository_provider.dart';
import 'package:uuid/uuid.dart';
import '../services/remote_detection_service.dart';

// =============================================================================
// Providers — Module Camera
// =============================================================================

/// Fournit l'implémentation active de [DetectionService].
///
/// Tente d'utiliser [RemoteDetectionService] pour la détection IA backend.
final detectionServiceProvider = Provider<DetectionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RemoteDetectionService(apiClient.dio);
});

// =============================================================================
// State
// =============================================================================

/// État immuable du module caméra.
class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final bool isRecordingVideo;
  final List<DetectionDto> detections;
  final String? lastCapturedPath;

  const CameraState({
    this.controller,
    this.isInitialized = false,
    this.isRecordingVideo = false,
    this.detections = const [],
    this.lastCapturedPath,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    bool? isRecordingVideo,
    List<DetectionDto>? detections,
    String? lastCapturedPath,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
      detections: detections ?? this.detections,
      lastCapturedPath: lastCapturedPath ?? this.lastCapturedPath,
    );
  }
}

// =============================================================================
// Notifier
// =============================================================================

/// Intervalle minimum entre deux traitements de frame (en ms).
const int _kFrameThrottleMs = 400;

/// Gère le cycle de vie du [CameraController] et le flux d'inférence IA.
///
/// Fonctionnalités :
/// - Initialisation automatique de la caméra arrière.
/// - Throttle du stream d'images à [_kFrameThrottleMs].
/// - Capture photo avec arrêt/relance automatique du stream.
/// - Enregistrement vidéo MP4 avec arrêt de l'IA pendant la capture.
class CameraNotifier extends StateNotifier<CameraState> {
  final DetectionService _detectionService;
  final AudioLevelService _audioLevelService;
  final ImpactScoreRepository _impactScoreRepository;

  bool _isProcessingFrame = false;
  DateTime? _lastFrameTime;

  CameraNotifier(
    this._detectionService,
    this._audioLevelService,
    this._impactScoreRepository,
  ) : super(const CameraState()) {
    _initCamera();
    _audioLevelService.init();
  }

  /// Initialise le [CameraController] et démarre le stream d'inférence.
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      await controller.startImageStream(_onCameraFrame);

      state = state.copyWith(controller: controller, isInitialized: true);
    } catch (_) {
      // Caméra non disponible (émulateur sans caméra, permissions refusées…).
    }
  }

  /// Callback du stream caméra — throttlé et protégé par un verrou.
  Future<void> _onCameraFrame(CameraImage image) async {
    if (_isProcessingFrame) return;

    final now = DateTime.now();
    if (_lastFrameTime != null &&
        now.difference(_lastFrameTime!).inMilliseconds < _kFrameThrottleMs) {
      return;
    }

    _isProcessingFrame = true;
    _lastFrameTime = now;

    try {
      // NOTE TECHNIQUE : Le FakeDetectionService ignore le fichier passé.
      // Pour une implémentation réelle, il faudra convertir le CameraImage
      // (YUV420) en JPEG via un isolate ou un plugin natif (ex: image package).
      final detections = await _detectionService.inferImage(File(''));

      if (mounted) {
        state = state.copyWith(detections: detections);
      }
    } catch (_) {
      // Ne jamais bloquer le stream caméra.
    } finally {
      _isProcessingFrame = false;
    }
  }

  /// Capture une photo et retourne le chemin local du fichier JPEG.
  ///
  /// Arrête le stream d'inférence le temps de la capture puis le relance.
  /// Retourne `null` si la caméra n'est pas initialisée.
  Future<String?> takePicture() async {
    final controller = state.controller;
    if (!state.isInitialized || controller == null) return null;

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }

      final xFile = await controller.takePicture();

      if (!mounted) return null;

      // Relancer le stream après capture.
      await controller.startImageStream(_onCameraFrame);

      state = state.copyWith(lastCapturedPath: xFile.path);
      return xFile.path;
    } catch (_) {
      return null;
    }
  }

  /// Bascule entre démarrage et arrêt de l'enregistrement vidéo.
  ///
  /// Pendant l'enregistrement, le stream d'inférence est arrêté
  /// et les bounding boxes sont vidées.
  Future<void> toggleVideoRecording() async {
    final controller = state.controller;
    if (!state.isInitialized || controller == null) return;

    try {
      if (state.isRecordingVideo) {
        final file = await controller.stopVideoRecording();
        await _audioLevelService.stop();

        // [Step 4] Injecter un fake ImpactScore à la fin de la vidéo
        final mockScore = ImpactScoreDto(
          id: const Uuid().v4(),
          observationId: 'obs_${DateTime.now().millisecondsSinceEpoch}',
          score: 85.5,
          level: 'high',
          calculationVersion: '1.0',
          computedAt: DateTime.now().toUtc().toIso8601String(),
        );
        await _impactScoreRepository.saveImpactScore(mockScore);

        if (!mounted) return;

        state = state.copyWith(
          isRecordingVideo: false,
          lastCapturedPath: file.path,
        );
        await controller.startImageStream(_onCameraFrame);
      } else {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        await _audioLevelService.start();
        await controller.startVideoRecording();

        if (!mounted) return;

        state = state.copyWith(isRecordingVideo: true, detections: const []);
      }
    } catch (_) {
      // Ignorer les erreurs de caméra non critiques.
    }
  }

  @override
  void dispose() {
    if (state.isRecordingVideo) {
      _audioLevelService.stop();
    }
    state.controller?.dispose();
    super.dispose();
  }
}

/// Provider principal du module caméra.
///
/// `autoDispose` : libère le [CameraController] quand l'écran caméra
/// n'est plus affiché, évitant les fuites de ressources.
final cameraProvider =
    StateNotifierProvider.autoDispose<CameraNotifier, CameraState>((ref) {
      return CameraNotifier(
        ref.watch(detectionServiceProvider),
        ref.watch(audioLevelServiceProvider),
        ref.watch(impactScoreRepositoryProvider),
      );
    });

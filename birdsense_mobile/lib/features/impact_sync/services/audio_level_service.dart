import 'package:birdsense_mobile/features/impact_sync/models/audio_level_sample.dart';

/// Interface pour le service de capture du niveau sonore.
abstract class AudioLevelService {
  /// Initialise le service (ex: demande de permissions).
  Future<void> init();
  
  /// Démarre la capture du niveau sonore.
  Future<void> start();
  
  /// Arrête la capture du niveau sonore.
  Future<void> stop();
  
  /// Flux des niveaux sonores bruts capturés (en décibels, de -120 à 0).
  Stream<AudioLevelSample> get audioLevelStream;
}

import 'dart:io';
import 'dart:math';

import '../models/detection_dto.dart';
import 'detection_service.dart';

/// Espèces simulées pour le mode démo.
const List<String> _kMockSpecies = [
  'Aigrette garzette',
  'Flamant rose',
  'Pélican blanc',
];

/// Implémentation simulée de [DetectionService] pour le mode démo/offline.
///
/// Retourne entre 0 et 3 détections aléatoires avec des coordonnées
/// normalisées réalistes et des scores de confiance entre 50 % et 99 %.
///
/// Le paramètre [imageFile] est ignoré — aucun traitement d'image réel
/// n'est effectué.
class FakeDetectionService implements DetectionService {
  final Random _random = Random();

  @override
  Future<List<DetectionDto>> inferImage(File imageFile) async {
    // Simuler la latence d'un modèle IA.
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final numBirds = _random.nextInt(4); // 0 à 3
    if (numBirds == 0) return const [];

    return List.generate(numBirds, (_) => _generateRandomDetection());
  }

  DetectionDto _generateRandomDetection() {
    final w = 0.1 + _random.nextDouble() * 0.2; // 10 % à 30 %
    final h = 0.1 + _random.nextDouble() * 0.2;
    final x = _random.nextDouble() * (1 - w);
    final y = _random.nextDouble() * (1 - h);

    return DetectionDto(
      label: _kMockSpecies[_random.nextInt(_kMockSpecies.length)],
      confidence: 0.50 + _random.nextDouble() * 0.49,
      x: x,
      y: y,
      width: w,
      height: h,
      trackId: 'mock_t_${_random.nextInt(1000)}',
    );
  }
}

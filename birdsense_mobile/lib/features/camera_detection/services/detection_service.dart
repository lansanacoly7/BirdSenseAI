import 'dart:io';

import '../models/detection_dto.dart';

/// Contrat d'interface pour les services d'inférence IA.
///
/// Permet de basculer entre une implémentation simulée
/// ([FakeDetectionService]) et une implémentation réseau
/// ([RemoteDetectionService]) sans modifier le code appelant.
abstract class DetectionService {
  /// Analyse [imageFile] et retourne les oiseaux détectés.
  ///
  /// Les coordonnées des bounding boxes dans chaque [DetectionDto]
  /// sont normalisées entre 0.0 et 1.0.
  Future<List<DetectionDto>> inferImage(File imageFile);
}

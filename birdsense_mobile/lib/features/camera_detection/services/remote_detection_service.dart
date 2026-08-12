import 'dart:io';

import 'package:dio/dio.dart';

import '../models/detection_dto.dart';
import 'detection_service.dart';

/// Implémentation réseau de [DetectionService].
///
/// Envoie l'image au serveur d'inférence IA via HTTP multipart
/// et parse les détections retournées.
///
/// En cas d'erreur réseau ou timeout, retourne une liste vide
/// afin de ne pas interrompre le flux caméra.
class RemoteDetectionService implements DetectionService {
  final Dio _dio;
  final String _inferEndpoint;

  /// Crée un service pointant vers [baseUrl]/api/v1/vision/detect par défaut.
  ///
  /// [dio] doit être pré-configuré (timeouts, intercepteurs JWT, etc.).
  RemoteDetectionService(this._dio, {String? baseUrl})
    : _inferEndpoint = baseUrl != null 
        ? '$baseUrl/api/v1/vision/detect' 
        : '/api/v1/vision/detect';

  @override
  Future<List<DetectionDto>> inferImage(File imageFile) async {
    if (!imageFile.existsSync() || imageFile.lengthSync() == 0) {
      return const [];
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'frame.jpg',
        ),
      });

      final response = await _dio.post(
        _inferEndpoint,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final dataMap = response.data is Map<String, dynamic> ? response.data : {};
        final rawDetections = (dataMap['data']?['detections'] as List<dynamic>?) ??
            (dataMap['detections'] as List<dynamic>?) ?? [];

        return rawDetections.map((json) {
          final item = json as Map<String, dynamic>;
          final normBox = (item['box_normalized'] as List<dynamic>?) ?? [0.2, 0.2, 0.8, 0.8];
          final x1 = (normBox.isNotEmpty ? normBox[0] as num : 0.2).toDouble();
          final y1 = (normBox.length > 1 ? normBox[1] as num : 0.2).toDouble();
          final x2 = (normBox.length > 2 ? normBox[2] as num : 0.8).toDouble();
          final y2 = (normBox.length > 3 ? normBox[3] as num : 0.8).toDouble();

          final speciesLabel = item['species_identification']?['top_species'] ?? 
              item['class_name'] ?? item['label'] ?? 'Oiseau';
          final confidence = (item['confidence'] as num?)?.toDouble() ?? 0.85;

          return DetectionDto(
            label: speciesLabel.toString(),
            confidence: confidence,
            x: x1,
            y: y1,
            width: (x2 - x1).clamp(0.05, 1.0),
            height: (y2 - y1).clamp(0.05, 1.0),
          );
        }).toList();
      }

      return const [];
    } catch (_) {
      // Erreur réseau ou timeout — ne pas bloquer le stream caméra.
      return const [];
    }
  }
}

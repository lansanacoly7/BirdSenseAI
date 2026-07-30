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

  /// Crée un service pointant vers [baseUrl]/infer.
  ///
  /// [dio] doit être pré-configuré (timeouts, intercepteurs JWT, etc.).
  RemoteDetectionService(this._dio, {required String baseUrl})
    : _inferEndpoint = '$baseUrl/infer';

  @override
  Future<List<DetectionDto>> inferImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'frame.jpg',
        ),
      });

      final response = await _dio.post(
        _inferEndpoint,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawDetections =
            (response.data['detections'] as List<dynamic>?) ?? [];
        return rawDetections
            .map((json) => DetectionDto.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return const [];
    } catch (_) {
      // Erreur réseau ou timeout — ne pas bloquer le stream caméra.
      return const [];
    }
  }
}

import 'dart:io';

import 'package:dio/dio.dart';

/// Résultat d'une détection renvoyé par l'API /api/v1/cv/detect.
class CvDetection {
  final String trackId;
  final String species;
  final double confidence;
  final Map<String, double> bbox;

  const CvDetection({
    required this.trackId,
    required this.species,
    required this.confidence,
    required this.bbox,
  });

  factory CvDetection.fromJson(Map<String, dynamic> json) {
    final rawBbox = json['bbox'] as Map<String, dynamic>;
    return CvDetection(
      trackId: json['track_id'] as String? ?? '',
      species: json['species'] as String? ?? 'Inconnu',
      confidence: (json['confidence'] as num).toDouble(),
      bbox: {
        'x_center': (rawBbox['x_center'] as num).toDouble(),
        'y_center': (rawBbox['y_center'] as num).toDouble(),
        'width': (rawBbox['width'] as num).toDouble(),
        'height': (rawBbox['height'] as num).toDouble(),
      },
    );
  }
}

/// Réponse complète de l'endpoint /api/v1/cv/detect.
class CvDetectResponse {
  final String status;
  final int birdCount;
  final String filename;
  final List<CvDetection> detections;

  const CvDetectResponse({
    required this.status,
    required this.birdCount,
    required this.filename,
    required this.detections,
  });

  factory CvDetectResponse.fromJson(Map<String, dynamic> json) {
    final rawList = (json['detections'] as List<dynamic>?) ?? [];
    return CvDetectResponse(
      status: json['status'] as String? ?? 'error',
      birdCount: json['bird_count'] as int? ?? 0,
      filename: json['filename'] as String? ?? '',
      detections: rawList
          .map((e) => CvDetection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Service qui envoie une image au endpoint `/api/v1/cv/detect`
/// et retourne la liste des oiseaux détectés.
///
/// Utilise `multipart/form-data` via [Dio].
/// En cas d'erreur réseau ou réponse invalide, lance une [Exception].
class CvUploadService {
  final Dio _dio;
  final String _endpoint;

  CvUploadService(Dio dio, {required String baseUrl})
      : _dio = dio,
        _endpoint = '$baseUrl/api/v1/cv/detect';

  /// Envoie [imageFile] au serveur et retourne la réponse parsée.
  ///
  /// Throws [Exception] si la réponse HTTP n'est pas 200 ou si
  /// le contenu ne peut pas être désérialisé.
  Future<CvDetectResponse> detectBirds(File imageFile) async {
    final filename = imageFile.path.split(Platform.pathSeparator).last;

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: filename,
      ),
    });

    final response = await _dio.post(
      _endpoint,
      data: formData,
      options: Options(
        sendTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception(
        'Erreur serveur : HTTP ${response.statusCode}',
      );
    }

    return CvDetectResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}

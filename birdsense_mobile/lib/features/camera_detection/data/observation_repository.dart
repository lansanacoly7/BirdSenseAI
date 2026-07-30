import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../models/detection_dto.dart';

/// Repository responsable de la persistance locale des observations.
///
/// Encapsule toute la logique d'insertion en base de données Drift,
/// permettant de garder les widgets propres et testables.
class ObservationRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  ObservationRepository(this._db);

  /// Sauvegarde une observation et ses détections IA en une seule transaction.
  ///
  /// Retourne l'UUID de l'observation créée.
  ///
  /// [userId]      : identifiant de l'utilisateur connecté.
  /// [photoPath]   : chemin local du fichier JPEG capturé.
  /// [detections]  : liste des détections IA de la frame courante.
  /// [latitude]    : coordonnée GPS (nullable si GPS désactivé).
  /// [longitude]   : coordonnée GPS (nullable si GPS désactivé).
  Future<String> saveObservation({
    required String userId,
    required String? photoPath,
    required List<DetectionDto> detections,
    double? latitude,
    double? longitude,
  }) async {
    final obsId = _uuid.v4();

    await _db.transaction(() async {
      // 1. Insérer l'observation parent.
      await _db
          .into(_db.localObservations)
          .insert(
            LocalObservationsCompanion.insert(
              id: obsId,
              userId: userId,
              createdAt: DateTime.now().toUtc(),
              localPhotoPath: Value(photoPath),
              latitude: Value(latitude),
              longitude: Value(longitude),
              status: const Value('pending'),
            ),
          );

      // 2. Insérer chaque détection IA liée.
      for (final det in detections) {
        await _db
            .into(_db.localObservationItems)
            .insert(
              LocalObservationItemsCompanion.insert(
                id: _uuid.v4(),
                observationId: obsId,
                label: det.label,
                confidence: det.confidence,
                trackId: Value(det.trackId),
                x: det.x,
                y: det.y,
                width: det.width,
                height: det.height,
              ),
            );
      }
    });

    return obsId;
  }
}

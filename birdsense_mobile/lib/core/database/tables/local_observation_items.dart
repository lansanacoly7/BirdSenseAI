import 'package:drift/drift.dart';

import 'local_observations.dart';

/// Table des détections IA associées à une [LocalObservation].
///
/// Chaque ligne représente un oiseau détecté dans l'image/vidéo,
/// avec ses coordonnées normalisées (0.0 → 1.0) pour la bounding box.
@DataClassName('LocalObservationItem')
class LocalObservationItems extends Table {
  /// UUID v4 unique de cet item de détection.
  TextColumn get id => text()();

  /// Clé étrangère vers [LocalObservations.id].
  TextColumn get observationId => text().references(LocalObservations, #id)();

  /// Nom de l'espèce détectée (ex: "pélican blanc").
  TextColumn get label => text()();

  /// Score de confiance du modèle IA, entre 0.0 et 1.0.
  RealColumn get confidence => real()();

  /// Identifiant de suivi inter-frames (tracking). Nullable si pas de suivi.
  TextColumn get trackId => text().nullable()();

  /// Coordonnée X du coin supérieur gauche de la bounding box (normalisée).
  RealColumn get x => real()();

  /// Coordonnée Y du coin supérieur gauche de la bounding box (normalisée).
  RealColumn get y => real()();

  /// Largeur de la bounding box (normalisée).
  RealColumn get width => real()();

  /// Hauteur de la bounding box (normalisée).
  RealColumn get height => real()();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

/// Table SQLite locale pour stocker les observations de terrain.
///
/// Chaque observation correspond à une capture (photo ou vidéo)
/// effectuée par l'utilisateur, potentiellement enrichie par des
/// détections IA (voir [LocalObservationItems]).
///
/// Le champ [status] suit la machine à états :
///   pending → syncing → synced
///                    ↘ failed (avec retry) → abandoned (si max retries atteint)
@DataClassName('LocalObservation')
class LocalObservations extends Table {
  /// UUID v4 généré côté mobile. Sert de clé d'idempotence pour la synchro.
  TextColumn get id => text()();

  /// Identifiant de l'utilisateur ayant capturé l'observation.
  TextColumn get userId => text()();

  /// Horodatage de la capture, stocké en UTC.
  DateTimeColumn get createdAt => dateTime()();

  /// Coordonnées GPS au moment de la capture (nullable si GPS désactivé).
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();

  /// Chemin absolu local vers la photo capturée.
  TextColumn get localPhotoPath => text().nullable()();

  /// Chemin absolu local vers la vidéo capturée.
  TextColumn get localVideoPath => text().nullable()();

  /// Statut de synchronisation : 'pending', 'syncing', 'synced', 'failed', 'abandoned'.
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Nombre de tentatives de synchronisation échouées.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Message d'erreur de la dernière tentative échouée.
  TextColumn get lastSyncError => text().nullable()();

  /// UUID attribué par le serveur après synchronisation réussie.
  TextColumn get serverId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

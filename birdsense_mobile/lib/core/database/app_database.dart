import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/local_observation_items.dart';
import 'tables/local_observations.dart';
import 'tables/local_impact_scores.dart';

part 'app_database.g.dart';

/// Base de données SQLite locale de BirdSense AI.
///
/// Gère le stockage offline des observations de terrain et de leurs
/// détections IA associées. Fournit des méthodes CRUD spécialisées
/// pour le workflow de synchronisation.
@DriftDatabase(tables: [LocalObservations, LocalObservationItems, LocalImpactScores])
class AppDatabase extends _$AppDatabase {
  /// Constructeur par défaut utilisant la connexion SQLite native.
  AppDatabase() : super(_openConnection());

  /// Constructeur injectable pour les tests unitaires.
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  // ---------------------------------------------------------------------------
  // Lecture
  // ---------------------------------------------------------------------------

  /// Récupère les observations ayant le statut `pending` ou `failed`.
  ///
  /// Utilisé par [SyncService] pour constituer le lot de synchronisation.
  Future<List<LocalObservation>> getPendingOrFailedObservations() {
    return (select(
          localObservations,
        )..where((t) => t.status.equals('pending') | t.status.equals('failed')))
        .get();
  }

  /// Récupère les items de détection liés à une observation donnée.
  Future<List<LocalObservationItem>> getItemsForObservation(
    String observationId,
  ) {
    return (select(
      localObservationItems,
    )..where((t) => t.observationId.equals(observationId))).get();
  }

  // ---------------------------------------------------------------------------
  // Écriture — Workflow de synchronisation
  // ---------------------------------------------------------------------------

  /// Passe les observations identifiées par [ids] au statut `syncing`.
  ///
  /// Appelé **avant** l'envoi réseau pour verrouiller le lot.
  Future<void> markAsSyncing(List<String> ids) async {
    await (update(localObservations)..where((t) => t.id.isIn(ids))).write(
      const LocalObservationsCompanion(status: Value('syncing')),
    );
  }

  /// Remet toutes les observations `syncing` en `pending`.
  ///
  /// Utilisé au démarrage de l'app pour récupérer un crash survenu
  /// pendant une synchronisation, et sur erreur 401 (session expirée).
  Future<void> resetSyncingToPending() async {
    await (update(localObservations)..where((t) => t.status.equals('syncing')))
        .write(const LocalObservationsCompanion(status: Value('pending')));
  }

  /// Marque une observation comme synchronisée avec succès.
  ///
  /// [serverId] est l'identifiant retourné par le backend.
  /// Gère aussi le cas `already_exists` de la même façon.
  Future<void> markAsSynced(String id, String serverId) async {
    await (update(localObservations)..where((t) => t.id.equals(id))).write(
      LocalObservationsCompanion(
        status: const Value('synced'),
        serverId: Value(serverId),
      ),
    );
  }

  /// Marque une observation comme échouée et incrémente le compteur de retry.
  /// Si le nombre maximum de tentatives ([maxRetryCount]) est atteint,
  /// le statut passe à `abandoned` pour ne plus bloquer la file de synchro.
  Future<void> markAsFailed(
    String id,
    String error,
    int currentRetryCount, {
    int maxRetryCount = 5,
  }) async {
    final newRetryCount = currentRetryCount + 1;
    final newStatus = newRetryCount >= maxRetryCount ? 'abandoned' : 'failed';

    await (update(localObservations)..where((t) => t.id.equals(id))).write(
      LocalObservationsCompanion(
        status: Value(newStatus),
        lastSyncError: Value(error),
        retryCount: Value(newRetryCount),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Écriture — Impact Scores (Phase 2)
  // ---------------------------------------------------------------------------

  /// Ajoute ou met à jour un score d'impact pour une observation
  Future<void> upsertImpactScore(LocalImpactScore score) async {
    await into(localImpactScores).insertOnConflictUpdate(score);
  }

  /// Récupère le score le plus récent pour une observation
  Future<LocalImpactScore?> getLatestImpactScoreForObservation(String observationId) async {
    return (select(localImpactScores)
          ..where((t) => t.observationId.equals(observationId))
          ..orderBy([(t) => OrderingTerm(expression: t.computedAt, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Observe en temps réel le score d'impact d'une observation
  Stream<LocalImpactScore?> watchLatestImpactScoreForObservation(String observationId) {
    return (select(localImpactScores)
          ..where((t) => t.observationId.equals(observationId))
          ..orderBy([(t) => OrderingTerm(expression: t.computedAt, mode: OrderingMode.desc)])
          ..limit(1))
        .watchSingleOrNull();
  }
}

/// Ouvre la connexion SQLite en arrière-plan avec chiffrement SQLCipher.
///
/// Le fichier de base de données est stocké dans le répertoire
/// documents de l'application sous le nom `birdsense_db.sqlite`.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'birdsense_db.sqlite'));

    // Chiffrement SQLCipher activé
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        // En production, cette clé doit provenir du module Auth ou du SecureStorage.
        // Pour l'extension, on utilise une clé statique forte configurée via environnement.
        const cipherKey = String.fromEnvironment(
          'SQLCIPHER_KEY',
          defaultValue: 'birdsense_secure_key_2026',
        );
        rawDb.execute("PRAGMA key = '$cipherKey';");
      },
    );
  });
}

import 'package:drift/drift.dart';

import 'connection/db_connection.dart';
import 'tables/local_observation_items.dart';
import 'tables/local_observations.dart';
import 'tables/community_tables.dart';

part 'app_database.g.dart';

/// Base de données locale de BirdSense AI (Mobile / Web).
@DriftDatabase(tables: [
  LocalObservations, 
  LocalObservationItems,
  CommunityFeed,
  UserFavorites,
  UserCollection,
  PendingActions
])
class AppDatabase extends _$AppDatabase {
  /// Constructeur par défaut utilisant la connexion cross-plateforme.
  AppDatabase() : super(openConnection());

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
  // Communauté - DAO (Data Access Object)
  // ---------------------------------------------------------------------------
  
  /// Insère ou met à jour une liste d'observations communautaires (mise en cache).
  Future<void> cacheCommunityFeed(List<CommunityObservation> observations) async {
    await batch((batch) {
      batch.insertAll(
        communityFeed, 
        observations, 
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  /// Récupère le flux des observations communautaires (triées par date décroissante).
  Stream<List<CommunityObservation>> watchCommunityFeed() {
    return (select(communityFeed)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Ajoute ou retire un favori.
  Future<void> toggleFavorite(String observationId) async {
    final existing = await (select(userFavorites)..where((t) => t.observationId.equals(observationId))).getSingleOrNull();
    if (existing != null) {
      await (delete(userFavorites)..where((t) => t.observationId.equals(observationId))).go();
    } else {
      await into(userFavorites).insert(
        UserFavoritesCompanion.insert(
          observationId: observationId,
          savedAt: DateTime.now().toUtc(),
        ),
      );
    }
  }

  /// Ajoute une action asynchrone (Validation, Signalement) dans la file d'attente WorkManager.
  Future<int> queuePendingAction(String actionType, String payloadJson) {
    return into(pendingActions).insert(
      PendingActionsCompanion.insert(
        actionType: actionType,
        payloadJson: payloadJson,
      ),
    );
  }

  /// Récupère les actions en attente pour le WorkManager.
  Future<List<PendingAction>> getPendingActions() {
    return (select(pendingActions)..where((t) => t.status.equals('pending'))).get();
  }

  /// Marque une action comme échouée après tentative du WorkManager.
  Future<void> markActionAsFailed(int id, int currentRetryCount) async {
    await (update(pendingActions)..where((t) => t.id.equals(id))).write(
      PendingActionsCompanion(
        retryCount: Value(currentRetryCount + 1),
        status: const Value('failed'),
      )
    );
  }
}


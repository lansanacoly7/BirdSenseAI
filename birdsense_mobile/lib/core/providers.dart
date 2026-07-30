import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'network/api_client.dart';
import 'network/sync_service.dart';
import '../features/camera_detection/data/observation_repository.dart';

// =============================================================================
// Providers globaux — Module Camera / SQLite / Sync
// =============================================================================
// Ces providers sont isolés dans `core/providers.dart` afin d'éviter tout
// conflit avec les providers définis par les autres membres de l'équipe
// dans leurs propres modules (auth, dashboard, etc.).
// =============================================================================

/// Fournit l'instance unique de la base de données Drift.
///
/// Automatiquement fermée lorsque le provider est disposé.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Fournit le client HTTP configuré pour le backend BirdSense AI.
///
/// L'URL de base est centralisée ici pour faciliter la configuration
/// par environnement (dev / staging / prod).
final apiClientProvider = Provider<ApiClient>((ref) {
  const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.birdsense.test',
  );
  return ApiClient(baseUrl: baseUrl);
});

/// Provider de l'ID utilisateur courant.
/// Point d'intégration pour le module d'authentification.
final authUserIdProvider = Provider<String>((ref) {
  return const String.fromEnvironment(
    'MOCK_USER_ID',
    defaultValue: 'demo-user-123',
  );
});

/// Fournit le service de synchronisation offline → backend.
final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    db: ref.watch(databaseProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

/// Fournit le repository de persistance des observations.
final observationRepositoryProvider = Provider<ObservationRepository>((ref) {
  return ObservationRepository(ref.watch(databaseProvider));
});

import 'dart:math';

import 'package:dio/dio.dart';

import '../database/app_database.dart';
import 'api_client.dart';
import 'dto/sync_request_dto.dart';
import 'dto/sync_response_dto.dart';

/// Taille maximale d'un lot de synchronisation.
const int _kMaxBatchSize = 20;

/// Nombre maximal de retries avant abandon d'une observation.
const int _kMaxRetryCount = 5;

/// Délai maximum de backoff exponentiel en secondes.
const int _kMaxBackoffSeconds = 30;

/// Exception levée lorsque le backend retourne un 401.
///
/// Doit être catchée par l'UI pour rediriger vers l'écran de login.
class SessionExpiredException implements Exception {
  @override
  String toString() => 'SessionExpiredException: Token JWT expiré ou invalide.';
}

/// Service de synchronisation offline → backend.
///
/// Orchestre l'envoi des observations locales vers le serveur.
/// Implémente :
/// - Un verrou anti-concurrence ([_isSyncInProgress]).
/// - Un backoff exponentiel en cas d'échecs réseau consécutifs.
/// - La gestion idempotente des réponses partielles.
/// - La récupération des synchronisations interrompues au redémarrage.
class SyncService {
  final AppDatabase _db;
  final ApiClient _apiClient;

  bool _isSyncInProgress = false;
  int _consecutiveFailures = 0;

  SyncService({required AppDatabase db, required ApiClient apiClient})
    : _db = db,
      _apiClient = apiClient;

  /// Restaure les observations bloquées en `syncing` au démarrage.
  ///
  /// Doit être appelé une seule fois dans `main()` ou `initState()`.
  Future<void> recoverInterruptedSyncs() async {
    await _db.resetSyncingToPending();
  }

  /// Calcule le délai de backoff exponentiel en secondes.
  ///
  /// Formule : min(2^failures, [_kMaxBackoffSeconds]).
  Duration get _currentBackoff {
    if (_consecutiveFailures == 0) return Duration.zero;
    final seconds = min(
      pow(2, _consecutiveFailures).toInt(),
      _kMaxBackoffSeconds,
    );
    return Duration(seconds: seconds);
  }

  /// Synchronise les observations en attente avec le backend.
  ///
  /// Ne fait rien si une synchronisation est déjà en cours
  /// ou si le backoff n'est pas écoulé.
  ///
  /// Lève [SessionExpiredException] en cas de 401.
  Future<void> syncPendingObservations() async {
    if (_isSyncInProgress) return;
    _isSyncInProgress = true;

    try {
      // Appliquer le backoff si nécessaire.
      final backoff = _currentBackoff;
      if (backoff > Duration.zero) {
        await Future<void>.delayed(backoff);
      }

      final observations = await _db.getPendingOrFailedObservations();
      if (observations.isEmpty) return;

      // Filtrer les observations ayant dépassé le max de retries.
      final eligible = observations
          .where((o) => o.retryCount < _kMaxRetryCount)
          .take(_kMaxBatchSize)
          .toList();
      if (eligible.isEmpty) return;

      final batchIds = eligible.map((o) => o.id).toList();

      // 1. Verrouiller le lot en base.
      await _db.markAsSyncing(batchIds);

      // 2. Construire le payload.
      final dtoList = await _buildPayload(eligible);
      final request = SyncRequestDto(observations: dtoList);

      // 3. Envoyer au backend.
      await _sendAndProcess(request, eligible, batchIds);
    } on SessionExpiredException {
      rethrow;
    } catch (_) {
      // Erreur inattendue — on ne crashe pas le flux.
    } finally {
      _isSyncInProgress = false;
    }
  }

  /// Construit la liste de DTOs à partir des observations Drift.
  Future<List<ObservationDto>> _buildPayload(
    List<LocalObservation> observations,
  ) async {
    final dtoList = <ObservationDto>[];

    for (final obs in observations) {
      final items = await _db.getItemsForObservation(obs.id);

      dtoList.add(
        ObservationDto(
          id: obs.id,
          userId: obs.userId,
          createdAt: obs.createdAt.toIso8601String(),
          latitude: obs.latitude,
          longitude: obs.longitude,
          items: items
              .map(
                (i) => ObservationItemDto(
                  id: i.id,
                  label: i.label,
                  confidence: i.confidence,
                  trackId: i.trackId,
                  x: i.x,
                  y: i.y,
                  width: i.width,
                  height: i.height,
                ),
              )
              .toList(),
        ),
      );
    }

    return dtoList;
  }

  /// Envoie le payload et traite la réponse du backend.
  Future<void> _sendAndProcess(
    SyncRequestDto request,
    List<LocalObservation> batch,
    List<String> batchIds,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/observations/sync',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        _consecutiveFailures = 0;
        final syncResponse = SyncResponseDto.fromJson(response.data);
        await _processResults(syncResponse, batch, batchIds);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Règle absolue : sur un 401, remettre en pending SANS incrémenter
        // le retryCount, puis signaler à l'UI.
        await _db.resetSyncingToPending();
        throw SessionExpiredException();
      }

      // Erreur réseau classique.
      _consecutiveFailures++;
      await _db.resetSyncingToPending();
    }
  }

  /// Traite les résultats individuels retournés par le backend.
  Future<void> _processResults(
    SyncResponseDto syncResponse,
    List<LocalObservation> batch,
    List<String> batchIds,
  ) async {
    final processedIds = <String>{};

    for (final result in syncResponse.results) {
      processedIds.add(result.id);

      if (result.status == 'synced' || result.status == 'already_exists') {
        await _db.markAsSynced(result.id, result.serverId ?? '');
      } else if (result.status == 'failed') {
        final obs = batch.firstWhere((o) => o.id == result.id);
        await _db.markAsFailed(
          result.id,
          result.error ?? 'Erreur serveur inconnue',
          obs.retryCount,
          maxRetryCount: _kMaxRetryCount,
        );
      }
    }

    // Si le backend omet des UUIDs dans sa réponse, on les remet en failed.
    final missingIds = batchIds.where((id) => !processedIds.contains(id));
    for (final missingId in missingIds) {
      final obs = batch.firstWhere((o) => o.id == missingId);
      await _db.markAsFailed(
        missingId,
        'Réponse serveur incomplète',
        obs.retryCount,
        maxRetryCount: _kMaxRetryCount,
      );
    }
  }
}

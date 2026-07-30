"""Tests Flutter pour le module analytics (T5.3 Mobile).

Ces tests vérifient le parsing JSON et les trois états de l'AnalyticsNotifier
(loading, loaded, error) sans appels réseau réels.
"""

// test/features/analytics/analytics_test.dart

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:birdsense_mobile/features/analytics/analytics_repository.dart';
import 'package:birdsense_mobile/features/analytics/analytics_state.dart';

// ── JSON de réponse mock ──────────────────────────────────────────────────
const mockStatsJson = {
  "bird_health_score": 1.5263,
  "species_diversity": [
    {"species_name": "Passer domesticus", "count": 45},
    {"species_name": "Corvus albus", "count": 12},
  ],
  "temporal_volume": [
    {"date": "2025-07-01", "count": 10},
    {"date": "2025-07-08", "count": 18},
  ],
};

void main() {
  group('AnalyticsRepository', () {
    test('parsit correctement la réponse JSON du serveur', () async {
      // MOCK : Client HTTP retournant une réponse statique
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockStatsJson), 200);
      });

      final repo = AnalyticsRepository(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      final stats = await repo.fetchStats();

      expect(stats.birdHealthScore, closeTo(1.5263, 0.001));
      expect(stats.speciesDiversity.length, 2);
      expect(stats.speciesDiversity.first.speciesName, 'Passer domesticus');
      expect(stats.temporalVolume.first.count, 10);
    });

    test('lève une exception en cas d\'erreur serveur (500)', () async {
      final mockClient = MockClient((_) async => http.Response('Internal Error', 500));

      final repo = AnalyticsRepository(
        baseUrl: 'http://localhost:8000',
        client: mockClient,
      );

      expect(() => repo.fetchStats(), throwsException);
    });
  });

  group('AnalyticsNotifier — gestion des états', () {
    late AnalyticsRepository repo;
    late AnalyticsNotifier notifier;

    test('état initial : AnalyticsStatus.initial', () {
      final mockClient = MockClient((_) async => http.Response(jsonEncode(mockStatsJson), 200));
      repo = AnalyticsRepository(baseUrl: 'http://localhost:8000', client: mockClient);
      notifier = AnalyticsNotifier(repository: repo);

      expect(notifier.status, AnalyticsStatus.initial);
      expect(notifier.isLoading, false);
      expect(notifier.hasData, false);
      expect(notifier.hasError, false);
    });

    test('état loaded après fetchStats() réussi', () async {
      final mockClient = MockClient((_) async => http.Response(jsonEncode(mockStatsJson), 200));
      repo = AnalyticsRepository(baseUrl: 'http://localhost:8000', client: mockClient);
      notifier = AnalyticsNotifier(repository: repo);

      await notifier.loadStats();

      expect(notifier.status, AnalyticsStatus.loaded);
      expect(notifier.hasData, true);
      expect(notifier.stats, isNotNull);
      expect(notifier.stats!.birdHealthScore, closeTo(1.5263, 0.001));
    });

    test('état error après échec réseau', () async {
      final mockClient = MockClient((_) async => throw Exception('Réseau indisponible'));
      repo = AnalyticsRepository(baseUrl: 'http://localhost:8000', client: mockClient);
      notifier = AnalyticsNotifier(repository: repo);

      await notifier.loadStats();

      expect(notifier.status, AnalyticsStatus.error);
      expect(notifier.hasError, true);
      expect(notifier.errorMessage, isNotNull);
      expect(notifier.errorMessage, contains('Réseau indisponible'));
    });
  });
}

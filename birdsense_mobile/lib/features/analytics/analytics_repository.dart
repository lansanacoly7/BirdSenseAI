// lib/features/analytics/analytics_repository.dart
//
// Classe chargée de la communication avec l'endpoint /api/v1/analytics/stats.
// Fournit les données brutes au AnalyticsNotifier (state management).
//
// DÉPENDANCE : Utilise http (dart:io) pour les requêtes HTTP.
// Remplacer par Dio si le reste du projet l'utilise (à aligner avec El Hadji Massogui Diop).

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Modèle représentant un item de diversité des espèces.
class SpeciesDiversityItem {
  final String speciesName;
  final int count;

  SpeciesDiversityItem({required this.speciesName, required this.count});

  factory SpeciesDiversityItem.fromJson(Map<String, dynamic> json) =>
      SpeciesDiversityItem(
        speciesName: json['species_name'] as String,
        count: json['count'] as int,
      );
}

/// Modèle représentant un item de volume temporel.
class TemporalVolumeItem {
  final String date;
  final int count;

  TemporalVolumeItem({required this.date, required this.count});

  factory TemporalVolumeItem.fromJson(Map<String, dynamic> json) =>
      TemporalVolumeItem(
        date: json['date'] as String,
        count: json['count'] as int,
      );
}

/// Modèle principal pour les statistiques analytics.
class AnalyticsStats {
  final double birdHealthScore;
  final List<SpeciesDiversityItem> speciesDiversity;
  final List<TemporalVolumeItem> temporalVolume;

  AnalyticsStats({
    required this.birdHealthScore,
    required this.speciesDiversity,
    required this.temporalVolume,
  });

  factory AnalyticsStats.fromJson(Map<String, dynamic> json) => AnalyticsStats(
        birdHealthScore: (json['bird_health_score'] as num).toDouble(),
        speciesDiversity: (json['species_diversity'] as List)
            .map((e) => SpeciesDiversityItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        temporalVolume: (json['temporal_volume'] as List)
            .map((e) => TemporalVolumeItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Repository responsable de récupérer les stats analytics depuis le backend.
class AnalyticsRepository {
  final String baseUrl;
  final http.Client _client;

  AnalyticsRepository({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Récupère les statistiques depuis GET /api/v1/analytics/stats.
  Future<AnalyticsStats> fetchStats() async {
    final uri = Uri.parse('$baseUrl/api/v1/analytics/stats');

    try {
      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AnalyticsStats.fromJson(json);
      } else {
        throw Exception(
          'Erreur serveur: ${response.statusCode} — ${response.body}',
        );
      }
    } on Exception catch (e) {
      throw Exception('Impossible de récupérer les stats analytics: $e');
    }
  }
}

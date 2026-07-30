// lib/features/analytics/analytics_state.dart
//
// Gestion de l'état du module Analytics.
// Trois états explicites : chargement, erreur, données disponibles.
//
// Pattern : simple ChangeNotifier (compatible Provider).
// Pas de Riverpod ni Bloc pour rester cohérent avec le projet existant.

import 'package:flutter/foundation.dart';
import 'analytics_repository.dart';

/// États possibles du module analytics.
enum AnalyticsStatus { initial, loading, loaded, error }

/// Notifier gérant le cycle de vie des données analytics.
class AnalyticsNotifier extends ChangeNotifier {
  final AnalyticsRepository _repository;

  AnalyticsStatus _status = AnalyticsStatus.initial;
  AnalyticsStats? _stats;
  String? _errorMessage;

  AnalyticsNotifier({required AnalyticsRepository repository})
      : _repository = repository;

  // ── Getters ──────────────────────────────────────────────────────────────
  AnalyticsStatus get status => _status;
  AnalyticsStats? get stats => _stats;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AnalyticsStatus.loading;
  bool get hasData => _status == AnalyticsStatus.loaded && _stats != null;
  bool get hasError => _status == AnalyticsStatus.error;

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Déclenche le chargement des statistiques.
  Future<void> loadStats() async {
    if (_status == AnalyticsStatus.loading) return; // Évite les appels doubles

    _status = AnalyticsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchStats();
      _stats = result;
      _status = AnalyticsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AnalyticsStatus.error;
    } finally {
      notifyListeners();
    }
  }

  /// Réinitialise l'état pour permettre un rechargement manuel.
  void reset() {
    _status = AnalyticsStatus.initial;
    _stats = null;
    _errorMessage = null;
    notifyListeners();
  }
}

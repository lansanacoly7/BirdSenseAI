import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Provider global de l'observateur réseau.
///
/// Doit être `watch`é depuis un widget de longue durée (ex: `BirdSenseApp`)
/// pour rester actif pendant toute la session utilisateur.
/// **Non** autoDispose car il doit survivre aux navigations.
final networkObserverProvider = Provider<NetworkObserver>((ref) {
  final observer = NetworkObserver(ref);
  ref.onDispose(observer.dispose);
  return observer;
});

/// Observe les changements de connectivité réseau et déclenche
/// automatiquement une synchronisation au retour online.
///
/// Ne déclenche pas de sync si l'appareil était déjà connecté ;
/// seule une **transition** vers un état connecté provoque l'appel.
class NetworkObserver {
  final Ref _ref;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  NetworkObserver(this._ref) {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isOnline =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (isOnline) {
      _ref
          .read(syncServiceProvider)
          .syncPendingObservations()
          .catchError((_) {});
    }
  }

  /// Libère le listener de connectivité.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

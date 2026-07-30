import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:workmanager/workmanager.dart';

import 'core/network/network_observer.dart';
import 'core/providers.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == 'syncObservationsTask') {
      final container = ProviderContainer();
      try {
        final syncService = container.read(syncServiceProvider);
        await syncService.syncPendingObservations();
      } finally {
        container.dispose();
      }
    }
    return Future.value(true);
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  
  Workmanager().registerPeriodicTask(
    'sync_observations',
    'syncObservationsTask',
    frequency: const Duration(minutes: 30),
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );

  runApp(const ProviderScope(child: BirdSenseApp()));
}

/// Widget racine de l'application BirdSense AI.
///
/// Modifications par Massogui Diop (module Camera / SQLite / Sync) :
/// - Enveloppé dans [ProviderScope] pour Riverpod.
/// - Initialisation de la récupération des synchros interrompues.
/// - Activation de l'observateur réseau pour la synchro automatique.
class BirdSenseApp extends ConsumerStatefulWidget {
  const BirdSenseApp({super.key});

  @override
  ConsumerState<BirdSenseApp> createState() => _BirdSenseAppState();
}

class _BirdSenseAppState extends ConsumerState<BirdSenseApp> {
  @override
  void initState() {
    super.initState();
    // Restaurer les synchros interrompues (crash ou kill app).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncServiceProvider).recoverInterruptedSyncs();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Garder l'observateur réseau actif pendant toute la session.
    ref.watch(networkObserverProvider);

    return MaterialApp(
      title: 'BirdSense AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}

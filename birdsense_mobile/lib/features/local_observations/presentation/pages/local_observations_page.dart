import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/sync_service.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';

// =============================================================================
// Provider — Observations locales (Module Massogui Diop)
// =============================================================================

/// Stream réactif des observations stockées en base SQLite locale.
///
/// Émet automatiquement une nouvelle liste à chaque modification
/// de la table [LocalObservations] (insertion, update, delete).
final localObservationsStreamProvider =
    StreamProvider.autoDispose<List<LocalObservation>>((ref) {
      final db = ref.watch(databaseProvider);
      return db.select(db.localObservations).watch();
    });

/// Page affichant la liste des observations stockées localement.
///
/// Chaque observation montre son UUID tronqué, son statut de synchro
/// (avec pastille colorée) et son horodatage.
///
/// Un bouton "Sync" en AppBar permet de forcer la synchronisation.
class LocalObservationsPage extends ConsumerWidget {
  const LocalObservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final observationsAsync = ref.watch(localObservationsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      appBar: AppBar(
        title: const Text(
          'Observations Locales',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryCanopy,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Forcer la synchronisation',
            onPressed: () => _forceSync(context, ref),
          ),
        ],
      ),
      body: observationsAsync.when(
        data: (observations) => _buildList(observations),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accentAmber),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Erreur : $err',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets privés
  // ---------------------------------------------------------------------------

  Widget _buildList(List<LocalObservation> observations) {
    if (observations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
            SizedBox(height: 12),
            Text(
              'Aucune observation locale.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: observations.length,
      separatorBuilder: (_, _) =>
          const Divider(color: AppColors.surfaceGlass, height: 1),
      itemBuilder: (_, index) {
        final obs = observations[index];
        return _ObservationTile(observation: obs);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _forceSync(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Synchronisation en cours…')));

    try {
      await ref.read(syncServiceProvider).syncPendingObservations();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Synchronisation terminée !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on SessionExpiredException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expirée. Veuillez vous reconnecter.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// =============================================================================
// Widget privé — Tile d'observation
// =============================================================================

class _ObservationTile extends StatelessWidget {
  final LocalObservation observation;

  const _ObservationTile({required this.observation});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _StatusIcon(status: observation.status),
      title: Text(
        'Observation ${observation.id.substring(0, 8)}…',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Statut : ${observation.status}\n'
        'Créée : ${_formatDate(observation.createdAt)}',
        style: const TextStyle(color: AppColors.textMuted),
      ),
      isThreeLine: true,
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

// =============================================================================
// Widget privé — Icône de statut
// =============================================================================

class _StatusIcon extends StatelessWidget {
  final String status;

  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      'pending' => const Icon(
        Icons.cloud_upload_outlined,
        color: AppColors.accentAmber,
      ),
      'syncing' => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      'synced' => const Icon(Icons.cloud_done, color: Colors.green),
      'failed' => const Icon(Icons.error_outline, color: Colors.red),
      'abandoned' => const Icon(Icons.block, color: Colors.grey),
      _ => const Icon(Icons.help_outline, color: Colors.grey),
    };
  }
}

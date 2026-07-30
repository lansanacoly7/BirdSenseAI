import 'package:birdsense_mobile/core/database/providers/database_provider.dart';
import 'package:birdsense_mobile/features/impact_sync/data/impact_score_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final impactScoreRepositoryProvider = Provider<ImpactScoreRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SqliteImpactScoreRepository(db);
});

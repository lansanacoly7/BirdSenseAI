import 'dart:convert';

import 'package:birdsense_mobile/core/database/app_database.dart';
import 'package:birdsense_mobile/features/impact_sync/models/impact_score_dto.dart';

abstract class ImpactScoreRepository {
  Future<void> saveImpactScore(ImpactScoreDto dto);
  Future<ImpactScoreDto?> getLatestScore(String observationId);
  Stream<ImpactScoreDto?> watchLatestScore(String observationId);
}

class SqliteImpactScoreRepository implements ImpactScoreRepository {
  final AppDatabase _db;

  SqliteImpactScoreRepository(this._db);

  @override
  Future<void> saveImpactScore(ImpactScoreDto dto) async {
    final score = LocalImpactScore(
      id: dto.id,
      observationId: dto.observationId,
      score: dto.score,
      level: dto.level,
      calculationVersion: dto.calculationVersion,
      computedAt: DateTime.parse(dto.computedAt),
      componentsJson: dto.components != null ? jsonEncode(dto.components!.toJson()) : null,
      updatedAt: DateTime.now().toUtc(),
    );
    await _db.upsertImpactScore(score);
  }

  @override
  Future<ImpactScoreDto?> getLatestScore(String observationId) async {
    final localScore = await _db.getLatestImpactScoreForObservation(observationId);
    if (localScore == null) return null;
    return _mapToDto(localScore);
  }

  @override
  Stream<ImpactScoreDto?> watchLatestScore(String observationId) {
    return _db.watchLatestImpactScoreForObservation(observationId).map((localScore) {
      if (localScore == null) return null;
      return _mapToDto(localScore);
    });
  }

  ImpactScoreDto _mapToDto(LocalImpactScore localScore) {
    ImpactScoreComponentsDto? components;
    if (localScore.componentsJson != null) {
      components = ImpactScoreComponentsDto.fromJson(
        jsonDecode(localScore.componentsJson!) as Map<String, dynamic>,
      );
    }

    return ImpactScoreDto(
      id: localScore.id,
      observationId: localScore.observationId,
      score: localScore.score,
      level: localScore.level,
      calculationVersion: localScore.calculationVersion,
      computedAt: localScore.computedAt.toIso8601String(),
      components: components,
    );
  }
}

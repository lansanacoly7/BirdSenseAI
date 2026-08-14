import 'dart:async';
import 'package:birdsense_mobile/features/impact_sync/models/impact_score_dto.dart';
import 'impact_score_repository.dart';

/// Implémentation en mémoire pour le développement sans base de données locale active.
class FakeImpactScoreRepository implements ImpactScoreRepository {
  final Map<String, ImpactScoreDto> _memoryStore = {};
  final _controller = StreamController<ImpactScoreDto?>.broadcast();

  @override
  Future<void> saveImpactScore(ImpactScoreDto dto) async {
    _memoryStore[dto.observationId] = dto;
    _controller.add(dto);
  }

  @override
  Future<ImpactScoreDto?> getLatestScore(String observationId) async {
    return _memoryStore[observationId];
  }

  @override
  Stream<ImpactScoreDto?> watchLatestScore(String observationId) async* {
    yield _memoryStore[observationId];
    yield* _controller.stream.where((event) => event?.observationId == observationId);
  }
}

import 'package:json_annotation/json_annotation.dart';

part 'impact_score_dto.g.dart';

@JsonSerializable()
class ImpactScoreDto {
  final String id;
  final String observationId;
  final double score;
  final String level;
  final String calculationVersion;
  final String computedAt;
  final ImpactScoreComponentsDto? components;

  const ImpactScoreDto({
    required this.id,
    required this.observationId,
    required this.score,
    required this.level,
    required this.calculationVersion,
    required this.computedAt,
    this.components,
  });

  factory ImpactScoreDto.fromJson(Map<String, dynamic> json) => _$ImpactScoreDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImpactScoreDtoToJson(this);
}

@JsonSerializable()
class ImpactScoreComponentsDto {
  final double? speciesDiversity;
  final double? observationActivity;
  final double? ambientSoundLevel;

  const ImpactScoreComponentsDto({
    this.speciesDiversity,
    this.observationActivity,
    this.ambientSoundLevel,
  });

  factory ImpactScoreComponentsDto.fromJson(Map<String, dynamic> json) => _$ImpactScoreComponentsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ImpactScoreComponentsDtoToJson(this);
}

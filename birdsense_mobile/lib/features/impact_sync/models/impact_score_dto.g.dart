// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'impact_score_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ImpactScoreDto _$ImpactScoreDtoFromJson(Map<String, dynamic> json) =>
    ImpactScoreDto(
      id: json['id'] as String,
      observationId: json['observationId'] as String,
      score: (json['score'] as num).toDouble(),
      level: json['level'] as String,
      calculationVersion: json['calculationVersion'] as String,
      computedAt: json['computedAt'] as String,
      components: json['components'] == null
          ? null
          : ImpactScoreComponentsDto.fromJson(
              json['components'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ImpactScoreDtoToJson(ImpactScoreDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'observationId': instance.observationId,
      'score': instance.score,
      'level': instance.level,
      'calculationVersion': instance.calculationVersion,
      'computedAt': instance.computedAt,
      'components': instance.components,
    };

ImpactScoreComponentsDto _$ImpactScoreComponentsDtoFromJson(
  Map<String, dynamic> json,
) => ImpactScoreComponentsDto(
  speciesDiversity: (json['speciesDiversity'] as num?)?.toDouble(),
  observationActivity: (json['observationActivity'] as num?)?.toDouble(),
  ambientSoundLevel: (json['ambientSoundLevel'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ImpactScoreComponentsDtoToJson(
  ImpactScoreComponentsDto instance,
) => <String, dynamic>{
  'speciesDiversity': instance.speciesDiversity,
  'observationActivity': instance.observationActivity,
  'ambientSoundLevel': instance.ambientSoundLevel,
};

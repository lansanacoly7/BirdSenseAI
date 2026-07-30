// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DetectionDto _$DetectionDtoFromJson(Map<String, dynamic> json) => DetectionDto(
  label: json['label'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  width: (json['width'] as num).toDouble(),
  height: (json['height'] as num).toDouble(),
  trackId: json['trackId'] as String?,
);

Map<String, dynamic> _$DetectionDtoToJson(DetectionDto instance) =>
    <String, dynamic>{
      'label': instance.label,
      'confidence': instance.confidence,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'trackId': instance.trackId,
    };

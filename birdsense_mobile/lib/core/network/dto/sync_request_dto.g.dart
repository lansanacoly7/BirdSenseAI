// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncRequestDto _$SyncRequestDtoFromJson(Map<String, dynamic> json) =>
    SyncRequestDto(
      observations: (json['observations'] as List<dynamic>)
          .map((e) => ObservationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncRequestDtoToJson(SyncRequestDto instance) =>
    <String, dynamic>{
      'observations': instance.observations.map((e) => e.toJson()).toList(),
    };

ObservationDto _$ObservationDtoFromJson(Map<String, dynamic> json) =>
    ObservationDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      createdAt: json['createdAt'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => ObservationItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ObservationDtoToJson(ObservationDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'createdAt': instance.createdAt,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

ObservationItemDto _$ObservationItemDtoFromJson(Map<String, dynamic> json) =>
    ObservationItemDto(
      id: json['id'] as String,
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      trackId: json['trackId'] as String?,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );

Map<String, dynamic> _$ObservationItemDtoToJson(ObservationItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'confidence': instance.confidence,
      'trackId': instance.trackId,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
    };

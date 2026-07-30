// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncResponseDto _$SyncResponseDtoFromJson(Map<String, dynamic> json) =>
    SyncResponseDto(
      results: (json['results'] as List<dynamic>)
          .map((e) => SyncResultDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SyncResponseDtoToJson(SyncResponseDto instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
    };

SyncResultDto _$SyncResultDtoFromJson(Map<String, dynamic> json) =>
    SyncResultDto(
      id: json['id'] as String,
      status: json['status'] as String,
      serverId: json['serverId'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$SyncResultDtoToJson(SyncResultDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'serverId': instance.serverId,
      'error': instance.error,
    };

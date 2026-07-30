import 'package:json_annotation/json_annotation.dart';

part 'sync_request_dto.g.dart';

/// Payload envoyé au backend pour synchroniser un lot d'observations.
///
/// Contient une liste d'[ObservationDto], chacune incluant ses
/// détections IA ([ObservationItemDto]).
@JsonSerializable(explicitToJson: true)
class SyncRequestDto {
  final List<ObservationDto> observations;

  const SyncRequestDto({required this.observations});

  factory SyncRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SyncRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncRequestDtoToJson(this);
}

/// Observation individuelle dans le payload de synchronisation.
///
/// Ne contient **pas** le fichier média (photo/vidéo) conformément
/// à la politique média MVP : seules les métadonnées sont transmises.
@JsonSerializable(explicitToJson: true)
class ObservationDto {
  /// UUID v4 mobile — sert de clé d'idempotence.
  final String id;

  /// Identifiant de l'utilisateur.
  final String userId;

  /// Horodatage ISO 8601 en UTC.
  final String createdAt;

  /// Coordonnées GPS (nullable si GPS désactivé).
  final double? latitude;
  final double? longitude;

  /// Liste des détections IA associées.
  final List<ObservationItemDto> items;

  const ObservationDto({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.latitude,
    this.longitude,
    required this.items,
  });

  factory ObservationDto.fromJson(Map<String, dynamic> json) =>
      _$ObservationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ObservationDtoToJson(this);
}

/// Détection IA individuelle dans le payload de synchronisation.
@JsonSerializable()
class ObservationItemDto {
  final String id;
  final String label;
  final double confidence;
  final String? trackId;
  final double x;
  final double y;
  final double width;
  final double height;

  const ObservationItemDto({
    required this.id,
    required this.label,
    required this.confidence,
    this.trackId,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory ObservationItemDto.fromJson(Map<String, dynamic> json) =>
      _$ObservationItemDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ObservationItemDtoToJson(this);
}

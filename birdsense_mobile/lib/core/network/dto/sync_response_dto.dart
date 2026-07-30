import 'package:json_annotation/json_annotation.dart';

part 'sync_response_dto.g.dart';

/// Réponse du backend après une tentative de synchronisation.
///
/// Contient un résultat par observation envoyée. Chaque [SyncResultDto]
/// indique si l'observation a été acceptée, rejetée ou si elle existait déjà.
@JsonSerializable(explicitToJson: true)
class SyncResponseDto {
  final List<SyncResultDto> results;

  const SyncResponseDto({required this.results});

  factory SyncResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResponseDtoToJson(this);
}

/// Résultat de synchronisation pour une observation donnée.
@JsonSerializable()
class SyncResultDto {
  /// UUID mobile de l'observation concernée.
  final String id;

  /// Statut retourné par le backend : `synced`, `already_exists` ou `failed`.
  final String status;

  /// UUID attribué par le serveur (présent si [status] == `synced`).
  final String? serverId;

  /// Message d'erreur (présent si [status] == `failed`).
  final String? error;

  const SyncResultDto({
    required this.id,
    required this.status,
    this.serverId,
    this.error,
  });

  factory SyncResultDto.fromJson(Map<String, dynamic> json) =>
      _$SyncResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResultDtoToJson(this);
}

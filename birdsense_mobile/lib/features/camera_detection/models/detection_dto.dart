import 'package:json_annotation/json_annotation.dart';

part 'detection_dto.g.dart';

/// Représente une détection unitaire retournée par le modèle IA.
///
/// Les coordonnées ([x], [y], [width], [height]) sont **normalisées**
/// entre 0.0 et 1.0 par rapport aux dimensions de l'image source.
@JsonSerializable()
class DetectionDto {
  /// Nom de l'espèce détectée (ex: "pélican blanc").
  final String label;

  /// Score de confiance du modèle, entre 0.0 et 1.0.
  final double confidence;

  /// Coordonnée X du coin supérieur gauche (normalisée).
  final double x;

  /// Coordonnée Y du coin supérieur gauche (normalisée).
  final double y;

  /// Largeur de la bounding box (normalisée).
  final double width;

  /// Hauteur de la bounding box (normalisée).
  final double height;

  /// Identifiant de tracking inter-frames (optionnel).
  final String? trackId;

  const DetectionDto({
    required this.label,
    required this.confidence,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.trackId,
  });

  factory DetectionDto.fromJson(Map<String, dynamic> json) =>
      _$DetectionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DetectionDtoToJson(this);
}

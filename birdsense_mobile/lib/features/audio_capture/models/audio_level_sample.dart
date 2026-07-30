class AudioLevelSample {
  final DateTime timestampUtc;
  final double dbfs;
  final double normalizedLevel;
  final bool isClipping;

  const AudioLevelSample({
    required this.timestampUtc,
    required this.dbfs,
    required this.normalizedLevel,
    required this.isClipping,
  });
}

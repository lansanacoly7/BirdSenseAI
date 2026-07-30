import 'package:birdsense_mobile/features/impact_sync/services/audio_level_service.dart';
import 'package:birdsense_mobile/features/impact_sync/services/native_audio_level_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioLevelServiceProvider = Provider<AudioLevelService>((ref) {
  return NativeAudioLevelService();
});

import 'package:birdsense_mobile/features/impact_sync/services/audio_level_service.dart';
import 'package:birdsense_mobile/features/impact_sync/services/native_audio_level_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioLevelServiceProvider = Provider<AudioLevelService>((ref) {
  // Par défaut, nous utilisons l'implémentation native pour le micro.
  // Pour simuler sans micro, on pourrait retourner FakeAudioLevelService().
  return NativeAudioLevelService();
});

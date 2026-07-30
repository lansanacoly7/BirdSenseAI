import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:birdsense_mobile/features/impact_sync/providers/audio_level_provider.dart';
import 'package:birdsense_mobile/features/impact_sync/presentation/widgets/audio_level_gauge_widget.dart';

class LiveAudioLevelGauge extends ConsumerWidget {
  const LiveAudioLevelGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(audioLevelServiceProvider);

    return StreamBuilder<AudioLevelSample>(
      stream: service.audioLevelStream,
      builder: (context, snapshot) {
        final decibels = snapshot.data?.decibels ?? -120.0;
        return AudioLevelGaugeWidget(decibels: decibels);
      },
    );
  }
}

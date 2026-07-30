import 'dart:async';
import 'dart:math';

import 'package:birdsense_mobile/features/impact_sync/models/audio_level_sample.dart';
import 'package:birdsense_mobile/features/impact_sync/services/audio_level_service.dart';

/// Implémentation simulée du service audio (utile pour le développement sur simulateur).
class FakeAudioLevelService implements AudioLevelService {
  Timer? _timer;
  final _controller = StreamController<AudioLevelSample>.broadcast();
  final _random = Random();
  
  bool _isRecording = false;

  @override
  Future<void> init() async {
    // Simule une demande de permission
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> start() async {
    if (_isRecording) return;
    _isRecording = true;
    
    // Génère des niveaux audio factices toutes les 100ms
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // Simule un bruit de fond avec des pics aléatoires (-100 à 0 dB)
      double noise = -80.0 + _random.nextDouble() * 20.0;
      if (_random.nextDouble() > 0.8) {
        noise += _random.nextDouble() * 40.0; // Pic de bruit occasionnel
      }
      
      final sample = AudioLevelSample(
        timestamp: DateTime.now(),
        decibels: noise.clamp(-120.0, 0.0),
      );
      
      _controller.add(sample);
    });
  }

  @override
  Future<void> stop() async {
    _isRecording = false;
    _timer?.cancel();
    _timer = null;
  }

  @override
  Stream<AudioLevelSample> get audioLevelStream => _controller.stream;
}

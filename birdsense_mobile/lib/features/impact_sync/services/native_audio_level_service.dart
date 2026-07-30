import 'dart:async';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:birdsense_mobile/features/impact_sync/models/audio_level_sample.dart';
import 'package:birdsense_mobile/features/impact_sync/services/audio_level_service.dart';

/// Implémentation native de la capture audio via le microphone de l'appareil.
/// Utilise le package `record` pour écouter l'amplitude sans enregistrer de fichier.
class NativeAudioLevelService implements AudioLevelService {
  final AudioRecorder _recorder = AudioRecorder();
  final StreamController<AudioLevelSample> _controller = StreamController<AudioLevelSample>.broadcast();
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  StreamSubscription<Uint8List>? _streamSubscription;

  @override
  Future<void> init() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  @override
  Future<void> start() async {
    if (await _recorder.isRecording()) return;
    
    if (await _recorder.hasPermission()) {
      // Sécurité anti-fuite : annuler les anciennes écoutes si jamais start() est appelé en concurrence
      await _streamSubscription?.cancel();
      await _amplitudeSubscription?.cancel();
      // On démarre un enregistrement vers un stream (les données brutes ne nous intéressent pas ici)
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ));
      
      // Il est impératif de drainer (écouter) le stream pour éviter les fuites mémoire ou le blocage côté natif
      _streamSubscription = stream.listen((_) {});

      _amplitudeSubscription = _recorder.onAmplitude().listen((amplitude) {
        if (!_controller.isClosed) {
          _controller.add(AudioLevelSample(
            timestamp: DateTime.now(),
            decibels: amplitude.current,
          ));
        }
      });
    }
  }

  @override
  Future<void> stop() async {
    await _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    
    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    // Ne pas fermer le controller principal pour que le StreamBuilder de l'UI reste branché
    // aux prochains démarrages !
  }

  @override
  Stream<AudioLevelSample> get audioLevelStream => _controller.stream;
}

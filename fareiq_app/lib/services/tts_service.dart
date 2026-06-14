import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> init() async {
    await _tts.setLanguage('en-IN');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _ready = true;
  }

  Future<void> announceFare({
    required double total,
    required double base,
    required double dist,
    required double time,
    required double fuel,
    required String vehicle,
  }) async {
    if (!_ready) await init();
    final text =
        'Your $vehicle fare is rupees ${total.toStringAsFixed(0)}. '
        'Base fare: ${base.toStringAsFixed(0)}. '
        'Distance charge: ${dist.toStringAsFixed(0)}. '
        'Time charge: ${time.toStringAsFixed(0)}. '
        'Fuel surcharge: ${fuel.toStringAsFixed(0)}. '
        'No surge applied. This fare is within the city approved band.';
    await _tts.speak(text);
  }

  Future<void> stop() async => _tts.stop();
}
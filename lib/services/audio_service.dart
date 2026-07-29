import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _ambientPlayer = AudioPlayer();
  
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  AudioService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
    });
  }

  // --- Audiobook Mode (TTS) ---
  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<void> pauseSpeaking() async {
    await _tts.pause();
    _isSpeaking = false;
  }

  // --- Ambient Reading Atmosphere ---
  Future<void> playAmbient(String soundType) async {
    String url = "";
    switch (soundType) {
      case "Rain":
        url = "https://cdn.pixabay.com/download/audio/2022/03/24/audio_733621f37e.mp3"; // High quality rain
        break;
      case "Cafe":
        url = "https://cdn.pixabay.com/download/audio/2022/01/18/audio_8231505c2a.mp3"; // High quality cafe ambience
        break;
      case "Focus":
        url = "https://cdn.pixabay.com/download/audio/2022/03/15/audio_2e02235940.mp3"; // White noise/Focus
        break;
    }

    if (url.isNotEmpty) {
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.play(UrlSource(url));
    }
  }

  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
  }

  void dispose() {
    _tts.stop();
    _ambientPlayer.dispose();
  }
}

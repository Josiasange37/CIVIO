import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class VoiceProvider with ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  
  bool _isListening = false;
  String _recognizedText = "";
  bool _isSpeaking = false;
  
  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  bool get isSpeaking => _isSpeaking;

  Future<void> init() async {
    await _tts.setLanguage("fr-FR");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    notifyListeners();
  }

  Future<void> startListening(Function(String) onResult) async {
    bool available = await _speech.initialize(
      onStatus: (val) => debugPrint('onStatus: $val'),
      onError: (val) => debugPrint('onError: $val'),
    );
    
    if (available) {
      _isListening = true;
      notifyListeners();
      _speech.listen(
        onResult: (val) {
          _recognizedText = val.recognizedWords;
          if (val.finalResult) {
            _isListening = false;
            onResult(_recognizedText);
            notifyListeners();
          }
        },
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }

  Future<void> speak(String text) async {
    _isSpeaking = true;
    notifyListeners();
    await _tts.speak(text);
    _isSpeaking = false;
    notifyListeners();
  }
}

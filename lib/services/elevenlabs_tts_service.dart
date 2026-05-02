import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class ElevenLabsTtsService {

  static const _apiKey =
      String.fromEnvironment('ELEVENLABS_API_KEY');

  static const _voiceId =
      String.fromEnvironment('ELEVENLABS_VOICE_ID');

  final AudioPlayer _player = AudioPlayer();

  Future<void> speak(String text) async {

if (_apiKey.isEmpty || _voiceId.isEmpty) {
  print("ELEVENLABS KEY OR VOICE ID MISSING");
  return;
}
    final response = await http.post(
      Uri.parse(
        "https://api.elevenlabs.io/v1/text-to-speech/$_voiceId"
      ),
      headers: {
        "xi-api-key": _apiKey,
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "text": text,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {
          "stability": 0.55,
          "similarity_boost": 0.80
        }
      }),
    );

    if (response.statusCode != 200) {
  print("ELEVENLABS ERROR: ${response.statusCode}");
  print(response.body);
  return;
}

    final audioBase64 =
        base64Encode(response.bodyBytes);

    await _player.setUrl(
        "data:audio/mpeg;base64,$audioBase64"
    );

    await _player.play();
  }
}
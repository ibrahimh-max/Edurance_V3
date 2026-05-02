import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class GoogleTtsService {

  static const _apiKey =
      String.fromEnvironment('GOOGLE_TTS_API_KEY');

  final AudioPlayer _player = AudioPlayer();

  Future<void> speak(String text) async {

    if (_apiKey.isEmpty) return;

    final response = await http.post(
      Uri.parse(
          "https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey"
      ),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "input": {
          "text": text
        },
        "voice": {
          "languageCode": "en-IN",
          "name": "en-IN-Neural2-A"
        },
        "audioConfig": {
          "audioEncoding": "MP3",
          "speakingRate": 0.9,
          "pitch": 2.0
        }
      }),
    );

    if (response.statusCode != 200) return;

    final audioBase64 =
        jsonDecode(response.body)["audioContent"];

    final bytes =
        base64Decode(audioBase64);

    await _player.setAudioSource(
      AudioSource.bytes(bytes),
    );

    await _player.play();

  }

}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class VoiceService {

  static const _apiKey =
      String.fromEnvironment('GOOGLE_TTS_API_KEY');

  final AudioPlayer _player = AudioPlayer();

  Future<void> speak(String text) async {

    if (_apiKey.isEmpty) return;

    final url = Uri.parse(
      "https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey"
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
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
          "audioEncoding": "MP3"
        }
      }),
    );

    if (response.statusCode != 200) return;

    final audioBase64 =
        jsonDecode(response.body)["audioContent"];

    if (audioBase64 == null) return;

    final bytes =
        base64Decode(audioBase64);

    await _player.setAudioSource(
      AudioSource.uri(
        Uri.dataFromBytes(bytes, mimeType: "audio/mp3"),
      ),
    );

    await _player.play();
  }

}
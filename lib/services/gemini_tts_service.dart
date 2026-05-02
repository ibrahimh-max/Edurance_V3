import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class GeminiTtsService {

  static const _apiKey =
      String.fromEnvironment('GEMINI_API_KEY');

  final AudioPlayer _player = AudioPlayer();

  Future<void> speak(String text) async {

    if (_apiKey.isEmpty) return;

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey"
    );

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Speak this like a friendly kindergarten teacher: $text"
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode != 200) return;

    final audioUrl =
        jsonDecode(response.body)["audio"]?["url"];

    if (audioUrl == null) return;

    await _player.setUrl(audioUrl);

    await _player.play();
  }

}
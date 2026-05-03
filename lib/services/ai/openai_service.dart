import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class OpenAIService {

  static const String _apiKey =
      String.fromEnvironment(
        'OPENAI_API_KEY',
        defaultValue: '',
      );

  static const String _chatBaseUrl =
      'https://api.openai.com/v1/chat/completions';

  static const String _ttsBaseUrl =
      'https://api.openai.com/v1/audio/speech';


  static bool get isConfigured =>
      _apiKey.isNotEmpty;


  /// Shared audio player instance
  static final AudioPlayer _audioPlayer =
      AudioPlayer();


  /// Send single message to OpenAI (existing feature — unchanged)
  static Future<String> sendMessage(
    String message,
  ) async {

    if (!isConfigured) {
      return "Let's think about the correct answer together!";
    }

    final response = await http.post(

      Uri.parse(_chatBaseUrl),

      headers: {

        'Content-Type':
            'application/json',

        'Authorization':
            'Bearer $_apiKey',

      },

      body: jsonEncode({

        'model': 'gpt-4o-mini',

        'messages': [
          {
            'role': 'user',
            'content': message,
          }
        ],

        'temperature': 0.7,

      }),

    );


    if (response.statusCode == 200) {

      final data =
          jsonDecode(response.body);

      return data['choices'][0]
                     ['message']
                     ['content'];

    }


    throw Exception(
      'OpenAI error ${response.statusCode}',
    );

  }


  /// Explain wrong MCQ answer for kids (existing feature — unchanged)
  static Future<String>
      getWrongAnswerExplanation({

    required String lessonTitle,
    required String module,
    required String correctAnswer,
    required String wrongAnswer,
    required String question,

  }) async {

    final prompt =

        "A child aged 3–8 is learning about $module.\n"
        "Topic: $lessonTitle\n"
        "Question: $question\n"
        "Correct answer: $correctAnswer\n"
        "Child selected: $wrongAnswer\n"
        "Explain kindly and simply why '$wrongAnswer' is incorrect "
        "and why '$correctAnswer' is correct.";

    return await sendMessage(prompt);

  }


  /// NEW: Speak text using OpenAI TTS (nova voice)
  static Future<void> speakWithOpenAI(
    String text,
  ) async {

    if (!isConfigured) return;

    try {

      final response = await http.post(

        Uri.parse(_ttsBaseUrl),

        headers: {

          'Content-Type':
              'application/json',

          'Authorization':
              'Bearer $_apiKey',

        },

        body: jsonEncode({

          "model": "tts-1",
          "voice": "nova",
          "input": text,
          "response_format": "mp3"

        }),

      );


      if (response.statusCode == 200) {

        Uint8List audioBytes =
            response.bodyBytes;


        /// Prevent overlapping narration
        await _audioPlayer.stop();


        await _audioPlayer.setAudioSource(

          AudioSource.uri(

            Uri.dataFromBytes(

              audioBytes,
              mimeType: "audio/mpeg",

            ),

          ),

        );


        /// Slightly slower playback for young learners
        await _audioPlayer.setSpeed(0.85);


        await _audioPlayer.play();

      }

      else {

        print(
          "OpenAI TTS failed: ${response.body}"
        );

      }

    }

    catch (e) {

      print(
        "OpenAI TTS error: $e"
      );

    }

  }

}
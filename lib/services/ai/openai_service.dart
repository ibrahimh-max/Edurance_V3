import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {

  static const String _apiKey =
      String.fromEnvironment(
        'OPENAI_API_KEY',
        defaultValue: '',
      );

  static const String _baseUrl =
      'https://api.openai.com/v1/chat/completions';


  static bool get isConfigured =>
      _apiKey.isNotEmpty;


  /// Send single message to OpenAI
  static Future<String> sendMessage(
    String message,
  ) async {

    if (!isConfigured) {
      return "Let's think about the correct answer together!";
    }

    final response = await http.post(

      Uri.parse(_baseUrl),

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


  /// Explain wrong MCQ answer for kids
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

}
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:beenai_sense/Constants/API_key.dart';

/// Configurable chat service supporting Perplexity (OpenAI-compatible) or local Flask.
class ChatService {
  /// Provider types
  static const String providerPerplexity = 'perplexity';
  static const String providerFlask = 'flask';

  /// Runtime configuration (set these at app start or via settings screen)
  static String provider =
      providerPerplexity; // default to Flask to keep costs down
  static String perplexityApiKey =
      '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'; // set at runtime
  static String perplexityModel = 'sonar';
  static Uri perplexityEndpoint = Uri.parse(
    'https://api.perplexity.ai/chat/completions',
  );

  /// Optional: If you have a Flask chatbot endpoint different from default
  static Uri flaskEndpoint = Uri.parse('${Api.baseUrl}/chatbot');
  static const String providerGemini = 'gemini';
  static String geminiApiKey =
      'AIzaSyAkdGAsmJSkqXi4b4nP42NKiQkW7PbxTfk'; // Set your Gemini API key
  static Uri geminiEndpoint = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent',
  );

  static Future<String> chat({
    required String prompt,
    required String languageCode,
    List<Map<String, String>> history = const [],
  }) async {
    if (provider == providerPerplexity) {
      try {
        return await _chatPerplexity(
          prompt: prompt,
          languageCode: languageCode,
          history: history,
        );
      } catch (e) {
        // If Perplexity fails due to quota/credits, fallback to Gemini
        if (e.toString().contains('quota') || e.toString().contains('credit')) {
          print('Perplexity quota exceeded, falling back to Gemini');
          return _chatGemini(
            prompt: prompt,
            languageCode: languageCode,
            history: history,
          );
        }
        rethrow;
      }
    } else if (provider == providerGemini) {
      return _chatGemini(
        prompt: prompt,
        languageCode: languageCode,
        history: history,
      );
    }
    return _chatFlask(
      prompt: prompt,
      languageCode: languageCode,
      history: history,
    );
  }

  static Future<String> _chatGemini({
    required String prompt,
    required String languageCode,
    required List<Map<String, String>> history,
  }) async {
    if (geminiApiKey.isEmpty) {
      throw Exception('Gemini API key not set');
    }

    final sys = _systemPromptFor(languageCode);

    // Merge system + cleaned history + new user prompt
    final cleanedHistory = <Map<String, String>>[];
    String? lastRole;
    for (var msg in history) {
      if (lastRole == msg['role']) continue;
      cleanedHistory.add(msg);
      lastRole = msg['role'];
    }
    if (cleanedHistory.isEmpty || cleanedHistory.last['role'] != 'user') {
      cleanedHistory.add({'role': 'user', 'content': prompt});
    } else {
      cleanedHistory.last = {'role': 'user', 'content': prompt};
    }

    // Gemini expects a different format
    final contents = [
      {
        'role': 'user',
        'parts': [
          {
            'text':
                '$sys\n\n${cleanedHistory.map((m) => "${m['role']}: ${m['content']}").join("\n")}',
          },
        ],
      },
    ];

    final resp = await http.post(
      geminiEndpoint.replace(queryParameters: {'key': geminiApiKey}),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'contents': contents}),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (text is String && text.trim().isNotEmpty) return text.trim();
      throw Exception('Gemini empty response');
    } else {
      throw Exception('Gemini error ${resp.statusCode}: ${resp.body}');
    }
  }

  static Future<String> _chatPerplexity({
    required String prompt,
    required String languageCode,
    required List<Map<String, String>> history,
  }) async {
    if (perplexityApiKey.isEmpty) {
      throw Exception('Perplexity API key not set');
    }

    final sys = _systemPromptFor(languageCode);

    // Ensure alternating roles
    final cleanedHistory = <Map<String, String>>[];
    String? lastRole;

    for (var msg in history) {
      if (lastRole == msg['role']) {
        // Skip duplicate consecutive roles
        continue;
      }
      cleanedHistory.add(msg);
      lastRole = msg['role'];
    }

    // Append latest prompt as user message if last role is not user
    if (cleanedHistory.isEmpty || cleanedHistory.last['role'] != 'user') {
      cleanedHistory.add({'role': 'user', 'content': prompt});
    } else {
      // If last is already user, replace it with the new prompt
      cleanedHistory[cleanedHistory.length - 1] = {
        'role': 'user',
        'content': prompt,
      };
    }

    final messages = [
      {'role': 'system', 'content': sys},
      ...cleanedHistory,
    ];
    print('Perplexity messages: $messages');
    final resp = await http.post(
      perplexityEndpoint,
      headers: {
        'Authorization': 'Bearer $perplexityApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': perplexityModel,
        'messages': messages,
        'temperature': 0.3,
        'max_tokens': 400,
      }),
    );
    // print('Perplexity response: ${resp.body}');

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body);
      print('Perplexity response: $data');
      final content = data['choices']?[0]?['message']?['content'];
      if (content is String && content.trim().isNotEmpty) return content.trim();
      throw Exception('Empty response from provider');
    } else {
      throw Exception('Perplexity error ${resp.statusCode}: ${resp.body}');
    }
  }

  static Future<String> _chatFlask({
    required String prompt,
    required String languageCode,
    required List<Map<String, String>> history,
  }) async {
    try {
      final resp = await http.post(
        flaskEndpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'prompt': prompt,
          'language': languageCode,
          'history': history,
        }),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body);
        final text = data['reply'] ?? data['response'] ?? data['text'];
        if (text is String && text.trim().isNotEmpty) return text.trim();
        throw Exception('Flask: empty reply');
      }
      throw Exception('Flask error ${resp.statusCode}: ${resp.body}');
    } catch (e) {
      // Graceful fallback minimal response
      return 'I could not reach the server. Please check your connection and try again.';
    }
  }

  static String _systemPromptFor(String languageCode) {
    switch (languageCode) {
      case 'ur-PK':
        return '''
آپ ایک مددگار وائس اسسٹنٹ ہیں۔ 
آپ کا انداز دوستانہ اور واضح ہونا چاہیے۔ 
جواب مختصر اور انسانی لہجے میں دیں۔ 
کسی قسم کے حوالہ جات، لنکس، یا مآخذ کا ذکر نہ کریں۔ 
ایسا جواب دیں جو آواز میں سننے پر قدرتی لگے۔
''';
      default:
        return '''
You are a helpful voice assistant. 
Respond in natural, human-sounding language without any references, citations, or links. 
Do not include phrases like "According to", "as per", or any source names. 
Always provide direct, clear, and concise answers that sound natural when spoken aloud. 
Avoid listing sources or adding references. Focus on speaking-style replies.
''';
    }
  }
}

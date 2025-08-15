import 'dart:convert';

import 'package:beenai_sense/Utility/chat_service.dart';
import 'package:device_apps/device_apps.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class IntentHelper {
  /// Returns true if an intent was handled; false to let LLM answer.
 static Future<bool> tryHandleIntent(String text, {String languageCode = 'en-US'}) async {
  final q = text.toLowerCase().trim();

  // 1️⃣ First try Gemini AI for intent classification
  try {
    final intent = await _classifyIntentWithGemini(text, languageCode);

    switch (intent['action']) {
      case 'open_url':
        if (intent['url'] != null) return await _launch(Uri.parse(intent['url']!));
        break;

      case 'search_web':
        if (intent['query'] != null) {
          return await _launch(Uri.parse('https://www.google.com/search?q=' +
              Uri.encodeComponent(intent['query']!)));
        }
        break;

      case 'play_youtube':
        if (intent['query'] != null) {
          return await _launch(Uri.parse('https://www.youtube.com/results?search_query=' +
              Uri.encodeComponent(intent['query']!)));
        }
        break;

      case 'make_call':
        if (intent['phone'] != null) {
          return await _launch(Uri.parse('tel:${intent['phone']}'));
        }
        break;

      case 'send_sms':
        if (intent['phone'] != null && intent['message'] != null) {
          return await _launch(Uri.parse('sms:${intent['phone']}?body=${Uri.encodeComponent(intent['message']!)}'));
        }
        break;

      case 'open_app':
        if (intent['package'] != null) {
          return await _launchApp(intent['package']!); // You need a helper method for launching apps
        }
        break;

      case 'get_directions':
        if (intent['destination'] != null) {
          return await _launch(Uri.parse(
              'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(intent['destination']!)}'));
        }
        break;
    }
  } catch (_) {
    // Ignore and fallback to regex
  }

  // 2️⃣ Regex fallback logic (offline / Gemini fails)
  // Search web
  if (q.startsWith('search ') || q.startsWith('google ')) {
    final query = q.replaceFirst(RegExp(r'^(search|google) '), '');
    return await _launch(Uri.parse('https://www.google.com/search?q=' + Uri.encodeComponent(query)));
  }

  // Open website
  if (RegExp(r'\bopen\b.*\.\w{2,}').hasMatch(q)) {
    final url = q.replaceFirst(RegExp(r'open '), '').trim();
    return await _launch(Uri.parse(url.startsWith('http') ? url : 'https://$url'));
  }

  // Call
  if (q.startsWith('call ')) {
    final number = q.replaceFirst('call ', '').replaceAll(' ', '');
    return await _launch(Uri.parse('tel:$number'));
  }

  // Send SMS
  if (q.startsWith('text ') || q.startsWith('sms ')) {
    final parts = q.split(' ');
    if (parts.length > 2) {
      final number = parts[1];
      final message = parts.sublist(2).join(' ');
      return await _launch(Uri.parse('sms:$number?body=${Uri.encodeComponent(message)}'));
    }
  }

  // YouTube search
  if (q.startsWith('play ') || q.startsWith('youtube ')) {
    final query = q.replaceFirst(RegExp(r'^(play|youtube) '), '');
    return await _launch(Uri.parse('https://www.youtube.com/results?search_query=' + Uri.encodeComponent(query)));
  }

  // Get directions
  if (q.startsWith('directions to ') || q.startsWith('navigate to ')) {
    final destination = q.replaceFirst(RegExp(r'^(directions to|navigate to) '), '');
    return await _launch(Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destination)}'));
  }

  return false;
}

// // Helper to open apps (Android only)
static Future<bool> _launchApp(String packageName) async {
  try {
    bool isInstalled = await DeviceApps.isAppInstalled(packageName);
    if (isInstalled) {
      return await DeviceApps.openApp(packageName);
    } else {
      print("App not installed: $packageName");
      return false;
    }
  } catch (e) {
    print("Error launching app: $e");
    return false;
  }
}


  static Future<Map<String, String?>> _classifyIntentWithGemini(
  String text,
  String lang,
) async {
  print('Gemini intent classification: $text');
  if (ChatService.geminiApiKey.isEmpty) return {};
  
  final prompt = """
You are an intent parser for a multilingual voice assistant.
Given the user input, output ONLY a JSON object with the keys:

- action: one of 
  ["open_url", "search_web", "play_youtube", "make_call", "send_sms", "open_app", "get_directions", "none"]

- query: optional text for search, YouTube, or general queries
- url: optional full URL for open_url
- phone: optional phone number for make_call or send_sms
- message: optional text for send_sms
- package: optional Android package name for open_app
- destination: optional place/address for get_directions

Rules:
1. Always detect based on the user’s intent.
2. Return action "none" if no intent is detected.
3. Respond with ONLY the JSON — no extra text or formatting.
4. Preserve the language of the original query in `query`, `message`, and `destination`.
5. NEVER return "search_web" unless the user explicitly uses phrases like "search", "google", or "look up". General questions must return "none".
6. The app’s current language is "$lang", use that for understanding but don’t translate user content.

Examples:

User: "Call 03001234567"
{
  "action": "make_call",
  "phone": "03001234567"
}

User: "Send hello to 03111234567"
{
  "action": "send_sms",
  "phone": "03111234567",
  "message": "hello"
}

User: "Who is the prime minister of Canada?"
{
  "action": "none"
}

User: "Navigate to Lahore"
{
  "action": "get_directions",
  "destination": "Lahore"
}

User: "Open YouTube"
{
  "action": "open_app",
  "package": "com.google.android.youtube"
}

User: "Play Coke Studio season 14"
{
  "action": "play_youtube",
  "query": "Coke Studio season 14"
}

Now parse this:

"$text"
""";

  try {
    final resp = await http.post(
      ChatService.geminiEndpoint.replace(
        queryParameters: {'key': ChatService.geminiApiKey},
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      final data = jsonDecode(resp.body);
      print('Gemini response: $data');
      final reply = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
      if (reply is String) {
        final cleaned = reply
            .replaceAll(RegExp(r'```json', caseSensitive: false), '')
            .replaceAll('```', '')
            .trim();
        if (cleaned.startsWith('{') && cleaned.endsWith('}')) {
          return Map<String, String?>.from(jsonDecode(cleaned));
        }
      }
    }
  } catch (e) {
    print('Gemini error $e');
    return {'action': 'none', 'query': null, 'url': null};
  }
  return {'action': 'none', 'query': null, 'url': null};
}

  static Future<bool> _launch(Uri uri) async {
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to browser
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Launch error: $e');
      return false;
    }
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class Api {
  static String? _cachedBaseUrl;

  static Future<String> getBaseUrl() async {
    // return cached if available
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;

    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('baseUrl') ?? "http://192.168.130.160:5000"; // fallback
    _cachedBaseUrl = url;
    return url;
  }

  static const predict = "/predict";
}

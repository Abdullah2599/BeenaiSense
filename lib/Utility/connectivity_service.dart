import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService {
  static Future<bool> isConnected() async {
    try {
      // Check network connectivity first
      final connectivityResult = await Connectivity().checkConnectivity();
      
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Verify actual internet access
      bool hasConnection = await InternetConnection().hasInternetAccess;
      return hasConnection;
    } catch (e) {
      print('Connectivity check error: $e');
      return false;
    }
  }

  // Check if specific API server is reachable
  static Future<bool> isServerReachable(String baseUrl) async {
    try {
      final uri = Uri.parse(baseUrl);
      final result = await InternetAddress.lookup(uri.host);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

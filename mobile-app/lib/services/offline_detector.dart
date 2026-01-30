import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to detect network connectivity status
class OfflineDetector {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device is currently online
  static Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();

      // Consider device online if has any active connection
      return result != ConnectivityResult.none;
    } catch (e) {
      // Assume offline if check fails
      return false;
    }
  }

  /// Get human-readable connection status
  static Future<String> getConnectionStatus() async {
    try {
      final result = await _connectivity.checkConnectivity();

      switch (result) {
        case ConnectivityResult.mobile:
          return 'Mobile Network';
        case ConnectivityResult.wifi:
          return 'WiFi Connected';
        case ConnectivityResult.ethernet:
          return 'Ethernet Connected';
        case ConnectivityResult.vpn:
          return 'VPN Connected';
        case ConnectivityResult.none:
          return 'No Connection';
        default:
          return 'Unknown';
      }
    } catch (e) {
      return 'Unable to determine';
    }
  }

  /// Stream of connectivity changes
  static Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      return result != ConnectivityResult.none;
    });
  }
}

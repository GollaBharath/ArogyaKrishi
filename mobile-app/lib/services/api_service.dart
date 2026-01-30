import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/detection_result.dart';
import '../models/nearby_alert.dart';
import '../models/scan_treatment_result.dart';
import '../utils/constants.dart';

/// API Service for ArogyaKrishi backend
class ApiService {
  // Use your computer's local IP for physical device
  // Use 10.0.2.2 for Android emulator
  // Change this to match your network setup
  static const String baseUrl = AppConstants.apiBaseUrl;

  /// Upload image for disease detection
  ///
  /// Parameters:
  /// - [imageFile]: Image file to analyze
  /// - [lat]: Optional latitude for location
  /// - [lng]: Optional longitude for location
  /// - [language]: Optional language code (en, te, hi, kn, ml)
  ///
  /// Returns: DetectionResult with crop, disease, confidence, and remedies
  Future<DetectionResult> detectImage({
    required File imageFile,
    double? lat,
    double? lng,
    String? language,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/detect-image').replace(
        queryParameters: {
          if (language != null) 'language': language,
          if (lat != null) 'lat': lat.toString(),
          if (lng != null) 'lng': lng.toString(),
        },
      );
      final url = uri.toString();
      print('🌐 API Request: POST $url');
      print('📁 Image path: ${imageFile.path}');
      print('📍 Location: lat=$lat, lng=$lng');

      var request = http.MultipartRequest('POST', uri);

      // Determine content type from file extension
      String contentType = 'image/jpeg';
      if (imageFile.path.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (imageFile.path.toLowerCase().endsWith('.jpg') ||
          imageFile.path.toLowerCase().endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      }

      print('📷 Content-Type: $contentType');

      // Add image file with explicit content type
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: http.MediaType.parse(contentType),
        ),
      );

      print('📤 Sending request...');
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');
      print(
        '📥 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return DetectionResult.fromJson(jsonData);
      } else {
        throw ApiException(
          'Failed to detect disease: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Scan fertilizer/medicine item for treatment feedback
  ///
  /// Parameters:
  /// - [imageFile]: Image file of the item
  /// - [disease]: Disease name (localized or English key)
  /// - [itemLabel]: Optional product name text
  /// - [language]: Optional language code (en, te, hi, kn, ml)
  ///
  /// Returns: ScanTreatmentResult with feedback
  Future<ScanTreatmentResult> scanTreatment({
    required File imageFile,
    required String disease,
    String? itemLabel,
    String? language,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/scan-treatment');
      final url = uri.toString();
      print('🌐 API Request: POST $url');
      print('📁 Image path: ${imageFile.path}');

      var request = http.MultipartRequest('POST', uri);

      String contentType = 'image/jpeg';
      if (imageFile.path.toLowerCase().endsWith('.png')) {
        contentType = 'image/png';
      } else if (imageFile.path.toLowerCase().endsWith('.jpg') ||
          imageFile.path.toLowerCase().endsWith('.jpeg')) {
        contentType = 'image/jpeg';
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: http.MediaType.parse(contentType),
        ),
      );

      request.fields['disease'] = disease;
      if (itemLabel != null && itemLabel.trim().isNotEmpty) {
        request.fields['item_label'] = itemLabel.trim();
        print('📝 Item label: ${itemLabel.trim()}');
      } else {
        print('⚠️ No item label provided');
      }
      if (language != null && language.trim().isNotEmpty) {
        request.fields['language'] = language.trim();
      }

      print('📤 Sending request...');
      print('📤 Fields: ${request.fields}');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');
      print(
        '📥 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}',
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ScanTreatmentResult.fromJson(jsonData);
      } else {
        throw ApiException(
          'Failed to scan treatment: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ API Error: $e');
      throw ApiException('Network error: $e', 0);
    }
  }

  /// Fetch nearby disease alerts
  ///
  /// Parameters:
  /// - [lat]: Latitude for location
  /// - [lng]: Longitude for location
  ///
  /// Returns: List of nearby alerts
  Future<NearbyAlertsResponse> getNearbyAlerts({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/nearby-alerts?lat=$lat&lng=$lng'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return NearbyAlertsResponse.fromJson(jsonData);
      } else {
        throw ApiException(
          'Failed to fetch alerts: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/myth_item.dart';
import '../utils/constants.dart';

class MythApiService {
  static const String _androidEmulatorBaseUrl = 'http://10.0.2.2:8000';
  final String baseUrl;
  static const String _envBaseUrl =
      String.fromEnvironment('BACKEND_URL', defaultValue: '');

  MythApiService({String? baseUrl})
      : baseUrl =
            baseUrl ??
            (_envBaseUrl.isNotEmpty ? _envBaseUrl : _getBackendUrl());

  /// Get backend URL based on platform (Android emulator vs real device)
  static String _getBackendUrl() {
    if (kDebugMode) {
      print('🔍 [MythApiService] Determining backend URL...');

      // Verification:
      // 1) Open emulator browser -> http://10.0.2.2:8000/docs
      // 2) Trigger classify from app and confirm POST /classify in backend terminal
      if (defaultTargetPlatform == TargetPlatform.android) {
        print('  → Running on Android emulator URL: $_androidEmulatorBaseUrl');
        return AppConstants.localBackendUrl;
      }

      if (kIsWeb) {
        print('  → Running on Web; using emulator host URL for local backend testing');
      }

      return _androidEmulatorBaseUrl;
    }

    // Production
    return AppConstants.baseUrl;
  }

  /// Classify a dental statement (main function)
  Future<MythCheckResult> classifyStatement(String text) async {
    final uri = Uri.parse('$baseUrl/classify');
    final requestBody = jsonEncode({'text': text});
    
    if (kDebugMode) {
      print('📨 [classifyStatement] Starting classification...');
      print('  → URL: $uri');
      print('  → Request body: $requestBody');
      print('  → Timeout: ${AppConstants.apiTimeout.inSeconds}s');
    }

    late http.Response response;

    try {
      // Send POST request with timeout
      response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(AppConstants.apiTimeout);
      
      if (kDebugMode) {
        print('  ✓ Got response: ${response.statusCode}');
        print('  → Body: ${response.body}');
      }
    } on TimeoutException catch (e) {
      final errorMsg =
          'Backend not reachable (timeout after ${AppConstants.apiTimeout.inSeconds}s): $e';
      if (kDebugMode) print('  ❌ $errorMsg');
      throw Exception(errorMsg);
    } on SocketException catch (e) {
      final errorMsg =
          'Backend not reachable at $baseUrl: ${e.message}';
      if (kDebugMode) print('  ❌ SocketException: $errorMsg');
      throw Exception(errorMsg);
    } on HttpException catch (e) {
      final errorMsg = 'HTTP error: ${e.message}';
      if (kDebugMode) print('  ❌ $errorMsg');
      throw Exception(errorMsg);
    } on FormatException catch (e) {
      final errorMsg = 'Invalid response format: ${e.message}';
      if (kDebugMode) print('  ❌ $errorMsg');
      throw Exception(errorMsg);
    } on IOException catch (e) {
      final errorMsg = 'I/O error: $e';
      if (kDebugMode) print('  ❌ $errorMsg');
      throw Exception(errorMsg);
    } catch (e) {
      final errorMsg = 'Unexpected error: $e';
      if (kDebugMode) print('  ❌ $errorMsg');
      throw Exception(errorMsg);
    }

    // Check HTTP status code
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMsg = 'Backend returned status ${response.statusCode}\nBody: ${response.body}';
      if (kDebugMode) print('  ❌ $errorMsg');
      throw Exception(errorMsg);
    }

    // Parse response
    try {
      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response: expected JSON object');
      }

      if (kDebugMode) {
        print('  🧾 Raw backend response JSON: ${response.body}');
      }
      
      final result = _mapToResult(data);
      if (kDebugMode) {
        print('  ✅ Parsed result: ${result.label}');
        print('     Confidence: ${result.confidence}');
        print('     Explanation: ${result.explanation}');
        print('     Reason: ${result.reason}');
      }
      
      return result;
    } catch (e) {
      final errorMsg = 'Failed to parse response: $e';
      if (kDebugMode) print('  ❌ $errorMsg');
      throw Exception(errorMsg);
    }
  }

  /// Map backend JSON response to MythCheckResult
  MythCheckResult _mapToResult(Map<String, dynamic> data) {
    final rawType = (data['type'] ?? '').toString().trim();
    final normalizedType = rawType.toLowerCase().replaceAll('_', ' ');
    final label = switch (normalizedType) {
      'myth' => 'Myth',
      'fact' => 'Fact',
      'not dental' => 'Not Dental',
      _ => 'Myth',
    };

    final explanation = (data['explanation'] ?? '').toString().trim();
    final tip = (data['tip'] ?? '').toString().trim();
    
    // Parse confidence (0.0 - 1.0 or 0 - 100) to integer percentage (0 - 100)
    final confidenceRaw = data['confidence'];
    final confidenceValue = confidenceRaw is num
        ? confidenceRaw.toDouble()
        : double.tryParse(confidenceRaw?.toString() ?? '') ?? 70.0;
    final confidence = confidenceValue <= 1
        ? (confidenceValue * 100).round().clamp(0, 100)
        : confidenceValue.round().clamp(0, 100);

    return MythCheckResult(
      label: label,
      explanation:
          explanation.isNotEmpty ? explanation : 'No explanation available.',
      confidence: confidence,
      matchedText: null,
      category: '',
      reason: tip.isNotEmpty ? 'Tip: $tip' : 'Source: backend',
    );
  }

  // Fetch myths from API (TODO: implement if needed)
  Future<List<Map<String, dynamic>>> fetchMyths({
    String? category,
    int? limit,
  }) async {
    try {
      if (kDebugMode) {
        print('Fetching myths from API...');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching myths: $e');
      }
      rethrow;
    }
  }

  // Check a myth (TODO: implement if needed)
  Future<Map<String, dynamic>> checkMyth({
    required String mythId,
    required String userAnswer,
  }) async {
    try {
      if (kDebugMode) {
        print('Checking myth: $mythId');
      }
      return {};
    } catch (e) {
      if (kDebugMode) {
        print('Error checking myth: $e');
      }
      rethrow;
    }
  }

  // Get myth statistics (TODO: implement if needed)
  Future<Map<String, dynamic>> getMythStatistics(String userId) async {
    try {
      if (kDebugMode) {
        print('Fetching myth statistics for user: $userId');
      }
      return {};
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching statistics: $e');
      }
      rethrow;
    }
  }
}

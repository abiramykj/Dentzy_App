import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/myth_item.dart';
import '../utils/constants.dart';

class MythApiService {
  final String baseUrl;

  MythApiService({String? baseUrl}) : baseUrl = baseUrl ?? _defaultBaseUrl();

  static String _defaultBaseUrl() {
    if (kDebugMode) {
      if (kIsWeb) {
        return 'http://localhost:8000';
      }
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 'http://10.0.2.2:8000';
        default:
          return 'http://localhost:8000';
      }
    }
    return AppConstants.baseUrl;
  }

  Future<MythCheckResult> classifyStatement(String text) async {
    final uri = Uri.parse('$baseUrl/classify');
    final response = await http
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'text': text}),
        )
        .timeout(AppConstants.apiTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Unexpected status: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid response payload');
    }

    return _mapToResult(data);
  }

  MythCheckResult _mapToResult(Map<String, dynamic> data) {
    final type = (data['type'] ?? '').toString().toLowerCase();
    final label = switch (type) {
      'myth' => 'Myth',
      'fact' => 'Fact',
      'not_dental' => 'Not Dental',
      _ => 'Unknown',
    };

    final explanation = (data['explanation'] ?? '').toString().trim();
    final tip = (data['tip'] ?? '').toString().trim();
    final confidenceRaw = data['confidence'];
    final confidenceValue = confidenceRaw is num
        ? confidenceRaw.toDouble()
        : double.tryParse(confidenceRaw?.toString() ?? '') ?? 0.0;
    final confidence = (confidenceValue * 100).round().clamp(0, 100);

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

  // Fetch myths from API
  Future<List<Map<String, dynamic>>> fetchMyths({
    String? category,
    int? limit,
  }) async {
    try {
      if (kDebugMode) {
        print('Fetching myths from API...');
      }

      // TODO: Implement actual API call
      return [
        {
          'id': '1',
          'title': 'Sample Myth 1',
          'category': category ?? 'Health',
          'description': 'This is a sample myth for demonstration',
        }
      ];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching myths: $e');
      }
      rethrow;
    }
  }

  // Check a myth
  Future<Map<String, dynamic>> checkMyth({
    required String mythId,
    required String userAnswer,
  }) async {
    try {
      if (kDebugMode) {
        print('Checking myth: $mythId');
      }

      // TODO: Implement actual API call
      return {
        'isCorrect': true,
        'correctAnswer': 'Sample Answer',
        'explanation': 'This is an explanation',
        'confidenceScore': 0.95,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error checking myth: $e');
      }
      rethrow;
    }
  }

  // Get myth statistics
  Future<Map<String, dynamic>> getMythStatistics(String userId) async {
    try {
      if (kDebugMode) {
        print('Fetching myth statistics for user: $userId');
      }

      // TODO: Implement actual API call
      return {
        'totalMythsChecked': 25,
        'correctAnswers': 20,
        'accuracyRate': 0.8,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching statistics: $e');
      }
      rethrow;
    }
  }
}

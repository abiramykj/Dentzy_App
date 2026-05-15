import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'auth_service.dart';
import '../models/myth_item.dart';
import '../utils/constants.dart';

class MythApiService {
  final String baseUrl;

  MythApiService({String? baseUrl})
  : baseUrl = (baseUrl ?? _defaultBackendUrl()).trim();

  /// Classify a dental statement using the backend Groq API.
  /// Supports English, Tamil, and Mixed (Tanglish) input.
  Future<MythCheckResult> classifyStatement(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError('Statement cannot be empty.');
    }

    // Detect input language for logging
    final detectedLanguage = _detectLanguage(trimmedText);

    final uri = Uri.parse('${_normalizedBaseUrl()}/classify');
    final url = uri.toString();
    final requestBody = jsonEncode({'text': trimmedText});

    print('[MythAPI] START classify');
    print('[MythAPI] loading token...');

    final token = await AuthService.getToken();
    print('[MythAPI] token=$token');
    print('[MythAPI] url=$url');

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('[MythAPI] Authorization header added');
    } else {
      print('[MythAPI] TOKEN IS NULL');
      print('[MythAPI] Authorization header skipped');
    }

    print('[MythAPI] headers=$headers');
    print('[MythAPI] body=$requestBody');

    try {
      final response = await http
          .post(
            uri,
            headers: headers,
            body: requestBody,
          )
          .timeout(AppConstants.apiTimeout);

          print('[MythAPI] response status=${response.statusCode}');
          print('[MythAPI] response body=${response.body}');

      final payload = _decodeJsonMap(response.body);
      debugPrint('[MythApiService] parsed_json=$payload');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = _extractErrorMessage(response.body);
        debugPrint('[MythApiService] backend_error=$message');
        debugPrint('=' * 60);
        return _fallbackResult(message);
      }

      final normalizedType = _normalizeType(payload['type']);
      final confidence = _normalizeConfidence(payload['confidence']);

      final result = MythCheckResult(
        label: _displayLabel(normalizedType),
        explanation: _safeText(
          payload['explanation'],
          fallback: 'Unable to generate detailed explanation at this time.',
        ),
        confidence: confidence,
        matchedText: null,
        category: normalizedType,
        reason: _safeText(
          payload['explanation'],
          fallback: 'Unable to generate detailed explanation at this time.',
        ),
      );
      
      debugPrint('[MythApiService] final_result=type:$normalizedType, confidence:$confidence');
      debugPrint('=' * 60);
      return result;
    } catch (error) {
      debugPrint('[MythApiService] classifyStatement_failed=$error');
      debugPrint('=' * 60);
      return _fallbackResult('Unable to classify statement right now.');
    }
  }

  /// Detect if input is English, Tamil, or Mixed.
  String _detectLanguage(String text) {
    // Tamil Unicode range: U+0B80 to U+0BFF
    final tamilPattern = RegExp(r'[\u0B80-\u0BFF]');
    final englishPattern = RegExp(r'[a-zA-Z]');
    
    final hasTamil = tamilPattern.hasMatch(text);
    final hasEnglish = englishPattern.hasMatch(text);
    
    if (hasTamil && hasEnglish) {
      return 'mixed';
    } else if (hasTamil) {
      return 'tamil';
    } else {
      return 'english';
    }
  }

  String _normalizedBaseUrl() {
    final value = baseUrl.trim();
    if (value.isEmpty) {
      return _defaultBackendUrl();
    }
    return value.replaceFirst(RegExp(r'/+$'), '');
  }

  static String _defaultBackendUrl() {
    final url = kIsWeb
        ? AppConstants.localBackendUrl.replaceFirst('10.0.2.2', 'localhost')
        : (defaultTargetPlatform == TargetPlatform.android
            ? AppConstants.localBackendUrl
            : AppConstants.localBackendUrl.replaceFirst('10.0.2.2', '127.0.0.1'));

    debugPrint('[MythApiService] Using backend URL: $url');
    return url;
  }

  Map<String, dynamic> _decodeJsonMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (error) {
      debugPrint('[MythApiService] Failed to decode JSON: $error');
    }

    return <String, dynamic>{};
  }

  String _normalizeType(dynamic value) {
    final normalized = value
        .toString()
        .trim()
        .toUpperCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    switch (normalized) {
      case 'FACT':
      case 'MYTH':
      case 'NOT_DENTAL':
        return normalized;
      default:
        return 'NOT_DENTAL';
    }
  }

  String _displayLabel(String normalizedType) {
    switch (normalizedType) {
      case 'FACT':
        return 'Fact';
      case 'MYTH':
        return 'Myth';
      case 'NOT_DENTAL':
        return 'Not Dental';
      default:
        return 'Not Dental';
    }
  }

  int _normalizeConfidence(dynamic value) {
    final parsed = double.tryParse(value.toString());
    if (parsed == null) {
      return 0;
    }

    final confidence = parsed <= 1 ? parsed * 100 : parsed;
    return confidence.clamp(0, 100).round();
  }

  String _safeText(dynamic value, {required String fallback}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['detail'] != null) {
        return decoded['detail'].toString();
      }
    } catch (_) {
      // Fall through to raw body handling.
    }

    return body.trim().isEmpty ? 'Unknown error' : body.trim();
  }

  /// Save myth classification result to backend history.
  /// Requires valid authentication token.
  Future<bool> saveMythHistory({
    required String statement,
    required String resultType,
    required int confidence,
    required String explanation,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        debugPrint('[MythApiService] No auth token available for saving history');
        return false;
      }

      final uri = Uri.parse('${_normalizedBaseUrl()}/api/myths/history');
      final requestBody = jsonEncode({
        'statement': statement.trim(),
        'result_type': resultType.toUpperCase(),
        'confidence': confidence.clamp(0, 100),
        'explanation': explanation.trim(),
      });

      debugPrint('[MythApiService] POST $uri (save history)');
      debugPrint('[MythApiService] request_body=$requestBody');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: requestBody,
          )
          .timeout(AppConstants.apiTimeout);

      debugPrint('[MythApiService] save_history status=${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[MythApiService] save_history failed: ${response.body}');
        return false;
      }

      debugPrint('[API] Myth history saved');
      return true;
    } catch (error) {
      debugPrint('[MythApiService] saveMythHistory error=$error');
      return false;
    }
  }

  /// Get stored myth history from backend.
  Future<List<Map<String, dynamic>>> getMythHistory() async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('[MythApiService] No auth token available for fetching history');
        return [];
      }

      final uri = Uri.parse('${_normalizedBaseUrl()}/api/myths/history');
      debugPrint('[MythApiService] GET $uri (fetch history)');

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(AppConstants.apiTimeout);

      debugPrint('[MythApiService] fetch_history status=${response.statusCode}');
      debugPrint('[MythApiService] fetch_history body=${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[MythApiService] fetch_history failed: ${response.body}');
        return [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        debugPrint('[API] Myth history fetched: ${decoded.length} items');
        return List<Map<String, dynamic>>.from(decoded);
      }
      return [];
    } catch (error) {
      debugPrint('[MythApiService] getMythHistory error=$error');
      return [];
    }
  }

  /// Get authentication token from auth service.
  Future<String?> _getAuthToken() async {
    try {
      return await AuthService.getToken();
    } catch (_) {
      return null;
    }
  }

  MythCheckResult _fallbackResult(String explanation) {
    return MythCheckResult(
      label: 'Not Dental',
      explanation: explanation,
      confidence: 0,
      matchedText: null,
      category: 'NOT_DENTAL',
      reason: explanation,
    );
  }
}

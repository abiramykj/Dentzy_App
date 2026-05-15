import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'auth_service.dart';

class BrushingApiService {
  final String baseUrl;

  BrushingApiService({String? baseUrl})
      : baseUrl = (baseUrl ?? _defaultBackendUrl()).trim();

  /// Save or update brushing record to backend.
  /// Requires valid authentication token.
  Future<bool> saveBrushingRecord({
    required DateTime date,
    required bool morningBrushed,
    required bool nightBrushed,
    required int streak,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        debugPrint('[BrushingApiService] No auth token available for saving record');
        return false;
      }

      final uri = Uri.parse('${_normalizedBaseUrl()}/api/brushing/records');
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final requestBody = jsonEncode({
        'date': dateStr,
        'morning_brushed': morningBrushed,
        'night_brushed': nightBrushed,
        'streak': streak,
      });

      debugPrint('[BrushingApiService] POST $uri');
      debugPrint('[BrushingApiService] date=$dateStr, morning=$morningBrushed, night=$nightBrushed, streak=$streak');

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

      debugPrint('[BrushingApiService] save status=${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[BrushingApiService] save failed: ${response.body}');
        return false;
      }

      debugPrint('[API] Brushing tracker saved');
      return true;
    } catch (error) {
      debugPrint('[BrushingApiService] saveBrushingRecord error=$error');
      return false;
    }
  }

  /// Get brushing records from backend.
  Future<List<Map<String, dynamic>>> getBrushingRecords() async {
    try {
      final token = await _getAuthToken();
      if (token == null || token.isEmpty) {
        debugPrint('[BrushingApiService] No auth token available for fetching records');
        return [];
      }

      final uri = Uri.parse('${_normalizedBaseUrl()}/api/brushing/records');
      debugPrint('[BrushingApiService] GET $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(AppConstants.apiTimeout);

      debugPrint('[BrushingApiService] fetch status=${response.statusCode}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[BrushingApiService] fetch failed: ${response.body}');
        return [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        debugPrint('[API] Brushing records fetched: ${decoded.length} items');
        return List<Map<String, dynamic>>.from(decoded);
      }
      return [];
    } catch (error) {
      debugPrint('[BrushingApiService] getBrushingRecords error=$error');
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

    debugPrint('[BrushingApiService] Using backend URL: $url');
    return url;
  }
}

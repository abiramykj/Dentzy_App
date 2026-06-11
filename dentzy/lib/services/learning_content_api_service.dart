import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class LearningContentApiService {
  static final LearningContentApiService instance = LearningContentApiService._internal();

  LearningContentApiService._internal();

  Future<List<Map<String, dynamic>>> fetchVideos({required String language}) async {
    return _fetchList('/videos', language: language);
  }

  Future<List<Map<String, dynamic>>> fetchArticles({required String language}) async {
    return _fetchList('/articles', language: language);
  }

  Future<List<Map<String, dynamic>>> _fetchList(
    String path, {
    required String language,
  }) async {
    final normalizedLanguage = _normalizeLanguage(language);
    final uri = Uri.parse('${_backendBaseUrl()}$path?language=$normalizedLanguage');

    try {
      debugPrint('[LearningContentApiService] GET $uri');
      final response = await http.get(uri).timeout(AppConstants.apiTimeout);
      debugPrint('[LearningContentApiService] $path status=${response.statusCode}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[LearningContentApiService] $path failed: ${response.body}');
        throw HttpException('Failed to load $path (${response.statusCode})');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        debugPrint('[LearningContentApiService] $path returned non-list payload');
        throw const FormatException('Learning content API returned invalid payload');
      }

      final items = decoded
          .whereType<Map>()
          .map((item) => item.map((key, value) => MapEntry(key.toString(), value)))
          .toList();

      debugPrint('[LearningContentApiService] $path loaded ${items.length} items for $normalizedLanguage');
      return items;
    } catch (error) {
      debugPrint('[LearningContentApiService] $path fetch failed: $error');
      rethrow;
    }
  }

  String _normalizeLanguage(String language) {
    return language.trim().toLowerCase() == 'ta' ? 'ta' : 'en';
  }

  String _backendBaseUrl() {
    final url = kIsWeb
        ? AppConstants.localBackendUrl.replaceFirst('10.0.2.2', 'localhost')
        : (defaultTargetPlatform == TargetPlatform.android
            ? AppConstants.localBackendUrl
            : AppConstants.localBackendUrl.replaceFirst('10.0.2.2', '127.0.0.1'));

    debugPrint('[LearningContentApiService] Using backend URL: $url');
    return url;
  }
}
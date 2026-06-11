import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../utils/constants.dart';
import 'auth_service.dart';
import 'authenticated_http_client.dart';

class TrackerService {
  static final TrackerService instance = TrackerService._internal();

  TrackerService._internal();

  Future<Map<String, dynamic>?> fetchStats() async {
    final uri = Uri.parse('${_backendBaseUrl()}/api/tracker/stats');
    try {
      debugPrint('[TrackerService] GET $uri');
      final response = await AuthenticatedHttpClient.instance.get(
        uri,
        headersProvider: () => AuthService.getAuthorizedHeaders(),
        onSessionExpired: AuthService.handleSessionExpired,
        timeout: AppConstants.apiTimeout,
      );

      if (response == null || response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[TrackerService] stats request failed');
        return null;
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (error) {
      debugPrint('[TrackerService] fetchStats failed: $error');
    }
    return null;
  }

  Future<void> markArticleCompleted(String articleId) async {
    await _postProgress('/api/tracker/articles/$articleId/complete', label: 'article', id: articleId);
  }

  Future<void> markVideoWatched(String videoId) async {
    await _postProgress('/api/tracker/videos/$videoId/watch', label: 'video', id: videoId);
  }

  Future<void> _postProgress(
    String path, {
    required String label,
    required String id,
  }) async {
    final uri = Uri.parse('${_backendBaseUrl()}$path');
    try {
      debugPrint('[TrackerService] POST $uri');
      final response = await AuthenticatedHttpClient.instance.post(
        uri,
        headersProvider: () => AuthService.getAuthorizedHeaders(includeContentType: true),
        body: jsonEncode({'id': id}),
        onSessionExpired: AuthService.handleSessionExpired,
        timeout: AppConstants.apiTimeout,
      );

      if (response == null) {
        return;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('[TrackerService] $label progress request failed: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint('[TrackerService] $label progress tracking failed: $error');
    }
  }

  String _backendBaseUrl() {
    final url = kIsWeb
        ? AppConstants.localBackendUrl.replaceFirst('10.0.2.2', 'localhost')
        : (defaultTargetPlatform == TargetPlatform.android
            ? AppConstants.localBackendUrl
            : AppConstants.localBackendUrl.replaceFirst('10.0.2.2', '127.0.0.1'));

    return url;
  }
}
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'auth_service.dart';

class NotificationApiService {
  final String baseUrl;

  NotificationApiService({String? baseUrl})
      : baseUrl = (baseUrl ?? _defaultBackendUrl()).trim();

  Future<bool> saveNotificationSettings({
    required TimeOfDay reminderTime,
    required bool enabled,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      final uri = Uri.parse('${_normalizedBaseUrl()}/api/notifications/me');
      final hh = reminderTime.hour.toString().padLeft(2, '0');
      final mm = reminderTime.minute.toString().padLeft(2, '0');
      final payload = jsonEncode({
        'reminder_time': '$hh:$mm:00',
        'enabled': enabled,
      });

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: payload,
          )
          .timeout(AppConstants.apiTimeout);

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
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

    debugPrint('[NotificationApiService] Using backend URL: $url');
    return url;
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'session_redirect_service.dart';

class AuthenticatedHttpClient {
  static final AuthenticatedHttpClient instance = AuthenticatedHttpClient._internal();

  final http.Client _client = http.Client();

  AuthenticatedHttpClient._internal();

  Future<http.Response?> get(
    Uri uri, {
    required Future<Map<String, String>?> Function() headersProvider,
    Future<void> Function()? onSessionExpired,
    Duration? timeout,
  }) {
    return _send(
      'GET',
      uri,
      headersProvider: headersProvider,
      onSessionExpired: onSessionExpired,
      timeout: timeout,
    );
  }

  Future<http.Response?> post(
    Uri uri, {
    required Future<Map<String, String>?> Function() headersProvider,
    Object? body,
    Future<void> Function()? onSessionExpired,
    Duration? timeout,
  }) {
    return _send(
      'POST',
      uri,
      headersProvider: headersProvider,
      body: body,
      onSessionExpired: onSessionExpired,
      timeout: timeout,
    );
  }

  Future<http.Response?> put(
    Uri uri, {
    required Future<Map<String, String>?> Function() headersProvider,
    Object? body,
    Future<void> Function()? onSessionExpired,
    Duration? timeout,
  }) {
    return _send(
      'PUT',
      uri,
      headersProvider: headersProvider,
      body: body,
      onSessionExpired: onSessionExpired,
      timeout: timeout,
    );
  }

  Future<http.Response?> delete(
    Uri uri, {
    required Future<Map<String, String>?> Function() headersProvider,
    Object? body,
    Future<void> Function()? onSessionExpired,
    Duration? timeout,
  }) {
    return _send(
      'DELETE',
      uri,
      headersProvider: headersProvider,
      body: body,
      onSessionExpired: onSessionExpired,
      timeout: timeout,
    );
  }

  Future<http.Response?> _send(
    String method,
    Uri uri, {
    required Future<Map<String, String>?> Function() headersProvider,
    Object? body,
    Future<void> Function()? onSessionExpired,
    Duration? timeout,
  }) async {
    final headers = await headersProvider();
    final authorization = headers?['Authorization']?.trim();
    final token = _extractToken(authorization);

    debugPrint('JWT Token: $token');
    debugPrint('Token length: ${token?.length}');
    debugPrint('Request URL: $uri');
    debugPrint('Request Headers: $headers');
    debugPrint('User Logged In: ${token != null && token.isNotEmpty}');

    if (headers == null || token == null || token.isEmpty) {
      debugPrint('Session expired. Please login again.');
      await _handleSessionExpired(onSessionExpired);
      return null;
    }

    final requestHeaders = Map<String, String>.from(headers);
    requestHeaders['Authorization'] = 'Bearer $token';

    debugPrint('Final outgoing headers: $requestHeaders');

    try {
      final future = switch (method) {
        'GET' => _client.get(uri, headers: requestHeaders),
        'POST' => _client.post(uri, headers: requestHeaders, body: body),
        'PUT' => _client.put(uri, headers: requestHeaders, body: body),
        'DELETE' => _client.delete(uri, headers: requestHeaders, body: body),
        _ => throw ArgumentError('Unsupported method: $method'),
      };

      final response = timeout == null ? await future : await future.timeout(timeout);
      if (response.statusCode == 401) {
        debugPrint('Session expired. Please login again.');
        await _handleSessionExpired(onSessionExpired);
        return null;
      }
      return response;
    } catch (error) {
      debugPrint('[AuthenticatedHttpClient] $method $uri failed: $error');
      rethrow;
    }
  }

  String? _extractToken(String? authorizationHeader) {
    final header = authorizationHeader?.trim() ?? '';
    if (header.isEmpty) {
      return null;
    }

    if (header.toLowerCase().startsWith('bearer ')) {
      final token = header.substring(7).trim();
      return token.isEmpty ? null : token;
    }

    return header;
  }

  Future<void> _handleSessionExpired(Future<void> Function()? onSessionExpired) async {
    if (onSessionExpired != null) {
      await onSessionExpired();
      return;
    }

    await SessionRedirectService.instance.showSessionExpiredAndRedirect();
  }
}

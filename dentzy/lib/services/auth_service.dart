import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import 'session_manager.dart';

class AuthResult {
  final bool success;
  final String message;
  final bool requiresLanguageSelection;
  final String? errorCode;

  const AuthResult({
    required this.success,
    required this.message,
    this.requiresLanguageSelection = false,
    this.errorCode,
  });
}

class AuthService {
  static const String _rememberedEmailKey = 'auth_remembered_email';
  static const String _rememberedTokenKey = 'auth_remembered_token';
  static const String _rememberMeFlagKey = 'auth_remember_me_enabled';

  static SharedPreferences? _prefs;
  static String? _accessToken;
  static String _cachedLanguageCode = '';
  static String _cachedUserName = '';

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    await AuthSessionService.instance.initialize();
  }

  static SharedPreferences get _safePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('AuthService is not initialized');
    }
    return prefs;
  }

  static String _backendBaseUrl() {
    final url = kIsWeb
        ? AppConstants.localBackendUrl.replaceFirst('10.0.2.2', 'localhost')
        : (defaultTargetPlatform == TargetPlatform.android
            ? AppConstants.localBackendUrl
            : AppConstants.localBackendUrl.replaceFirst('10.0.2.2', '127.0.0.1'));

    _logDebug('[API] Using backend URL: $url');
    return url;
  }

  static Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  static AuthResult _authResultFromErrorResponse(http.Response response) {
    final payload = _decodeBody(response.body);
    final detail = payload['detail'];
    if (detail is Map) {
      final message = detail['message']?.toString() ?? 'Something went wrong. Please try again.';
      final errorCode = detail['error_code']?.toString();
      return AuthResult(success: false, message: message, errorCode: errorCode);
    }

    return const AuthResult(
      success: false,
      message: 'Something went wrong. Please try again.',
    );
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static void _logDebug(String message) {
    if (kDebugMode) {
      debugPrint('[AuthService] $message');
    }
  }

  static String _authEndpoint(String path) {
    return '${_backendBaseUrl()}$path';
  }

  static String? _rememberedEmail() {
    final email = _safePrefs.getString(_rememberedEmailKey)?.trim() ?? '';
    return email.isEmpty ? null : email;
  }

  static String? _rememberedToken() {
    final token = _safePrefs.getString(_rememberedTokenKey)?.trim() ?? '';
    return token.isEmpty ? null : token;
  }

  static Future<void> _storeRememberedSession({
    required String email,
    required String token,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    await _safePrefs.setString(_rememberedEmailKey, normalizedEmail);
    await _safePrefs.setString(_rememberedTokenKey, token);
    await _safePrefs.setBool(_rememberMeFlagKey, true);
    _accessToken = token;
    _logDebug('Stored remembered session for $normalizedEmail');
  }

  static Future<void> _clearRememberedSession() async {
    await _safePrefs.remove(_rememberedEmailKey);
    await _safePrefs.remove(_rememberedTokenKey);
    await _safePrefs.setBool(_rememberMeFlagKey, false);
    _logDebug('Cleared remembered session storage');
  }

  static Map<String, dynamic>? _extractUser(Map<String, dynamic> payload) {
    final user = payload['user'];
    if (user is Map<String, dynamic>) {
      return user;
    }
    if (user is Map) {
      return user.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  static Future<bool> restoreRememberedSession() async {
    await initialize();

    final email = _rememberedEmail();
    final token = _rememberedToken();
    if (email == null || token == null) {
      _logDebug('restoreRememberedSession skipped: no remembered credentials');
      return false;
    }

    try {
      final uri = Uri.parse(_authEndpoint('/api/users/me'));
      _logDebug('restoreRememberedSession -> GET $uri email=$email');
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(AppConstants.apiTimeout);

      _logDebug('restoreRememberedSession <- status=${response.statusCode} body=${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        await _clearRememberedSession();
        return false;
      }

      final payload = _decodeBody(response.body);
      _accessToken = token;
      _cachedUserName = payload['username']?.toString().trim() ?? '';
      _cachedLanguageCode = payload['selected_language']?.toString().trim() ?? '';

      await AuthSessionService.instance.setSession(
        email: payload['email']?.toString() ?? email,
        userId: payload['id']?.toString() ?? email,
        rememberMe: true,
        userName: _cachedUserName,
      );
      return true;
    } catch (error, stackTrace) {
      _logDebug('restoreRememberedSession !! error=$error');
      _logDebug('restoreRememberedSession !! stackTrace=$stackTrace');
      await _clearRememberedSession();
      return false;
    }
  }

  static bool hasAccount() {
    return AuthSessionService.instance.hasActiveSession();
  }

  static bool needsLanguageSelection() {
    return _cachedLanguageCode.trim().isEmpty;
  }

  static Future<AuthResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    try {
      final uri = Uri.parse(_authEndpoint('/api/auth/signup'));
      final payload = {
        'username': fullName.trim(),
        'email': normalizedEmail,
        'password': password,
      };
      _logDebug('signUp -> POST $uri body=${jsonEncode(payload)}');
      final response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(AppConstants.apiTimeout);

      _logDebug('signUp <- status=${response.statusCode} body=${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _authResultFromErrorResponse(response);
      }

      final payloadResponse = _decodeBody(response.body);
      final user = _extractUser(payloadResponse);
      _cachedUserName = (user?['username']?.toString() ?? fullName.trim()).trim();
      _cachedLanguageCode = (user?['selected_language']?.toString() ?? '').trim();

      return AuthResult(
        success: true,
        message: payloadResponse['message']?.toString() ?? 'Account created successfully.',
        requiresLanguageSelection: _cachedLanguageCode.isEmpty,
      );
    } catch (error, stackTrace) {
      _logDebug('signUp !! error=$error');
      _logDebug('signUp !! stackTrace=$stackTrace');
      return const AuthResult(
        success: false,
        message: 'Unable to connect to server. Please try again.',
        errorCode: 'network_error',
      );
    }
  }

  static Future<AuthResult> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    try {
      final uri = Uri.parse(_authEndpoint('/api/auth/login'));
      final payload = {
        'email': normalizedEmail,
        'password': password,
        'remember_me': rememberMe,
      };
      _logDebug('signIn -> POST $uri body=${jsonEncode(payload)}');
      // Additional explicit debug prints requested
      debugPrint('[AuthService] signIn -> POST $uri');
      debugPrint('[AuthService] signIn -> BODY ${jsonEncode(payload)}');
      final response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(AppConstants.apiTimeout);

      debugPrint('[AuthService] signIn <- status=${response.statusCode} body=${response.body}');
      _logDebug('signIn <- status=${response.statusCode} body=${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _authResultFromErrorResponse(response);
      }

      final payloadResponse = _decodeBody(response.body);
      final token = payloadResponse['access_token']?.toString() ?? '';
      final user = _extractUser(payloadResponse);
      final userId = user?['id']?.toString() ?? '';
      final userName = (user?['username']?.toString() ?? '').trim();
      final selectedLanguage = (user?['selected_language']?.toString() ?? '').trim();

      _accessToken = token.isEmpty ? null : token;
      _cachedUserName = userName;
      _cachedLanguageCode = selectedLanguage;

      if (rememberMe && token.isNotEmpty) {
        await _storeRememberedSession(email: normalizedEmail, token: token);
      } else {
        await _clearRememberedSession();
      }

      await AuthSessionService.instance.setSession(
        email: normalizedEmail,
        userId: userId.isEmpty ? normalizedEmail : userId,
        rememberMe: rememberMe,
        userName: userName,
      );

      _logDebug('signIn: user=$normalizedEmail rememberMe=$rememberMe language=$selectedLanguage');

      return AuthResult(
        success: true,
        message: payloadResponse['message']?.toString() ?? 'Signed in successfully.',
        requiresLanguageSelection: selectedLanguage.isEmpty,
      );
    } catch (error, stackTrace) {
      _logDebug('signIn !! error=$error');
      _logDebug('signIn !! stackTrace=$stackTrace');
      return const AuthResult(
        success: false,
        message: 'Unable to connect to server. Please try again.',
        errorCode: 'network_error',
      );
    }
  }

  static Future<AuthResult> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    try {
      final uri = Uri.parse(_authEndpoint('/api/auth/reset-password'));
      final payload = {
        'email': normalizedEmail,
        'otp': otp.trim(),
        'new_password': newPassword,
      };
      _logDebug('resetPassword -> POST $uri body=${jsonEncode(payload)}');
      final response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      _logDebug('resetPassword <- status=${response.statusCode} body=${response.body}');
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _authResultFromErrorResponse(response);
      }

      return AuthResult(
        success: true,
        message: _decodeBody(response.body)['message']?.toString() ?? 'Password reset successfully.',
      );
    } catch (error, stackTrace) {
      _logDebug('resetPassword !! error=$error');
      _logDebug('resetPassword !! stackTrace=$stackTrace');
      return const AuthResult(
        success: false,
        message: 'Unable to connect to server. Please try again.',
        errorCode: 'network_error',
      );
    }
  }

  static Future<void> saveSelectedLanguage(String languageCode) async {
    final currentEmail = AuthSessionService.instance.currentLoggedInUserEmail;
    if (currentEmail == null || currentEmail.isEmpty) {
      _logDebug('saveSelectedLanguage skipped: no active session');
      return;
    }

    final token = _accessToken ?? _rememberedToken();
    if (token == null || token.isEmpty) {
      _logDebug('saveSelectedLanguage skipped: no access token');
      return;
    }

    try {
      final uri = Uri.parse(_authEndpoint('/api/users/language'));
      final payload = {'selected_language': languageCode};
      _logDebug('saveSelectedLanguage -> PUT $uri body=${jsonEncode(payload)}');
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 20));

      _logDebug('saveSelectedLanguage <- status=${response.statusCode} body=${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _cachedLanguageCode = languageCode.trim();
      }
    } catch (error, stackTrace) {
      _logDebug('saveSelectedLanguage !! error=$error');
      _logDebug('saveSelectedLanguage !! stackTrace=$stackTrace');
    }
  }

  static Future<void> setLoggedOut() async {
    final token = _accessToken ?? _rememberedToken();
    if (token != null && token.isNotEmpty) {
      try {
        final uri = Uri.parse(_authEndpoint('/api/auth/logout'));
        await http.post(
          uri,
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));
      } catch (_) {
        // Keep logout resilient even if backend is temporarily unreachable.
      }
    }

    await AuthSessionService.instance.clearSession();
    _accessToken = null;
    await _clearRememberedSession();
    _logDebug('setLoggedOut: Cleared active session state');
  }

  /// Check if app should auto-login on startup
  static bool shouldAutoLogin() {
    final result = (_safePrefs.getBool(_rememberMeFlagKey) ?? false) &&
        (_rememberedEmail() ?? '').isNotEmpty &&
        (_rememberedToken() ?? '').isNotEmpty;
    _logDebug('shouldAutoLogin: $result (email=${_rememberedEmail()}, rememberMe=${_safePrefs.getBool(_rememberMeFlagKey)}, tokenPresent=${_rememberedToken() != null})');
    return result;
  }

  /// Get saved email for Remember Me feature
  static String? getSavedEmail() {
    if (isRememberMeEnabled()) {
      return _rememberedEmail();
    }
    return null;
  }

  /// Get saved password for Remember Me feature
  static String? getSavedPassword() {
    return null;
  }

  /// Check if Remember Me is currently enabled
  static bool isRememberMeEnabled() {
    return _safePrefs.getBool(_rememberMeFlagKey) ?? false;
  }

  static String? getSavedToken() {
    if (!isRememberMeEnabled()) {
      return null;
    }
    return _rememberedToken();
  }

  static Future<String?> getToken() async {
    await initialize();
    final activeToken = _accessToken?.trim();
    if (activeToken != null && activeToken.isNotEmpty) {
      return activeToken;
    }

    final savedToken = getSavedToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      return savedToken;
    }

    return null;
  }

  /// Get the current access token (valid during active session)
  static String? getAccessToken() {
    return _accessToken;
  }

  static Future<AuthResult> sendPasswordResetOtp({
    required String email,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    try {
      final uri = Uri.parse(_authEndpoint('/api/auth/send-otp'));
      final payload = {'email': normalizedEmail};
      _logDebug('sendPasswordResetOtp -> POST $uri body=${jsonEncode(payload)}');
      final response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      _logDebug(
        'sendPasswordResetOtp <- status=${response.statusCode} body=${response.body}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const AuthResult(
          success: true,
          message: 'Verification code sent.',
        );
      }

      return _authResultFromErrorResponse(response);
    } catch (error, stackTrace) {
      _logDebug('sendPasswordResetOtp !! error=$error');
      _logDebug('sendPasswordResetOtp !! stackTrace=$stackTrace');
      return const AuthResult(
        success: false,
        message: 'Unable to connect to server. Please try again.',
        errorCode: 'network_error',
      );
    }
  }

  static Future<AuthResult> verifyPasswordResetOtp({
    required String email,
    required String otp,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    try {
      final uri = Uri.parse(_authEndpoint('/api/auth/verify-otp'));
      final payload = {
        'email': normalizedEmail,
        'otp': otp.trim(),
      };
      _logDebug('verifyPasswordResetOtp -> POST $uri body=${jsonEncode(payload)}');
      final response = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      _logDebug(
        'verifyPasswordResetOtp <- status=${response.statusCode} body=${response.body}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const AuthResult(
          success: true,
          message: 'Verification successful.',
        );
      }

      return _authResultFromErrorResponse(response);
    } catch (error, stackTrace) {
      _logDebug('verifyPasswordResetOtp !! error=$error');
      _logDebug('verifyPasswordResetOtp !! stackTrace=$stackTrace');
      return const AuthResult(
        success: false,
        message: 'Unable to connect to server. Please try again.',
        errorCode: 'network_error',
      );
    }
  }

  static String getStoredEmail() {
    return AuthSessionService.instance.currentLoggedInUserEmail ?? '';
  }

  static String getStoredName() {
    return AuthSessionService.instance.currentUserName ?? '';
  }

  static bool isLoggedIn() {
    return AuthSessionService.instance.isLoggedIn;
  }

  static String getStoredLanguage() {
    return _cachedLanguageCode;
  }
}

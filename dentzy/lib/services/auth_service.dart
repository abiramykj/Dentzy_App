import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

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
  static const String _nameKey = 'auth_name';
  static const String _emailKey = 'auth_email';
  static const String _passwordKey = 'auth_password';
  static const String _isLoggedInKey = 'auth_is_logged_in';
  static const String _selectedLanguageKey = 'auth_selected_language';
  static const String _languageProviderKey = 'language';
  static const String _rememberMeKey = 'auth_remember_me';
  static const String _autoLoginKey = 'auth_auto_login';

  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _safePrefs {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('AuthService is not initialized');
    }
    return prefs;
  }

  static String _backendBaseUrl() {
    if (kIsWeb) {
      return AppConstants.localBackendUrl.replaceFirst('10.0.2.2', 'localhost');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AppConstants.localBackendUrl;
      default:
        return AppConstants.localBackendUrl.replaceFirst('10.0.2.2', '127.0.0.1');
    }
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

  static bool hasAccount() {
    final prefs = _safePrefs;
    return (prefs.getString(_emailKey) ?? '').isNotEmpty &&
        (prefs.getString(_passwordKey) ?? '').isNotEmpty;
  }

  static bool needsLanguageSelection() {
    final prefs = _safePrefs;
    final selectedLanguage =
        prefs.getString(_selectedLanguageKey) ?? prefs.getString(_languageProviderKey) ?? '';
    return selectedLanguage.isEmpty;
  }

  static Future<AuthResult> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final prefs = _safePrefs;
    final normalizedEmail = _normalizeEmail(email);

    if (hasAccount()) {
      final existingEmail = prefs.getString(_emailKey) ?? '';
      if (existingEmail != normalizedEmail) {
        return const AuthResult(
          success: false,
          message: 'An account already exists on this device. Please sign in.',
        );
      }
    }

    await prefs.setString(_nameKey, fullName.trim());
    await prefs.setString(_emailKey, normalizedEmail);
    await prefs.setString(_passwordKey, password);
    await prefs.setBool(_isLoggedInKey, true);

    return AuthResult(
      success: true,
      message: 'Account created successfully.',
      requiresLanguageSelection: needsLanguageSelection(),
    );
  }

  static Future<AuthResult> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final prefs = _safePrefs;

    if (!hasAccount()) {
      return const AuthResult(
        success: false,
        message: 'No account found. Please create an account first.',
      );
    }

    final normalizedEmail = _normalizeEmail(email);
    final storedEmail = prefs.getString(_emailKey) ?? '';
    final storedPassword = prefs.getString(_passwordKey) ?? '';

    if (normalizedEmail != storedEmail || password != storedPassword) {
      return const AuthResult(
        success: false,
        message: 'Invalid email or password.',
      );
    }

    await prefs.setBool(_isLoggedInKey, true);
    
    // Save Remember Me preference
    await prefs.setBool(_rememberMeKey, rememberMe);
    if (rememberMe) {
      await prefs.setBool(_autoLoginKey, true);
      _logDebug('signIn: Remember Me enabled - auto-login will be triggered on next app launch');
    } else {
      await prefs.setBool(_autoLoginKey, false);
      _logDebug('signIn: Remember Me disabled');
    }

    return AuthResult(
      success: true,
      message: 'Signed in successfully.',
      requiresLanguageSelection: needsLanguageSelection(),
    );
  }

  static bool accountExistsForEmail(String email) {
    final prefs = _safePrefs;
    final normalizedEmail = _normalizeEmail(email);
    final storedEmail = prefs.getString(_emailKey) ?? '';
    return storedEmail.isNotEmpty && storedEmail == normalizedEmail;
  }

  static Future<AuthResult> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final prefs = _safePrefs;
    final normalizedEmail = _normalizeEmail(email);
    final storedEmail = prefs.getString(_emailKey) ?? '';

    if (storedEmail.isEmpty || storedEmail != normalizedEmail) {
      return const AuthResult(
        success: false,
        message: 'No account found for this email.',
      );
    }

    await prefs.setString(_passwordKey, newPassword);
    await prefs.setBool(_isLoggedInKey, false);

    return const AuthResult(
      success: true,
      message: 'Password reset successfully.',
    );
  }

  static Future<void> saveSelectedLanguage(String languageCode) async {
    final prefs = _safePrefs;
    await prefs.setString(_selectedLanguageKey, languageCode);
  }

  static Future<void> setLoggedOut() async {
    final prefs = _safePrefs;
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.setBool(_rememberMeKey, false);
    await prefs.setBool(_autoLoginKey, false);
    _logDebug('setLoggedOut: Cleared all login and Remember Me data');
  }

  /// Check if app should auto-login on startup
  static bool shouldAutoLogin() {
    final prefs = _safePrefs;
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
    final autoLogin = prefs.getBool(_autoLoginKey) ?? false;
    
    final result = rememberMe && isLoggedIn && autoLogin && hasAccount();
    _logDebug('shouldAutoLogin: $result (rememberMe=$rememberMe, isLoggedIn=$isLoggedIn, autoLogin=$autoLogin, hasAccount=${hasAccount()})');
    return result;
  }

  /// Get saved email for Remember Me feature
  static String? getSavedEmail() {
    final prefs = _safePrefs;
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    if (rememberMe) {
      return prefs.getString(_emailKey);
    }
    return null;
  }

  /// Get saved password for Remember Me feature
  static String? getSavedPassword() {
    final prefs = _safePrefs;
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    if (rememberMe) {
      return prefs.getString(_passwordKey);
    }
    return null;
  }

  /// Check if Remember Me is currently enabled
  static bool isRememberMeEnabled() {
    final prefs = _safePrefs;
    return prefs.getBool(_rememberMeKey) ?? false;
  }

  static Future<AuthResult> sendPasswordResetOtp({
    required String email,
  }) async {
    final normalizedEmail = _normalizeEmail(email);

    if (!accountExistsForEmail(normalizedEmail)) {
      return const AuthResult(
        success: false,
        message: 'No account found for this email.',
        errorCode: 'no_account',
      );
    }

    try {
      final uri = Uri.parse('${_backendBaseUrl()}/send-otp');
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
      final uri = Uri.parse('${_backendBaseUrl()}/verify-otp');
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
    return _safePrefs.getString(_emailKey) ?? '';
  }

  static String getStoredName() {
    return _safePrefs.getString(_nameKey) ?? '';
  }

  static bool isLoggedIn() {
    return _safePrefs.getBool(_isLoggedInKey) ?? false;
  }
}

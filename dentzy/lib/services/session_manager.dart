import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionService extends ChangeNotifier {
  static final AuthSessionService instance = AuthSessionService._internal();

  static const String _sessionEmailKey = 'session_current_email';
  static const String _sessionUserIdKey = 'session_current_user_id';
  static const String _sessionUserNameKey = 'session_current_user_name';
  static const String _sessionIsLoggedInKey = 'session_is_logged_in';
  static const String _sessionRememberMeKey = 'session_remember_me';

  SharedPreferences? _prefs;
  bool _initialized = false;
  int _sessionEpoch = 0;

  String? _currentLoggedInUserEmail;
  String? _currentUserId;
  String? _currentUserName;
  bool _isLoggedIn = false;
  bool _rememberMe = false;

  AuthSessionService._internal();

  String? get currentLoggedInUserEmail => _currentLoggedInUserEmail;
  String? get currentUserId => _currentUserId;
  String? get currentUserName => _currentUserName;
  bool get isLoggedIn => _isLoggedIn;
  bool get rememberMe => _rememberMe;
  int get sessionEpoch => _sessionEpoch;

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static String userScopedKey(String email, String suffix) {
    return 'user_${normalizeEmail(email)}_$suffix';
  }

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    if (_initialized) {
      return;
    }

    final storedEmail = normalizeEmail(_prefs?.getString(_sessionEmailKey) ?? '');
    final storedUserId = _prefs?.getString(_sessionUserIdKey)?.trim() ?? '';
    final storedUserName = _prefs?.getString(_sessionUserNameKey)?.trim() ?? '';
    final storedIsLoggedIn = _prefs?.getBool(_sessionIsLoggedInKey) ?? false;
    final storedRememberMe = _prefs?.getBool(_sessionRememberMeKey) ?? false;
    final hasActiveSession = storedEmail.isNotEmpty && storedIsLoggedIn && storedRememberMe;

    if (hasActiveSession) {
      _currentLoggedInUserEmail = storedEmail;
      _currentUserId = storedUserId.isEmpty ? storedEmail : storedUserId;
      _currentUserName = storedUserName.isEmpty ? null : storedUserName;
      _isLoggedIn = true;
      _rememberMe = true;
      _sessionEpoch++;
      _initialized = true;

      debugPrint(
        '[SESSION] initialize active user=$_currentLoggedInUserEmail userId=$_currentUserId rememberMe=$_rememberMe epoch=$_sessionEpoch',
      );

      notifyListeners();
      return;
    }

    final hadPersistedSession = storedEmail.isNotEmpty || storedUserId.isNotEmpty || storedUserName.isNotEmpty || storedIsLoggedIn || storedRememberMe;

    _currentLoggedInUserEmail = null;
    _currentUserId = null;
    _currentUserName = null;
    _isLoggedIn = false;
    _rememberMe = false;

    if (hadPersistedSession && _prefs != null) {
      await _prefs!.setString(_sessionEmailKey, '');
      await _prefs!.setString(_sessionUserIdKey, '');
      await _prefs!.setString(_sessionUserNameKey, '');
      await _prefs!.setBool(_sessionIsLoggedInKey, false);
      await _prefs!.setBool(_sessionRememberMeKey, false);
      _sessionEpoch++;
    }

    _initialized = true;

    debugPrint(
      '[SESSION] initialize anonymous activeSession=$hasActiveSession epoch=$_sessionEpoch',
    );

    if (hadPersistedSession) {
      notifyListeners();
    }
  }

  Future<void> setSession({
    required String email,
    required String userId,
    required bool rememberMe,
    String? userName,
  }) async {
    await initialize();

    final normalizedEmail = normalizeEmail(email);
    final previousEmail = _currentLoggedInUserEmail;
    _currentLoggedInUserEmail = normalizedEmail;
    _currentUserId = userId;
    _currentUserName = userName?.trim();
    _isLoggedIn = true;
    _rememberMe = rememberMe;
    _sessionEpoch++;

    debugPrint(
      '[SESSION] Logged in user=$_currentLoggedInUserEmail userId=$_currentUserId rememberMe=$_rememberMe previousUser=$previousEmail epoch=$_sessionEpoch',
    );

    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(_sessionEmailKey, normalizedEmail);
      await prefs.setString(_sessionUserIdKey, userId);
      await prefs.setString(_sessionUserNameKey, _currentUserName ?? '');
      await prefs.setBool(_sessionIsLoggedInKey, true);
      await prefs.setBool(_sessionRememberMeKey, rememberMe);
    }

    notifyListeners();
  }

  Future<void> clearSession() async {
    _prefs ??= await SharedPreferences.getInstance();

    debugPrint('[SESSION] Clearing active session for user=$_currentLoggedInUserEmail epoch=$_sessionEpoch');

    _currentLoggedInUserEmail = null;
    _currentUserId = null;
    _currentUserName = null;
    _isLoggedIn = false;
    _rememberMe = false;
    _sessionEpoch++;

    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(_sessionEmailKey, '');
      await prefs.setString(_sessionUserIdKey, '');
      await prefs.setString(_sessionUserNameKey, '');
      await prefs.setBool(_sessionIsLoggedInKey, false);
      await prefs.setBool(_sessionRememberMeKey, false);
    }

    debugPrint('[SESSION] Session cleared epoch=$_sessionEpoch');
    notifyListeners();
  }

  Future<void> updateDisplayName(String userName) async {
    await initialize();
    _currentUserName = userName.trim();

    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(_sessionUserNameKey, _currentUserName ?? '');
    }

    debugPrint('[SESSION] Updated display name for user=$_currentLoggedInUserEmail');
    notifyListeners();
  }

  bool hasActiveSession() =>
      _isLoggedIn && (_currentLoggedInUserEmail ?? '').isNotEmpty;
}
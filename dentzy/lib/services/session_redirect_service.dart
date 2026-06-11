import 'dart:async';

import 'package:flutter/material.dart';

class SessionRedirectService {
  static final SessionRedirectService instance = SessionRedirectService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  bool _isRedirecting = false;

  SessionRedirectService._internal();

  Future<void> showSessionExpiredAndRedirect() async {
    if (_isRedirecting) {
      return;
    }

    _isRedirecting = true;

    try {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please login again.'),
        ),
      );
      navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
    } finally {
      Timer(const Duration(seconds: 3), () {
        _isRedirecting = false;
      });
    }
  }
}

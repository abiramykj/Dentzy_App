import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/language_provider.dart';
import 'home_screen.dart';
import 'language_screen.dart';
import 'login_welcome_screen.dart';
import 'signup_screen.dart';
import 'splash_screen.dart';

enum _StartupStep {
  splash,
  login,
  signup,
  language,
  home,
  autoLogin,
}

class StartupFlowScreen extends StatefulWidget {
  final LanguageProvider languageProvider;

  const StartupFlowScreen({
    super.key,
    required this.languageProvider,
  });

  @override
  State<StartupFlowScreen> createState() => _StartupFlowScreenState();
}

class _StartupFlowScreenState extends State<StartupFlowScreen> {
  _StartupStep _step = _StartupStep.splash;
  bool _requireLanguageAfterAuth = false;

  void _toStep(_StartupStep next) {
    if (!mounted) return;
    setState(() {
      _step = next;
    });
  }

  Future<void> _performAutoLogin() async {
    debugPrint('🔄 [_performAutoLogin] Checking for Remember Me auto-login...');
    
    await AuthService.initialize();
    
    if (AuthService.shouldAutoLogin()) {
      debugPrint('✅ [_performAutoLogin] Auto-login enabled, validating session...');
      final restored = await AuthService.restoreRememberedSession();
      if (!restored) {
        debugPrint('❌ [_performAutoLogin] Remembered session is no longer valid');
        _toStep(_StartupStep.login);
        return;
      }

      debugPrint('✅ [_performAutoLogin] Auto-login validated, checking language...');
      final storedLanguage = AuthService.getStoredLanguage();
      if (storedLanguage.isNotEmpty) {
        widget.languageProvider.setLocaleOnly(storedLanguage);
      }
      
      if (AuthService.needsLanguageSelection()) {
        debugPrint('🔄 [_performAutoLogin] Language selection required');
        _requireLanguageAfterAuth = true;
        _toStep(_StartupStep.language);
      } else {
        debugPrint('✅ [_performAutoLogin] Auto-login to home screen');
        _toStep(_StartupStep.home);
      }
    } else {
      debugPrint('❌ [_performAutoLogin] Auto-login not enabled, going to login screen');
      _toStep(_StartupStep.login);
    }
  }

  Future<void> _onLanguageSelected(String languageCode) async {
    await AuthService.initialize();
    await AuthService.saveSelectedLanguage(languageCode);
    _requireLanguageAfterAuth = false;
    _toStep(_StartupStep.home);
  }

  void _onLoginSuccess(bool requiresLanguageSelection) {
    if (requiresLanguageSelection) {
      _requireLanguageAfterAuth = true;
      _toStep(_StartupStep.language);
      return;
    }

    final storedLanguage = AuthService.getStoredLanguage();
    if (storedLanguage.isNotEmpty) {
      widget.languageProvider.setLocaleOnly(storedLanguage);
    }
    _toStep(_StartupStep.home);
  }

  void _onAccountCreated(bool requiresLanguageSelection) {
    _toStep(_StartupStep.login);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        final scale = Tween<double>(begin: 0.985, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(_step),
        child: _buildCurrentStep(),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case _StartupStep.splash:
        return SplashScreen(
          onFinished: () => _performAutoLogin(),
        );
      case _StartupStep.autoLogin:
        return SplashScreen(
          onFinished: () => _performAutoLogin(),
        );
      case _StartupStep.login:
        return LoginWelcomeScreen(
          onLoginSuccess: _onLoginSuccess,
          onGoToSignUp: () => _toStep(_StartupStep.signup),
        );
      case _StartupStep.signup:
        return SignUpScreen(
          onAccountCreated: _onAccountCreated,
          onBackToLogin: () => _toStep(_StartupStep.login),
        );
      case _StartupStep.language:
        if (!_requireLanguageAfterAuth) {
          return HomeScreen(languageProvider: widget.languageProvider);
        }
        return LanguageScreen(
          languageProvider: widget.languageProvider,
          onLanguageSelected: _onLanguageSelected,
        );
      case _StartupStep.home:
        return HomeScreen(languageProvider: widget.languageProvider);
    }
  }
}

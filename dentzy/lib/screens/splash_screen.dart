import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/language_provider.dart';
import '../l10n/app_localizations.dart';
import 'language_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final LanguageProvider languageProvider;

  const SplashScreen({
    super.key,
    required this.languageProvider,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _fadeController.forward();
    await _scaleController.forward();

    if (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;

    // Always show language selection for each app launch (testing/demo flow).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LanguageScreen(
          languageProvider: widget.languageProvider,
          onLanguageSelected: (language) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  languageProvider: widget.languageProvider,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeController,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0)
                .animate(_scaleController),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  loc.appName,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.appTagline,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

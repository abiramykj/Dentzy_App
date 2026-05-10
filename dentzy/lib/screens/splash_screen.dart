import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
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
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF7FCFB), Color(0xFFF2FAF9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -40,
            child: _SplashOrb(color: AppTheme.primaryLight.withOpacity(0.22)),
          ),
          Positioned(
            bottom: 80,
            left: -40,
            child: _SplashOrb(color: AppTheme.secondaryLight.withOpacity(0.2), size: 170),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeController,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1.0)
                    .animate(_scaleController),
                child: CustomCard(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFEAF9F6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 118,
                        height: 118,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        loc.appName,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loc.appTagline,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      const _MiniPill(
                        icon: Icons.medical_services_rounded,
                        label: 'Premium dental AI',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

class _SplashOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _SplashOrb({required this.color, this.size = 190});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

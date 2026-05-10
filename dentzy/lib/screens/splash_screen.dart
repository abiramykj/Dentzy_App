import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/theme.dart';
import '../widgets/dentzy_logo.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const SplashScreen({
    super.key,
    required this.onFinished,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 980),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1450),
      vsync: this,
    );
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1900),
      vsync: this,
    )..repeat(reverse: true);

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _fadeController.forward();
    await _scaleController.forward();
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      widget.onFinished();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _SplashBackground(),
          Positioned(
            top: 112,
            left: 22,
            child: _FloatingIcon(
              icon: Icons.auto_awesome,
              animation: _sparkleController,
              color: const Color(0xFFEFB968),
            ),
          ),
          Positioned(
            top: 165,
            right: 28,
            child: _FloatingIcon(
              icon: Icons.health_and_safety_rounded,
              animation: _sparkleController,
              color: AppTheme.secondaryColor.withOpacity(0.7),
              reverse: true,
            ),
          ),
          Positioned(
            bottom: 148,
            left: 36,
            child: _FloatingIcon(
              icon: Icons.auto_awesome_rounded,
              animation: _sparkleController,
              color: AppTheme.primaryColor.withOpacity(0.75),
            ),
          ),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _fadeController,
                  curve: Curves.easeOut,
                ),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.84, end: 1).animate(
                    CurvedAnimation(
                      parent: _scaleController,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: const Hero(
                    tag: 'dentzy-logo-hero',
                    child: DentzyLogo(size: 136),
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

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFE8F8F5)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -60,
          right: -55,
          child: _Blob(size: 220, color: AppTheme.primaryColor.withOpacity(0.11)),
        ),
        Positioned(
          bottom: -56,
          left: -52,
          child: _Blob(size: 200, color: AppTheme.accentColor.withOpacity(0.1)),
        ),
        Positioned(
          bottom: 170,
          right: 36,
          child: Icon(Icons.local_hospital_rounded, color: AppTheme.primaryColor.withOpacity(0.12), size: 54),
        ),
        Positioned(
          top: 230,
          left: 30,
          child: Icon(Icons.clean_hands_rounded, color: AppTheme.secondaryColor.withOpacity(0.13), size: 50),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.44),
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final IconData icon;
  final Animation<double> animation;
  final Color color;
  final bool reverse;

  const _FloatingIcon({
    required this.icon,
    required this.animation,
    required this.color,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = reverse ? 1 - animation.value : animation.value;
        final dy = math.sin(value * math.pi * 2) * 8;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Icon(
        icon,
        size: 28,
        color: color,
      ),
    );
  }
}

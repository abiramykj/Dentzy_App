import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/dentzy_logo.dart';
import 'reset_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with SingleTickerProviderStateMixin {
  static const int _otpCountdownSeconds = 45;

  final _otpController = TextEditingController();
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _countdownTimer;
  int _secondsRemaining = _otpCountdownSeconds;
  bool _canResend = false;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _fadeAnimation = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));

    _entranceController.forward();
    _startTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = _otpCountdownSeconds;
      _canResend = false;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
        return;
      }

      setState(() {
        _secondsRemaining -= 1;
      });
    });
  }

  Future<void> _verifyOtp() async {
    final loc = AppLocalizations.of(context)!;
    final otp = _otpController.text.trim();

    setState(() {
      _inlineError = null;
    });

    if (otp.length != 6) {
      setState(() {
        _inlineError = loc.authInvalidOtp;
      });
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await AuthService.initialize();
      await Future.delayed(const Duration(milliseconds: 850));
      final result = await AuthService.verifyPasswordResetOtp(
        email: widget.email,
        otp: otp,
      );

      if (!mounted) return;
      setState(() {
        _isVerifying = false;
      });

      if (!result.success) {
        setState(() {
          _inlineError = result.errorCode == 'otp_expired'
              ? loc.authOtpExpired
              : result.errorCode == 'network_error'
                  ? loc.authSomethingWentWrong
                  : loc.authInvalidOtp;
        });
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: widget.email),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVerifying = false;
        _inlineError = loc.authSomethingWentWrong;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend || _isResending) return;

    final loc = AppLocalizations.of(context)!;

    setState(() {
      _inlineError = null;
      _isResending = true;
    });

    try {
      await AuthService.initialize();
      await Future.delayed(const Duration(milliseconds: 850));
      final result = await AuthService.sendPasswordResetOtp(email: widget.email);

      if (!mounted) return;
      setState(() {
        _isResending = false;
      });

      if (!result.success) {
        setState(() {
          _inlineError = result.errorCode == 'network_error'
              ? loc.authSomethingWentWrong
              : result.message;
        });
        return;
      }

      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.authResetLinkSent),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _inlineError = loc.authSomethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const _AuthBackdrop(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Hero(
                        tag: 'dentzy-logo-hero',
                        child: DentzyLogo(size: 92),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        loc.authVerifyOtp,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.authOtpSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryDark,
                            ),
                      ),
                      const SizedBox(height: 20),
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              loc.authVerificationCode,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: loc.authVerificationCodeHint,
                                prefixIcon: const Icon(Icons.password_rounded),
                              ),
                              onChanged: (_) {
                                if (_inlineError != null) {
                                  setState(() {
                                    _inlineError = null;
                                  });
                                }
                              },
                            ),
                            if (_inlineError != null) ...[
                              const SizedBox(height: 12),
                              _InlineError(message: _inlineError!),
                            ],
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isVerifying ? null : _verifyOtp,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(56),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: _isVerifying
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(loc.authVerifyOtp),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _canResend && !_isResending ? _resendOtp : null,
                              child: _isResending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2.2),
                                    )
                                  : Text(
                                      _canResend
                                          ? loc.authResendCode
                                          : loc.authResendInSeconds(_secondsRemaining),
                                    ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                              child: Text(loc.authBackToLogin),
                            ),
                          ],
                        ),
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

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDFEFE), Color(0xFFF1FBF9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -70,
            child: _Blob(size: 220, color: AppTheme.primaryColor.withOpacity(0.11)),
          ),
          Positioned(
            bottom: -70,
            left: -35,
            child: _Blob(size: 200, color: AppTheme.accentColor.withOpacity(0.1)),
          ),
          Positioned(
            top: 120,
            left: -35,
            child: _Blob(size: 120, color: AppTheme.secondaryColor.withOpacity(0.08)),
          ),
        ],
      ),
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
        borderRadius: BorderRadius.circular(size * 0.42),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.84),
            const Color(0xFFE8FAF7).withOpacity(0.72),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.75), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3CACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFC0392B), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFC0392B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

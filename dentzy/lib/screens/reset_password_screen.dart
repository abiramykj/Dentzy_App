import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/dentzy_logo.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _isSubmitting = false;

  String? _errorMessage;
  String? _confirmError;

  bool _hasMinLength(String value) => value.length >= 8;
  bool _hasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);
  bool _hasLowercase(String value) => RegExp(r'[a-z]').hasMatch(value);
  bool _hasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);
  bool _hasSpecial(String value) => RegExp(r'[^A-Za-z0-9]').hasMatch(value);

  bool _isStrongPassword(String value) {
    return _hasMinLength(value) &&
        _hasUppercase(value) &&
        _hasLowercase(value) &&
        _hasNumber(value) &&
        _hasSpecial(value);
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
    _entranceController.forward();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final confirm = _confirmPasswordController.text;
    final password = _newPasswordController.text;
    final mismatch = confirm.isNotEmpty && confirm != password;
    setState(() {
      _confirmError = mismatch ? AppLocalizations.of(context)!.authPasswordsDoNotMatch : null;
      if (_errorMessage != null) {
        _errorMessage = null;
      }
    });
  }

  Future<void> _resetPassword() async {
    final loc = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final password = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    setState(() {
      _errorMessage = null;
      _confirmError = null;
    });

    if (password.isEmpty || confirm.isEmpty) {
      setState(() {
        _errorMessage = loc.authFillAllFields;
      });
      return;
    }

    if (!_isStrongPassword(password)) {
      setState(() {
        _errorMessage = loc.authWeakPassword;
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _confirmError = loc.authPasswordsDoNotMatch;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.initialize();
      final result = await AuthService.resetPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: password,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorMessage = result.success ? null : result.message;
      });

      if (!result.success) return;

      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'success',
        barrierColor: Colors.black.withOpacity(0.26),
        transitionDuration: const Duration(milliseconds: 280),
        pageBuilder: (dialogContext, _, __) {
          return _ResetSuccessDialog(
            title: loc.success,
            message: loc.authPasswordResetSuccess,
            cta: loc.ok,
          );
        },
        transitionBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.86, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          );
        },
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = loc.authSomethingWentWrong;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final password = _newPasswordController.text;

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
                        loc.authResetPasswordTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.authResetPasswordSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 20),
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _newPasswordController,
                              obscureText: !_showNewPassword,
                              decoration: InputDecoration(
                                hintText: loc.authNewPasswordHint,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showNewPassword = !_showNewPassword;
                                    });
                                  },
                                  child: Text(_showNewPassword ? loc.loginHidePassword : loc.loginShowPassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: !_showConfirmPassword,
                              decoration: InputDecoration(
                                hintText: loc.authConfirmPasswordHint,
                                errorText: _confirmError,
                                prefixIcon: const Icon(Icons.verified_user_outlined),
                                suffixIcon: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showConfirmPassword = !_showConfirmPassword;
                                    });
                                  },
                                  child: Text(
                                    _showConfirmPassword ? loc.loginHidePassword : loc.loginShowPassword,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _PasswordChecklist(
                              minLength: _hasMinLength(password),
                              uppercase: _hasUppercase(password),
                              lowercase: _hasLowercase(password),
                              number: _hasNumber(password),
                              special: _hasSpecial(password),
                              loc: loc,
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
                              _InlineError(message: _errorMessage!),
                            ],
                            const SizedBox(height: 14),
                            ElevatedButton(
                              onPressed: _isSubmitting ? null : _resetPassword,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                    )
                                  : Text(loc.authResetPasswordButton),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
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

class _PasswordChecklist extends StatelessWidget {
  final bool minLength;
  final bool uppercase;
  final bool lowercase;
  final bool number;
  final bool special;
  final AppLocalizations loc;

  const _PasswordChecklist({
    required this.minLength,
    required this.uppercase,
    required this.lowercase,
    required this.number,
    required this.special,
    required this.loc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Column(
        children: [
          _ChecklistItem(ok: minLength, label: loc.authRuleMinChars),
          _ChecklistItem(ok: uppercase, label: loc.authRuleUppercase),
          _ChecklistItem(ok: lowercase, label: loc.authRuleLowercase),
          _ChecklistItem(ok: number, label: loc.authRuleNumber),
          _ChecklistItem(ok: special, label: loc.authRuleSpecial),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final bool ok;
  final String label;

  const _ChecklistItem({required this.ok, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = ok ? const Color(0xFF27AE60) : const Color(0xFFD64545);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle_rounded : Icons.cancel_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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

class _ResetSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cta;

  const _ResetSuccessDialog({
    required this.title,
    required this.message,
    required this.cta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 26),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.95),
                const Color(0xFFE8FAF3).withOpacity(0.92),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.9)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF27AE60).withOpacity(0.16),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x1F27AE60),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF27AE60),
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(cta),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

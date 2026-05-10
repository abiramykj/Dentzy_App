import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../utils/theme.dart';
import '../widgets/dentzy_logo.dart';

class SignUpScreen extends StatefulWidget {
  final ValueChanged<bool> onAccountCreated;
  final VoidCallback onBackToLogin;

  const SignUpScreen({
    super.key,
    required this.onAccountCreated,
    required this.onBackToLogin,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isSubmitting = false;

  String? _errorMessage;
  String? _emailError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
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

    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    final confirm = _confirmPasswordController.text;
    final password = _passwordController.text;
    final mismatch = confirm.isNotEmpty && confirm != password;
    setState(() {
      _confirmPasswordError = mismatch ? 'Passwords do not match' : null;
    });
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
  }

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

  Future<void> _createAccount() async {
    final loc = AppLocalizations.of(context)!;
    FocusScope.of(context).unfocus();

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    setState(() {
      _errorMessage = null;
      _emailError = null;
      _confirmPasswordError = null;
    });

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() {
        _errorMessage = loc.authFillAllFields;
      });
      return;
    }

    if (!_isEmailValid(email)) {
      setState(() {
        _emailError = loc.authInvalidEmail;
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
        _confirmPasswordError = loc.authPasswordsDoNotMatch;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AuthService.initialize();
      final result = await AuthService.signUp(
        fullName: fullName,
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _errorMessage = result.success ? null : result.message;
      });

      if (result.success) {
        widget.onAccountCreated(result.requiresLanguageSelection);
      }
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
    final password = _passwordController.text;

    return Scaffold(
      body: Stack(
        children: [
          const _SignUpBackdrop(),
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
                      const SizedBox(height: 16),
                      Text(
                        loc.authCreateAccount,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.authCreateAccountSubtitle,
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
                              controller: _fullNameController,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: loc.authFullNameHint,
                                prefixIcon: const Icon(Icons.badge_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onChanged: (_) {
                                if (_emailError != null) {
                                  setState(() {
                                    _emailError = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText: loc.loginEmailHint,
                                errorText: _emailError,
                                prefixIcon: const Icon(Icons.mail_outline_rounded),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordController,
                              obscureText: !_showPassword,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: loc.loginPasswordHint,
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showPassword = !_showPassword;
                                    });
                                  },
                                  child: Text(_showPassword ? loc.loginHidePassword : loc.loginShowPassword),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: !_showConfirmPassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: loc.authConfirmPasswordHint,
                                errorText: _confirmPasswordError,
                                prefixIcon: const Icon(Icons.verified_user_outlined),
                                suffixIcon: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showConfirmPassword = !_showConfirmPassword;
                                    });
                                  },
                                  child: Text(_showConfirmPassword ? loc.loginHidePassword : loc.loginShowPassword),
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
                              onPressed: _isSubmitting ? null : _createAccount,
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
                                  : Text(loc.authCreateAccountButton),
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: _isSubmitting ? null : widget.onBackToLogin,
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

class _SignUpBackdrop extends StatelessWidget {
  const _SignUpBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDFEFE), Color(0xFFEDF9F7)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: _Blob(size: 220, color: AppTheme.secondaryColor.withOpacity(0.1)),
          ),
          Positioned(
            top: 220,
            right: -40,
            child: _Blob(size: 140, color: AppTheme.accentColor.withOpacity(0.12)),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: _Blob(size: 200, color: AppTheme.primaryColor.withOpacity(0.12)),
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
        borderRadius: BorderRadius.circular(size * 0.45),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.86),
            const Color(0xFFE8FAF7).withOpacity(0.74),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white.withOpacity(0.74)),
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

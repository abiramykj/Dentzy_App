import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';
import '../services/language_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageScreen extends StatefulWidget {
  final LanguageProvider languageProvider;
  final Function(String) onLanguageSelected;

  const LanguageScreen({
    super.key,
    required this.languageProvider,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> with TickerProviderStateMixin {
  String? selectedLang;
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  // Do NOT preselect any language - start with null
  // @override
  // void initState() {
  //   super.initState();
  //   selectedLang = widget.languageProvider.currentLanguageCode;
  // }

  /// Validate and save language
  Future<void> _handleContinue() async {
    debugPrint('🎬 [LanguageScreen._handleContinue] START');
    
    if (selectedLang == null) {
      debugPrint('❌ [LanguageScreen._handleContinue] No language selected');
      _showErrorSnackBar('Please select a language');
      return;
    }

    debugPrint('✓ [LanguageScreen._handleContinue] Language selected: $selectedLang');
    setState(() => _isLoading = true);
    debugPrint('⏳ [LanguageScreen._handleContinue] Loading state set to true');

    try {
      debugPrint('💾 [LanguageScreen._handleContinue] Calling setLanguage...');
      final success = await widget.languageProvider.setLanguage(selectedLang!);
      debugPrint('📊 [LanguageScreen._handleContinue] setLanguage returned: $success');

      if (!mounted) {
        debugPrint('⚠️  [LanguageScreen._handleContinue] Widget not mounted, aborting');
        return;
      }

      if (!success) {
        debugPrint('❌ [LanguageScreen._handleContinue] Save failed (returned false)');
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to save language preference');
        return;
      }

      setState(() => _isLoading = false);
      debugPrint('✅ [LanguageScreen._handleContinue] Language saved, calling onLanguageSelected...');
      
      // Navigate only after language save completes successfully
      widget.onLanguageSelected(selectedLang!);
      debugPrint('✅ [LanguageScreen._handleContinue] onLanguageSelected callback invoked');
    } catch (e) {
      debugPrint('❌ [LanguageScreen._handleContinue] EXCEPTION CAUGHT: $e');
      
      if (!mounted) {
        debugPrint('⚠️  [LanguageScreen._handleContinue] Widget not mounted after error');
        return;
      }

      setState(() => _isLoading = false);
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Floating decorative backdrop
          const _DecorativeBackdrop(),
          
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: FadeTransition(
                opacity: _fadeController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Hero Illustration Section
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE9FBF7), Color(0xFFDFF6F4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Floating animation icons
                            Positioned(
                              top: 20,
                              left: 30,
                              child: AnimatedBuilder(
                                animation: _floatController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _floatController.value * 8 - 4),
                                    child: Icon(
                                      Icons.sentiment_very_satisfied_rounded,
                                      size: 48,
                                      color: AppTheme.primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 25,
                              right: 30,
                              child: AnimatedBuilder(
                                animation: _floatController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, -((_floatController.value * 8 - 4))),
                                    child: Icon(
                                      Icons.brush_rounded,
                                      size: 44,
                                      color: AppTheme.accentColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Center sparkle icon
                            Icon(
                              Icons.auto_awesome,
                              size: 52,
                              color: AppTheme.primaryColor.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Heading
                      Text(
                        loc.selectLanguage,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Choose your preferred language for a personalized dental experience.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // Language Cards (Horizontal)
                      Row(
                        children: () {
                          final cards = <Widget>[];
                          final languages =
                              AppConstants.supportedLanguages.entries
                                  .toList();
                          
                          for (int i = 0; i < languages.length; i++) {
                            final language = languages[i];
                            final isSelected =
                                selectedLang == language.key;
                            final displayName = language.key == 'ta'
                                ? loc.tamil
                                : loc.english;

                            cards.add(
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedLang = language.key;
                                      widget.languageProvider
                                          .setLocaleOnly(
                                              language.key);
                                    });
                                  },
                                  child: AnimatedScale(
                                    scale:
                                        isSelected ? 1.05 : 1.0,
                                    duration: const Duration(
                                        milliseconds: 200),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? const LinearGradient(
                                                colors: [
                                                  Color(
                                                      0xFFBDF5EA),
                                                  Color(
                                                      0xFF8ED9D1),
                                                ],
                                                begin: Alignment
                                                    .topLeft,
                                                end: Alignment
                                                    .bottomRight,
                                              )
                                            : null,
                                        color: isSelected
                                            ? null
                                            : Colors.white
                                                .withOpacity(0.6),
                                        borderRadius:
                                            BorderRadius.circular(
                                                24),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors
                                                  .transparent
                                              : Colors.grey[300]!,
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          if (isSelected)
                                            BoxShadow(
                                              color: AppTheme
                                                  .primaryColor
                                                  .withOpacity(
                                                      0.25),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                              offset:
                                                  const Offset(
                                                      0, 8),
                                            ),
                                          if (!isSelected)
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(
                                                      0.06),
                                              blurRadius: 12,
                                              offset:
                                                  const Offset(
                                                      0, 4),
                                            ),
                                        ],
                                      ),
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                              vertical: 24,
                                              horizontal: 12),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Icon(
                                            Icons
                                                .language_rounded,
                                            size: 40,
                                            color: isSelected
                                                ? Colors.white
                                                : AppTheme
                                                    .primaryColor,
                                          ),
                                          const SizedBox(
                                              height: 12),
                                          Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.w700,
                                              color: isSelected
                                                  ? Colors.white
                                                  : AppTheme
                                                      .textPrimary,
                                            ),
                                            textAlign:
                                                TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );

                            // Add spacing between cards
                            if (i < languages.length - 1) {
                              cards.add(const SizedBox(width: 12));
                            }
                          }

                          return cards;
                        }(),
                      ),

                      const SizedBox(height: 36),

                      // Feature Highlight Chips
                      Text(
                        'Key Features',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),

                      const SizedBox(height: 14),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildFeatureChip(
                              Icons.auto_awesome,
                              'Myth Checker',
                              AppTheme.primaryColor),
                          _buildFeatureChip(Icons.brush_rounded,
                              'Brushing Tracker', AppTheme.accentColor),
                          _buildFeatureChip(Icons.lightbulb_rounded,
                              'Dental Tips', AppTheme.successColor),
                          _buildFeatureChip(Icons.analytics_rounded,
                              'Progress Tracking', AppTheme.primaryDark),
                        ],
                      ),

                      const SizedBox(height: 36),

                      // Continue Button with Gradient
                      Material(
                        child: InkWell(
                          onTap: (selectedLang == null || _isLoading)
                              ? null
                              : _handleContinue,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: (selectedLang == null ||
                                      _isLoading)
                                  ? LinearGradient(
                                      colors: [
                                        Colors.grey[400]!,
                                        Colors.grey[300]!,
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFFBDF5EA),
                                        Color(0xFF8ED9D1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                if (selectedLang != null &&
                                    !_isLoading)
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16),
                            child: Center(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  if (!_isLoading) ...[
                                    Text(
                                      loc.continueBtn,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons
                                          .arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ] else ...[
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<
                                                Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Saving...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
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

  Widget _buildFeatureChip(IconData icon, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeBackdrop extends StatelessWidget {
  const _DecorativeBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8FCFC), Color(0xFFF3FBFA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // Top-right floating blob
          Positioned(
            top: -50,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryLight.withOpacity(0.16),
              ),
            ),
          ),
          // Bottom-left floating blob
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentColor.withOpacity(0.12),
              ),
            ),
          ),
          // Center-bottom soft circle
          Positioned(
            bottom: 100,
            right: 50,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryLight.withOpacity(0.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

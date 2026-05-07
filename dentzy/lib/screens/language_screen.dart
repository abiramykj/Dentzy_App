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

class _LanguageScreenState extends State<LanguageScreen> {
  String? selectedLang;
  bool _isLoading = false;

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                loc.selectLanguage,
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: AppConstants.supportedLanguages.length,
                itemBuilder: (context, index) {
                  final language = AppConstants.supportedLanguages.entries.toList()[index];
                  final isSelected = selectedLang == language.key;
                  
                  // Get localized language name
                  String displayName = language.key == 'ta' ? loc.tamil : loc.english;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLang = language.key;
                        // Update locale immediately for instant UI change
                        widget.languageProvider.setLocaleOnly(language.key);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.primaryGradient : null,
                        color: isSelected ? null : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.dividerColor,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.language,
                            size: 32,
                            color: isSelected
                                ? Colors.white
                                : AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                // Disable Continue until language is selected
                onPressed: (selectedLang == null || _isLoading) 
                    ? null 
                    : _handleContinue,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.arrow_forward),
                label: Text(
                  _isLoading 
                      ? 'Saving...' 
                      : (selectedLang == null 
                          ? loc.continueBtn  
                          : loc.continueBtn),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // Visual feedback for disabled state
                  backgroundColor: selectedLang == null
                      ? Colors.grey
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

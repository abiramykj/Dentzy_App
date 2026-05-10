import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../utils/theme.dart';
import 'session_manager.dart';

class AppTourService {
  static late SharedPreferences _prefs;
  static const String _tourSeenSuffix = 'tour_seen';
  
  static Future<void> initialize() async {
    try {
      debugPrint('🎯 [AppTourService] Initializing...');
      _prefs = await SharedPreferences.getInstance();
      debugPrint('✅ [AppTourService] SharedPreferences loaded');
    } catch (e) {
      debugPrint('❌ [AppTourService] Initialize error: $e');
      rethrow;
    }
  }

  static Future<bool> hasSeenTour() async {
    try {
      final email = AuthSessionService.instance.currentLoggedInUserEmail;
      if (email == null || email.isEmpty) {
        return false;
      }

      final key = AuthSessionService.userScopedKey(email, _tourSeenSuffix);
      debugPrint('[STORAGE] Loading key=$key');
      return _prefs.getBool(key) ?? false;
    } catch (e) {
      debugPrint('❌ [AppTourService] hasSeenTour error: $e');
      return true; // Default to true to skip tour if error
    }
  }

  static Future<void> markTourAsSeen() async {
    try {
      final email = AuthSessionService.instance.currentLoggedInUserEmail;
      if (email == null || email.isEmpty) {
        return;
      }

      final key = AuthSessionService.userScopedKey(email, _tourSeenSuffix);
      debugPrint('[STORAGE] Saving key=$key');
      await _prefs.setBool(key, true);
    } catch (e) {
      debugPrint('❌ [AppTourService] markTourAsSeen error: $e');
    }
  }

  static Future<void> resetTour() async {
    try {
      final email = AuthSessionService.instance.currentLoggedInUserEmail;
      if (email == null || email.isEmpty) {
        return;
      }

      final key = AuthSessionService.userScopedKey(email, _tourSeenSuffix);
      debugPrint('[STORAGE] Saving key=$key');
      await _prefs.setBool(key, false);
    } catch (e) {
      debugPrint('❌ [AppTourService] resetTour error: $e');
    }
  }

  static Future<void> showAppTour(BuildContext context) async {
    try {
      final loc = AppLocalizations.of(context)!;
      
      final steps = [
        _TourStep(
          icon: Icons.waving_hand_rounded,
          title: loc.tourWelcomeTitle,
          description: loc.tourWelcomeDescription,
          color: AppTheme.primaryColor,
        ),
        _TourStep(
          icon: Icons.auto_fix_high_rounded,
          title: loc.tourMythCheckerTitle,
          description: loc.tourMythCheckerDescription,
          color: AppTheme.primaryColor,
        ),
        _TourStep(
          icon: Icons.brush_rounded,
          title: loc.tourBrushingTrackerTitle,
          description: loc.tourBrushingTrackerDescription,
          color: AppTheme.successColor,
        ),
      ];

      if (!context.mounted) return;
      
      await _showTourStep(context, steps, 0, loc);
      await markTourAsSeen();
    } catch (e) {
      debugPrint('❌ [AppTourService] showAppTour error: $e');
    }
  }

  static Future<void> _showTourStep(
    BuildContext context,
    List<_TourStep> steps,
    int currentIndex,
    AppLocalizations loc,
  ) async {
    if (currentIndex >= steps.length) return;
    if (!context.mounted) return;

    final step = steps[currentIndex];
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TourStepDialog(
        step: step,
        currentStep: currentIndex + 1,
        totalSteps: steps.length,
        onNext: () async {
          Navigator.pop(context);
          await _showTourStep(context, steps, currentIndex + 1, loc);
        },
        onPrevious: currentIndex > 0
            ? () async {
                Navigator.pop(context);
                await _showTourStep(context, steps, currentIndex - 1, loc);
              }
            : null,
        onSkip: () {
          Navigator.pop(context);
        },
        loc: loc,
      ),
    );
  }
}

class _TourStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isLastStep;

  _TourStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isLastStep = false,
  });
}

class _TourStepDialog extends StatefulWidget {
  final _TourStep step;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onSkip;
  final AppLocalizations loc;

  const _TourStepDialog({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    this.onPrevious,
    required this.onSkip,
    required this.loc,
  });

  @override
  State<_TourStepDialog> createState() => _TourStepDialogState();
}

class _TourStepDialogState extends State<_TourStepDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  spreadRadius: 5,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.step.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${widget.currentStep} / ${widget.totalSteps}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: widget.step.color,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onSkip,
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.grey[400],
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            widget.step.color.withOpacity(0.2),
                            widget.step.color.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          widget.step.icon,
                          size: 44,
                          color: widget.step.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      widget.step.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      widget.step.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value:
                            widget.currentStep / widget.totalSteps,
                        minHeight: 6,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.step.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        if (widget.onPrevious != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onPrevious,
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                              ),
                              label: Text(
                                widget.loc.tourPrevious,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        if (widget.onPrevious != null) const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: widget.step.color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              widget.step.isLastStep
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                            ),
                            label: Text(
                              widget.step.isLastStep
                                  ? widget.loc.tourFinish
                                  : widget.loc.tourNext,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/myth_item.dart';
import '../widgets/custom_card.dart';
import '../services/myth_api_service.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

class ResultScreen extends StatefulWidget {
  final String inputText;
  final MythCheckResult? preloadedResult;

  const ResultScreen({
    super.key,
    required this.inputText,
    this.preloadedResult,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool isLoading = true;
  Map<String, dynamic>? result;
  final MythApiService _apiService = MythApiService();

  @override
  void initState() {
    super.initState();
    // If result was preloaded, use it immediately without API call
    if (widget.preloadedResult != null) {
      _setResultFromPreloaded(widget.preloadedResult!);
    } else {
      // Only fetch from API if result wasn't preloaded
      fetchResult();
    }
  }

  void _setResultFromPreloaded(MythCheckResult mythResult) {
    setState(() {
      result = {
        'type': mythResult.label.toLowerCase().replaceAll(' ', '_'),
        'explanation': mythResult.explanation,
        'tip': mythResult.reason,
      };
      isLoading = false;
    });
  }

  Future<void> fetchResult() async {
    setState(() {
      isLoading = true;
    });

    try {
      final mythResult = await _apiService.classifyStatement(widget.inputText);
      if (!mounted) {
        return;
      }

      setState(() {
        result = {
          'type': mythResult.label.toLowerCase().replaceAll(' ', '_'),
          'explanation': mythResult.explanation,
          'tip': mythResult.reason,
        };
        isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
        result = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.error ?? 'Error')),
      );
    }
  }

  String _resultTitle(String? type) {
    switch (type) {
      case 'myth':
        return '❌ Myth';
      case 'fact':
        return '✅ Fact';
      case 'not_dental':
        return '⚠️ Not Dental';
      default:
        return 'Result';
    }
  }

  String _resultSubtitle(String? type) {
    switch (type) {
      case 'myth':
        return 'This statement is a myth.';
      case 'fact':
        return 'This statement is a fact.';
      case 'not_dental':
        return 'This statement is not about dental health.';
      default:
        return 'We could not classify this statement.';
    }
  }

  IconData _resultIcon(String? type) {
    switch (type) {
      case 'myth':
        return Icons.cancel;
      case 'fact':
        return Icons.check_circle;
      case 'not_dental':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }

  LinearGradient _resultGradient(String? type) {
    switch (type) {
      case 'fact':
        return const LinearGradient(
          colors: [Color(0xFF36B37E), Color(0xFF8AE3B8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'not_dental':
        return LinearGradient(
          colors: [
            Colors.grey[350]!,
            Colors.grey[500]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'myth':
      default:
        return LinearGradient(
          colors: [
            const Color(0xFFE76F7A),
            const Color(0xFFF09AA3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _resultTitleColor(String? type) {
    switch (type) {
      case 'fact':
        return AppTheme.successColor;
      case 'not_dental':
        return Colors.grey[700]!;
      case 'myth':
      default:
        return AppTheme.errorColor;
    }
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  Map<String, Color> _resultPalette(String? type) {
    switch (type) {
      case 'fact':
        return {
          'color': AppTheme.successColor,
          'soft': const Color(0xFFE8FAF1),
        };
      case 'myth':
        return {
          'color': AppTheme.errorColor,
          'soft': const Color(0xFFFDECEF),
        };
      case 'not_dental':
      default:
        return {
          'color': Colors.grey,
          'soft': const Color(0xFFF2F5F5),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          const _ResultBackdrop(),
          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    child: result == null
                        ? _buildErrorContent(context)
                        : _buildResultContent(context),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFFDECEF), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MiniStatusPill(
                icon: Icons.report_problem_rounded,
                label: loc.resultUnavailable,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 14),
              Text(
                loc.error,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.retry,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          label: Text(loc.checkAnotherStatement),
        ),
      ],
    );
  }

  Widget _buildResultContent(BuildContext context) {
    final String? type = (result?['type'] as String?)?.toLowerCase();
    final loc = AppLocalizations.of(context)!;
    final String explanationText = _firstNonEmpty([
          result?['explanation_ta'] as String?,
          result?['explanation'] as String?,
        ]) ??
      loc.noExplanationAvailable;
    final String? tipText = type == 'myth'
        ? _firstNonEmpty([
            result?['recommended_action_ta'] as String?,
            result?['tip'] as String?,
          ])
        : null;

    final palette = _resultPalette(type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(20),
          gradient: _resultGradient(type),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.28),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      _resultIcon(type),
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _resultTitle(type),
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _resultSubtitle(type),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Confidence ${result!['confidence'] ?? 0}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.myProfile ?? 'Your Statement', // TODO: choose better key or add new one
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(widget.inputText, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(18),
          gradient: const LinearGradient(
            colors: [Color(0xFFEFF9F7), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_rounded, color: palette['color']),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)?.educationalContent ?? 'Explanation', // TODO: add proper key
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(explanationText, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        if (type == 'myth' && tipText != null) ...[
          const SizedBox(height: 16),
          CustomCard(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(18),
            gradient: const LinearGradient(
              colors: [Color(0xFFF7FBFF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_rounded, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)?.brushingTips ?? 'Care tip', // TODO: add proper key
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(tipText, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(AppLocalizations.of(context)?.retry ?? 'Check another statement'),
        ),
      ],
    );
  }

}

class _ResultBackdrop extends StatelessWidget {
  const _ResultBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7FCFB), Color(0xFFF1F8F8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: _BackdropOrb(color: AppTheme.primaryLight.withOpacity(0.18)),
          ),
          Positioned(
            left: -60,
            top: 140,
            child: _BackdropOrb(color: AppTheme.secondaryLight.withOpacity(0.18), size: 160),
          ),
        ],
      ),
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _BackdropOrb({required this.color, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _MiniStatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniStatusPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

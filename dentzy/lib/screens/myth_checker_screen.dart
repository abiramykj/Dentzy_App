import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/myth_item.dart';
import '../services/myth_api_service.dart';
import '../utils/theme.dart';
import '../widgets/custom_card.dart';

class MythCheckerScreen extends StatefulWidget {
  const MythCheckerScreen({super.key});

  @override
  State<MythCheckerScreen> createState() => _MythCheckerScreenState();
}

class _MythCheckerScreenState extends State<MythCheckerScreen> {
  final TextEditingController _inputController = TextEditingController();
  final MythApiService _apiService = MythApiService();

  MythCheckResult? _result;
  bool _isChecking = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _checkInput() async {
    if (_isChecking) return;

    final input = _inputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.enterStatementToCheck)),
      );
      return;
    }

    setState(() {
      _isChecking = true;
      _result = null;
    });

    try {
      debugPrint('[MythCheckerScreen] request text="$input"');
      final result = await _apiService.classifyStatement(input);
      debugPrint(
        '[MythCheckerScreen] result label=${result.label} confidence=${result.confidence} category=${result.category} reason=${result.reason}',
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _isChecking = false;
      });

      // Save result to backend history
      await _apiService.saveMythHistory(
        statement: input,
        resultType: result.category,
        confidence: result.confidence,
        explanation: result.explanation,
      );
    } catch (_) {
      debugPrint('[MythCheckerScreen] classify failed, using fallback');
      if (!mounted) return;
      setState(() {
        _result = MythCheckResult(
          label: 'Not Dental',
          explanation: 'Unable to classify statement right now.',
          confidence: 0,
          category: 'NOT_DENTAL',
          reason: 'Unable to classify statement right now.',
        );
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.mythChecker),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _MiniStatusPill(
              icon: Icons.auto_awesome_rounded,
              label: 'AI',
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const _CheckerBackdrop(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(20),
                    gradient: AppTheme.cyanGradient,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _MiniStatusPill(
                                icon: Icons.medical_services_rounded,
                                label: loc.aiDentalScreening,
                                color: AppTheme.primaryDark,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                loc.scanMyths,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                loc.mythPremiumDescription,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.18),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.yourStatement,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _inputController,
                          enabled: !_isChecking,
                          maxLines: 4,
                          minLines: 3,
                          decoration: InputDecoration(
                            hintText: loc.statementExample,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isChecking ? null : _checkInput,
                            icon: _isChecking
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(Icons.search_rounded),
                            label: Text(_isChecking ? (AppLocalizations.of(context)?.loading ?? 'Analyzing...') : (AppLocalizations.of(context)?.mythChecker ?? 'Check statement')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _result == null
                        ? CustomCard(
                            key: const ValueKey('empty-result'),
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _MiniStatusPill(
                                  icon: Icons.auto_graph_rounded,
                                  label: loc.liveResult,
                                  color: AppTheme.secondaryDark,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  loc.resultsWillAppearHere,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  loc.tryDentalStatement,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          )
                        : _buildResultCard(context),
                  ),
                  const SizedBox(height: 18),
                  CustomCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF8FDFC), Color(0xFFEFF9F7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.whatAIchecksFirst,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(loc.dentalRelevance, loc.dentalRelevanceDesc),
                        const SizedBox(height: 10),
                        _buildInfoItem(loc.thenClassify, loc.thenClassifyDesc),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(BuildContext context) {
    final palette = _resultPalette(_result!.label);

    return CustomCard(
      key: ValueKey(_result!.label),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        colors: [palette['light']!, Colors.white],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette['color']!.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  _getResultIcon(_result!.label),
                  color: palette['color'],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _result!.label,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: palette['color'],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _result!.reason.isNotEmpty ? _result!.reason : 'AI classification result',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Confidence',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _result!.confidence / 100,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(palette['color']!),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_result!.confidence}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Explanation',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _result!.explanation,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (_result!.matchedText != null) ...[
            const SizedBox(height: 14),
            _miniInfoBox(
              context,
              title: 'Database match',
              body: _result!.matchedText!,
              icon: Icons.library_books_rounded,
            ),
          ],
          if (_result!.category.isNotEmpty) ...[
            const SizedBox(height: 14),
            _miniInfoBox(
              context,
              title: 'Category',
              body: _result!.category,
              icon: Icons.category_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Map<String, Color> _resultPalette(String label) {
    switch (_normalizeLabel(label)) {
      case 'fact':
        return {
          'color': AppTheme.successColor,
          'light': const Color(0xFFE8FAF1),
        };
      case 'myth':
        return {
          'color': AppTheme.errorColor,
          'light': const Color(0xFFFDECEF),
        };
      case 'not dental':
      default:
        return {
          'color': Colors.grey,
          'light': const Color(0xFFF2F5F5),
        };
    }
  }

  IconData _getResultIcon(String label) {
    switch (_normalizeLabel(label)) {
      case 'myth':
        return Icons.cancel_rounded;
      case 'fact':
        return Icons.verified_rounded;
      case 'not dental':
        return Icons.help_outline_rounded;
      default:
        return Icons.question_mark_rounded;
    }
  }

  Widget _buildInfoItem(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_outline, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _miniInfoBox(
    BuildContext context, {
    required String title,
    required String body,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeLabel(String label) => label.toLowerCase().replaceAll('_', ' ').trim();
}

class _CheckerBackdrop extends StatelessWidget {
  const _CheckerBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7FCFB), Color(0xFFF3FAF9)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: _BackdropOrb(color: AppTheme.primaryLight.withOpacity(0.16)),
          ),
          Positioned(
            left: -50,
            top: 180,
            child: _BackdropOrb(color: AppTheme.secondaryLight.withOpacity(0.18), size: 150),
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

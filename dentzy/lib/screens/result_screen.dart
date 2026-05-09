import 'package:flutter/material.dart';

import '../widgets/custom_card.dart';
import '../services/myth_api_service.dart';
import '../utils/theme.dart';

class ResultScreen extends StatefulWidget {
  final String inputText;

  const ResultScreen({
    super.key,
    required this.inputText,
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
    fetchResult();
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
        const SnackBar(content: Text('Failed to fetch result')),
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
        return AppTheme.successGradient;
      case 'not_dental':
        return LinearGradient(
          colors: [
            Colors.grey[400]!,
            Colors.grey[600]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'myth':
      default:
        return LinearGradient(
          colors: [
            Colors.red[400]!,
            Colors.red[600]!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: result == null
                      ? _buildErrorContent(context)
                      : _buildResultContent(context),
                ),
              ),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomCard(
          padding: const EdgeInsets.all(20),
          border: Border.all(
            color: AppTheme.errorColor,
            width: 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Result Unavailable',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We could not fetch the classification right now. Please try again.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Check Another Statement'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildResultContent(BuildContext context) {
    final String? type = (result?['type'] as String?)?.toLowerCase();
    final String explanationText = _firstNonEmpty([
          result?['explanation_ta'] as String?,
          result?['explanation'] as String?,
        ]) ??
        'No explanation available.';
    final String? tipText = type == 'myth'
        ? _firstNonEmpty([
            result?['recommended_action_ta'] as String?,
            result?['tip'] as String?,
          ])
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _resultGradient(type),
            ),
            child: Icon(
              _resultIcon(type),
              size: 60,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              Text(
                _resultTitle(type),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: _resultTitleColor(type),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _resultSubtitle(type),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        CustomCard(
          padding: const EdgeInsets.all(20),
          border: Border.all(
            color: AppTheme.dividerColor,
            width: 1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Statement',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.inputText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomCard(
          padding: const EdgeInsets.all(20),
          border: Border.all(
            color: AppTheme.accentColor,
            width: 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb, color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    'Explanation',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                explanationText,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        if (type == 'myth' && tipText != null) ...[
          const SizedBox(height: 16),
          CustomCard(
            padding: const EdgeInsets.all(20),
            border: Border.all(
              color: AppTheme.primaryColor,
              width: 1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Tip',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  tipText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          label: const Text('Check Another Statement'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

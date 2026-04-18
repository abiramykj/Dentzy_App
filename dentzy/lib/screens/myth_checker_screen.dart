import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';
import '../services/advanced_myth_checker.dart';
import '../models/myth_item.dart';

class MythCheckerScreen extends StatefulWidget {
  const MythCheckerScreen({super.key});

  @override
  State<MythCheckerScreen> createState() => _MythCheckerScreenState();
}

class _MythCheckerScreenState extends State<MythCheckerScreen> {
  final TextEditingController _inputController = TextEditingController();
  MythCheckResult? _result;
  bool _isChecking = false;
  bool _isDataLoaded = false;
  List<MythItem> _database = [];
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadDatasets();
  }

  /// Load datasets on init
  void _loadDatasets() async {
    try {
      final data = await MythDataLoader.loadAllDatasets();
      setState(() {
        _database = data;
        _isDataLoaded = true;
      });
    } catch (e) {
      setState(() {
        _loadError = 'Error loading datasets: $e';
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _checkInput() async {
    if (!_isDataLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading datasets... Please wait')),
      );
      return;
    }

    if (_inputController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a statement to check')),
      );
      return;
    }

    setState(() {
      _isChecking = true;
    });

    // Process with advanced myth checker
    Future.delayed(const Duration(milliseconds: 800), () async {
      final result = await AdvancedMythChecker.classify(
        _inputController.text.trim(),
        _database,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isChecking = false;
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    // Show loading if datasets not loaded
    if (!_isDataLoaded) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(loc.mythChecker),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text('Loading dental knowledge base...',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 8),
              if (_loadError != null)
                Text(_loadError!,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(loc.mythChecker),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header section
              Text(
                'Check Any Dental Statement',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter a dental statement to find out if it\'s a myth, fact, or not dental-related. Uses our comprehensive dental knowledge base.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Input section
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Statement',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText:
                            'E.g., "Brushing teeth twice daily prevents cavities"',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                      minLines: 2,
                      enabled: !_isChecking,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isChecking ? null : _checkInput,
                        icon: _isChecking
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                            AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                            : const Icon(Icons.check_circle),
                        label: Text(
                          _isChecking ? 'Analyzing...' : 'Check Statement',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Result section
              if (_result != null) ...[
                // Result card
                CustomCard(
                  padding: const EdgeInsets.all(20),
                  gradient: LinearGradient(
                    colors: [
                      _getResultColor(_result!.label).withOpacity(0.1),
                      _getResultColor(_result!.label).withOpacity(0.05),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Result badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _getResultColor(_result!.label),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getResultIcon(_result!.label),
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _result!.label.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category
                      if (_result!.category.isNotEmpty &&
                          _result!.category != 'Non-Dental' &&
                          _result!.category != 'Input Validation' &&
                          _result!.category != 'Unknown')
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Icon(Icons.label_outline,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                'Category: ${_result!.category}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Confidence score
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Text(
                              'Confidence: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: _result!.confidence / 100,
                                  minHeight: 6,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                    _getResultColor(_result!.label),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_result!.confidence}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Explanation
                      Text(
                        'Explanation',
                        style:
                        Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _getResultColor(_result!.label),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!.explanation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      // Matched text (if applicable)
                      if (_result!.matchedText != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Database Match',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _result!.matchedText!,
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Reason
                      if (_result!.reason.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Reason: ${_result!.reason}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _inputController.clear();
                    setState(() {
                      _result = null;
                    });
                  },
                  child: const Text('Check Another Statement'),
                ),
              ],

              const SizedBox(height: 24),

              // Information section
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How It Works',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      '1. Load Dataset',
                      'Loads myths and facts from comprehensive knowledge bases',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      '2. Text Normalization',
                      'Processes input (numbers, synonyms, stopwords)',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      '3. Dental Filter',
                      'Checks for dental-related keywords',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      '4. Priority Rules',
                      'Applies high-confidence pattern matching',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      '5. Similarity Matching',
                      'Compares with database using advanced algorithms',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      '6. Result Classification',
                      'Returns Myth, Fact, or Not Dental with confidence',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getResultColor(String label) {
    switch (label) {
      case 'Myth':
        return Colors.red;
      case 'Fact':
        return Colors.green;
      case 'Not Dental':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getResultIcon(String label) {
    switch (label) {
      case 'Myth':
        return Icons.warning_rounded;
      case 'Fact':
        return Icons.verified_rounded;
      case 'Not Dental':
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
          child: Icon(Icons.check_circle_outline,
              size: 18, color: AppTheme.primaryColor),
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
}

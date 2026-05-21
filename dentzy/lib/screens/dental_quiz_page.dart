import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../localization/quiz_assessment_data.dart';
import '../localization/quiz_assessment_localizations.dart';
import '../utils/theme.dart';
import '../widgets/custom_card.dart';

class DentalQuizPage extends StatefulWidget {
  const DentalQuizPage({super.key});

  @override
  State<DentalQuizPage> createState() => _DentalQuizPageState();
}

class _DentalQuizPageState extends State<DentalQuizPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final Map<String, dynamic> userData = {};
  final Map<int, String> answers = {};

  final List<QuizAssessmentQuestion> _questions = quizAssessmentQuestions;

  int _pageIndex = 0;
  int _currentQuestionIndex = 0;
  String? _selectedArea;
  String? _nameError;
  String? _ageError;
  int _totalScore = 0;
  String _categoryKey = 'category_good_oral_hygiene';
  String _riskKey = 'risk_low';
  String _motivationKey = 'motivation_low';
  Color _categoryColor = AppTheme.textSecondary;
  List<String> _weakAreas = [];
  List<Map<String, String>> _suggestions = [];

  int get _totalQuestions => _questions.length;

  QuizAssessmentLocalizations get _loc => QuizAssessmentLocalizations.of(context);

  QuizAssessmentQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  String? get _currentAnswerId => answers[_currentQuestionIndex];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = _loc;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: Text(loc.text('assessment_title'))),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _pageIndex == 0
              ? _buildDetailsPage(loc)
              : _pageIndex == 1
                  ? _buildQuestionPage(loc)
                  : _buildResultPage(loc),
        ),
      ),
    );
  }

  void _startAssessment() {
    final loc = _loc;
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    setState(() {
      _nameError = null;
      _ageError = null;
    });

    if (name.isEmpty) {
      setState(() {
        _nameError = loc.text('please_enter_name');
      });
      return;
    }

    if (age == null || age <= 0) {
      setState(() {
        _ageError = loc.text('please_enter_valid_age');
      });
      return;
    }

    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.text('please_select_area'))),
      );
      return;
    }

    userData['name'] = name;
    userData['age'] = age;
    userData['area'] = _selectedArea;

    setState(() {
      _pageIndex = 1;
      _currentQuestionIndex = 0;
    });
  }

  void _selectAnswer(String answerId) {
    setState(() {
      answers[_currentQuestionIndex] = answerId;
    });
  }

  void _goNext() {
    final loc = _loc;
    if (_currentAnswerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.text('please_select_option'))),
      );
      return;
    }

    if (_currentQuestionIndex == _totalQuestions - 1) {
      _finishAssessment();
      return;
    }

    setState(() {
      _currentQuestionIndex += 1;
    });
  }

  void _goPrevious() {
    if (_currentQuestionIndex == 0) {
      setState(() {
        _pageIndex = 0;
      });
      return;
    }

    setState(() {
      _currentQuestionIndex -= 1;
    });
  }

  void _finishAssessment() {
    int totalScore = 0;
    final weakAreas = <String>[];
    final suggestions = <Map<String, String>>[];
    final seenSuggestionKeys = <String>{};

    for (final entry in answers.entries) {
      final question = _questions[entry.key];
      final selectedOptionId = entry.value;
      final selectedOption = question.options.firstWhere((option) => option.id == selectedOptionId);
      totalScore += selectedOption.score;

      final feedback = question.feedbackByOptionId[selectedOptionId];
      if (selectedOption.score <= 2 && feedback != null) {
        final suggestionKey = '${question.id}|$selectedOptionId';
        if (seenSuggestionKeys.add(suggestionKey)) {
          weakAreas.add(_buildWeakAreaLabel(question.id, selectedOptionId));
          suggestions.add({
            'title': _loc.text(question.categoryKey),
            'issue': _loc.text(feedback.issueKey),
            'detail': _loc.text(feedback.detailKey),
            'solution': _loc.text(feedback.solutionKey),
          });
        }
      }
    }

    suggestions.addAll(_buildGeneralSuggestions(totalScore));

    final categoryData = _resolveCategory(totalScore);

    setState(() {
      _totalScore = totalScore;
      _weakAreas = weakAreas;
      _suggestions = suggestions;
      _categoryKey = categoryData.$1;
      _categoryColor = categoryData.$2;
      _riskKey = categoryData.$3;
      _motivationKey = categoryData.$4;
      _pageIndex = 2;
    });
  }

  (String, Color, String, String) _resolveCategory(int totalScore) {
    if (totalScore >= 40) {
      return ('category_good_oral_hygiene', AppTheme.successColor, 'risk_low', 'motivation_low');
    }

    if (totalScore >= 25) {
      return ('category_average', AppTheme.warningColor, 'risk_medium', 'motivation_medium');
    }

    return ('category_needs_improvement', AppTheme.errorColor, 'risk_high', 'motivation_high');
  }

  List<Map<String, String>> _buildGeneralSuggestions(int totalScore) {
    if (totalScore >= 40) {
      return [
        {
          'title': _loc.text('recommendation_maintenance_title'),
          'issue': _loc.text('recommendation_maintenance_issue'),
          'detail': _loc.text('recommendation_maintenance_detail'),
          'solution': _loc.text('recommendation_maintenance_solution'),
        },
      ];
    }

    if (totalScore >= 25) {
      return [
        {
          'title': _loc.text('recommendation_routine_title'),
          'issue': _loc.text('recommendation_routine_issue'),
          'detail': _loc.text('recommendation_routine_detail'),
          'solution': _loc.text('recommendation_routine_solution'),
        },
      ];
    }

    return [
      {
        'title': _loc.text('recommendation_urgent_title'),
        'issue': _loc.text('recommendation_urgent_issue'),
        'detail': _loc.text('recommendation_urgent_detail'),
        'solution': _loc.text('recommendation_urgent_solution'),
      },
    ];
  }

  String _buildWeakAreaLabel(String questionId, String answerId) {
    final labelKey = switch (questionId) {
      'brushing_frequency' => 'label_brushing_habit',
      'cleaning_method' => 'label_cleaning_method',
      'between_teeth_cleaning' => 'label_flossing_habit',
      'dental_visits' => 'label_dental_visits',
      'sugar_exposure' => 'label_sugar_intake',
      'night_brushing' => 'label_night_brushing',
      'toothbrush_care' => 'label_toothbrush_replacement',
      'mouthwash_use' => 'label_mouthwash_habit',
      'after_meal_care' => 'label_after_meal_care',
      'tobacco_exposure' => 'label_tobacco_habit',
      _ => 'problem_label',
    };

    return '${_loc.text(labelKey)}: ${_optionTextFor(questionId, answerId)}';
  }

  String _optionTextFor(String questionId, String answerId) {
    final question = _questions.firstWhere((item) => item.id == questionId);
    final option = question.options.firstWhere((item) => item.id == answerId);
    return _loc.text(option.textKey);
  }

  Widget _buildDetailsPage(QuizAssessmentLocalizations loc) {
    return SingleChildScrollView(
      key: const ValueKey('details'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            gradient: AppTheme.primaryGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.health_and_safety, color: Colors.white, size: 36),
                const SizedBox(height: 16),
                Text(
                  loc.text('assessment_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.text('assessment_description'),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.text('user_details'), style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: loc.text('name_label'),
                    prefixIcon: const Icon(Icons.person_outline),
                    errorText: _nameError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: loc.text('age_label'),
                    prefixIcon: const Icon(Icons.cake_outlined),
                    errorText: _ageError,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedArea,
                  decoration: InputDecoration(
                    labelText: loc.text('area_label'),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  items: [
                    DropdownMenuItem(value: 'urban', child: Text(loc.text('urban'))),
                    DropdownMenuItem(value: 'rural', child: Text(loc.text('rural'))),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedArea = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startAssessment,
              icon: const Icon(Icons.play_arrow),
              label: Text(loc.text('start_assessment')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(QuizAssessmentLocalizations loc) {
    final progress = (_currentQuestionIndex + 1) / _totalQuestions;

    return SingleChildScrollView(
      key: const ValueKey('questions'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.questionNumber(_currentQuestionIndex + 1, _totalQuestions),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      backgroundColor: const Color.fromRGBO(44, 185, 168, 0.1),
                      foregroundColor: AppTheme.primaryColor,
                      child: Text('${_currentQuestionIndex + 1}'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  loc.text(_currentQuestion.questionKey),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                RadioGroup<String>(
                  groupValue: _currentAnswerId,
                  onChanged: (value) {
                    if (value != null) {
                      _selectAnswer(value);
                    }
                  },
                  child: Column(
                    children: _currentQuestion.options.map((option) {
                      final selected = _currentAnswerId == option.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CustomCard(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.zero,
                          border: Border.all(
                            color: selected ? AppTheme.primaryColor : AppTheme.dividerColor,
                            width: selected ? 2 : 1,
                          ),
                          child: RadioListTile<String>(
                            value: option.id,
                            title: Text(
                              loc.text(option.textKey),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goPrevious,
                  child: Text(loc.text('previous')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _goNext,
                  child: Text(
                    _currentQuestionIndex == _totalQuestions - 1
                        ? loc.text('view_result')
                        : loc.text('next'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultPage(QuizAssessmentLocalizations loc) {
    final maxScore = _totalQuestions * 5;
    final name = userData['name'] as String? ?? loc.text('name_fallback');
    final areaKey = userData['area'] as String? ?? 'urban';

    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            gradient: LinearGradient(
              colors: [
                _categoryColor,
                _categoryColor.withValues(alpha: 0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _categoryColor == AppTheme.successColor
                      ? Icons.verified
                      : _categoryColor == AppTheme.warningColor
                          ? Icons.warning_amber_rounded
                          : Icons.health_and_safety,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.scoreLine(_totalScore, maxScore),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  loc.categoryLine(_categoryKey),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.text('result_summary_title'), style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                _buildSummaryRow(loc.text('name_label'), name),
                _buildSummaryRow(loc.text('age_label'), '${userData['age']}'),
                _buildSummaryRow(loc.text('area_label'), loc.text(areaKey)),
                _buildSummaryRow(loc.text('total_questions_label'), '$_totalQuestions'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.text('risk_level_title'),
                        style: Theme.of(context).textTheme.headlineSmall,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  loc.text(_riskKey),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.text(_motivationKey),
                  style: Theme.of(context).textTheme.bodyLarge,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.report_problem, color: AppTheme.warningColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.text('areas_to_improve'),
                        style: Theme.of(context).textTheme.headlineSmall,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_weakAreas.isEmpty)
                  Text(loc.text('no_major_weak_habits'), style: const TextStyle(fontSize: 14))
                else
                  ..._weakAreas.map(
                    (weakArea) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.remove_circle, color: AppTheme.errorColor, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              weakArea,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.text('recommendations_title'),
                        style: Theme.of(context).textTheme.headlineSmall,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ..._suggestions.map((suggestion) => _buildSuggestionCard(loc, suggestion)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.text('motivational_message_title'),
                        style: Theme.of(context).textTheme.headlineSmall,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  loc.text(_motivationKey),
                  style: Theme.of(context).textTheme.bodyLarge,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _exportPdfReport,
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: Text(loc.text('export_pdf')),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetAssessment,
              icon: const Icon(Icons.refresh),
              label: Text(loc.text('retake_assessment')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(QuizAssessmentLocalizations loc, Map<String, String> suggestion) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            const SizedBox(height: 5),
            Text(
              '${loc.text('problem_label')}: ${suggestion['issue'] ?? ''}',
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            Text(
              '${loc.text('why_label')}: ${suggestion['detail'] ?? ''}',
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
            Text(
              '${loc.text('solution_label')}: ${suggestion['solution'] ?? ''}',
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdfReport() async {
    final loc = _loc;
    final isTamil = loc.isTamil;
    final regularFont = isTamil ? await PdfGoogleFonts.notoSansTamilRegular() : await PdfGoogleFonts.notoSansRegular();
    final boldFont = isTamil ? await PdfGoogleFonts.notoSansTamilBold() : await PdfGoogleFonts.notoSansBold();
    final document = pw.Document();
    final maxScore = _totalQuestions * 5;
    final name = userData['name'] as String? ?? loc.text('name_fallback');
    final areaKey = userData['area'] as String? ?? 'urban';

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(24),
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        ),
        build: (context) => [
          pw.Text(loc.text('assessment_title'), style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Text(loc.scoreLine(_totalScore, maxScore)),
          pw.Text(loc.categoryLine(_categoryKey)),
          pw.SizedBox(height: 16),
          pw.Text(loc.text('result_summary_title'), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('${loc.text('name_label')}: $name'),
          pw.Text('${loc.text('age_label')}: ${userData['age']}'),
          pw.Text('${loc.text('area_label')}: ${loc.text(areaKey)}'),
          pw.Text('${loc.text('total_questions_label')}: $_totalQuestions'),
          pw.SizedBox(height: 16),
          pw.Text(loc.text('risk_level_title'), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Text(loc.text(_riskKey)),
          pw.SizedBox(height: 8),
          pw.Text(loc.text(_motivationKey)),
          pw.SizedBox(height: 16),
          pw.Text(loc.text('areas_to_improve'), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          if (_weakAreas.isEmpty)
            pw.Text(loc.text('no_major_weak_habits'))
          else
            ..._weakAreas.map((weakArea) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text('• $weakArea'),
                )),
          pw.SizedBox(height: 16),
          pw.Text(loc.text('recommendations_title'), style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          ..._suggestions.map(
            (suggestion) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(suggestion['title'] ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${loc.text('problem_label')}: ${suggestion['issue'] ?? ''}'),
                  pw.Text('${loc.text('why_label')}: ${suggestion['detail'] ?? ''}'),
                  pw.Text('${loc.text('solution_label')}: ${suggestion['solution'] ?? ''}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    await Printing.sharePdf(bytes: await document.save(), filename: loc.localizedPdfFilename());
  }

  void _resetAssessment() {
    setState(() {
      _pageIndex = 0;
      _currentQuestionIndex = 0;
      _selectedArea = null;
      _nameError = null;
      _ageError = null;
      _totalScore = 0;
      _categoryKey = 'category_good_oral_hygiene';
      _categoryColor = AppTheme.textSecondary;
      _riskKey = 'risk_low';
      _motivationKey = 'motivation_low';
      _weakAreas = [];
      _suggestions = [];
      userData.clear();
      answers.clear();
      _nameController.clear();
      _ageController.clear();
    });
  }
}
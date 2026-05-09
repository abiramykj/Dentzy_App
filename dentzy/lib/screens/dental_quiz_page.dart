import 'package:flutter/material.dart';

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
  final Map<int, Map<String, dynamic>> answers = {};

  final List<Map<String, dynamic>> _questions = [
    {
      'category': 'Brushing Frequency',
      'question': 'How many times do you brush your teeth per day?',
      'options': [
        {'text': 'Once', 'score': 1},
        {'text': 'Twice', 'score': 5},
        {'text': 'More than twice', 'score': 4},
      ],
      'feedback': {
        'Once': {
          'issue': 'Brushing frequency is too low.',
          'detail': 'Brushing only once a day allows plaque to stay on teeth longer.',
          'solution': 'Brush twice daily using a soft toothbrush and fluoride toothpaste.',
        },
        'Twice': {
          'issue': 'Healthy brushing habit.',
          'detail': 'Twice-daily brushing is the standard preventive habit for most users.',
          'solution': 'Keep this routine and continue brushing along the gumline.',
        },
        'More than twice': {
          'issue': 'Possible over-brushing.',
          'detail': 'Brushing too often or too hard may wear enamel and irritate gums.',
          'solution': 'Brush twice daily unless your dentist recommends more frequent cleaning.',
        },
      },
    },
    {
      'category': 'Cleaning Method',
      'question': 'What do you usually use to clean your teeth?',
      'options': [
        {'text': 'Fluoride toothpaste and toothbrush', 'score': 5},
        {'text': 'Neem stick only', 'score': 2},
        {'text': 'Ash or charcoal powder', 'score': 1},
        {'text': 'Salt only', 'score': 2},
      ],
      'feedback': {
        'Fluoride toothpaste and toothbrush': {
          'issue': 'Recommended cleaning method in use.',
          'detail': 'Fluoride toothpaste helps protect enamel and reduce cavity risk.',
          'solution': 'Continue this routine and use a gentle circular brushing technique.',
        },
        'Neem stick only': {
          'issue': 'Cleaning routine is incomplete.',
          'detail': 'Traditional methods may help, but they do not replace a full brushing routine.',
          'solution': 'Use a soft toothbrush with fluoride toothpaste for better protection.',
        },
        'Ash or charcoal powder': {
          'issue': 'Potentially harmful cleaning method.',
          'detail': 'Abrasive powders can scratch enamel and irritate gum tissue.',
          'solution': 'Avoid ash or charcoal powder and switch to fluoride toothpaste.',
        },
        'Salt only': {
          'issue': 'Cleaning method is insufficient.',
          'detail': 'Salt alone does not provide proper plaque removal or fluoride protection.',
          'solution': 'Use toothpaste with fluoride and brush twice daily.',
        },
      },
    },
    {
      'category': 'Between-Teeth Cleaning',
      'question': 'How often do you floss or clean between teeth?',
      'options': [
        {'text': 'Daily', 'score': 5},
        {'text': 'Sometimes', 'score': 3},
        {'text': 'Never', 'score': 1},
      ],
      'feedback': {
        'Daily': {
          'issue': 'Healthy interdental cleaning habit.',
          'detail': 'Daily flossing helps remove plaque from areas the brush cannot reach.',
          'solution': 'Keep this habit and pair it with regular brushing.',
        },
        'Sometimes': {
          'issue': 'Inconsistent interdental cleaning.',
          'detail': 'Cleaning between teeth only sometimes can allow plaque and food debris to remain.',
          'solution': 'Make flossing or interdental cleaning part of your daily routine.',
        },
        'Never': {
          'issue': 'No interdental cleaning habit.',
          'detail': 'Skipping flossing leaves hidden plaque between teeth and can increase gum problems.',
          'solution': 'Start flossing once daily or use an interdental brush if recommended.',
        },
      },
    },
    {
      'category': 'Dental Visits',
      'question': 'How often do you visit a dentist for a checkup?',
      'options': [
        {'text': 'Every 6 months', 'score': 5},
        {'text': 'Once a year', 'score': 4},
        {'text': 'Only when there is pain', 'score': 2},
        {'text': 'Rarely or never', 'score': 1},
      ],
      'feedback': {
        'Every 6 months': {
          'issue': 'Excellent preventive care pattern.',
          'detail': 'Regular visits help detect cavities, gum issues, and wear before symptoms worsen.',
          'solution': 'Continue routine dental checkups every 6 months.',
        },
        'Once a year': {
          'issue': 'Preventive visits could be more frequent.',
          'detail': 'Annual visits are helpful, but some problems progress between appointments.',
          'solution': 'Try to schedule dental checkups every 6 months.',
        },
        'Only when there is pain': {
          'issue': 'Reactive dental care pattern.',
          'detail': 'Waiting for pain often means the problem has already progressed.',
          'solution': 'Visit a dentist regularly even when there is no pain.',
        },
        'Rarely or never': {
          'issue': 'No preventive dental visit routine.',
          'detail': 'Problems may remain hidden and become harder to treat later.',
          'solution': 'Book a preventive dental checkup as soon as possible.',
        },
      },
    },
    {
      'category': 'Sugar Exposure',
      'question': 'How often do you consume sugary snacks or sweet drinks?',
      'options': [
        {'text': 'Rarely', 'score': 5},
        {'text': '1-2 times a day', 'score': 3},
        {'text': 'Many times a day', 'score': 1},
      ],
      'feedback': {
        'Rarely': {
          'issue': 'Low sugar exposure.',
          'detail': 'Limiting sugar reduces the food supply for cavity-causing bacteria.',
          'solution': 'Keep sugars occasional and maintain good oral hygiene after sweet foods.',
        },
        '1-2 times a day': {
          'issue': 'Moderate sugar exposure.',
          'detail': 'Daily sugar intake increases cavity risk, especially if consumed between meals.',
          'solution': 'Limit sugary snacks and rinse or brush after consuming them.',
        },
        'Many times a day': {
          'issue': 'High sugar exposure.',
          'detail': 'Frequent sugar intake repeatedly feeds plaque bacteria and raises cavity risk.',
          'solution': 'Reduce sugary drinks and snacks, especially between meals.',
        },
      },
    },
    {
      'category': 'Night Brushing',
      'question': 'Do you brush your teeth before sleeping at night?',
      'options': [
        {'text': 'Always', 'score': 5},
        {'text': 'Sometimes', 'score': 3},
        {'text': 'Never', 'score': 1},
      ],
      'feedback': {
        'Always': {
          'issue': 'Strong protective habit.',
          'detail': 'Night brushing removes plaque and food before saliva flow decreases during sleep.',
          'solution': 'Continue brushing before bed every night.',
        },
        'Sometimes': {
          'issue': 'Inconsistent night brushing.',
          'detail': 'Missing night brushing allows plaque to stay on teeth overnight.',
          'solution': 'Brush every night before sleeping to reduce plaque buildup.',
        },
        'Never': {
          'issue': 'Night brushing is missing.',
          'detail': 'Leaving teeth unclean overnight significantly increases cavity and gum risk.',
          'solution': 'Make night brushing a daily non-negotiable habit.',
        },
      },
    },
    {
      'category': 'Toothbrush Care',
      'question': 'How often do you replace your toothbrush?',
      'options': [
        {'text': 'Every 3 months', 'score': 5},
        {'text': 'Every 6 months', 'score': 3},
        {'text': 'Only when it looks damaged', 'score': 1},
      ],
      'feedback': {
        'Every 3 months': {
          'issue': 'Ideal toothbrush replacement schedule.',
          'detail': 'Fresh bristles clean more effectively and maintain better plaque removal.',
          'solution': 'Continue replacing your toothbrush every 3 months or sooner if bristles fray.',
        },
        'Every 6 months': {
          'issue': 'Replacement interval is a little long.',
          'detail': 'Worn bristles may become less effective before 6 months.',
          'solution': 'Replace your toothbrush around every 3 months.',
        },
        'Only when it looks damaged': {
          'issue': 'Toothbrush replacement is delayed.',
          'detail': 'A worn brush can clean poorly even if it still looks usable.',
          'solution': 'Replace your toothbrush regularly rather than waiting for visible damage.',
        },
      },
    },
    {
      'category': 'Mouthwash Use',
      'question': 'Do you use mouthwash or rinse after brushing?',
      'options': [
        {'text': 'Yes, as advised', 'score': 4},
        {'text': 'Sometimes', 'score': 3},
        {'text': 'No', 'score': 2},
      ],
      'feedback': {
        'Yes, as advised': {
          'issue': 'Supportive hygiene habit.',
          'detail': 'Mouthwash can be helpful when it is used based on dental advice and not as a substitute for brushing.',
          'solution': 'Continue using mouthwash only if it has been recommended for your needs.',
        },
        'Sometimes': {
          'issue': 'Inconsistent rinse habit.',
          'detail': 'Using mouthwash irregularly may not provide consistent benefits.',
          'solution': 'Follow a regular oral care routine and use mouthwash as advised.',
        },
        'No': {
          'issue': 'Mouthwash is not part of your routine.',
          'detail': 'This is not always a problem, but some users may benefit from dentist-recommended rinses.',
          'solution': 'Ask your dentist whether a therapeutic mouthwash could help your gum health.',
        },
      },
    },
    {
      'category': 'After-Meal Care',
      'question': 'After eating sticky or sugary foods, what do you usually do?',
      'options': [
        {'text': 'Rinse or brush soon after', 'score': 5},
        {'text': 'Drink water only', 'score': 3},
        {'text': 'Do nothing', 'score': 1},
      ],
      'feedback': {
        'Rinse or brush soon after': {
          'issue': 'Good after-meal response.',
          'detail': 'Removing residue quickly reduces plaque buildup and sugar contact time.',
          'solution': 'Keep rinsing or brushing after sticky or sugary foods.',
        },
        'Drink water only': {
          'issue': 'Partial cleaning after meals.',
          'detail': 'Water helps, but it may not remove all sticky debris from tooth surfaces.',
          'solution': 'Rinse well and brush when practical after sugary foods.',
        },
        'Do nothing': {
          'issue': 'No after-meal cleaning habit.',
          'detail': 'Food stuck on teeth gives bacteria more time to produce acids.',
          'solution': 'Rinse or brush after sticky meals whenever possible.',
        },
      },
    },
    {
      'category': 'Tobacco Exposure',
      'question': 'Do you use tobacco, gutkha, or smoke regularly?',
      'options': [
        {'text': 'No', 'score': 5},
        {'text': 'Occasionally', 'score': 2},
        {'text': 'Yes, regularly', 'score': 1},
      ],
      'feedback': {
        'No': {
          'issue': 'No tobacco-related oral risk detected.',
          'detail': 'Avoiding tobacco reduces gum disease, staining, and oral cancer risk.',
          'solution': 'Continue avoiding tobacco and support others to do the same.',
        },
        'Occasionally': {
          'issue': 'Intermittent tobacco exposure.',
          'detail': 'Even occasional use can irritate tissues and harm long-term oral health.',
          'solution': 'Work toward quitting completely and seek support if needed.',
        },
        'Yes, regularly': {
          'issue': 'High tobacco-related risk.',
          'detail': 'Regular tobacco use can damage gums, stain teeth, and increase serious oral disease risk.',
          'solution': 'Seek cessation support and avoid tobacco products as soon as possible.',
        },
      },
    },
  ];

  int _pageIndex = 0;
  int _currentQuestionIndex = 0;
  String? _selectedArea;
  String? _nameError;
  String? _ageError;
  int _totalScore = 0;
  String _category = '';
  Color _categoryColor = AppTheme.textSecondary;
  List<String> _weakAreas = [];
  List<Map<String, String>> _suggestions = [];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  int get _totalQuestions => _questions.length;

  Map<String, dynamic> get _currentQuestion => _questions[_currentQuestionIndex];

  Map<String, dynamic>? get _currentAnswer => answers[_currentQuestionIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Dental Habit Assessment')),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _pageIndex == 0
              ? _buildDetailsPage()
              : _pageIndex == 1
                  ? _buildQuestionPage()
                  : _buildResultPage(),
        ),
      ),
    );
  }

  void _startAssessment() {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    setState(() {
      _nameError = null;
      _ageError = null;
    });

    if (name.isEmpty) {
      setState(() {
        _nameError = 'Please enter your name';
      });
      return;
    }

    if (age == null || age <= 0) {
      setState(() {
        _ageError = 'Please enter a valid age';
      });
      return;
    }

    if (_selectedArea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your area')),
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

  void _selectAnswer(String answer) {
    final options = List<Map<String, dynamic>>.from(_currentQuestion['options'] as List);
    final selectedOption = options.firstWhere(
      (option) => option['text'] == answer,
      orElse: () => {'text': answer, 'score': 0},
    );

    setState(() {
      answers[_currentQuestionIndex] = {
        'answer': answer,
        'score': selectedOption['score'] as int,
      };
    });
  }

  void _goNext() {
    if (_currentAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option to continue')),
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

    for (int index = 0; index < _questions.length; index++) {
      final question = _questions[index];
      final selectedResponse = answers[index];
      if (selectedResponse == null) {
        continue;
      }

      final selectedAnswer = selectedResponse['answer'] as String;
      final score = selectedResponse['score'] as int;
      totalScore += score;

      if (score <= 2) {
        final feedbackMap = question['feedback'] as Map<String, dynamic>;
        final suggestion = feedbackMap[selectedAnswer] as Map<String, dynamic>?;
        if (suggestion != null) {
          final suggestionKey = '${question['category']}|$selectedAnswer';
          if (seenSuggestionKeys.add(suggestionKey)) {
            weakAreas.add(
              _buildWeakAreaLabel(question['question'] as String, selectedAnswer),
            );
            suggestions.add({
              'title': question['category'] as String,
              'issue': suggestion['issue'] as String,
              'detail': suggestion['detail'] as String,
              'solution': suggestion['solution'] as String,
            });
          }
        }
      }
    }

    suggestions.addAll(_buildGeneralSuggestions(totalScore));

    final categoryData = _resolveCategory(totalScore);

    setState(() {
      _totalScore = totalScore;
      _weakAreas = weakAreas;
      _suggestions = suggestions;
      _category = categoryData.$1;
      _categoryColor = categoryData.$2;
      _pageIndex = 2;
    });
  }

  (String, Color) _resolveCategory(int totalScore) {
    if (totalScore >= 40) {
      return ('Good Oral Hygiene', AppTheme.successColor);
    }
    if (totalScore >= 25) {
      return ('Average', AppTheme.warningColor);
    }
    return ('Needs Improvement', AppTheme.errorColor);
  }

  List<Map<String, String>> _buildGeneralSuggestions(int totalScore) {
    if (totalScore >= 40) {
      return [
        {
          'title': 'Maintenance',
          'issue': 'Your oral hygiene is strong.',
          'detail': 'Good habits are already in place, but consistency still matters.',
          'solution': 'Keep brushing, flossing, and visiting your dentist regularly.',
        },
      ];
    }

    if (totalScore >= 25) {
      return [
        {
          'title': 'Routine Improvement',
          'issue': 'Your oral care routine is partly effective.',
          'detail': 'A few habits are healthy, but some weak areas still raise risk.',
          'solution': 'Focus on the weak areas below and maintain the habits you do well.',
        },
      ];
    }

    return [
      {
        'title': 'Urgent Improvement',
        'issue': 'Your oral care routine has multiple weak points.',
        'detail': 'Several daily habits may be increasing cavity and gum disease risk.',
        'solution': 'Start with brushing twice daily, reducing sugar, and scheduling a dental visit.',
      },
    ];
  }

  String _buildWeakAreaLabel(String question, String answer) {
    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('brush') && lowerQuestion.contains('day')) {
      return 'Brushing habit: $answer';
    }
    if (lowerQuestion.contains('clean your teeth')) {
      return 'Cleaning method: $answer';
    }
    if (lowerQuestion.contains('floss')) {
      return 'Flossing habit: $answer';
    }
    if (lowerQuestion.contains('dentist')) {
      return 'Dental visits: $answer';
    }
    if (lowerQuestion.contains('sugary')) {
      return 'Sugar intake: $answer';
    }
    if (lowerQuestion.contains('sleeping')) {
      return 'Night brushing: $answer';
    }
    if (lowerQuestion.contains('replace your toothbrush')) {
      return 'Toothbrush replacement: $answer';
    }
    if (lowerQuestion.contains('mouthwash')) {
      return 'Mouth rinse habit: $answer';
    }
    if (lowerQuestion.contains('sticky or sugary foods')) {
      return 'After-meal care: $answer';
    }
    if (lowerQuestion.contains('tobacco') || lowerQuestion.contains('smoke')) {
      return 'Tobacco habit: $answer';
    }

    return '$question - $answer';
  }

  Widget _buildDetailsPage() {
    return SingleChildScrollView(
      key: const ValueKey('details'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            gradient: AppTheme.primaryGradient,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety, color: Colors.white, size: 36),
                SizedBox(height: 16),
                Text(
                  'Dental Habit Assessment',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This assessment reviews daily oral care habits and gives personalized improvement tips.',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Details', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    errorText: _nameError,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    prefixIcon: const Icon(Icons.cake_outlined),
                    errorText: _ageError,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedArea,
                  decoration: const InputDecoration(
                    labelText: 'Area',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Urban', child: Text('Urban')),
                    DropdownMenuItem(value: 'Rural', child: Text('Rural')),
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
              label: const Text('Start Assessment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage() {
    final progress = (_currentQuestionIndex + 1) / _totalQuestions;
    final questionText = _currentQuestion['question'] as String;
    final options = List<Map<String, dynamic>>.from(_currentQuestion['options'] as List);

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
                            'Question ${_currentQuestionIndex + 1} of $_totalQuestions',
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
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      foregroundColor: AppTheme.primaryColor,
                      child: Text('${_currentQuestionIndex + 1}'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  questionText,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ...options
                    .map(
                      (option) {
                        final text = option['text'] as String;
                        final selected = _currentAnswer?['answer'] == text;

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
                              value: text,
                              groupValue: _currentAnswer?['answer'] as String?,
                              onChanged: (value) {
                                if (value != null) {
                                  _selectAnswer(value);
                                }
                              },
                              title: Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                    .toList(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _goPrevious,
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _goNext,
                  child: Text(
                    _currentQuestionIndex == _totalQuestions - 1 ? 'View Result' : 'Next',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultPage() {
    final maxScore = _totalQuestions * 5;

    return SingleChildScrollView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomCard(
            gradient: LinearGradient(
              colors: [_categoryColor, _categoryColor.withOpacity(0.75)],
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
                  userData['name'] as String? ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Score: $_totalScore / $maxScore',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Category: $_category',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assessment Summary', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                _buildSummaryRow('Age', '${userData['age']}'),
                _buildSummaryRow('Area', '${userData['area']}'),
                _buildSummaryRow('Total Questions', '$_totalQuestions'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.report_problem, color: AppTheme.warningColor),
                    const SizedBox(width: 8),
                    Text('Areas to Improve', style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 12),
                if (_weakAreas.isEmpty)
                  const Text(
                    'No major weak habits were detected.',
                    style: TextStyle(fontSize: 14),
                  )
                else
                  ..._weakAreas
                      .map(
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
                      )
                      .toList(),
              ],
            ),
          ),
          const SizedBox(height: 8),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text('Personalized Suggestions', style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
                const SizedBox(height: 12),
                ..._suggestions.map((suggestion) => _buildSuggestionCard(suggestion)).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _resetAssessment,
              icon: const Icon(Icons.refresh),
              label: const Text('Retake Assessment'),
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
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, String> suggestion) {
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
            ),
            const SizedBox(height: 5),
            Text('Problem: ${suggestion['issue'] ?? ''}'),
            Text('Why: ${suggestion['detail'] ?? ''}'),
            Text('Solution: ${suggestion['solution'] ?? ''}'),
          ],
        ),
      ),
    );
  }

  void _resetAssessment() {
    setState(() {
      _pageIndex = 0;
      _currentQuestionIndex = 0;
      _selectedArea = null;
      _nameError = null;
      _ageError = null;
      _totalScore = 0;
      _category = '';
      _categoryColor = AppTheme.textSecondary;
      _weakAreas = [];
      _suggestions = [];
      userData.clear();
      answers.clear();
      _nameController.clear();
      _ageController.clear();
    });
  }
}
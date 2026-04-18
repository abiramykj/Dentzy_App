import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';

class ResultScreen extends StatelessWidget {
  final bool isCorrect;
  final String myth;
  final String correctAnswer;
  final String explanation;

  const ResultScreen({
    super.key,
    required this.isCorrect,
    required this.myth,
    required this.correctAnswer,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Result Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isCorrect
                        ? AppTheme.successGradient
                        : LinearGradient(
                          colors: [
                            Colors.red[400]!,
                            Colors.red[600]!,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                    ),
                    child: Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Result Text
                Center(
                  child: Column(
                    children: [
                      Text(
                        isCorrect ? 'Correct!' : 'Incorrect',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isCorrect
                          ? 'Great job! You got it right.'
                          : 'Don\'t worry, learn from this and try again.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Question Card
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
                        'The Myth',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        myth,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Correct Answer Card
                CustomCard(
                  padding: const EdgeInsets.all(20),
                  gradient: AppTheme.successGradient,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'The Truth',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        correctAnswer,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Explanation Card
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
                        explanation,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next Question'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.home),
                  label: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

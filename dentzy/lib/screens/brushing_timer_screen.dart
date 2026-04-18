import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/custom_card.dart';
import '../utils/theme.dart';
import '../l10n/app_localizations.dart';

class BrushingTimerScreen extends StatefulWidget {
  const BrushingTimerScreen({super.key});

  @override
  State<BrushingTimerScreen> createState() => _BrushingTimerScreenState();
}

class _BrushingTimerScreenState extends State<BrushingTimerScreen> {
  late Timer _timer;
  int _remainingSeconds = 120; // 2 minutes in seconds
  bool _isRunning = false;
  final int _totalSeconds = 120;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!_isRunning && _remainingSeconds > 0) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _isRunning = false;
            _timer.cancel();
            _showCompletionDialog();
          }
        });
      });
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _remainingSeconds = 120;
      _isRunning = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Great Job!'),
        content: const Text('You completed your 2-minute brushing session!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final progress = (_totalSeconds - _remainingSeconds) / _totalSeconds;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Brushing Timer'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),

            // Timer Display
            Center(
              child: CustomCard(
                padding: const EdgeInsets.all(40),
                gradient: AppTheme.primaryGradient,
                child: Column(
                  children: [
                    Text(
                      'Time Remaining',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Circular Progress
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.3),
                            ),
                            backgroundColor:
                                Colors.white.withOpacity(0.1),
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Tips Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          'Brushing Tips',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Brush for at least 2 minutes\n'
                      '• Use gentle, circular motions\n'
                      '• Don\'t forget your tongue\n'
                      '• Brush twice daily',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Control Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRunning
                              ? null
                              : (_remainingSeconds > 0 ? _startTimer : null),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRunning ? _pauseTimer : null,
                          icon: const Icon(Icons.pause),
                          label: const Text('Pause'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _resetTimer,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                    ),
                  ).expandedWidth(context),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

extension ExpandedWidth on Widget {
  Widget expandedWidth(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: this,
    );
  }
}

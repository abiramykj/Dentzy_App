import 'package:flutter/material.dart';
import '../utils/theme.dart';

class ProgressChart extends StatelessWidget {
  final String title;
  final double percentage;
  final Color? color;
  final double size;
  final bool showLabel;

  const ProgressChart({
    super.key,
    required this.title,
    required this.percentage,
    this.color,
    this.size = 150,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final chartColor = color ?? AppTheme.primaryColor;
    final clampedPercentage = percentage.clamp(0.0, 100.0);

    return Column(
      children: [
        SizedBox(
          height: size,
          width: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                height: size,
                width: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
              ),
              // Progress circle
              SizedBox(
                height: size,
                width: size,
                child: CircularProgressIndicator(
                  value: clampedPercentage / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(chartColor),
                ),
              ),
              // Center text
              if (showLabel)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${clampedPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: chartColor,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final double borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(8),
    this.onTap,
    this.gradient,
    this.borderRadius = 16,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? AppTheme.surfaceColor : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }

    return Container(
      margin: margin,
      child: cardContent,
    );
  }
}

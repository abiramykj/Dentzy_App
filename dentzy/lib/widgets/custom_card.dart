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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null 
          ? (isDark ? const Color(0xFF1E293B) : AppTheme.surfaceColor)
          : null,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
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

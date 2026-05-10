import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/theme.dart';

class DentzyLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const DentzyLogo({
    super.key,
    this.size = 118,
    this.showWordmark = true,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: AppTheme.primaryDark,
          letterSpacing: 0.2,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryLight.withOpacity(0.25),
                    AppTheme.secondaryLight.withOpacity(0.22),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: _ToothPainter(),
              ),
            ),
            Positioned(
              top: size * 0.1,
              right: -6,
              child: _Sparkle(size: size * 0.17),
            ),
            Positioned(
              top: size * 0.66,
              left: -4,
              child: _Sparkle(size: size * 0.12),
            ),
          ],
        ),
        if (showWordmark) ...[
          const SizedBox(height: 14),
          Text('Dentzy', style: textStyle),
        ],
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double size;

  const _Sparkle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD79D), Color(0xFFF2B66D)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF2B66D).withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToothPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = const LinearGradient(
        colors: [Color(0xFFE8FFFB), Color(0xFFCCF7F0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = AppTheme.primaryColor;

    final tooth = Path()
      ..moveTo(size.width * 0.50, size.height * 0.17)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.16,
        size.width * 0.21,
        size.height * 0.28,
        size.width * 0.21,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.21,
        size.height * 0.57,
        size.width * 0.28,
        size.height * 0.68,
        size.width * 0.35,
        size.height * 0.81,
      )
      ..cubicTo(
        size.width * 0.41,
        size.height * 0.92,
        size.width * 0.48,
        size.height * 0.86,
        size.width * 0.50,
        size.height * 0.75,
      )
      ..cubicTo(
        size.width * 0.52,
        size.height * 0.86,
        size.width * 0.59,
        size.height * 0.92,
        size.width * 0.65,
        size.height * 0.81,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.68,
        size.width * 0.79,
        size.height * 0.57,
        size.width * 0.79,
        size.height * 0.44,
      )
      ..cubicTo(
        size.width * 0.79,
        size.height * 0.28,
        size.width * 0.66,
        size.height * 0.16,
        size.width * 0.50,
        size.height * 0.17,
      )
      ..close();

    canvas.drawPath(tooth, fillPaint);
    canvas.drawPath(tooth, strokePaint);

    final eyePaint = Paint()..color = AppTheme.primaryDark;
    canvas.drawCircle(
      Offset(size.width * 0.40, size.height * 0.44),
      size.width * 0.024,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.60, size.height * 0.44),
      size.width * 0.024,
      eyePaint,
    );

    final smilePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.03
      ..color = AppTheme.primaryDark;
    final smile = Path()
      ..moveTo(size.width * 0.38, size.height * 0.57)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.67,
        size.width * 0.62,
        size.height * 0.57,
      );
    canvas.drawPath(smile, smilePaint);

    final blushPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFFB7B7).withOpacity(0.45);
    canvas.drawCircle(
      Offset(size.width * 0.31, size.height * 0.54),
      size.width * 0.045,
      blushPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.69, size.height * 0.54),
      size.width * 0.045,
      blushPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

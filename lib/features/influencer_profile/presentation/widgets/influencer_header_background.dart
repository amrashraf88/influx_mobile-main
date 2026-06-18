import 'dart:math' as math;

import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';

class InfluencerHeaderBackground extends StatelessWidget {
  const InfluencerHeaderBackground({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: const _HeaderGridPainter(),
        child: const ColoredBox(color: Colors.transparent),
      ),
    );
  }
}

class _HeaderGridPainter extends CustomPainter {
  const _HeaderGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.brandBlue);

    final Paint grid = Paint()
      ..color = AppColors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    const double step = 42;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final math.Random random = math.Random(23);
    final Paint stars = Paint()
      ..color = AppColors.white.withValues(alpha: 0.34);
    for (int i = 0; i < 80; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double d = 0.6 + random.nextDouble() * 1.2;
      canvas.drawCircle(Offset(x, y), d, stars);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

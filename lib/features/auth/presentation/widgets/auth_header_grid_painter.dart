import 'dart:math' as math;

import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';

/// Blueprint-style grid + dots for auth flow blue headers (phone, OTP, etc.).
class AuthHeaderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double step = 40;
    final Paint gridMajor = Paint()
      ..color = AppColors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridMajor);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridMajor);
    }

    final math.Random r = math.Random(42);
    for (int layer = 0; layer < 3; layer++) {
      final double baseAlpha = layer == 0 ? 0.14 : (layer == 1 ? 0.11 : 0.08);
      for (int i = 0; i < 36; i++) {
        final Paint dot = Paint()
          ..color = AppColors.white.withValues(
            alpha: (baseAlpha + r.nextDouble() * 0.14).clamp(0.05, 0.38),
          );
        final double radius = (layer + 1) * 0.35 + r.nextDouble() * 1.45;
        canvas.drawCircle(
          Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
          radius,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

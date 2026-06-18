import 'dart:math' as math;

import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Same starfield grid look used on the influencer marketing home, scoped to
/// the registered company home so they share a visual language.
class CompanyHomeHeaderBackground extends StatelessWidget {
  const CompanyHomeHeaderBackground({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(color: AppColors.brandBlue),
      child: CustomPaint(painter: _CompanyHeaderPainter()),
    );
  }
}

class _CompanyHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint grid = Paint()
      ..color = AppColors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    const double step = 42;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final math.Random r = math.Random(7);
    final Paint p = Paint()..color = AppColors.white.withValues(alpha: 0.30);
    for (int i = 0; i < 70; i++) {
      final double x = r.nextDouble() * size.width;
      final double y = r.nextDouble() * size.height;
      final double d = 0.4 + r.nextDouble() * 1.2;
      canvas.drawCircle(Offset(x, y), d, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Row of brand title + bell + search icon, sized to match the design.
class CompanyHomeHeaderRow extends StatelessWidget {
  const CompanyHomeHeaderRow({
    super.key,
    required this.brandLogoUrl,
    required this.onSearchTap,
  });

  final String brandLogoUrl;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final double sideIconSize = 36.w;
    return Row(
      children: <Widget>[
        _CircleIcon(icon: Icons.search_rounded, onTap: onSearchTap),
        Expanded(
          child: Center(child: _BrandLockup(logoUrl: brandLogoUrl)),
        ),
        SizedBox(width: sideIconSize, height: sideIconSize),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  const _BrandLockup({required this.logoUrl});

  final String logoUrl;
  @override
  Widget build(BuildContext context) {
    return Image.asset(logoUrl, width: 151.w, height: 42.h);
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.white, size: 20.sp),
          ),
        ],
      ),
    );
  }
}

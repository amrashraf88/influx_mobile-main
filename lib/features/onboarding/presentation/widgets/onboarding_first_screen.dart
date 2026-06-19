import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adzmavall/utils/appcolors.dart';

/// Welcome / first onboarding screen — rebuilt from native widgets so all copy
/// is real, localizable text (no baked-in images).
class OnboardingFirstScreen extends StatelessWidget {
  const OnboardingFirstScreen({super.key, required this.onSkip});

  final VoidCallback onSkip;

  static const Color _circleColor = Color(0xFF3B9BE8);
  static const Color _lineColor = Color(0xFF63ADEC);
  static const Color _accentBlue = Color(0xFF1E90F0);
  static const Color _panelColor = Color(0xFF050608);

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double h = constraints.maxHeight;
            final double panelHeight = h * 0.47;

            return Stack(
              children: <Widget>[
                // Decorative orbit (circles + connecting curves).
                Positioned.fill(
                  child: CustomPaint(
                    painter: _OrbitPainter(
                      circleColor: _circleColor,
                      lineColor: _lineColor,
                    ),
                  ),
                ),

                // Header copy, centred in the upper white area.
                Positioned(
                  top: h * 0.205,
                  left: 32.w,
                  right: 32.w,
                  child: Text(
                    AppStrings.of(locale, 'onboarding_header'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 27.sp,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Bottom black panel with curved top edge.
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: panelHeight,
                  child: _WelcomePanel(
                    locale: locale,
                    panelColor: _panelColor,
                    accentBlue: _accentBlue,
                    onSkip: onSkip,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({
    required this.locale,
    required this.panelColor,
    required this.accentBlue,
    required this.onSkip,
  });

  final Locale locale;
  final Color panelColor;
  final Color accentBlue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final TextDirection dir = Directionality.of(context);

    final String brand = AppStrings.of(locale, 'onboarding_brand_primary');
    final String suffix = AppStrings.of(locale, 'onboarding_brand_suffix');
    final TextStyle brandStyle = TextStyle(
      color: accentBlue,
      fontSize: 30.sp,
      fontWeight: FontWeight.w700,
    );
    final TextStyle suffixStyle = TextStyle(
      color: AppColors.white,
      fontSize: 30.sp,
      fontWeight: FontWeight.w800,
    );

    // Measure the brand text so the underline matches its width exactly.
    final TextPainter brandPainter = TextPainter(
      text: TextSpan(text: brand, style: brandStyle),
      textDirection: dir,
    )..layout();
    final double brandWidth = brandPainter.width;

    return CustomPaint(
      painter: _PanelBackgroundPainter(
        panelColor: panelColor,
        arcColor: accentBlue,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24.w,
                  42.h,
                  24.w,
                  16.h + bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      AppStrings.of(locale, 'onboarding_title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    // Scales down to one line on narrow screens; underline only under
                    // the brand word, not the " App" suffix.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(brand, maxLines: 1, style: brandStyle),
                              SizedBox(height: 4.h),
                              CustomPaint(
                                size: Size(brandWidth, 9.h),
                                painter: _SquigglePainter(color: accentBlue),
                              ),
                            ],
                          ),
                          Text(suffix, maxLines: 1, style: suffixStyle),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppStrings.of(locale, 'onboarding_first_lorem'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 14.sp,
                        height: 1.45,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 18.h),
                    TextButton(
                      onPressed: onSkip,
                      child: Text(
                        AppStrings.of(locale, 'skip'),
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Paints the black panel with a top edge that bulges upward in the centre,
/// plus a bright arc stroke along that edge.
class _PanelBackgroundPainter extends CustomPainter {
  _PanelBackgroundPainter({required this.panelColor, required this.arcColor});

  final Color panelColor;
  final Color arcColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double dip = 30 * (w / 390); // sides drop relative to the centre peak

    final Path fill = Path()
      ..moveTo(0, dip)
      ..quadraticBezierTo(w / 2, -dip, w, dip)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(fill, Paint()..color = panelColor);

    final Path arc = Path()
      ..moveTo(0, dip)
      ..quadraticBezierTo(w / 2, -dip, w, dip);
    canvas.drawPath(
      arc,
      Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PanelBackgroundPainter oldDelegate) =>
      oldDelegate.panelColor != panelColor || oldDelegate.arcColor != arcColor;
}

/// A short hand-drawn double underline under the brand name.
class _SquigglePainter extends CustomPainter {
  _SquigglePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final Path top = Path()
      ..moveTo(w * 0.04, h * 0.55)
      ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.96, h * 0.5);
    canvas.drawPath(top, p);

    final Path bottom = Path()
      ..moveTo(w * 0.10, h * 0.95)
      ..quadraticBezierTo(w * 0.55, h * 0.55, w * 0.90, h * 0.95);
    canvas.drawPath(bottom, p);
  }

  @override
  bool shouldRepaint(_SquigglePainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Paints the five orbiting dots and the thin connecting curves.
class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.circleColor, required this.lineColor});

  final Color circleColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = w * 0.072;

    final Paint linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    // Upper sweep passing over the two top dots.
    final Path topArc = Path()
      ..moveTo(w * 0.06, h * 0.27)
      ..cubicTo(w * 0.02, h * 0.05, w * 0.42, h * 0.00, w * 0.70, h * 0.18);
    canvas.drawPath(topArc, linePaint);

    // Lower-right orbit loop around the bottom cluster.
    final Path bottomArc = Path()
      ..moveTo(w * 0.16, h * 0.50)
      ..cubicTo(w * 0.18, h * 0.66, w * 0.92, h * 0.60, w * 0.80, h * 0.32);
    canvas.drawPath(bottomArc, linePaint);

    final Path bottomTail = Path()
      ..moveTo(w * 0.50, h * 0.40)
      ..cubicTo(w * 0.72, h * 0.40, w * 0.80, h * 0.52, w * 0.60, h * 0.50);
    canvas.drawPath(bottomTail, linePaint);

    final Paint dotPaint = Paint()..color = circleColor;
    final List<Offset> centers = <Offset>[
      Offset(w * 0.17, h * 0.155),
      Offset(w * 0.66, h * 0.115),
      Offset(w * 0.74, h * 0.345),
      Offset(w * 0.205, h * 0.405),
      Offset(w * 0.625, h * 0.455),
    ];
    for (final Offset c in centers) {
      canvas.drawCircle(c, r, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) =>
      oldDelegate.circleColor != circleColor ||
      oldDelegate.lineColor != lineColor;
}

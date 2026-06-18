import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adzmavall/utils/appcolors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final TextTheme textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        surface: AppColors.card,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimaryDark,
        centerTitle: true,
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  /// DM Sans — used for headings / titles / numbers across the design.
  static TextStyle heading({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textPrimaryDark,
    double? height,
  }) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  /// Inter — body / labels.
  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textPrimaryDark,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  // Common shadows
  static List<BoxShadow> get cardShadow => <BoxShadow>[
        BoxShadow(
          color: const Color(0xFF1A1D29).withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get softShadow => <BoxShadow>[
        BoxShadow(
          color: const Color(0xFF1A1D29).withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// The blue hero header gradient (165°, top-left → bottom-right).
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AppColors.heroGradient,
  );
}

import 'package:flutter/material.dart';

class AppColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color brandBlue = Color(0xFF0072DE);
  static const Color lightText = Color(0xFFD9D9D9);
  static const Color pageBackground = Color(0xFFF3F5F8);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color headerGradientTop = Color(0xFF061428);
  static const Color headerGradientBottom = Color(0xFF0B2A4A);
  static const Color tagBackground = Color.fromARGB(255, 229, 229, 229);
  static const Color tagText = Color(0xFF737373);

  // Figma design tokens (shared with the rest of the app).
  static const Color fgPrimary = Color(0xFF101828);
  static const Color fgSecondary = Color(0xFF344054);
  static const Color fgTertiary = Color(0xFF475467);
  static const Color fgQuaternary = Color(0xFF667085);
  static const Color fgQuinary = Color(0xFF98A2B3);
  static const Color borderPrimary = Color(0xFFD0D5DD);
  static const Color borderSecondary = Color(0xFFEAECF0);
  static const Color success = Color(0xFF4CA30D);
  static const Color successLight = Color(0xFF66C61C);
  static const Color error = Color(0xFFE11D48);

  // ---------------------------------------------------------------------------
  // AdzMavall design system (ported 1:1 from the "Adz Mavall" Claude Design).
  // These are the canonical tokens used by the redesigned screens/widgets.
  // ---------------------------------------------------------------------------

  // Brand blues
  static const Color primary = Color(0xFF0072DE);
  static const Color primaryDark = Color(0xFF0066D6);
  static const Color primaryLight = Color(0xFF2A8DF2);

  // Header / hero gradient (linear-gradient(165deg, #2A8DF2, #0066D6)).
  static const List<Color> heroGradient = <Color>[
    Color(0xFF2A8DF2),
    Color(0xFF0066D6),
  ];

  // Surfaces
  static const Color background = Color(0xFFF4F6FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color softBlue = Color(0xFFE8F1FF);
  static const Color chipBg = Color(0xFFF1F4F9);
  static const Color navPill = Color(0xFFEAF1FF);

  // Text
  static const Color textPrimaryDark = Color(0xFF0E1426);
  static const Color textMuted = Color(0xFF8796AF);
  static const Color textTertiary = Color(0xFF9BA3B4);
  static const Color tagTextSoft = Color(0xFF5A6680);

  // Status
  static const Color successGreen = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFEAFBF0);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFC77700);
  static const Color warningBg = Color(0xFFFFF4E0);
  static const Color verified = Color(0xFF0072DE);

  // Borders / dividers
  static const Color border = Color(0xFFE6EAF1);
  static const Color divider = Color(0xFFECEFF3);

  // Social brand colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color instagram = Color(0xFFE1306C);
  static const Color tiktok = Color(0xFF0E0E0E);
  static const Color youtube = Color(0xFFFF0000);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color snapchat = Color(0xFFFFFC00);

  // Category / tag gradients
  static const List<Color> influencerGradient = <Color>[Color(0xFF22D3EE), Color(0xFF3B82F6)];
  static const List<Color> modelGradient = <Color>[Color(0xFF8B5CF6), Color(0xFF6366F1)];
  static const List<Color> ugcGradient = <Color>[Color(0xFFF472B6), Color(0xFFEF4444)];
  static const List<Color> collageGradient = <Color>[Color(0xFF38BDF8), Color(0xFF2563EB)];

  // Creator type accent colors
  static const Color tInfluencer = Color(0xFF0072DE);
  static const Color tModel = Color(0xFF7C3AED);
  static const Color tUGC = Color(0xFFEC4899);
  static const Color tCollage = Color(0xFF0EA5E9);

  /// Saudi Riyal currency glyph used throughout the source design.
  static const String riyal = '﷼';
}

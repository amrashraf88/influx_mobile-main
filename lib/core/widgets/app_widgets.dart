import 'package:adzmavall/core/theme/app_theme.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared design-system widgets for the AdzMavall app, ported 1:1 from the
/// "Adz Mavall" Claude Design source and adapted to flutter_screenutil sizing.

/// Resolves a social platform code (FB/IG/TT/YT/WA/SC) to its brand color.
Color socialColor(String code) {
  switch (code.toUpperCase()) {
    case 'FB':
      return AppColors.facebook;
    case 'IG':
      return AppColors.instagram;
    case 'TT':
      return AppColors.tiktok;
    case 'YT':
      return AppColors.youtube;
    case 'WA':
      return AppColors.whatsapp;
    case 'SC':
      return AppColors.snapchat;
    default:
      return AppColors.primary;
  }
}

/// Blue hero header background with rounded bottom corners.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(borderRadius ?? 28.r),
        ),
      ),
      child: child,
    );
  }
}

/// Rounded gradient badge used on creator cards (Influencer/Model/UGC/Collage).
class GradientBadge extends StatelessWidget {
  const GradientBadge({super.key, required this.label, required this.colors});

  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Small blue verified check.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.verified, color: AppColors.verified, size: size.sp);
  }
}

/// Circular avatar with a colored gradient fallback + initials.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.name,
    this.color = AppColors.primary,
    this.radius = 22,
    this.imageUrl,
  });

  final String name;
  final Color color;
  final double radius;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final double d = radius.r * 2;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: d,
          height: d,
          fit: BoxFit.cover,
          errorBuilder: (_, e, s) => _initials(d),
        ),
      );
    }
    return _initials(d);
  }

  Widget _initials(double d) {
    final String initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase();
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[color, Color.lerp(color, Colors.black, 0.25)!],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius.r * 0.7,
        ),
      ),
    );
  }
}

/// Small rounded social icon chip (FB/IG/TT/YT/WA/SC).
class SocialChip extends StatelessWidget {
  const SocialChip({super.key, required this.code, this.size = 30});

  final String code;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = socialColor(code);
    final Color fg = code.toUpperCase() == 'SC' ? Colors.black : Colors.white;
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size.w * 0.28),
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        style: TextStyle(
          color: fg,
          fontSize: size.sp * 0.32,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Section header: bold title on the left and a "See All" link on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onSeeAll, this.seeAllLabel = 'See All'});

  final String title;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(title, style: AppTheme.heading(size: 18.sp, weight: FontWeight.w800)),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              seeAllLabel,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
      ],
    );
  }
}

/// Pill-shaped tag chip (filter rows).
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.chipBg,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ),
    );
  }
}

/// White rounded card container with the standard soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(radius ?? 18.r),
          boxShadow: AppTheme.softShadow,
        ),
        child: child,
      ),
    );
  }
}

/// Soft secondary tag used inside detail cards.
class SoftTag extends StatelessWidget {
  const SoftTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Status pill (success / warning / danger / neutral).
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, this.bg});

  final String label;
  final Color color;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg ?? color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Reusable primary filled button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: enabled ? (onPressed ?? () {}) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[Icon(icon, size: 18.sp), SizedBox(width: 8.w)],
            Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Outlined / secondary button.
class OutlineButton extends StatelessWidget {
  const OutlineButton({super.key, required this.label, this.onPressed, this.icon});

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: OutlinedButton(
        onPressed: onPressed ?? () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[Icon(icon, size: 18.sp), SizedBox(width: 8.w)],
            Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

/// Rounded search field with an optional trailing blue filter button.
class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.showFilter = true,
    this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  final String hint;
  final bool showFilter;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.search, color: AppColors.textTertiary, size: 20.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showFilter) ...<Widget>[
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(Icons.tune, color: Colors.white, size: 22.sp),
            ),
          ),
        ],
      ],
    );
  }
}

/// Standard inner screen: centered title with a back button and a divider.
class InnerScaffold extends StatelessWidget {
  const InnerScaffold({
    super.key,
    required this.title,
    required this.child,
    this.bottom,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? bottom;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 6.h, 16.w, 10.h),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Icon(Icons.chevron_left, size: 28.sp),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: AppTheme.heading(size: 18.sp, weight: FontWeight.w800),
                      ),
                    ),
                  ),
                  SizedBox(width: 28.w, child: trailing),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            Expanded(child: child),
            if (bottom != null) SafeArea(top: false, child: bottom!),
          ],
        ),
      ),
    );
  }
}

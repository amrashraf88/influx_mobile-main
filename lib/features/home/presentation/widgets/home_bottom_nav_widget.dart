import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeBottomNavWidget extends StatelessWidget {
  const HomeBottomNavWidget({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.firstItemLabelKey = 'home_nav_home',
    this.firstItemIcon,
    this.centerItemEnabled = true,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;
  final String firstItemLabelKey;
  final IconData? firstItemIcon;
  final bool centerItemEnabled;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h + bottomInset + 8.h),
      child: Container(
        height: 69.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F8FF),
          borderRadius: BorderRadius.circular(36.r),
        ),
        child: Row(
          children: <Widget>[
            _NavItem(
              iconAsset: ImageAssets.homeBottomNavHome,
              icon: firstItemIcon,
              label: AppStrings.of(locale, firstItemLabelKey),
              selected: currentIndex == 0,
              onTap: () => onTap?.call(0),
            ),
            _NavItem(
              iconAsset: ImageAssets.homeBottomNavOrders,
              label: AppStrings.of(locale, 'home_nav_orders'),
              selected: currentIndex == 1,
              onTap: () => onTap?.call(1),
            ),
            _CenterFab(
              selected: currentIndex == 2,
              onTap: centerItemEnabled ? () => onTap?.call(2) : null,
            ),
            _NavItem(
              iconAsset: ImageAssets.homeBottomNavChat,
              label: AppStrings.of(locale, 'home_nav_chat'),
              selected: currentIndex == 3,
              onTap: () => onTap?.call(3),
            ),
            _NavItem(
              iconAsset: ImageAssets.homeBottomNavSettings,
              label: AppStrings.of(locale, 'home_nav_settings'),
              selected: currentIndex == 4,
              onTap: () => onTap?.call(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.iconAsset,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String iconAsset;
  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color c = selected ? AppColors.brandBlue : Colors.black;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: SizedBox(
          height: double.infinity,
          width: 56.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null)
                Icon(icon, color: c, size: 24.sp)
              else
                ColorFiltered(
                  colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
                  child: Image.asset(
                    iconAsset,
                    width: 23.w,
                    height: 23.w,
                    fit: BoxFit.contain,
                  ),
                ),
              SizedBox(height: 1.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: c,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  const _CenterFab({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Transform.translate(
          offset: Offset(0, -1.5.h),
          child: Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandBlue,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      ImageAssets.homeBottomNavAward,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

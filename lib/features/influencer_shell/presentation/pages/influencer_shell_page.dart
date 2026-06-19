import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InfluencerShellPage extends StatelessWidget {
  const InfluencerShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const Map<int, int> _branchIndexByNavIndex = <int, int>{
    0: 0,
    1: 1,
    2: 2,
    3: 3,
    4: 4,
  };

  static const Map<int, int> _navIndexByBranchIndex = <int, int>{
    0: 0,
    1: 1,
    2: 2,
    3: 3,
    4: 4,
  };

  void _onTap(int navIndex) {
    final int? branchIndex = _branchIndexByNavIndex[navIndex];
    if (branchIndex == null) {
      return;
    }

    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: navigationShell,
      bottomNavigationBar: Material(
        color: Colors.transparent,
        elevation: 0,
        child: _InfluencerBottomNav(
          currentIndex:
              _navIndexByBranchIndex[navigationShell.currentIndex] ?? 0,
          onTap: _onTap,
        ),
      ),
    );
  }
}

class _InfluencerBottomNav extends StatelessWidget {
  const _InfluencerBottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
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
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F8FF),
          borderRadius: BorderRadius.circular(36.r),
        ),
        child: Row(
          children: <Widget>[
            _NavItem(
              icon: Icons.home_outlined,
              label: AppStrings.of(locale, 'home_nav_home'),
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.article_outlined,
              label: AppStrings.of(locale, 'home_nav_orders'),
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              label: AppStrings.of(locale, 'influencer_nav_profile'),
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: Icons.chat_bubble_outline_rounded,
              label: AppStrings.of(locale, 'home_nav_chat'),
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.settings_outlined,
              label: AppStrings.of(locale, 'home_nav_settings'),
              selected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color c = selected ? AppColors.brandBlue : const Color(0xFF1F2937);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: c, size: 23.sp),
            SizedBox(height: 2.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c,
                fontSize: 10.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Company app bottom bar: five equal tabs, pill container (no center FAB). Not the influencer bar.
class CompanyBottomNavWidget extends StatelessWidget {
  const CompanyBottomNavWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

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
            _Item(
              icon: Icons.home_outlined,
              label: AppStrings.of(locale, 'company_nav_home'),
              selected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _Item(
              icon: Icons.chat_bubble_outline_rounded,
              label: AppStrings.of(locale, 'company_nav_chat'),
              selected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _Item(
              icon: Icons.auto_awesome_outlined,
              label: AppStrings.of(locale, 'company_nav_stars'),
              selected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            _Item(
              icon: Icons.article_outlined,
              label: AppStrings.of(locale, 'company_nav_campaigns'),
              selected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _Item(
              icon: Icons.person_outline_rounded,
              label: AppStrings.of(locale, 'company_nav_account'),
              selected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
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
            Icon(icon, color: c, size: 24.sp),
            SizedBox(height: 2.h),
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
    );
  }
}

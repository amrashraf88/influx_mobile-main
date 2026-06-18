import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfluencerProfileTabBar extends StatelessWidget {
  const InfluencerProfileTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<InfluencerProfileTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => SizedBox(width: 12.w),
        itemBuilder: (BuildContext context, int index) {
          final InfluencerProfileTabItem tab = tabs[index];
          final bool selected = index == selectedIndex;
          return _ProfileTabChip(
            tab: tab,
            selected: selected,
            onTap: () => onChanged(index),
          );
        },
      ),
    );
  }
}

class _ProfileTabChip extends StatelessWidget {
  const _ProfileTabChip({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final InfluencerProfileTabItem tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = selected ? AppColors.white : const Color(0xFF9AA2AE);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandBlue : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? AppColors.brandBlue : const Color(0xFFE3E7EE),
          ),
          boxShadow: selected
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppColors.brandBlue.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: Offset(0, 5.h),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ColorFiltered(
              colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
              child: Image.asset(
                tab.asset,
                width: 16.w,
                height: 16.h,
                fit: BoxFit.scaleDown,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              tab.label,
              style: TextStyle(
                color: fg,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

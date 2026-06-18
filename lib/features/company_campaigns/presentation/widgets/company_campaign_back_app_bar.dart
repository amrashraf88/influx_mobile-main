import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CompanyCampaignBackAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CompanyCampaignBackAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.pageBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: EdgeInsets.only(left: 12.w),
        child: Center(
          child: Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 40.w,
                height: 40.w,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared back + centered-title app bar for settings sub-screens.
class SettingsSubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SettingsSubAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.pageBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp),
        color: AppColors.fgPrimary,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.fgPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

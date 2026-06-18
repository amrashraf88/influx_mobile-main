import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSearchBarWidget extends StatelessWidget {
  const HomeSearchBarWidget({super.key, this.hintText});

  /// When set (e.g. from [ApiEndpoints.homeSearchHintPath]), overrides [AppStrings] hint.
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final String resolvedHint = (hintText != null && hintText!.trim().isNotEmpty)
        ? hintText!.trim()
        : AppStrings.of(locale, 'home_search_hint');
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(14.r),
      child: TextField(
        readOnly: true,
        onTap: () {},
        style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.white,
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 22.sp),
          hintText: resolvedHint,
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 4.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_sub_page_sheet.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyAboutAppPage extends StatelessWidget {
  const CompanyAboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    return CompanyAccountSubPageSheet(
      title: AppStrings.of(locale, 'company_account_about_title'),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppStrings.of(locale, 'company_account_privacy_policy'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              AppStrings.of(locale, 'company_account_privacy_effective'),
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppStrings.of(locale, 'company_account_privacy_intro'),
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textPrimary,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

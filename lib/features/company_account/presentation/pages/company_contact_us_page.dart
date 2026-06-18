import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_menu_panel.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_sub_page_sheet.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyContactUsPage extends StatelessWidget {
  const CompanyContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    return CompanyAccountSubPageSheet(
      title: AppStrings.of(locale, 'company_account_contact_title'),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppStrings.of(locale, 'company_account_contact_body'),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            _ContactRow(
              icon: Icons.mail_outline_rounded,
              value: AppStrings.of(locale, 'company_account_contact_email'),
            ),
            SizedBox(height: 14.h),
            _ContactRow(
              icon: Icons.phone_outlined,
              value: AppStrings.of(locale, 'company_account_contact_phone'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: CompanyAccountStyle.cardBorder),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppColors.brandBlue, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

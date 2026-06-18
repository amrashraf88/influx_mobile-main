import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// White card overlay on top of the blue header that informs the company that
/// their just-submitted profile is being reviewed.
class CompanyUnderReviewBannerWidget extends StatelessWidget {
  const CompanyUnderReviewBannerWidget({super.key, required this.progress});

  /// Visual completeness from 0..1 — purely cosmetic for now.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppStrings.of(locale, 'company_home_under_review_title'),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${AppStrings.of(locale, 'company_home_under_review_body')} ✅',
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6.h,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.brandBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

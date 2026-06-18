import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_account/data/company_account_view_data.dart';
import 'package:adzmavall/features/company_account/presentation/models/company_account_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class CompanyAccountStyle {
  static const Color signOut = Color(0xFFC85042);
  static const Color cardBorder = Color(0xFFE5E7EB);
}

class CompanyAccountMenuPanel extends StatelessWidget {
  const CompanyAccountMenuPanel({
    super.key,
    required this.onAction,
    required this.onSignOut,
  });

  final ValueChanged<CompanyAccountMenuAction> onAction;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (
          int i = 0;
          i < CompanyAccountViewData.menuSections.length;
          i++
        ) ...<Widget>[
          _SectionBlock(
            section: CompanyAccountViewData.menuSections[i],
            locale: locale,
            onAction: onAction,
          ),
          if (i != CompanyAccountViewData.menuSections.length - 1)
            SizedBox(height: 20.h),
        ],
        SizedBox(height: 22.h),
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: OutlinedButton.icon(
            onPressed: onSignOut,
            style: OutlinedButton.styleFrom(
              foregroundColor: CompanyAccountStyle.signOut,
              side: const BorderSide(color: CompanyAccountStyle.signOut),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28.r),
              ),
            ),
            icon: Icon(Icons.logout_rounded, size: 20.sp),
            label: Text(
              AppStrings.of(locale, 'company_account_sign_out'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.section,
    required this.locale,
    required this.onAction,
  });

  final CompanyAccountSection section;
  final Locale locale;
  final ValueChanged<CompanyAccountMenuAction> onAction;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppStrings.of(locale, section.titleKey),
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: CompanyAccountStyle.cardBorder),
          ),
          child: Column(
            children: <Widget>[
              for (int index = 0; index < section.items.length; index++) ...<Widget>[
                _MenuRow(
                  item: section.items[index],
                  locale: locale,
                  isRtl: isRtl,
                  onTap: () => onAction(section.items[index].action),
                ),
                if (index != section.items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 12.w,
                    endIndent: 12.w,
                    color: CompanyAccountStyle.cardBorder,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.item,
    required this.locale,
    required this.isRtl,
    required this.onTap,
  });

  final CompanyAccountMenuItem item;
  final Locale locale;
  final bool isRtl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          child: Row(
            children: <Widget>[
              Image.asset(
                item.iconAsset,
                width: 22.w,
                height: 22.w,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.circle_outlined,
                  size: 22.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Text(
                  AppStrings.of(locale, item.titleKey),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (item.trailingBalance != null) ...<Widget>[
                Text(
                  item.trailingBalance!,
                  style: TextStyle(
                    color: AppColors.brandBlue,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 4.w),
                Image.asset(
                  ImageAssets.rsIcon,
                  width: 18.w,
                  height: 18.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 6.w),
              ],
              Icon(
                isRtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

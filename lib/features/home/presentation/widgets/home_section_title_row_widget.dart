import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeSectionTitleRowWidget extends StatelessWidget {
  const HomeSectionTitleRowWidget({
    super.key,
    required this.titleKey,
    this.trailingKey,
    this.onTrailingTap,
    this.titleFontWeight = FontWeight.w700,
    this.autoSizeTexts = false,
  });

  final String titleKey;
  final String? trailingKey;
  final VoidCallback? onTrailingTap;
  final FontWeight titleFontWeight;
  final bool autoSizeTexts;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final TextStyle titleStyle = TextStyle(
      fontSize: 18.sp,
      fontWeight: titleFontWeight,
      color: AppColors.textPrimaryDark,
    );
    final TextStyle trailingStyle = TextStyle(
      color: AppColors.brandBlue,
      fontSize: 13.sp,
      fontWeight: FontWeight.w600,
    );

    if (autoSizeTexts) {
      return Row(
        children: <Widget>[
          Expanded(
            child: AutoSizeText(
              AppStrings.of(locale, titleKey),
              style: titleStyle,
              maxLines: 1,
              minFontSize: 11,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailingKey != null)
            TextButton(
              onPressed: onTrailingTap,
              style: TextButton.styleFrom(
                padding: EdgeInsets.only(left: 8.w),
                minimumSize: Size(0, 20.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: AutoSizeText(
                AppStrings.of(locale, trailingKey!),
                style: trailingStyle,
                maxLines: 1,
                minFontSize: 9,
                textAlign: TextAlign.end,
              ),
            ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          AppStrings.of(locale, titleKey),
          style: titleStyle,
        ),
        if (trailingKey != null)
          TextButton(
            onPressed: onTrailingTap,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 20.h),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              AppStrings.of(locale, trailingKey!),
              style: trailingStyle,
            ),
          ),
      ],
    );
  }
}

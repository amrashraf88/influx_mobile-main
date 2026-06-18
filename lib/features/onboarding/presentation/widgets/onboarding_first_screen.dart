import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';

class OnboardingFirstScreen extends StatelessWidget {
  const OnboardingFirstScreen({super.key, required this.onSkip});

  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      ImageAssets.onboarding0TopConnectedPeoples,
                      width: 309.w,
                      height: 389.h,
                      fit: BoxFit.scaleDown,
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Image.asset(
                ImageAssets.onboarding0Bot,
                // width: 402.w,/
                height: 412.h,
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomCenter,
              ),
            ),
            Positioned(
              left: 40.w,
              right: 40.w,
              bottom: 173.h,
              child: Text(
                AppStrings.of(locale, 'onboarding_first_lorem'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 16.sp,
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 48.h,
              child: Center(
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    AppStrings.of(locale, 'skip'),
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

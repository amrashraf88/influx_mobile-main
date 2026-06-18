import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/onboarding/presentation/models/onboarding_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingListScreen extends StatelessWidget {
  const OnboardingListScreen({
    super.key,
    required this.item,
  });

  final OnboardingModel item;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Stack(
      children: <Widget>[
        Positioned(
          top: 145.h,
          left: 22.w,
          right: 22.w,
          bottom: 414.h,
          child: Image.asset(item.imagePath, fit: BoxFit.contain),
        ),
        Positioned(
          left: 60.w,
          right: 60.w,
          bottom: 190.h,
          child: Image.asset(item.titleImagePath, fit: BoxFit.fitWidth),
        ),
        Positioned(
          left: 47.w,
          right: 47.w,
          bottom: 142.h,
          child: Text(
            AppStrings.of(locale, item.descriptionKey),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFAAAAAA),
              fontSize: 14.sp,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

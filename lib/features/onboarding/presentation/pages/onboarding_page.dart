import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/onboarding/presentation/onboarding_list.dart';
import 'package:adzmavall/features/onboarding/presentation/widgets/onboarding_first_screen.dart';
import 'package:adzmavall/features/onboarding/presentation/widgets/onboarding_list_screen.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:adzmavall/core/localization/app_strings.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  bool _showThreeOnboardingScreens = false;
  int _currentThreeScreensIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final isLastOnboardingPage =
        _currentThreeScreensIndex == onboardingList.length - 1;
    final double actionButtonSize = 57.w;
    final double progressRingSize = isLastOnboardingPage ? 60.w : 70.w;

    if (!_showThreeOnboardingScreens) {
      return OnboardingFirstScreen(
        onSkip: () {
          setState(() {
            _showThreeOnboardingScreens = true;
            _currentThreeScreensIndex = 0;
          });
        },
      );
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Stack(
          children: <Widget>[
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 498.h,
              child: Image.asset(ImageAssets.onboardingBg,height: 498.h, fit: BoxFit.fitHeight),
            ),
            PageView.builder(
              controller: _pageController,
              itemCount: onboardingList.length,
              onPageChanged: (value) {
                setState(() => _currentThreeScreensIndex = value);
              },
              itemBuilder: (context, index) {
                final item = onboardingList[index];
                return OnboardingListScreen(item: item);
              },
            ),
            SafeArea(
              bottom: false,
              top:false,
              child: Padding(
                padding: EdgeInsets.only(left: 20.w,right: 20.w,top: 20.h),
                child: Align(
                  alignment: isArabic ? Alignment.topLeft : Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h),
                    height: 25.h,
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                    child: TextButton(
                      onPressed: () => context.go(RouteNames.authAccountType),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size(25.w, 45.h),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.of(locale, 'skip'),
                        style: TextStyle(
                          color: const Color(0xFF263238),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 45.h,
              child: Center(
                child: SizedBox(
                  width: progressRingSize,
                  height: progressRingSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: progressRingSize,
                        height: progressRingSize,
                        child: CircularProgressIndicator(
                          value:
                              (_currentThreeScreensIndex + 1) /
                              onboardingList.length,
                          strokeWidth: 2.2.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF4D9AE7),
                          ),
                          // backgroundColor: const Color(0xFF2C3648),
                        ),
                      ),
                      SizedBox(
                        width: actionButtonSize,
                        height: actionButtonSize,
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            color: Color(0xFF0072DE),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (_currentThreeScreensIndex <
                                  onboardingList.length - 1) {
                                _pageController.animateToPage(
                                  _currentThreeScreensIndex + 1,
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOut,
                                );
                              } else {
                                context.go(RouteNames.authAccountType);
                              }
                            },
                            icon: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..scale(isArabic ? -1.0 : 1.0, 1.0),
                              child: Image.asset(
                                ImageAssets.onboardingArrow,
                                width: 13.w,
                                height: 10.55.w,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

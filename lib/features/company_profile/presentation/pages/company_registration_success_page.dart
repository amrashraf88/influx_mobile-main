import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_header_grid_painter.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Shown after company registration is submitted (temp flow until API exists).
///
/// [phone] is forwarded to the company home so the registered (data-filled)
/// home is shown after the user taps the CTA, without needing the backend.
class CompanyRegistrationSuccessPage extends StatelessWidget {
  const CompanyRegistrationSuccessPage({super.key, this.phone = ''});

  final String phone;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppColors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 360.h,
                      width: double.infinity,
                      child: CustomPaint(
                        foregroundPainter: AuthHeaderGridPainter(),
                        child: Container(color: AppColors.brandBlue),
                      ),
                    ),
                    const Expanded(child: ColoredBox(color: AppColors.white)),
                  ],
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Material(
                        elevation: 10,
                        shadowColor: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(22.r),
                        color: AppColors.white,
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(maxWidth: 400.w),
                          padding: EdgeInsets.fromLTRB(22.w, 36.h, 22.w, 28.h),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(22.r),
                            border: Border.all(color: const Color(0xFFE8ECF2)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const _SuccessMark(),
                              SizedBox(height: 28.h),
                              Text(
                                AppStrings.of(
                                  locale,
                                  'company_registration_success_title',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 14.h),
                              Text(
                                AppStrings.of(
                                  locale,
                                  'company_registration_success_subtitle',
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14.sp,
                                  height: 1.45,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 32.h),
                              SizedBox(
                                width: double.infinity,
                                height: 48.h,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.brandBlue,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        800.r,
                                      ),
                                    ),
                                    textStyle: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onPressed: () => context.go(
                                    RouteNames.companyHomePath(
                                      phone: phone,
                                      registered: true,
                                    ),
                                  ),
                                  child: Text(
                                    AppStrings.of(
                                      locale,
                                      'company_registration_home_cta',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      ImageAssets.receviedSuccessIcon,
      width: 142.w,
      height: 142.h,
      fit: BoxFit.contain,
    );
  }
}

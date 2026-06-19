import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/auth/presentation/cubit/auth_post_otp_navigator.dart';
import 'package:adzmavall/features/auth/presentation/cubit/otp_verification_cubit.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_flow_header_widget.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_header_grid_painter.dart';
import 'package:adzmavall/features/auth/presentation/widgets/otp_pin_input_widget.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationPage extends StatelessWidget {
  const OtpVerificationPage({
    super.key,
    required this.displayPhone,
    required this.accountType,
    this.creatorType,
    this.mode,
  });

  final String displayPhone;
  final String accountType;
  final String? creatorType;
  final String? mode;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final String subtitle = AppStrings.of(
      locale,
      'auth_verification_subtitle',
    ).replaceAll('{phone}', displayPhone);

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: SafeArea(
          bottom: false,
          top: false,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double headerHeight = 394.h;

              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      SizedBox(
                        height: headerHeight,
                        width: double.infinity,
                        child: CustomPaint(
                          foregroundPainter: AuthHeaderGridPainter(),
                          child: Container(
                            color: AppColors.brandBlue,
                            padding: EdgeInsets.only(top: 75.h),
                            child: AuthFlowHeaderWidget(
                              showStar: false,
                              centerText: true,
                              title: AppStrings.of(
                                locale,
                                'auth_verification_title',
                              ),
                              subtitle: subtitle,
                            ),
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    top: headerHeight - 137.h,
                    child: BlocConsumer<OtpVerificationCubit, OtpVerificationState>(
                      listenWhen:
                          (
                            OtpVerificationState previous,
                            OtpVerificationState current,
                          ) => previous.status != current.status,
                      listener:
                          (
                            BuildContext context,
                            OtpVerificationState state,
                          ) async {
                            if (state.status != OtpVerificationStatus.success) {
                              return;
                            }
                            final cubit = context.read<OtpVerificationCubit>();
                            if (!context.mounted) {
                              return;
                            }
                            context.go(
                              AuthPostOtpNavigator.routeAfterOtp(
                                accountType: accountType,
                                displayPhone: displayPhone,
                                hasExistingAccount: cubit.hasExistingAccount,
                                creatorType: creatorType,
                                mode: mode,
                              ),
                            );
                          },
                      builder: (context, state) {
                        final cubit = context.read<OtpVerificationCubit>();
                        final bool canSubmit =
                            state.isComplete && !state.isLoading;
                        return Material(
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20.r),
                          color: AppColors.white,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              24.h,
                              16.w,
                              23.h,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                OtpPinInputWidget(
                                  length: OtpVerificationState.codeLength,
                                  value: state.code,
                                  onChanged: cubit.setCode,
                                ),
                                if (state.errorMessage != null) ...<Widget>[
                                  SizedBox(height: 12.h),
                                  Text(
                                    state.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFFB91C1C),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 22.h),
                                SizedBox(
                                  height: 40.h,
                                  width: double.infinity,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: canSubmit
                                          ? AppColors.brandBlue
                                          : const Color(0xFFECEFF1),
                                      foregroundColor: canSubmit
                                          ? AppColors.white
                                          : const Color(0xFF90A4AE),
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
                                    onPressed: canSubmit
                                        ? cubit.completeOtp
                                        : null,
                                    child: state.isLoading
                                        ? SizedBox(
                                            width: 22.w,
                                            height: 22.w,
                                            child:
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.white,
                                                ),
                                          )
                                        : Text(
                                            AppStrings.of(locale, 'auth_next'),
                                          ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : cubit.resendOtp,
                                    child: Text(
                                      AppStrings.of(locale, 'auth_resend_code'),
                                      style: TextStyle(
                                        color: AppColors.brandBlue,
                                        fontSize: 16.sp,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.brandBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Align(
                                  alignment: Alignment.center,
                                  child: TextButton(
                                    onPressed: state.isLoading
                                        ? null
                                        : cubit.resendOtp,
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.textPrimary,
                                    ),
                                    child: Text(
                                      AppStrings.of(
                                        locale,
                                        'auth_send_via_whatsapp',
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

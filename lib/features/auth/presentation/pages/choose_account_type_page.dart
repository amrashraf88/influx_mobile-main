import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/auth/presentation/cubit/account_type_cubit.dart';
import 'package:adzmavall/features/auth/presentation/widgets/account_type_option_tile_widget.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_flow_header_widget.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChooseAccountTypePage extends StatelessWidget {
  const ChooseAccountTypePage({super.key, this.mode});

  final String? mode;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: SafeArea(
          bottom: false,
          top: false,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        // height: headerHeight.clamp(220.h, 313.h),
                        height: 313.h,
                        width: double.infinity,
                        color: AppColors.brandBlue,
                        alignment: Alignment.topCenter,
                        child: AuthFlowHeaderWidget(
                          title: AppStrings.of(
                            locale,
                            'auth_choose_account_title',
                          ),
                          subtitle: AppStrings.of(
                            locale,
                            'auth_choose_account_subtitle',
                          ),
                        ),
                      ),
                      // const Expanded(child: SizedBox()),
                    ],
                  ),
                  Positioned(
                    left: 20.w,
                    right: 20.w,
                    top: 313.h - 56.h,
                    child: BlocBuilder<AccountTypeCubit, AccountTypeState>(
                      builder: (context, state) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Material(
                              elevation: 8,
                              shadowColor: Colors.black.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20.r),
                              color: AppColors.white,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  24.w,
                                  24.h,
                                  24.w,
                                  24.h,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    AccountTypeOptionTileWidget(
                                      option: AccountTypeOption.influencer,
                                      selected: state.selected,
                                      title: AppStrings.of(
                                        locale,
                                        'auth_account_influencer_title',
                                      ),
                                      description: AppStrings.of(
                                        locale,
                                        'auth_account_influencer_desc',
                                      ),
                                      leading: _AccountTypeLeadingIcon(
                                        background: const Color(0xFFE3F2FD),
                                        child: Image.asset(
                                          ImageAssets.loginflowstarsicon,
                                          color: AppColors.brandBlue,
                                          width: 24.w,
                                          height: 24.h,
                                        ),
                                      ),
                                      onTap: () => context
                                          .read<AccountTypeCubit>()
                                          .select(AccountTypeOption.influencer),
                                    ),
                                    SizedBox(height: 12.h),
                                    AccountTypeOptionTileWidget(
                                      option: AccountTypeOption.company,
                                      selected: state.selected,
                                      title: AppStrings.of(
                                        locale,
                                        'auth_account_company_title',
                                      ),
                                      description: AppStrings.of(
                                        locale,
                                        'auth_account_company_desc',
                                      ),
                                      leading: _AccountTypeLeadingIcon(
                                        background: const Color(0xFFF1F5F9),
                                        child: Image.asset(
                                          ImageAssets.loginflowBuildingicon,
                                          color: const Color(0xFF64748B),
                                          width: 24.w,
                                          height: 24.h,
                                        ),
                                      ),
                                      onTap: () => context
                                          .read<AccountTypeCubit>()
                                          .select(AccountTypeOption.company),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    width: double.infinity,
                                    height: 40.h,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.brandBlue,
                                        foregroundColor: AppColors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24.r,
                                          ),
                                        ),
                                        textStyle: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      onPressed: () {
                                        final type = context
                                            .read<AccountTypeCubit>()
                                            .state
                                            .selected;
                                        if (mode == 'register') {
                                          if (type ==
                                              AccountTypeOption.company) {
                                            context.push(
                                              Uri(
                                                path: RouteNames.authPhone,
                                                queryParameters:
                                                    <String, String>{
                                                      'account': 'company',
                                                      'mode': 'register',
                                                    },
                                              ).toString(),
                                            );
                                          } else {
                                            context.push(
                                              RouteNames.authCreatorType,
                                            );
                                          }
                                          return;
                                        }
                                        context.push(
                                          Uri(
                                            path: RouteNames.authPhone,
                                            queryParameters: <String, String>{
                                              'account': type.name,
                                            },
                                          ).toString(),
                                        );
                                      },
                                      child: Text(
                                        AppStrings.of(locale, 'auth_next'),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16.h),
                                  TextButton(
                                    onPressed: () =>
                                        context.go(RouteNames.companyHome),
                                    child: Text(
                                      AppStrings.of(locale, 'auth_skip_setup'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.brandBlue,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                        decorationColor: AppColors.brandBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

class _AccountTypeLeadingIcon extends StatelessWidget {
  const _AccountTypeLeadingIcon({
    required this.background,
    required this.child,
  });

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: child,
    );
  }
}

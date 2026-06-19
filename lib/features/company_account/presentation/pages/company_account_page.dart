import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/auth/auth_token_storage.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/core/widgets/app_feedback.dart';
import 'package:adzmavall/features/company_account/data/company_account_repository.dart';
import 'package:adzmavall/features/company_account/data/company_account_view_data.dart';
import 'package:adzmavall/features/company_account/presentation/models/company_account_models.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_menu_panel.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_profile_header.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_sign_out_dialog.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_header_background.dart';
import 'package:adzmavall/features/influencer_settings/data/wallet_repository.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CompanyAccountPage extends StatefulWidget {
  const CompanyAccountPage({super.key});

  @override
  State<CompanyAccountPage> createState() => _CompanyAccountPageState();
}

class _CompanyAccountPageState extends State<CompanyAccountPage> {
  CompanyAccountProfile _profile = CompanyAccountViewData.profile;
  String _walletBalance = CompanyAccountViewData.profile.walletBalance;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!AuthTokenStorage.instance.isBrand) {
      return;
    }
    if (!ApiUrlResolver.isConfigured) {
      return;
    }
    try {
      final CompanyAccountProfile profile = await CompanyAccountRepository(
        DioClient.instance,
      ).fetchProfile();
      if (!mounted) {
        return;
      }
      setState(() => _profile = profile);
    } on Object {
      // Keep the view-data fallback already in _profile.
    }
    try {
      final WalletSummary wallet = await WalletRepository(
        DioClient.instance,
      ).fetchSummary();
      if (!mounted) {
        return;
      }
      setState(() {
        _walletBalance = wallet.availableBalance.toString();
      });
    } on Object {
      // Keep the view-data balance.
    }
  }

  void _onMenuAction(BuildContext context, CompanyAccountMenuAction action) {
    switch (action) {
      case CompanyAccountMenuAction.wallet:
        context.push(RouteNames.companyAccountWallet);
      case CompanyAccountMenuAction.myBills:
        context.push(RouteNames.companyAccountBills);
      case CompanyAccountMenuAction.language:
        context.push(RouteNames.companyAccountLanguage);
      case CompanyAccountMenuAction.shareApp:
        showAppFeedback(
          context,
          message: 'Share app will be connected later.',
          type: AppFeedbackType.info,
        );
      case CompanyAccountMenuAction.settings:
        context.push(RouteNames.companyAccountSettings);
      case CompanyAccountMenuAction.contactUs:
        context.push(RouteNames.companyAccountContact);
      case CompanyAccountMenuAction.about:
        context.push(RouteNames.companyAccountAbout);
    }
  }

  Future<void> _onSignOut(BuildContext context) async {
    final bool? confirmed = await showCompanySignOutDialog(context);
    if (confirmed == true && context.mounted) {
      context.go(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Stack(
        children: <Widget>[
          InfluencerHeaderBackground(height: 280.h),
          SafeArea(
            bottom: false,
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: <Widget>[
                Positioned(
                  left: 0,
                  right: 0,
                  top: 188.h,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.pageBackground,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                      child: CompanyAccountMenuPanel(
                        walletBalance: _walletBalance,
                        onAction: (CompanyAccountMenuAction a) =>
                            _onMenuAction(context, a),
                        onSignOut: () => _onSignOut(context),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: 200.h,
                  child: CompanyAccountProfileHeader(profile: _profile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:adzmavall/core/auth/auth_token_storage.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/core/widgets/app_feedback.dart';
import 'package:adzmavall/features/influencer_profile/presentation/pages/edit_profile_page.dart';
import 'package:adzmavall/features/influencer_profile/presentation/profile_refresh_notifier.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_header_background.dart';
import 'package:adzmavall/features/influencer_settings/data/settings_repository.dart';
import 'package:adzmavall/features/influencer_settings/presentation/influencer_settings_static_menu.dart';
import 'package:adzmavall/features/influencer_settings/presentation/models/influencer_settings_models.dart';
import 'package:adzmavall/features/influencer_settings/presentation/pages/about_app_page.dart';
import 'package:adzmavall/features/influencer_settings/presentation/pages/app_settings_page.dart';
import 'package:adzmavall/features/influencer_settings/presentation/pages/contact_us_page.dart';
import 'package:adzmavall/features/influencer_settings/presentation/pages/language_page.dart';
import 'package:adzmavall/features/influencer_settings/presentation/pages/mawthooq_page.dart';
import 'package:adzmavall/features/influencer_settings/presentation/pages/wallet_page.dart';
import 'package:adzmavall/features/influencer_settings/presentation/widgets/influencer_settings_panel.dart';
import 'package:adzmavall/features/influencer_settings/presentation/widgets/influencer_settings_profile_header.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InfluencerSettingsPage extends StatefulWidget {
  const InfluencerSettingsPage({super.key});

  @override
  State<InfluencerSettingsPage> createState() => _InfluencerSettingsPageState();
}

class _InfluencerSettingsPageState extends State<InfluencerSettingsPage> {
  InfluencerSettingsProfile _profile = InfluencerSettingsStaticMenu.demoProfile;

  SettingsRepository get _repo => SettingsRepository(DioClient.instance);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    influencerProfileRefresh.addListener(_loadProfile);
  }

  @override
  void dispose() {
    influencerProfileRefresh.removeListener(_loadProfile);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (!ApiUrlResolver.isConfigured) return;
    try {
      final InfluencerSettingsProfile p = await _repo.fetchProfile();
      if (mounted) setState(() => _profile = p);
    } on Object {
      // Keep the demo fallback already in _profile.
    }
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  Future<void> _signOut(BuildContext context) async {
    final bool? confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.fromLTRB(
            20.w,
            20.h,
            20.w,
            MediaQuery.paddingOf(sheetContext).bottom + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.logout_rounded, size: 40.sp, color: AppColors.error),
              SizedBox(height: 14.h),
              Text(
                'Sign out ?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.fgPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'You will need to sign in again to access your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.45,
                  color: AppColors.fgQuaternary,
                ),
              ),
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(800.r),
                    ),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(true),
                  child: const Text('Sign out'),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.fgTertiary,
                    side: const BorderSide(color: AppColors.borderPrimary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(800.r),
                    ),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(false),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      // Best-effort server-side logout; always clear the local token after.
      if (ApiUrlResolver.isConfigured) {
        try {
          await _repo.logout();
        } on Object {
          // Ignore — proceed with local sign-out regardless.
        }
      }
      await AuthTokenStorage.instance.clearToken();
      if (context.mounted) {
        context.go(RouteNames.onboarding);
      }
    }
  }

  void _handleAction(
    BuildContext context,
    InfluencerSettingsAction action,
    String label,
  ) {
    switch (action) {
      case InfluencerSettingsAction.editProfile:
        _push(context, const EditProfilePage());
        return;
      case InfluencerSettingsAction.wallet:
        _push(context, const WalletPage());
        return;
      case InfluencerSettingsAction.language:
        _push(context, const LanguagePage());
        return;
      case InfluencerSettingsAction.settings:
        _push(context, const AppSettingsPage());
        return;
      case InfluencerSettingsAction.about:
        _push(context, const AboutAppPage());
        return;
      case InfluencerSettingsAction.verifyAccount:
      case InfluencerSettingsAction.mawthooqLicense:
        _push(context, const MawthooqPage());
        return;
      case InfluencerSettingsAction.contactUs:
        _push(context, const ContactUsPage());
        return;
      case InfluencerSettingsAction.shareApp:
        Clipboard.setData(
          const ClipboardData(
            text:
                'https://adzmavall.com — Discover & collaborate on Adz Mavall',
          ),
        );
        showAppFeedback(
          context,
          message: 'App link copied',
          type: AppFeedbackType.success,
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';
    final InfluencerSettingsProfile profile = _profile;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: AppColors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Stack(
          children: <Widget>[
            InfluencerHeaderBackground(height: 350.h),
            SafeArea(
              bottom: false,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 200.h,
                    bottom: 0,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      child: Column(
                        children: <Widget>[
                          InfluencerSettingsPanel(
                            profile: profile,
                            onAction:
                                (
                                  InfluencerSettingsAction action,
                                  String label,
                                ) {
                                  _handleAction(context, action, label);
                                },
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.error,
                                side: const BorderSide(color: AppColors.error),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(800.r),
                                ),
                                textStyle: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              onPressed: () => _signOut(context),
                              icon: Icon(Icons.logout_rounded, size: 18.sp),
                              label: const Text('Sign out'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 232.h,
                    child: InfluencerSettingsProfileHeader(
                      profile: profile,
                      onEdit: () => _handleAction(
                        context,
                        InfluencerSettingsAction.editProfile,
                        'Edit profile',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

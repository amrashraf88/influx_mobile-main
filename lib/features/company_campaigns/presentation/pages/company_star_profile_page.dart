import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/company_campaigns/data/company_stars_repository.dart';
import 'package:adzmavall/features/company_campaigns/data/company_stars_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_star_models.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_header_background.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_profile_summary_card.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_profile_tab_bar.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_panel_card.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CompanyStarProfilePage extends StatefulWidget {
  const CompanyStarProfilePage({super.key, required this.starId});

  final String starId;

  @override
  State<CompanyStarProfilePage> createState() => _CompanyStarProfilePageState();
}

class _CompanyStarProfilePageState extends State<CompanyStarProfilePage> {
  int _tabIndex = 2;
  late CompanyStarProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = CompanyStarsViewData.profileFor(widget.starId);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!ApiUrlResolver.isConfigured) {
      return;
    }
    try {
      final CompanyStarProfile profile = await CompanyStarsRepository(
        DioClient.instance,
      ).fetchStarProfile(widget.starId);
      if (!mounted) {
        return;
      }
      setState(() => _profile = profile);
    } on Object {
      // Keep the view-data fallback already in _profile.
    }
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final CompanyStarProfile profile = _profile;
    final double topInset = MediaQuery.paddingOf(context).top;
    final List<InfluencerProfileTabItem> tabs = <InfluencerProfileTabItem>[
      InfluencerProfileTabItem(
        label: AppStrings.of(locale, 'company_star_tab_accounts'),
        asset: ImageAssets.categoryIcon,
      ),
      InfluencerProfileTabItem(
        label: AppStrings.of(locale, 'company_star_tab_clients'),
        asset: ImageAssets.userStarIcon,
      ),
      InfluencerProfileTabItem(
        label: AppStrings.of(locale, 'company_star_tab_ad_price'),
        asset: ImageAssets.hotPriceIcon,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Stack(
          children: <Widget>[
            InfluencerHeaderBackground(height: 158.h),
            SafeArea(
              top: false,
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: topInset + 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: _ProfileBackButton(onTap: () => context.pop()),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: InfluencerProfileSummaryCard(
                      profile: InfluencerProfileSummaryData(
                        name: profile.name,
                        title: profile.headline,
                        bio: profile.bio,
                        avatarUrl: profile.avatarUrl,
                        mawthooqLabel: profile.mawthooqLabel,
                      ),
                      contactActions: <InfluencerContactAction>[
                        InfluencerContactAction(
                          label: AppStrings.of(locale, 'company_star_chat'),
                          asset: ImageAssets.homeBottomNavChat,
                        ),
                        const InfluencerContactAction(
                          label: 'Whatsapp',
                          asset: ImageAssets.whatsappIcon,
                        ),
                        InfluencerContactAction(
                          label: AppStrings.of(locale, 'company_star_email'),
                          asset: ImageAssets.mailIcon,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  InfluencerProfileTabBar(
                    tabs: tabs,
                    selectedIndex: _tabIndex,
                    onChanged: (int index) => setState(() => _tabIndex = index),
                  ),
                  SizedBox(height: 18.h),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 100.h),
                      child: _tabIndex == 2
                          ? Column(
                              children: profile.adPrices
                                  .map(
                                    (CompanyStarAdPriceLine line) => Padding(
                                      padding: EdgeInsets.only(bottom: 14.h),
                                      child: _AdPriceCard(
                                        line: line,
                                        locale: locale,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: SizedBox(
              height: 48.h,
              child: FilledButton(
                onPressed: () => context.push(
                  RouteNames.companyRequestAdPath(widget.starId),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Text(
                  AppStrings.of(locale, 'company_star_request_ad'),
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileBackButton extends StatelessWidget {
  const _ProfileBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdPriceCard extends StatelessWidget {
  const _AdPriceCard({required this.line, required this.locale});

  final CompanyStarAdPriceLine line;
  final Locale locale;

  String? get _platformAsset {
    switch (line.labelKey) {
      case 'company_star_platform_snapchat':
        return ImageAssets.snapchatIcon;
      case 'company_star_platform_tiktok':
        return ImageAssets.homeInfluencerTiktok;
      case 'company_star_platform_whatsapp':
        return ImageAssets.whatsappIcon;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? asset = _platformAsset;
    return InfluencerPanelCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              if (asset != null) ...<Widget>[
                Image.asset(asset, width: 25.w, height: 25.h),
                SizedBox(width: 6.w),
              ],
              Expanded(
                child: Text(
                  AppStrings.of(locale, line.labelKey),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8D8),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '399.6k ${AppStrings.of(locale, 'company_star_followers')}',
                  style: TextStyle(
                    color: const Color(0xFFE6C44E),
                    fontSize: 8.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 28.w,
                height: 28.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F7FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.open_in_new_rounded,
                  color: const Color(0xFF6EC7EA),
                  size: 15.sp,
                ),
              ),
            ],
          ),
          Divider(height: 22.h, color: const Color(0xFFE7E9ED)),
          Row(
            children: <Widget>[
              Expanded(
                child: _PriceMetric(
                  label: AppStrings.of(locale, 'company_star_coverage'),
                  value: line.coveragePrice,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: _PriceMetric(
                  label: AppStrings.of(locale, 'company_star_video'),
                  value: line.videoPrice,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceMetric extends StatelessWidget {
  const _PriceMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF7D8591),
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8.w),
            Image.asset(ImageAssets.rsIcon, width: 16.w, height: 16.h),
          ],
        ),
      ],
    );
  }
}

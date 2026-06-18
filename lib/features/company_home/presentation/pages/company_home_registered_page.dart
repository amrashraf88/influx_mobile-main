import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/company_home/data/company_home_repository.dart';
import 'package:adzmavall/features/company_home/data/company_home_view_data.dart';
import 'package:adzmavall/features/company_home/presentation/models/company_home_models.dart';
import 'package:adzmavall/features/company_home/presentation/widgets/company_home_campaign_card_widget.dart';
import 'package:adzmavall/features/company_home/presentation/widgets/company_home_category_item_widget.dart';
import 'package:adzmavall/features/company_home/presentation/widgets/company_home_header_widget.dart';
import 'package:adzmavall/features/company_home/presentation/widgets/company_home_influencer_card_widget.dart';
import 'package:adzmavall/features/company_home/presentation/widgets/company_under_review_banner_widget.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_section_title_row_widget.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home shown to a registered company (after profile completion).
///
/// All data is loaded via [CompanyHomeRepository], with [CompanyHomeViewData]
/// fallbacks while [ApiUrlResolver.isConfigured] is false.
class CompanyHomeRegisteredPage extends StatefulWidget {
  const CompanyHomeRegisteredPage({super.key});

  @override
  State<CompanyHomeRegisteredPage> createState() =>
      _CompanyHomeRegisteredPageState();
}

class _CompanyHomeRegisteredPageState extends State<CompanyHomeRegisteredPage> {
  late final Future<CompanyHomeSummary> _summaryFuture;
  late final Future<List<CompanyHomeCampaign>> _campaignsFuture;
  late final Future<List<CompanyHomeCategory>> _categoriesFuture;
  late final Future<List<CompanyHomeInfluencer>> _influencersFuture;

  CompanyHomeRepository? _repo;

  @override
  void initState() {
    super.initState();
    if (ApiUrlResolver.isConfigured) {
      _repo = CompanyHomeRepository(DioClient.instance);
    }
    _summaryFuture = _loadSummary();
    _campaignsFuture = _loadCampaigns();
    _categoriesFuture = _loadCategories();
    _influencersFuture = _loadInfluencers();
  }

  Future<CompanyHomeSummary> _loadSummary() async {
    if (_repo == null) {
      return CompanyHomeViewData.summary;
    }
    try {
      return await _repo!.fetchSummary();
    } on Object {
      return CompanyHomeViewData.summary;
    }
  }

  Future<List<CompanyHomeCampaign>> _loadCampaigns() async {
    if (_repo == null) {
      return CompanyHomeViewData.currentCampaigns;
    }
    try {
      final List<CompanyHomeCampaign> list = await _repo!
          .fetchCurrentCampaigns();
      return list.isNotEmpty ? list : CompanyHomeViewData.currentCampaigns;
    } on Object {
      return CompanyHomeViewData.currentCampaigns;
    }
  }

  Future<List<CompanyHomeCategory>> _loadCategories() async {
    if (_repo == null) {
      return CompanyHomeViewData.categories;
    }
    try {
      final List<CompanyHomeCategory> list = await _repo!.fetchCategories();
      return list.isNotEmpty ? list : CompanyHomeViewData.categories;
    } on Object {
      return CompanyHomeViewData.categories;
    }
  }

  Future<List<CompanyHomeInfluencer>> _loadInfluencers() async {
    if (_repo == null) {
      return CompanyHomeViewData.influencers;
    }
    try {
      final List<CompanyHomeInfluencer> list = await _repo!.fetchInfluencers();
      return list.isNotEmpty ? list : CompanyHomeViewData.influencers;
    } on Object {
      return CompanyHomeViewData.influencers;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ColoredBox(
        color: AppColors.pageBackground,
        child: SafeArea(
          top: false,
          bottom: false,
          child: FutureBuilder<CompanyHomeSummary>(
            future: _summaryFuture,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<CompanyHomeSummary> snapshot,
                ) {
                  final CompanyHomeSummary summary =
                      snapshot.data ?? CompanyHomeViewData.summary;
                  return _Body(
                    summary: summary,
                    campaignsFuture: _campaignsFuture,
                    categoriesFuture: _categoriesFuture,
                    influencersFuture: _influencersFuture,
                  );
                },
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.summary,
    required this.campaignsFuture,
    required this.categoriesFuture,
    required this.influencersFuture,
  });

  final CompanyHomeSummary summary;
  final Future<List<CompanyHomeCampaign>> campaignsFuture;
  final Future<List<CompanyHomeCategory>> categoriesFuture;
  final Future<List<CompanyHomeInfluencer>> influencersFuture;

  @override
  Widget build(BuildContext context) {
    final double safeTopInset = MediaQuery.paddingOf(context).top;
    final double headerHeight =
        (summary.isUnderReview ? 215.h : 168.h) + safeTopInset;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: CompanyHomeHeaderBackground(height: headerHeight - 30.h),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          top: safeTopInset + 12.h,
          child: CompanyHomeHeaderRow(
            brandLogoUrl: ImageAssets.adzmavelHomescreenLogo,
            onSearchTap: () {},
          ),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          top: safeTopInset + 70.h,
          child: summary.isUnderReview
              ? CompanyUnderReviewBannerWidget(progress: summary.reviewProgress)
              : _buildApprovedSearchField(context),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: headerHeight - 30.h,
          bottom: 0,
          child: _Sections(
            campaignsFuture: campaignsFuture,
            categoriesFuture: categoriesFuture,
            influencersFuture: influencersFuture,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedSearchField(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(28.r),
      child: Container(
        height: 44.h,
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                AppStrings.of(locale, 'company_home_search_hint'),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({
    required this.campaignsFuture,
    required this.categoriesFuture,
    required this.influencersFuture,
  });

  final Future<List<CompanyHomeCampaign>> campaignsFuture;
  final Future<List<CompanyHomeCategory>> categoriesFuture;
  final Future<List<CompanyHomeInfluencer>> influencersFuture;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          HomeSectionTitleRowWidget(
            titleKey: 'company_home_section_current_campaign',
            trailingKey: 'company_home_see_all',
            onTrailingTap: () {},
          ),
          SizedBox(height: 12.h),
          _CampaignsRow(future: campaignsFuture),
          SizedBox(height: 22.h),
          HomeSectionTitleRowWidget(
            titleKey: 'company_home_section_categories',
            trailingKey: 'company_home_see_all',
            onTrailingTap: () {},
          ),
          SizedBox(height: 12.h),
          _CategoriesRow(future: categoriesFuture),
          SizedBox(height: 22.h),
          HomeSectionTitleRowWidget(
            titleKey: 'company_home_section_influencers',
            trailingKey: 'company_home_see_all',
            onTrailingTap: () {},
          ),
          SizedBox(height: 12.h),
          _InfluencersGrid(future: influencersFuture),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _CampaignsRow extends StatelessWidget {
  const _CampaignsRow({required this.future});

  final Future<List<CompanyHomeCampaign>> future;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 142.h,
      child: FutureBuilder<List<CompanyHomeCampaign>>(
        future: future,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<List<CompanyHomeCampaign>> snapshot,
            ) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final List<CompanyHomeCampaign> items =
                  snapshot.data ?? CompanyHomeViewData.currentCampaigns;
              if (items.isEmpty) {
                return const SizedBox.shrink();
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (BuildContext _, int _) =>
                    SizedBox(width: 12.w),
                itemBuilder: (BuildContext context, int index) {
                  return CompanyHomeCampaignCardWidget(campaign: items[index]);
                },
              );
            },
      ),
    );
  }
}

class _CategoriesRow extends StatelessWidget {
  const _CategoriesRow({required this.future});

  final Future<List<CompanyHomeCategory>> future;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: FutureBuilder<List<CompanyHomeCategory>>(
        future: future,
        builder:
            (
              BuildContext context,
              AsyncSnapshot<List<CompanyHomeCategory>> snapshot,
            ) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final List<CompanyHomeCategory> items =
                  snapshot.data ?? CompanyHomeViewData.categories;
              if (items.isEmpty) {
                return const SizedBox.shrink();
              }
              // Fixed-width, horizontally scrollable tiles so each icon keeps
              // its designed size (matches the mockup) even when the API
              // returns more than four categories.
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (BuildContext _, int _) =>
                    SizedBox(width: 12.w),
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: 76.w,
                    child: CompanyHomeCategoryItemWidget(
                      category: items[index],
                      index: index,
                    ),
                  );
                },
              );
            },
      ),
    );
  }
}

class _InfluencersGrid extends StatelessWidget {
  const _InfluencersGrid({required this.future});

  final Future<List<CompanyHomeInfluencer>> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CompanyHomeInfluencer>>(
      future: future,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<CompanyHomeInfluencer>> snapshot,
          ) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SizedBox(
                height: 200.h,
                child: Center(
                  child: SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            final List<CompanyHomeInfluencer> items =
                snapshot.data ?? CompanyHomeViewData.influencers;
            if (items.isEmpty) {
              return const SizedBox.shrink();
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.68,
              ),
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return CompanyHomeInfluencerCardWidget(
                  influencer: items[index],
                );
              },
            );
          },
    );
  }
}

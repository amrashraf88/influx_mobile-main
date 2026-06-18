import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/home/data/home_categories_repository.dart';
import 'package:adzmavall/features/home/data/home_search_hint_repository.dart';
import 'package:adzmavall/features/home/data/home_trending_tags_repository.dart';
import 'package:adzmavall/features/home/data/home_welcome_repository.dart';
import 'package:adzmavall/features/home/data/home_why_features_repository.dart';
import 'package:adzmavall/features/home/data/top_stories_repository.dart';
import 'package:adzmavall/features/home/data/top_influencers_repository.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:adzmavall/features/home/presentation/models/home_view_data.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_bottom_nav_widget.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_categories_row_widget.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_influencer_card_widget.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_search_bar_widget.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_section_title_row_widget.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_star_header_widget.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_trending_section_widget.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_welcome_card_widget.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_why_adz_section_widget.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,

    /// When false, no bottom bar here — used inside [CompanyShellPage].
    this.showInfluencerMarketingBottomNav = true,
  });

  /// The marketing home shown when skipping login; includes influencer-style nav
  /// only when this page is not embedded in the company shell.
  final bool showInfluencerMarketingBottomNav;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<HomeInfluencerModel>> _topInfluencersFuture;
  late final Future<List<HomeStoryModel>> _topStoriesFuture;
  late final Future<List<HomeCategoryModel>> _categoriesFuture;
  late final Future<List<HomeTrendingTagModel>> _trendingTagsFuture;
  late final Future<HomeWelcomeCardContent?> _welcomeFuture;
  late final Future<List<HomeWhyFeatureModel>> _whyFeaturesFuture;
  late final Future<String?> _searchHintFuture;

  @override
  void initState() {
    super.initState();
    _topInfluencersFuture = _loadTopInfluencers();
    _topStoriesFuture = _loadTopStories();
    _categoriesFuture = _loadCategories();
    _trendingTagsFuture = _loadTrendingTags();
    _welcomeFuture = _loadWelcomeContent();
    _whyFeaturesFuture = _loadWhyFeatures();
    _searchHintFuture = _loadSearchHint();
  }

  Future<List<HomeInfluencerModel>> _loadTopInfluencers() async {
    if (!ApiUrlResolver.isConfigured) {
      return HomeViewData.featuredInfluencers;
    }
    try {
      final List<HomeInfluencerModel> list = await TopInfluencersRepository(
        DioClient.instance,
      ).fetchTopInfluencers();
      return list.isNotEmpty ? list : HomeViewData.featuredInfluencers;
    } on Object {
      return HomeViewData.featuredInfluencers;
    }
  }

  Future<List<HomeStoryModel>> _loadTopStories() async {
    if (!ApiUrlResolver.isConfigured) {
      return HomeViewData.trendingStories;
    }
    try {
      final List<HomeStoryModel> list = await TopStoriesRepository(
        DioClient.instance,
      ).fetchTopStories();
      return list.isNotEmpty ? list : HomeViewData.trendingStories;
    } on Object {
      return HomeViewData.trendingStories;
    }
  }

  Future<List<HomeCategoryModel>> _loadCategories() async {
    if (!ApiUrlResolver.isConfigured) {
      return HomeViewData.categories;
    }
    try {
      final List<HomeCategoryModel> list = await HomeCategoriesRepository(
        DioClient.instance,
      ).fetchCategories();
      return list.isNotEmpty ? list : HomeViewData.categories;
    } on Object {
      return HomeViewData.categories;
    }
  }

  Future<List<HomeTrendingTagModel>> _loadTrendingTags() async {
    if (!ApiUrlResolver.isConfigured) {
      return HomeViewData.trendingTags;
    }
    try {
      final List<HomeTrendingTagModel> list = await HomeTrendingTagsRepository(
        DioClient.instance,
      ).fetchTrendingTags();
      return list.isNotEmpty ? list : HomeViewData.trendingTags;
    } on Object {
      return HomeViewData.trendingTags;
    }
  }

  Future<HomeWelcomeCardContent?> _loadWelcomeContent() async {
    if (!ApiUrlResolver.isConfigured) {
      return null;
    }
    try {
      return await HomeWelcomeRepository(
        DioClient.instance,
      ).fetchWelcomeContent();
    } on Object {
      return null;
    }
  }

  Future<List<HomeWhyFeatureModel>> _loadWhyFeatures() async {
    if (!ApiUrlResolver.isConfigured) {
      return HomeViewData.whyFeatures;
    }
    try {
      final List<HomeWhyFeatureModel> list = await HomeWhyFeaturesRepository(
        DioClient.instance,
      ).fetchWhyFeatures();
      return list.isNotEmpty ? list : HomeViewData.whyFeatures;
    } on Object {
      return HomeViewData.whyFeatures;
    }
  }

  Future<String?> _loadSearchHint() async {
    if (!ApiUrlResolver.isConfigured) {
      return null;
    }
    try {
      return await HomeSearchHintRepository(
        DioClient.instance,
      ).fetchSearchHint();
    } on Object {
      return null;
    }
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      context.go(RouteNames.influencerProfile);
    } else if (index == 1) {
      context.go(RouteNames.influencerOrders);
    } else if (index == 3) {
      context.go(RouteNames.influencerChats);
    } else if (index == 4) {
      context.go(RouteNames.influencerSettings);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Column(
        children: <Widget>[
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              const HomeStarHeaderWidget(),
              Positioned(
                left: 16.w,
                right: 16.w,
                bottom: 30.h,
                child: FutureBuilder<String?>(
                  future: _searchHintFuture,
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                        return HomeSearchBarWidget(hintText: snapshot.data);
                      },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FutureBuilder<HomeWelcomeCardContent?>(
                    future: _welcomeFuture,
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<HomeWelcomeCardContent?> snapshot,
                        ) {
                          return HomeWelcomeCardWidget(content: snapshot.data);
                        },
                  ),
                  SizedBox(height: 24.h),
                  HomeSectionTitleRowWidget(
                    titleKey: 'home_section_categories',
                    trailingKey: 'home_show_more',
                    onTrailingTap: () {},
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    height: 175.h,
                    child: FutureBuilder<List<HomeCategoryModel>>(
                      future: _categoriesFuture,
                      builder:
                          (
                            BuildContext context,
                            AsyncSnapshot<List<HomeCategoryModel>> snapshot,
                          ) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return Center(
                                child: SizedBox(
                                  width: 28.w,
                                  height: 28.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            final List<HomeCategoryModel> items =
                                snapshot.data ?? HomeViewData.categories;
                            return HomeCategoriesRowWidget(items: items);
                          },
                    ),
                  ),
                  SizedBox(height: 22.h),
                  HomeSectionTitleRowWidget(
                    titleKey: 'home_section_featured',
                    trailingKey: 'home_show_more',
                    onTrailingTap: () {},
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    AppStrings.of(locale, 'home_featured_subtitle'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 315.h,
                    child: FutureBuilder<List<HomeInfluencerModel>>(
                      future: _topInfluencersFuture,
                      builder:
                          (
                            BuildContext context,
                            AsyncSnapshot<List<HomeInfluencerModel>> snapshot,
                          ) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return Center(
                                child: SizedBox(
                                  width: 28.w,
                                  height: 28.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            final List<HomeInfluencerModel> items =
                                snapshot.data ??
                                HomeViewData.featuredInfluencers;
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: items.length,
                              separatorBuilder: (BuildContext context, int i) =>
                                  SizedBox(width: 16.w),
                              itemBuilder: (BuildContext context, int index) {
                                return HomeInfluencerCardWidget(
                                  model: items[index],
                                );
                              },
                            );
                          },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  HomeTrendingSectionWidget(
                    tagsFuture: _trendingTagsFuture,
                    storiesFuture: _topStoriesFuture,
                  ),
                  SizedBox(height: 22.h),
                  FutureBuilder<List<HomeWhyFeatureModel>>(
                    future: _whyFeaturesFuture,
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<List<HomeWhyFeatureModel>> snapshot,
                        ) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return SizedBox(
                              height: 280.h,
                              child: Center(
                                child: SizedBox(
                                  width: 28.w,
                                  height: 28.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final List<HomeWhyFeatureModel> features =
                              snapshot.data ?? HomeViewData.whyFeatures;
                          return HomeWhyAdzSectionWidget(features: features);
                        },
                  ),
                  // SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showInfluencerMarketingBottomNav
          ? Material(
              color: Colors.transparent,
              elevation: 0,
              child: HomeBottomNavWidget(
                currentIndex: 2,
                firstItemLabelKey: 'influencer_nav_profile',
                firstItemIcon: Icons.person_outline_rounded,
                onTap: _onBottomNavTap,
              ),
            )
          : null,
    );
  }
}

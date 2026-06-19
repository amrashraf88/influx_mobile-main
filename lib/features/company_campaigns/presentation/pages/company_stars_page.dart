import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/company_campaigns/data/company_stars_repository.dart';
import 'package:adzmavall/features/company_campaigns/data/company_stars_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_star_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_star_grid_card.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_stars_filter_sheet.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Stars directory — browse tab or influencer pick flow (UI only).
class CompanyStarsPage extends StatefulWidget {
  const CompanyStarsPage({super.key, this.selectionMode = false});

  /// True when opened from create-campaign (All / Selected + Next).
  final bool selectionMode;

  @override
  State<CompanyStarsPage> createState() => _CompanyStarsPageState();
}

class _CompanyStarsPageState extends State<CompanyStarsPage> {
  static const int _perPage = 10;

  bool _secondaryTabOn = false;
  bool _showSelectedOnly = false;
  CompanyStarCategory _category = CompanyStarCategory.all;
  final TextEditingController _search = TextEditingController();
  final CompanyStarsFilterDraft _filter = CompanyStarsFilterDraft();
  final Set<String> _selectedIds = <String>{};
  final ScrollController _scrollController = ScrollController();
  final Set<String> _seenKeys = <String>{};
  late List<CompanyStarListItem> _stars;

  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;
  bool _initialLoading = false;

  @override
  void initState() {
    super.initState();
    _stars = <CompanyStarListItem>[];
    if (widget.selectionMode) {
      _secondaryTabOn = false;
    }
    _scrollController.addListener(_onScroll);
    _loadPage(reset: true);
  }

  CompanyStarsRepository get _repo => CompanyStarsRepository(DioClient.instance);

  /// Server-side type filter for the active category (null = all types).
  String? get _typeParam => switch (_category) {
    CompanyStarCategory.all => null,
    CompanyStarCategory.influencer => 'influencer',
    CompanyStarCategory.model => 'model',
    CompanyStarCategory.ugc => 'ugc',
    CompanyStarCategory.collage => 'collage',
  };

  /// Loads the next page (or page 1 when [reset]), appending de-duplicated rows.
  Future<void> _loadPage({bool reset = false}) async {
    if (!ApiUrlResolver.isConfigured) {
      // Pure-UI mode (no backend): show sample data once.
      if (_stars.isEmpty) {
        setState(
          () => _stars = List<CompanyStarListItem>.from(
            CompanyStarsViewData.stars,
          ),
        );
      }
      _hasMore = false;
      return;
    }
    if (_loadingMore) {
      return;
    }
    if (!reset && !_hasMore) {
      return;
    }

    final int pageToLoad = reset ? 1 : _page + 1;
    setState(() {
      _loadingMore = true;
      if (reset) {
        _initialLoading = true;
      }
    });

    try {
      final CompanyStarsPageResult result = await _repo.fetchStarsPage(
        page: pageToLoad,
        perPage: _perPage,
        type: _typeParam,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        if (reset) {
          _stars = <CompanyStarListItem>[];
          _seenKeys.clear();
        }
        int added = 0;
        for (final CompanyStarListItem star in result.items) {
          final String key = star.id.isNotEmpty
              ? star.id
              : '${star.name}-${star.coverImageUrl}';
          if (_seenKeys.add(key)) {
            _stars.add(star);
            added += 1;
          }
        }
        _page = result.page;
        _hasMore = result.hasMore && added > 0;
        _loadingMore = false;
        _initialLoading = false;
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingMore = false;
        _initialLoading = false;
        if (reset) {
          // Keep the list empty on failure — the empty state is shown.
          _hasMore = false;
        }
      });
    }
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore) {
      return;
    }
    final ScrollPosition position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      _loadPage();
    }
  }

  void _onCategorySelected(CompanyStarCategory category) {
    if (_category == category) {
      return;
    }
    setState(() => _category = category);
    if (ApiUrlResolver.isConfigured) {
      _loadPage(reset: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
  }

  List<CompanyStarListItem> get _visible {
    final String q = _search.text.trim().toLowerCase();
    return _stars.where((CompanyStarListItem s) {
      if (widget.selectionMode) {
        if (_showSelectedOnly && !_selectedIds.contains(s.id)) {
          return false;
        }
      } else if (_secondaryTabOn && !s.isFavorite) {
        return false;
      }
      if (!widget.selectionMode && _category != CompanyStarCategory.all) {
        if (s.creatorTypeValue.toLowerCase() != _category.name) {
          return false;
        }
      }
      if (q.isNotEmpty &&
          !s.name.toLowerCase().contains(q) &&
          !s.location.toLowerCase().contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _toggleFavorite(String id) {
    setState(() {
      _stars = _stars
          .map(
            (CompanyStarListItem s) =>
                s.id == id ? s.copyWith(isFavorite: !s.isFavorite) : s,
          )
          .toList();
    });
  }

  void _toggleSelected(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool showNext = widget.selectionMode && _selectedIds.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Header(
              locale: locale,
              selectionMode: widget.selectionMode,
              onBack: widget.selectionMode ? () => context.pop() : null,
              onSearchTap: () {},
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _SegmentedTabs(
                selectionMode: widget.selectionMode,
                secondaryOn: widget.selectionMode
                    ? _showSelectedOnly
                    : _secondaryTabOn,
                onPrimary: () => setState(() {
                  if (widget.selectionMode) {
                    _showSelectedOnly = false;
                  } else {
                    _secondaryTabOn = false;
                  }
                }),
                onSecondary: () => setState(() {
                  if (widget.selectionMode) {
                    _showSelectedOnly = true;
                  } else {
                    _secondaryTabOn = true;
                  }
                }),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _SearchField(
                      controller: _search,
                      locale: locale,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _SquareAction(
                    icon: Icons.tune_rounded,
                    onTap: () => showCompanyStarsFilterSheet(
                      context: context,
                      draft: _filter,
                      onApplied: () => setState(() {}),
                    ),
                  ),
                  if (widget.selectionMode) ...<Widget>[
                    SizedBox(width: 8.w),
                    _SquareAction(icon: Icons.edit_outlined, onTap: () {}),
                  ],
                ],
              ),
            ),
            if (!widget.selectionMode) ...<Widget>[
              SizedBox(height: 12.h),
              SizedBox(
                height: 40.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: <Widget>[
                    _CategoryChip(
                      label: AppStrings.of(
                        locale,
                        'company_campaign_filter_all',
                      ),
                      selected: _category == CompanyStarCategory.all,
                      icon: Icons.grid_view_rounded,
                      onTap: () => _onCategorySelected(CompanyStarCategory.all),
                    ),
                    _CategoryChip(
                      label: 'Influencer',
                      selected: _category == CompanyStarCategory.influencer,
                      icon: Icons.campaign_outlined,
                      onTap: () =>
                          _onCategorySelected(CompanyStarCategory.influencer),
                    ),
                    _CategoryChip(
                      label: 'Model',
                      selected: _category == CompanyStarCategory.model,
                      icon: Icons.person_outline_rounded,
                      onTap: () =>
                          _onCategorySelected(CompanyStarCategory.model),
                    ),
                    _CategoryChip(
                      label: 'UGC',
                      selected: _category == CompanyStarCategory.ugc,
                      icon: Icons.video_camera_front_outlined,
                      onTap: () => _onCategorySelected(CompanyStarCategory.ugc),
                    ),
                    _CategoryChip(
                      label: 'Collage',
                      selected: _category == CompanyStarCategory.collage,
                      icon: Icons.school_outlined,
                      onTap: () =>
                          _onCategorySelected(CompanyStarCategory.collage),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
                child: Text(
                  AppStrings.of(locale, 'company_stars_top_influencer'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ] else
              SizedBox(height: 12.h),
            Expanded(
              child: (_initialLoading && _stars.isEmpty)
                  ? const Center(child: CircularProgressIndicator())
                  : (_visible.isEmpty
                  ? _StarsEmptyState(locale: locale)
                  : Stack(
                      children: <Widget>[
                        if (widget.selectionMode)
                          GridView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.fromLTRB(
                              16.w,
                              0,
                              16.w,
                              showNext ? 88.h : 24.h,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12.h,
                                  crossAxisSpacing: 12.w,
                                  childAspectRatio:
                                      CompanyStarGridCardLayout.gridAspectRatio(),
                                ),
                            itemCount: _visible.length,
                            itemBuilder: (BuildContext context, int index) {
                              final CompanyStarListItem star = _visible[index];
                              final bool selected = _selectedIds.contains(
                                star.id,
                              );
                              return FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.topCenter,
                                child: CompanyStarGridCard(
                                  star: star,
                                  selectionMode: true,
                                  isSelected: selected,
                                  onSelectToggle: () => _toggleSelected(star.id),
                                  onFavoriteToggle: () =>
                                      _toggleFavorite(star.id),
                                ),
                              );
                            },
                          )
                        else
                          ListView.separated(
                            controller: _scrollController,
                            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
                            itemCount: _visible.length,
                            separatorBuilder: (_, _) => SizedBox(height: 12.h),
                            itemBuilder: (BuildContext context, int index) {
                              final CompanyStarListItem star = _visible[index];
                              return CompanyStarListCard(
                                star: star,
                                onFavoriteToggle: () => _toggleFavorite(star.id),
                                onCardTap: () => context.push(
                                  RouteNames.companyStarProfilePath(star.id),
                                ),
                              );
                            },
                          ),
                        if (_loadingMore && _stars.isNotEmpty)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 10.h,
                            child: Center(
                              child: SizedBox(
                                width: 26.w,
                                height: 26.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              ),
                            ),
                          ),
                      ],
                    )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showNext
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
                child: SizedBox(
                  height: 48.h,
                  child: FilledButton(
                    onPressed: () {
                      if (_selectedIds.isEmpty) {
                        return;
                      }
                      context.push(
                        RouteNames.companyStarProfilePath(_selectedIds.first),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: Text(
                      AppStrings.of(locale, 'company_stars_next'),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _StarsEmptyState extends StatelessWidget {
  const _StarsEmptyState({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = locale.languageCode == 'ar';
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.people_outline_rounded,
              size: 56.sp,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 12.h),
            Text(
              isArabic ? 'لا يوجد نتائج' : 'No stars found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.locale,
    required this.selectionMode,
    this.onBack,
    this.onSearchTap,
  });

  final Locale locale;
  final bool selectionMode;
  final VoidCallback? onBack;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 4.h),
      child: Row(
        children: <Widget>[
          if (selectionMode)
            IconButton(
              onPressed: onBack,
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
            )
          else
            SizedBox(width: 48.w),
          Expanded(
            child: Text(
              AppStrings.of(locale, 'company_nav_stars'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (selectionMode)
            IconButton(
              onPressed: onSearchTap,
              icon: Icon(Icons.search_rounded, size: 24.sp),
            )
          else
            SizedBox(width: 48.w),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.selectionMode,
    required this.secondaryOn,
    required this.onPrimary,
    required this.onSecondary,
  });

  final bool selectionMode;
  final bool secondaryOn;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String primary = AppStrings.of(locale, 'company_campaign_filter_all');
    final String secondary = selectionMode
        ? AppStrings.of(locale, 'company_stars_tab_selected')
        : AppStrings.of(locale, 'company_star_favorite');

    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FA),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _Seg(
              label: primary,
              selected: !secondaryOn,
              onTap: onPrimary,
            ),
          ),
          Expanded(
            child: _Seg(
              label: secondary,
              selected: secondaryOn,
              onTap: onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Material(
        color: selected ? AppColors.brandBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.locale,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Locale locale;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: AppStrings.of(locale, 'company_home_search_hint'),
        prefixIcon: Icon(Icons.search_rounded, size: 22.sp),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SquareAction extends StatelessWidget {
  const _SquareAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brandBlue,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          width: 48.w,
          height: 48.h,
          child: Icon(icon, color: AppColors.white, size: 22.sp),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 18.sp,
          color: selected ? AppColors.white : AppColors.textSecondary,
        ),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.brandBlue,
        checkmarkColor: AppColors.white,
        labelStyle: TextStyle(
          color: selected ? AppColors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
        backgroundColor: AppColors.white,
        side: BorderSide(
          color: selected ? AppColors.brandBlue : const Color(0xFFE1E5EC),
        ),
      ),
    );
  }
}

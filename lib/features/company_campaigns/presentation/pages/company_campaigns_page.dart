import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/company_campaigns/data/company_campaigns_repository.dart';
import 'package:adzmavall/features/company_campaigns/data/company_campaigns_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_list_card_widget.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Company campaigns tab — loads campaigns from `GET /auth/campaigns`, with
/// [CompanyCampaignsViewData] as a fallback when the API is empty or fails.
class CompanyCampaignsPage extends StatefulWidget {
  const CompanyCampaignsPage({super.key});

  @override
  State<CompanyCampaignsPage> createState() => _CompanyCampaignsPageState();
}

class _CompanyCampaignsPageState extends State<CompanyCampaignsPage> {
  CompanyCampaignFilter _filter = CompanyCampaignFilter.all;
  final TextEditingController _search = TextEditingController();

  List<CompanyCampaignListItem> _campaigns = CompanyCampaignsViewData.campaigns;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  Future<void> _loadCampaigns() async {
    if (!ApiUrlResolver.isConfigured) {
      return;
    }
    try {
      final List<CompanyCampaignListItem> list =
          await CompanyCampaignsRepository(DioClient.instance).fetchCampaigns();
      if (!mounted || list.isEmpty) {
        return;
      }
      setState(() => _campaigns = list);
    } on Object {
      // Keep the view-data fallback already in _campaigns.
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<CompanyCampaignListItem> get _visible {
    final String q = _search.text.trim().toLowerCase();
    return _campaigns.where((CompanyCampaignListItem c) {
      if (!CompanyCampaignsViewData.matchesFilter(c, _filter)) {
        return false;
      }
      if (q.isEmpty) {
        return true;
      }
      return c.title.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      AppStrings.of(locale, 'company_campaigns_title'),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Material(
                    color: AppColors.brandBlue,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () =>
                          context.push(RouteNames.companyCreateCampaign),
                      borderRadius: BorderRadius.circular(12.r),
                      child: SizedBox(
                        width: 44.w,
                        height: 44.w,
                        child: Icon(
                          Icons.add_rounded,
                          color: AppColors.white,
                          size: 26.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            SizedBox(
              height: 40.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: _filterChips(locale),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: AppStrings.of(
                          locale,
                          'company_home_search_hint',
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 22.sp,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Material(
                    color: AppColors.brandBlue,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(12.r),
                      child: SizedBox(
                        width: 48.w,
                        height: 48.h,
                        child: Icon(
                          Icons.tune_rounded,
                          color: AppColors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                itemCount: _visible.length,
                itemBuilder: (BuildContext context, int index) {
                  final CompanyCampaignListItem item = _visible[index];
                  return CompanyCampaignListCardWidget(
                    campaign: item,
                    onTap: () => context.push(
                      RouteNames.companyCampaignDetailsPath(item.id),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _filterChips(Locale locale) {
    final List<(CompanyCampaignFilter, String)> items =
        <(CompanyCampaignFilter, String)>[
      (CompanyCampaignFilter.all, 'company_campaign_filter_all'),
      (CompanyCampaignFilter.completed, 'company_campaign_filter_completed'),
      (CompanyCampaignFilter.cancelled, 'company_campaign_filter_cancelled'),
      (CompanyCampaignFilter.newPending, 'company_campaign_filter_new'),
      (
        CompanyCampaignFilter.pendingClientReview,
        'company_campaign_filter_pending',
      ),
    ];
    return items.map(((CompanyCampaignFilter, String) e) {
      final bool selected = _filter == e.$1;
      return Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: ChoiceChip(
          label: Text(AppStrings.of(locale, e.$2)),
          selected: selected,
          onSelected: (_) => setState(() => _filter = e.$1),
          selectedColor: AppColors.brandBlue,
          backgroundColor: AppColors.white,
          labelStyle: TextStyle(
            color: selected ? AppColors.white : AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: selected ? AppColors.brandBlue : const Color(0xFFE1E5EC),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      );
    }).toList();
  }
}

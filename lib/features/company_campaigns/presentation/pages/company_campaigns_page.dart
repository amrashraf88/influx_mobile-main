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

  List<CompanyCampaignListItem> get _visible {
    return _campaigns;
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
                        fontSize: 21.sp,
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
                        height: 36.h,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 13.w),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.add_rounded,
                                color: AppColors.white,
                                size: 18.sp,
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                'New',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18.h),
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
}

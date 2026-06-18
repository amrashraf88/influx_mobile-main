import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/company_campaigns/data/company_campaigns_repository.dart';
import 'package:adzmavall/features/company_campaigns/data/company_campaigns_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_back_app_bar.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_creator_card.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_form_field.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_platform_chip.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_shared_sections.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_segmented_progress.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_status_chip.dart';
import 'package:adzmavall/features/profile/presentation/widgets/profile_form_widgets.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Campaign details — mock [CompanyCampaignsViewData.detailFor]; API later.
class CompanyCampaignDetailsPage extends StatefulWidget {
  const CompanyCampaignDetailsPage({super.key, required this.campaignId});

  final String campaignId;

  @override
  State<CompanyCampaignDetailsPage> createState() =>
      _CompanyCampaignDetailsPageState();
}

class _CompanyCampaignDetailsPageState
    extends State<CompanyCampaignDetailsPage> {
  late CompanyCampaignDetail _detail;
  late Set<String> _selectedPlatforms;

  @override
  void initState() {
    super.initState();
    _detail = CompanyCampaignsViewData.detailFor(widget.campaignId);
    _selectedPlatforms = Set<String>.from(_detail.selectedPlatforms);
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    if (!ApiUrlResolver.isConfigured) {
      return;
    }
    try {
      final CompanyCampaignDetail detail = await CompanyCampaignsRepository(
        DioClient.instance,
      ).fetchCampaignDetail(widget.campaignId);
      if (!mounted) {
        return;
      }
      setState(() {
        _detail = detail;
        _selectedPlatforms = Set<String>.from(detail.selectedPlatforms);
      });
    } on Object {
      // Keep the view-data fallback already in _detail.
    }
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String deliveryLine = AppStrings.of(
      locale,
      'company_campaign_delivery_date',
    ).replaceAll('{date}', _detail.deliveryDateLabel);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: CompanyCampaignBackAppBar(
        title: AppStrings.of(locale, 'company_campaign_details_title'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _CampaignHeroSummary(detail: _detail),
            SizedBox(height: 14.h),
            _CampaignStatusSection(
              status: _detail.status,
              statusLabelKey: _detail.statusLabelKey,
              deliveryLine: deliveryLine,
              filledSegments: _detail.progressSegmentsFilled,
            ),
            SizedBox(height: 16.h),
            SizedBox(
              height: CompanyCampaignCreatorCardLayout.designHeight(),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _detail.creators.length,
                itemBuilder: (BuildContext context, int index) {
                  final CompanyCampaignCreatorSummary c =
                      _detail.creators[index];
                  return CompanyCampaignCreatorCard(
                    creator: c,
                    onTap: () => context.push(
                      RouteNames.companyCampaignInfluencerDetailsPath(
                        campaignId: widget.campaignId,
                        influencerId: c.id,
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            ProfileSectionCard(
              title: AppStrings.of(locale, 'company_campaign_details_title'),
              children: <Widget>[
                CompanyCampaignFormField(
                  label: AppStrings.of(locale, 'company_campaign_brand_name'),
                  value: _detail.brandName,
                  readOnly: true,
                  prefixIconAsset: ImageAssets.brandNameIcon,
                ),
                SizedBox(height: 12.h),
                CompanyCampaignFormField(
                  label: AppStrings.of(locale, 'company_campaign_website'),
                  value: _detail.website,
                  readOnly: true,
                  prefixIconAsset: ImageAssets.linkIcon,
                ),
                SizedBox(height: 12.h),
                CompanyCampaignFormField(
                  label: AppStrings.of(locale, 'company_campaign_title_field'),
                  value: _detail.campaignTitle,
                  readOnly: true,
                ),
                SizedBox(height: 12.h),
                CompanyCampaignFormField(
                  label: AppStrings.of(
                    locale,
                    'company_campaign_target_followers',
                  ),
                  value: _detail.targetFollowers,
                  readOnly: true,
                  prefixIconAsset: ImageAssets.userStarIcon,
                ),
                SizedBox(height: 12.h),
                CompanyCampaignFormField(
                  label: AppStrings.of(locale, 'company_campaign_target_age'),
                  value: _detail.targetAgeGroup,
                  readOnly: true,
                  prefixIconAsset: ImageAssets.personIcon,
                ),
                SizedBox(height: 12.h),
                Text(
                  AppStrings.of(locale, 'company_campaign_proposed_budget'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CompanyCampaignFormField(
                        label: '',
                        value: _detail.budgetMin,
                        readOnly: true,
                        hidePrefixIcon: true,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CompanyCampaignFormField(
                        label: '',
                        value: _detail.budgetMax,
                        readOnly: true,
                        hidePrefixIcon: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CompanyCampaignFormField(
                  label: AppStrings.of(
                    locale,
                    'company_campaign_delivery_date_field',
                  ),
                  value: _detail.deliveryDateField,
                  readOnly: true,
                  prefixIconAsset: ImageAssets.calendarIcon,
                ),
                SizedBox(height: 12.h),
                CompanyCampaignFormField(
                  label: AppStrings.of(
                    locale,
                    'company_campaign_details_field',
                  ),
                  value: _detail.detailsText,
                  readOnly: true,
                  hidePrefixIcon: true,
                  maxLines: 4,
                ),
                SizedBox(height: 12.h),
                _AttachedFileRow(name: _detail.attachedFileName),
              ],
            ),
            SizedBox(height: 14.h),
            const CompanyCampaignPortfolioSection(),
            SizedBox(height: 14.h),
            ProfileSectionCard(
              title: AppStrings.of(locale, 'company_campaign_choose_platform'),
              children: <Widget>[
                CompanyCampaignPlatformPicker(
                  platforms: _detail.availablePlatforms,
                  selected: _selectedPlatforms,
                  onToggle: (String platform) {
                    setState(() {
                      if (_selectedPlatforms.contains(platform)) {
                        _selectedPlatforms.remove(platform);
                      } else {
                        _selectedPlatforms.add(platform);
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignStatusSection extends StatelessWidget {
  const _CampaignStatusSection({
    required this.status,
    required this.statusLabelKey,
    required this.deliveryLine,
    required this.filledSegments,
  });

  final CompanyCampaignListStatus status;
  final String? statusLabelKey;
  final String deliveryLine;
  final int filledSegments;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CompanyCampaignStatusChip(
            status: status,
            labelKeyOverride: statusLabelKey,
          ),
          SizedBox(height: 8.h),
          Text(
            deliveryLine,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          CompanyCampaignSegmentedProgress(
            status: status,
            filledSegments: filledSegments,
          ),
        ],
      ),
    );
  }
}

class _CampaignHeroSummary extends StatelessWidget {
  const _CampaignHeroSummary({required this.detail});

  final CompanyCampaignDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 15.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  detail.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              CompanyCampaignStatusChip(
                status: detail.status,
                labelKeyOverride: detail.statusLabelKey,
                compact: true,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: <Widget>[
              const _AvatarStack(),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  '${detail.creators.length} influencers · ${detail.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            children: <Widget>[
              const _PlatformDot(color: AppColors.instagram, label: 'IG'),
              SizedBox(width: 7.w),
              const _PlatformDot(color: AppColors.tiktok, label: 'TT'),
              SizedBox(width: 7.w),
              const _PlatformDot(color: AppColors.youtube, label: 'YT'),
              const Spacer(),
              Text(
                '${detail.budgetMin} - ${detail.budgetMax} SAR',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.brandBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    const List<Color> colors = <Color>[
      Color(0xFF2A8DF2),
      Color(0xFFE1306C),
      Color(0xFFFACC15),
    ];
    return SizedBox(
      width: 52.w,
      height: 22.w,
      child: Stack(
        children: List<Widget>.generate(colors.length, (int index) {
          return Positioned(
            left: (index * 15).w,
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2.w),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PlatformDot extends StatelessWidget {
  const _PlatformDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 7.5.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _AttachedFileRow extends StatelessWidget {
  const _AttachedFileRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE1E5EC)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.brandBlue,
            size: 22.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.close_rounded,
            color: AppColors.textSecondary,
            size: 22.sp,
          ),
        ],
      ),
    );
  }
}

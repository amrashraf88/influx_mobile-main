import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_campaigns/data/company_campaigns_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_back_app_bar.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_platform_chip.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_status_chip.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Influencer details from a campaign — mock data until API.
class CompanyCampaignInfluencerDetailsPage extends StatelessWidget {
  const CompanyCampaignInfluencerDetailsPage({
    super.key,
    required this.campaignId,
    required this.influencerId,
  });

  final String campaignId;
  final String influencerId;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final CompanyCampaignInfluencerDetail d =
        CompanyCampaignsViewData.influencerDetail(influencerId);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: CompanyCampaignBackAppBar(
        title: AppStrings.of(
          locale,
          'company_campaign_influencer_details_title',
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        child: Column(
          children: <Widget>[
            _ProfileCard(detail: d, locale: locale),
            SizedBox(height: 14.h),
            _FilesLinksCard(detail: d, locale: locale),
            SizedBox(height: 14.h),
            _OrderSummaryCard(detail: d, locale: locale),
            SizedBox(height: 14.h),
            _DepositCard(detail: d, locale: locale),
            SizedBox(height: 14.h),
            _PaymentTermsCard(locale: locale),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.detail, required this.locale});

  final CompanyCampaignInfluencerDetail detail;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        children: <Widget>[
          CircleAvatar(
            radius: 44.r,
            backgroundImage: detail.avatarUrl.isNotEmpty
                ? CachedNetworkImageProvider(detail.avatarUrl)
                : null,
            child: detail.avatarUrl.isEmpty
                ? Icon(Icons.person, size: 40.sp)
                : null,
          ),
          SizedBox(height: 12.h),
          Text(
            detail.name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            detail.headline,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          CompanyCampaignStatusChip(
            status: CompanyCampaignListStatus.pendingClientReview,
            labelKeyOverride: detail.statusLabelKey,
          ),
          SizedBox(height: 14.h),
          const Divider(height: 1, color: Color(0xFFE7EAF0)),
          SizedBox(height: 12.h),
          Row(
            children: <Widget>[
              Row(
                children: detail.socialPlatforms
                    .map(
                      (String p) => Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Image.asset(
                          CompanyCampaignPlatformAssets.assetFor(p),
                          width: 22.w,
                          height: 22.w,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    AppStrings.of(locale, 'company_campaign_price'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    detail.priceLabel,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilesLinksCard extends StatelessWidget {
  const _FilesLinksCard({required this.detail, required this.locale});

  final CompanyCampaignInfluencerDetail detail;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            title: AppStrings.of(
              locale,
              'company_campaign_files_count',
            ).replaceAll('{count}', '${detail.files.length}'),
          ),
          ...detail.files.map((({String name, String sizeLabel}) f) {
            return Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE1E5EC)),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 28.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        f.name,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      f.sizeLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.brandBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 16.h),
          _SectionHeader(
            title: AppStrings.of(locale, 'company_campaign_links'),
          ),
          ...detail.links.map((String link) {
            return Padding(
              padding: EdgeInsets.only(top: 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE1E5EC)),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        link,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.brandBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.delete_outline, color: Colors.red, size: 22.sp),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: AppColors.brandBlue,
            size: 18.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.detail, required this.locale});

  final CompanyCampaignInfluencerDetail detail;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        children: <Widget>[
          ...detail.orderLines.map((({String labelKey, String value}) line) {
            final bool isTax = line.labelKey == 'company_campaign_order_tax';
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      AppStrings.of(locale, line.labelKey),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    line.value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isTax
                          ? const Color(0xFF22C55E)
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: Color(0xFFE7EAF0)),
          SizedBox(height: 8.h),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  AppStrings.of(locale, 'company_campaign_total_with_tax'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                detail.totalWithTax,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
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

class _DepositCard extends StatelessWidget {
  const _DepositCard({required this.detail, required this.locale});

  final CompanyCampaignInfluencerDetail detail;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        children: <Widget>[
          _MoneyRow(
            label: AppStrings.of(locale, 'company_campaign_deposit'),
            amount: detail.depositAmount,
            done: true,
          ),
          SizedBox(height: 12.h),
          _MoneyRow(
            label: AppStrings.of(locale, 'company_campaign_released'),
            amount: detail.releasedAmount,
            done: false,
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.amount,
    required this.done,
  });

  final String label;
  final String amount;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: done ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 16.sp,
            color: done ? AppColors.white : const Color(0xFF94A3B8),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.brandBlue,
          ),
        ),
      ],
    );
  }
}

class _PaymentTermsCard extends StatelessWidget {
  const _PaymentTermsCard({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.inventory_2_outlined,
                color: AppColors.brandBlue,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                AppStrings.of(locale, 'company_campaign_payment_terms'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            AppStrings.of(locale, 'company_campaign_payment_terms_body'),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: <Widget>[
              Text(
                AppStrings.of(locale, 'company_campaign_learn_more'),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: AppColors.brandBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

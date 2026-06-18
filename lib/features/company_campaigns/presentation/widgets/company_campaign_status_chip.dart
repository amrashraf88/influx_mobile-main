import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Status pill colors aligned with campaign list / details designs.
class CompanyCampaignStatusStyle {
  const CompanyCampaignStatusStyle({
    required this.background,
    required this.dot,
    required this.text,
    required this.labelKey,
  });

  final Color background;
  final Color dot;
  final Color text;
  final String labelKey;

  static CompanyCampaignStatusStyle forStatus(CompanyCampaignListStatus status) {
    switch (status) {
      case CompanyCampaignListStatus.completed:
        return const CompanyCampaignStatusStyle(
          background: Color(0xFFD1FAE5),
          dot: Color(0xFF22C55E),
          text: Color(0xFF15803D),
          labelKey: 'company_home_campaign_status_completed',
        );
      case CompanyCampaignListStatus.newPendingApproval:
        return const CompanyCampaignStatusStyle(
          background: Color(0xFFDBEAFE),
          dot: AppColors.brandBlue,
          text: AppColors.brandBlue,
          labelKey: 'company_home_campaign_status_pending',
        );
      case CompanyCampaignListStatus.cancelled:
        return const CompanyCampaignStatusStyle(
          background: Color(0xFFFEE2E2),
          dot: Color(0xFFEF4444),
          text: Color(0xFFB91C1C),
          labelKey: 'company_campaign_status_cancelled',
        );
      case CompanyCampaignListStatus.pendingClientReview:
        return const CompanyCampaignStatusStyle(
          background: Color(0xFFFFEDD5),
          dot: Color(0xFFF59E0B),
          text: Color(0xFFC2410C),
          labelKey: 'company_campaign_status_pending_client',
        );
    }
  }

  static CompanyCampaignStatusStyle forLabelKey(String labelKey) {
    if (labelKey == 'company_campaign_status_approved_completed') {
      return forStatus(CompanyCampaignListStatus.completed).copyWith(
        labelKey: labelKey,
      );
    }
    if (labelKey == 'company_home_campaign_status_pending') {
      return forStatus(CompanyCampaignListStatus.newPendingApproval);
    }
    if (labelKey == 'company_campaign_status_cancelled') {
      return forStatus(CompanyCampaignListStatus.cancelled);
    }
    if (labelKey == 'company_campaign_status_pending_client') {
      return forStatus(CompanyCampaignListStatus.pendingClientReview);
    }
    return forStatus(CompanyCampaignListStatus.completed).copyWith(
      labelKey: labelKey,
    );
  }

  CompanyCampaignStatusStyle copyWith({String? labelKey}) {
    return CompanyCampaignStatusStyle(
      background: background,
      dot: dot,
      text: text,
      labelKey: labelKey ?? this.labelKey,
    );
  }
}

class CompanyCampaignStatusChip extends StatelessWidget {
  const CompanyCampaignStatusChip({
    super.key,
    required this.status,
    this.labelKeyOverride,
    this.compact = false,
  });

  final CompanyCampaignListStatus status;
  final String? labelKeyOverride;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final CompanyCampaignStatusStyle style = labelKeyOverride == null
        ? CompanyCampaignStatusStyle.forStatus(status)
        : CompanyCampaignStatusStyle.forLabelKey(labelKeyOverride!);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.w : 10.w,
        vertical: compact ? 4.h : 6.h,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: compact ? 6.w : 8.w,
            height: compact ? 6.w : 8.w,
            decoration: BoxDecoration(color: style.dot, shape: BoxShape.circle),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              AppStrings.of(locale, style.labelKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: style.text,
                fontSize: compact ? 10.sp : 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

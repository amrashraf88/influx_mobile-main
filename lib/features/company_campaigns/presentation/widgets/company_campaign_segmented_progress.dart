import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyCampaignSegmentedProgress extends StatelessWidget {
  const CompanyCampaignSegmentedProgress({
    super.key,
    required this.status,
    required this.filledSegments,
    this.segments = 4,
  });

  final CompanyCampaignListStatus status;
  final int filledSegments;
  final int segments;

  Color get _activeColor {
    switch (status) {
      case CompanyCampaignListStatus.completed:
        return const Color(0xFF22C55E);
      case CompanyCampaignListStatus.newPendingApproval:
        return AppColors.brandBlue;
      case CompanyCampaignListStatus.cancelled:
        return const Color(0xFFEF4444);
      case CompanyCampaignListStatus.pendingClientReview:
        return const Color(0xFFF59E0B);
    }
  }

  static double segmentWidth() => 40.w;

  @override
  Widget build(BuildContext context) {
    final int filled = filledSegments.clamp(0, segments);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(segments, (int i) {
        final bool active = i < filled;
        return Padding(
          padding: EdgeInsets.only(right: i == segments - 1 ? 0 : 4.w),
          child: Container(
            width: segmentWidth(),
            height: 6.h,
            decoration: BoxDecoration(
              color: active ? _activeColor : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        );
      }),
    );
  }
}

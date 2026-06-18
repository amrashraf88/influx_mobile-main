import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_segmented_progress.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_status_chip.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CompanyCampaignListCardWidget extends StatelessWidget {
  const CompanyCampaignListCardWidget({
    super.key,
    required this.campaign,
    this.onTap,
  });

  final CompanyCampaignListItem campaign;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String amount = NumberFormat.decimalPattern().format(
      campaign.amountValue,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: SizedBox(
                height: 160.h,
                width: double.infinity,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(child: _Cover(url: campaign.coverImageUrl)),
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: CompanyCampaignStatusChip(
                        status: campaign.status,
                        compact: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              campaign.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlue,
                  ),
                ),
                SizedBox(width: 4.w),
                Image.asset(
                  ImageAssets.rsIcon,
                  width: 18.w,
                  height: 18.w,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(height: 10.h),
            CompanyCampaignSegmentedProgress(
              status: campaign.status,
              filledSegments: campaign.progressSegmentsFilled,
            ),
            SizedBox(height: 10.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    campaign.dateLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  campaign.code,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(color: const Color(0xFFE5E7EB));
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: const Color(0xFFE5E7EB)),
      errorWidget: (_, _, _) => Container(
        color: const Color(0xFFE5E7EB),
        alignment: Alignment.center,
        child: Icon(Icons.broken_image_outlined, size: 32.sp),
      ),
    );
  }
}

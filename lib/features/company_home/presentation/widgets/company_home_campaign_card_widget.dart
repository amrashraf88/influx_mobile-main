import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_home/presentation/models/company_home_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// Single campaign card in the "Current Campaign" horizontal list.
class CompanyHomeCampaignCardWidget extends StatelessWidget {
  const CompanyHomeCampaignCardWidget({
    super.key,
    required this.campaign,
    this.onTap,
  });

  final CompanyHomeCampaign campaign;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String amount = NumberFormat.decimalPattern().format(
      campaign.amountValue,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 240.w,
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                height: 124.h,
                width: double.infinity,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: _CoverImage(url: campaign.coverImageUrl),
                    ),
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: _StatusChip(status: campaign.status),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              campaign.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlue,
                  ),
                ),
                SizedBox(width: 4.w),
                Padding(
                  padding: EdgeInsets.only(bottom: 1.h),
                  child: Image.asset(
                    ImageAssets.rsIcon,
                    width: 16.w,
                    height: 16.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            _SegmentedProgress(progress: campaign.progress),
            SizedBox(height: 8.h),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    campaign.dateLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  campaign.code,
                  style: TextStyle(
                    fontSize: 10.sp,
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

class _CoverImage extends StatelessWidget {
  const _CoverImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        color: const Color(0xFFE5E7EB),
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: 36.sp,
          color: const Color(0xFF9CA3AF),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String url) => Container(
        color: const Color(0xFFE5E7EB),
        alignment: Alignment.center,
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (BuildContext context, String url, Object? _) => Container(
        color: const Color(0xFFE5E7EB),
        alignment: Alignment.center,
        child: Icon(
          Icons.broken_image_outlined,
          size: 32.sp,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CompanyCampaignStatus status;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isCompleted = status == CompanyCampaignStatus.completed;
    final Color bg = isCompleted
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFDBEEFF);
    final Color fg = isCompleted
        ? const Color(0xFF16A34A)
        : const Color(0xFF0284C7);
    final String labelKey = isCompleted
        ? 'company_home_campaign_status_completed'
        : 'company_home_campaign_status_pending';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            AppStrings.of(locale, labelKey),
            style: TextStyle(
              color: fg,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedProgress extends StatelessWidget {
  const _SegmentedProgress({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    const int segments = 4;
    final int filled = (progress.clamp(0.0, 1.0) * segments).round();
    return Row(
      children: List<Widget>.generate(segments, (int i) {
        final bool active = i < filled;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == segments - 1 ? 0 : 4.w),
            child: Container(
              height: 6.h,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        );
      }),
    );
  }
}

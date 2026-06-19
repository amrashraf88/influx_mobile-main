import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_platform_chip.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_status_chip.dart';
import 'package:adzmavall/utils/appcolors.dart';
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
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
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
                    campaign.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.15,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                CompanyCampaignStatusChip(
                  status: campaign.status,
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
                    '${campaign.dateLabel} · ${campaign.code}',
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
                const _PlatformDot(platform: 'instagram'),
                SizedBox(width: 7.w),
                const _PlatformDot(platform: 'tiktok'),
                SizedBox(width: 7.w),
                const _PlatformDot(platform: 'youtube'),
                const Spacer(),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brandBlue,
                    height: 1,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  'SAR',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandBlue,
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
  const _PlatformDot({required this.platform});

  final String platform;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24.w,
      height: 24.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        shape: BoxShape.circle,
      ),
      child: Image.asset(
        CompanyCampaignPlatformAssets.assetFor(platform),
        width: 15.w,
        height: 15.w,
        fit: BoxFit.contain,
      ),
    );
  }
}

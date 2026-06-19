import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_platform_chip.dart';
import 'package:adzmavall/features/company_home/presentation/models/company_home_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
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
    final String detailsLabel = <String>[
      if (campaign.influencersCount > 0)
        '${campaign.influencersCount} influencers',
      if (campaign.code.trim().isNotEmpty) campaign.code.trim(),
    ].join(' · ');
    final List<String> platforms = campaign.platforms
        .where((String platform) => platform.trim().isNotEmpty)
        .toSet()
        .take(4)
        .toList();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 270.w,
        padding: EdgeInsets.fromLTRB(15.w, 14.h, 15.w, 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 16,
              offset: Offset(0, 7.h),
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
                SizedBox(width: 8.w),
                _StatusChip(status: campaign.status),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: <Widget>[
                if (campaign.influencersCount > 0) ...<Widget>[
                  const _AvatarStack(),
                  SizedBox(width: 9.w),
                ],
                if (detailsLabel.isNotEmpty)
                  Expanded(
                    child: Text(
                      detailsLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                for (final String platform in platforms) ...<Widget>[
                  _PlatformDot(platform: platform),
                  SizedBox(width: 7.w),
                ],
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CompanyCampaignStatus status;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isCompleted = status == CompanyCampaignStatus.completed;
    final Color bg = isCompleted
        ? const Color(0xFFEAFBF0)
        : const Color(0xFFFFF4E0);
    final Color fg = isCompleted
        ? const Color(0xFF16A34A)
        : const Color(0xFFC77700);
    final String labelKey = isCompleted
        ? 'company_home_campaign_status_completed'
        : 'company_home_campaign_status_pending';
    return Container(
      constraints: BoxConstraints(maxWidth: 86.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        AppStrings.of(locale, labelKey),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: fg,
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w800,
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

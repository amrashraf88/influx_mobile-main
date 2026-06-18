import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_status_chip.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class CompanyCampaignCreatorCardLayout {
  static double designWidth() => 176.w;
  static double designHeight() => 188.h;
}

class CompanyCampaignCreatorCard extends StatelessWidget {
  const CompanyCampaignCreatorCard({
    super.key,
    required this.creator,
    this.onTap,
  });

  final CompanyCampaignCreatorSummary creator;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: SizedBox(
          width: CompanyCampaignCreatorCardLayout.designWidth(),
          height: CompanyCampaignCreatorCardLayout.designHeight(),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE7EAF0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    ClipOval(
                      child: SizedBox(
                        width: 48.w,
                        height: 48.w,
                        child: creator.avatarUrl.isEmpty
                            ? Container(
                                color: const Color(0xFFE5E7EB),
                                child: Icon(
                                  Icons.person_outline_rounded,
                                  size: 26.sp,
                                  color: AppColors.textMuted,
                                ),
                              )
                            : CachedNetworkImage(
                                imageUrl: creator.avatarUrl,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        creator.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: <Widget>[
                    ...creator.platforms.take(3).map(_platformIcon),
                    const Spacer(),
                    Text(
                      creator.priceLabel,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brandBlue,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                CompanyCampaignStatusChip(
                  status: creator.status,
                  compact: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _platformIcon(String platform) {
  IconData icon;
  switch (platform) {
    case 'youtube':
      icon = Icons.play_circle_outline;
      break;
    case 'tiktok':
      icon = Icons.music_note_outlined;
      break;
    case 'facebook':
      icon = Icons.facebook_outlined;
      break;
    default:
      icon = Icons.link;
  }
  return Padding(
    padding: EdgeInsets.only(left: 4.w),
    child: Icon(icon, size: 16.sp, color: const Color(0xFF64748B)),
  );
}

import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_status_chip.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class CompanyCampaignCreatorCardLayout {
  static double designWidth() => 203.w;
  static double designHeight() => 248.h;
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
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: const Color(0xFFE7EAF0)),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: SizedBox(
                    width: double.infinity,
                    child: creator.avatarUrl.isEmpty
                        ? Container(color: const Color(0xFFE5E7EB))
                        : CachedNetworkImage(
                            imageUrl: creator.avatarUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      creator.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  ...creator.platforms.take(3).map(_platformIcon),
                ],
              ),
              SizedBox(height: 6.h),
              CompanyCampaignStatusChip(
                status: creator.status,
                compact: true,
              ),
              SizedBox(height: 6.h),
              Text(
                creator.priceLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandBlue,
                ),
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

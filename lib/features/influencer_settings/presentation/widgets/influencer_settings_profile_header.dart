import 'package:adzmavall/features/influencer_settings/presentation/models/influencer_settings_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfluencerSettingsProfileHeader extends StatelessWidget {
  const InfluencerSettingsProfileHeader({
    super.key,
    required this.profile,
    required this.onEdit,
  });

  final InfluencerSettingsProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 10.h, 16.w, 0),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.topEnd,
            child: Image.asset(
              ImageAssets.editSettingsIcon,
              width: 30.w,
              height: 30.h,
              color: AppColors.white,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _ProfileAvatar(imageUrl: profile.avatarUrl),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(width: 7.w),
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.white,
                      size: 18.sp,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  profile.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.86),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106.w,
      height: 106.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (BuildContext context, String url) =>
            const ColoredBox(color: Color(0xFFEFF4F9)),
        errorWidget: (BuildContext context, String url, Object error) =>
            const ColoredBox(
              color: Color(0xFFEFF4F9),
              child: Icon(Icons.person_rounded, color: AppColors.brandBlue),
            ),
      ),
    );
  }
}

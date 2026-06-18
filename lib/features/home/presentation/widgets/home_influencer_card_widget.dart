import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeInfluencerCardWidget extends StatelessWidget {
  const HomeInfluencerCardWidget({super.key, required this.model});

  final HomeInfluencerModel model;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final String formattedPrice = '${model.priceLabel.replaceAll('\$', '').trim()}\$';
    return Container(
      width: 236.w,
      height: 315.h,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF101840).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: SizedBox(
              height: 152.h,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: _CoverImage(url: model.coverImageUrl)),
                  Positioned(
                    top: 8.h,
                    right: 10.w,
                    // left: 10.w,
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        // shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            model.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
              height: 1.1,
            ),
          ),
          SizedBox(height: 7.h),
          _MetaRow(iconAsset: ImageAssets.homeInfluencerLocation, text: model.location),
          SizedBox(height: 3.h),
          _MetaRow(iconAsset: ImageAssets.homeInfluencerTag, text: model.niche),
          SizedBox(height: 5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                AppStrings.of(locale, 'home_starting_from'),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                formattedPrice,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: AppColors.brandBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Divider(height: 1, thickness: 1, color: const Color(0xFFD8D8D8)),
          SizedBox(height: 5.h),
          _SocialRow(
            youtube: model.youtubeFollowersLabel,
            tiktok: model.tiktokFollowersLabel,
            facebook: model.facebookFollowersLabel,
          ),
        ],
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
      return ColoredBox(
        color: const Color(0xFFE5E7EB),
        child: Center(
          child: Icon(Icons.person_outline_rounded, size: 48.sp, color: const Color(0xFF9CA3AF)),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String url) => ColoredBox(
        color: const Color(0xFFE5E7EB),
        child: Center(child: SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2))),
      ),
      errorWidget: (BuildContext context, String url, Object? _) => ColoredBox(
        color: const Color(0xFFE5E7EB),
        child: Icon(Icons.broken_image_outlined, size: 36.sp, color: const Color(0xFF9CA3AF)),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.iconAsset, required this.text});

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Image.asset(iconAsset, width: 14.w, height: 14.w, fit: BoxFit.contain),
        SizedBox(width: 4.h),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF1E1E1E),
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({
    required this.youtube,
    required this.tiktok,
    required this.facebook,
  });

  final String youtube;
  final String tiktok;
  final String facebook;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _SocialItem(iconAsset: ImageAssets.homeInfluencerYoutube, value: youtube),
        _DividerLine(),
        _SocialItem(iconAsset: ImageAssets.homeInfluencerTiktok, value: tiktok),
        _DividerLine(),
        _SocialItem(iconAsset: ImageAssets.homeInfluencerFacebook, value: facebook),
      ],
    );
  }
}

class _SocialItem extends StatelessWidget {
  const _SocialItem({
    required this.iconAsset,
    required this.value,
  });

  final String iconAsset;
  final String value;

  Size _iconSize() {
    if (iconAsset == ImageAssets.homeInfluencerYoutube) {
      return Size(12.w, 8.h);
    }
    if (iconAsset == ImageAssets.homeInfluencerFacebook) {
      return Size(10.w, 10.h);
    }
    if (iconAsset == ImageAssets.homeInfluencerTiktok) {
      return Size(10.w, 12.h);
    }
    return Size(14.w, 14.h);
  }

  @override
  Widget build(BuildContext context) {
    final Size iconSize = _iconSize();
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 18.w,
            height: 18.h,
            // alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(57.r),
            ),
            child: Image.asset(
              iconAsset,
              width: iconSize.width,
              height: iconSize.height,
              fit: BoxFit.scaleDown,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF1E1E1E),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 28.h,
      color: const Color(0xFFD8D8D8),
    );
  }
}

import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_star_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Matches [HomeInfluencerCardWidget] design size: 218 × 315.
abstract final class CompanyStarGridCardLayout {
  static double designWidth() => 218.w;
  static double designHeight() => 315.h;
  static double coverHeight() => 145.h;

  /// Keeps 218:315 proportions in the grid (scaled via [FittedBox] per cell).
  static double gridAspectRatio() => designWidth() / designHeight();
}

class CompanyStarGridCard extends StatelessWidget {
  const CompanyStarGridCard({
    super.key,
    required this.star,
    this.selectionMode = false,
    this.isSelected = false,
    this.onCardTap,
    this.onSelectToggle,
    this.onFavoriteToggle,
  });

  final CompanyStarListItem star;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onCardTap;
  final VoidCallback? onSelectToggle;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final Widget body = SizedBox(
      width: CompanyStarGridCardLayout.designWidth(),
      height: CompanyStarGridCardLayout.designHeight(),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.brandBlue : const Color(0xFFE7EAF0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(18.r),
              child: SizedBox(
                height: CompanyStarGridCardLayout.coverHeight(),
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CachedNetworkImage(
                      imageUrl: star.coverImageUrl,
                      fit: BoxFit.cover,
                    ),
                    if (!selectionMode)
                      Positioned(
                        top: 8.h,
                        right: 10.w,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(100.r),
                          child: InkWell(
                            onTap: onFavoriteToggle,
                            borderRadius: BorderRadius.circular(100.r),
                            child: SizedBox(
                              width: 32.w,
                              height: 32.h,
                              child: Center(
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                    star.isFavorite
                                        ? const Color(0xFFEF4444)
                                        : AppColors.white,
                                    BlendMode.srcIn,
                                  ),
                                  child: Image.asset(
                                    ImageAssets.favoriteIcon,
                                    width: 20.w,
                                    height: 20.h,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              star.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E1E),
                height: 1.1,
              ),
            ),
            SizedBox(height: 8.h),
            _MetaRow(
              iconAsset: ImageAssets.homeInfluencerLocation,
              text: star.location,
            ),
            SizedBox(height: 3.h),
            _MetaRow(
              iconAsset: ImageAssets.homeInfluencerTag,
              text: star.categoriesLabel,
            ),
            SizedBox(height: 5.h),
            Row(
              children: <Widget>[
                Text(
                  AppStrings.of(locale, 'home_starting_from'),
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  star.startingPriceLabel,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.brandBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (!selectionMode) ...<Widget>[
              SizedBox(height: 5.h),
              const Divider(height: 1, thickness: 1, color: Color(0xFFD8D8D8)),
              SizedBox(height: 5.h),
              _SocialRow(
                youtube: star.youtubeFollowers,
                tiktok: star.tiktokFollowers,
                facebook: star.facebookFollowers,
              ),
            ],
            if (selectionMode) ...<Widget>[
              SizedBox(height: 5.h),
              const Divider(height: 1, thickness: 1, color: Color(0xFFD8D8D8)),
              SizedBox(height: 5.h),
              SizedBox(
                width: double.infinity,
                height: 34.h,
                child: isSelected
                    ? FilledButton.icon(
                        onPressed: onSelectToggle,
                        icon: Icon(Icons.check_rounded, size: 16.sp),
                        label: Text(
                          AppStrings.of(locale, 'company_stars_selected'),
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: onSelectToggle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandBlue,
                          side: const BorderSide(color: AppColors.brandBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        child: Text(
                          AppStrings.of(locale, 'company_stars_select'),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );

    if (!selectionMode && onCardTap != null) {
      return InkWell(
        onTap: onCardTap,
        borderRadius: BorderRadius.circular(12.r),
        child: body,
      );
    }
    return body;
  }
}

class CompanyStarListCard extends StatelessWidget {
  const CompanyStarListCard({
    super.key,
    required this.star,
    required this.onCardTap,
    required this.onFavoriteToggle,
  });

  final CompanyStarListItem star;
  final VoidCallback onCardTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onCardTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          height: 112.h,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF111827).withValues(alpha: 0.045),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: SizedBox(
                  width: 88.w,
                  height: 88.h,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      CachedNetworkImage(
                        imageUrl: star.coverImageUrl,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 6.w,
                        top: 6.h,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.influencerGradient,
                            ),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            'Influencer',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 7.5.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            star.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryDark,
                              height: 1.1,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.verified_rounded,
                          size: 14.sp,
                          color: AppColors.verified,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '${star.location} · ${star.categoriesLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        color: AppColors.textMuted,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: <Widget>[
                        _CompactSocial(
                          iconAsset: ImageAssets.homeInfluencerYoutube,
                          value: star.youtubeFollowers,
                        ),
                        SizedBox(width: 10.w),
                        _CompactSocial(
                          iconAsset: ImageAssets.homeInfluencerTiktok,
                          value: star.tiktokFollowers,
                        ),
                        SizedBox(width: 10.w),
                        _CompactSocial(
                          iconAsset: ImageAssets.homeInfluencerFacebook,
                          value: star.facebookFollowers,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        Text(
                          AppStrings.of(locale, 'home_starting_from'),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          star.startingPriceLabel,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.brandBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              InkWell(
                onTap: onFavoriteToggle,
                borderRadius: BorderRadius.circular(20.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    star.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    size: 22.sp,
                    color: star.isFavorite
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFD3D8E1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSocial extends StatelessWidget {
  const _CompactSocial({required this.iconAsset, required this.value});

  final String iconAsset;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(iconAsset, width: 16.w, height: 16.w, fit: BoxFit.contain),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryDark,
          ),
        ),
      ],
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
        SizedBox(width: 4.w),
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
        _SocialItem(
          iconAsset: ImageAssets.homeInfluencerYoutube,
          value: youtube,
        ),
        const _DividerLine(),
        _SocialItem(iconAsset: ImageAssets.homeInfluencerTiktok, value: tiktok),
        const _DividerLine(),
        _SocialItem(
          iconAsset: ImageAssets.homeInfluencerFacebook,
          value: facebook,
        ),
      ],
    );
  }
}

class _SocialItem extends StatelessWidget {
  const _SocialItem({required this.iconAsset, required this.value});

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
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                color: const Color(0xFF1E1E1E),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1.w, height: 28.h, color: const Color(0xFFD8D8D8));
  }
}

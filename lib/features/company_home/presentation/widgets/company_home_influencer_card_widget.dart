import 'package:adzmavall/features/company_home/presentation/models/company_home_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Card used in the company-home "Influencers" grid: cover photo + tag chip,
/// social row at the bottom and avatar/name/handle below.
class CompanyHomeInfluencerCardWidget extends StatelessWidget {
  const CompanyHomeInfluencerCardWidget({
    super.key,
    required this.influencer,
    this.onTap,
  });

  final CompanyHomeInfluencer influencer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 0.78,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  _Cover(url: influencer.coverImageUrl),
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: _CategoryChip(label: influencer.tagLabel),
                  ),
                  Positioned(
                    left: 8.w,
                    right: 8.w,
                    bottom: 8.h,
                    child: const _SocialOverlayRow(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _Avatar(url: influencer.avatarUrl, size: 32.w),
              SizedBox(width: 6.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      influencer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      influencer.handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
          size: 28.sp,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: url.isEmpty
            ? Container(
                color: const Color(0xFFE5E7EB),
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_outline_rounded,
                  size: size * 0.6,
                  color: const Color(0xFF9CA3AF),
                ),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    Container(color: const Color(0xFFE5E7EB)),
                errorWidget: (BuildContext context, String url, Object? _) =>
                    Container(
                      color: const Color(0xFFE5E7EB),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: size * 0.6,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
              ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SocialOverlayRow extends StatelessWidget {
  const _SocialOverlayRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _SocialPill(icon: Icons.play_arrow_rounded),
        SizedBox(width: 10.w),
        _SocialPill(icon: Icons.camera_alt_outlined),
        SizedBox(width: 10.w),
        _SocialPill(icon: Icons.music_note_rounded),
      ],
    );
  }
}

class _SocialPill extends StatelessWidget {
  const _SocialPill({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.37),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.white, size: 16.sp),
    );
  }
}

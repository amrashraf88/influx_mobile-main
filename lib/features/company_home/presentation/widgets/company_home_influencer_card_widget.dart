import 'package:adzmavall/features/company_home/presentation/models/company_home_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact creator card for the brand-home Influencers grid.
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
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 14,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
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
                  SizedBox(width: 7.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          influencer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          influencer.handle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textSecondary,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    if (url.trim().isEmpty) {
      return const _ImageFallback();
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: const Color(0xFFE5E7EB)),
      errorWidget: (_, _, _) => const _ImageFallback(),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline_rounded,
        size: 34.sp,
        color: AppColors.textMuted,
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
        child: url.trim().isEmpty
            ? _AvatarFallback(size: size)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: const Color(0xFFE5E7EB)),
                errorWidget: (_, _, _) => _AvatarFallback(size: size),
              ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE5E7EB),
      alignment: Alignment.center,
      child: Icon(
        Icons.person_outline_rounded,
        size: size * 0.6,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final String text = label.trim().isEmpty ? 'Creator' : label.trim();
    return Container(
      constraints: BoxConstraints(maxWidth: 112.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w800,
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
        SizedBox(width: 8.w),
        _SocialPill(icon: Icons.camera_alt_outlined),
        SizedBox(width: 8.w),
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
      width: 28.w,
      height: 28.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.white, size: 15.sp),
    );
  }
}

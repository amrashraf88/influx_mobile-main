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
    final String creatorLabel = _creatorTypeLabel(influencer.creatorTypeValue);
    final String metaLabel = _cleanTag(influencer);
    final String handle = influencer.handle.trim();
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(9.w),
          decoration: BoxDecoration(
            color: AppColors.white,
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
                        child: _CategoryChip(
                          label: creatorLabel,
                          colors: _creatorGradient(influencer.creatorTypeValue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _Avatar(url: influencer.avatarUrl, size: 30.w),
                    SizedBox(width: 7.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            influencer.name.trim().isEmpty
                                ? 'Creator'
                                : influencer.name.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              height: 1.12,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            handle.isEmpty ? metaLabel : handle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              color: AppColors.textSecondary,
                              height: 1.1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (metaLabel.isNotEmpty && handle.isNotEmpty) ...<Widget>[
                SizedBox(height: 7.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F9FF),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    metaLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
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
  const _CategoryChip({required this.label, required this.colors});

  final String label;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final String text = label.trim().isEmpty ? 'Creator' : label.trim();
    return Container(
      constraints: BoxConstraints(maxWidth: 112.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
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

String _creatorTypeLabel(String value) {
  return switch (value) {
    'model' => 'Model',
    'ugc' => 'UGC',
    'collage' => 'Collage',
    _ => 'Influencer',
  };
}

String _cleanTag(CompanyHomeInfluencer influencer) {
  final String tag = influencer.tagLabel.trim();
  if (tag.isEmpty ||
      tag.startsWith('{') ||
      tag.toLowerCase().contains('value:')) {
    return _creatorTypeLabel(influencer.creatorTypeValue);
  }
  return tag;
}

List<Color> _creatorGradient(String value) {
  return switch (value) {
    'model' => AppColors.modelGradient,
    'ugc' => AppColors.ugcGradient,
    'collage' => AppColors.collageGradient,
    _ => AppColors.influencerGradient,
  };
}

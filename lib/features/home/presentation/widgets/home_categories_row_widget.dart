import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeCategoriesRowWidget extends StatelessWidget {
  const HomeCategoriesRowWidget({super.key, required this.items});

  final List<HomeCategoryModel> items;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return SizedBox(
      height: 175.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (BuildContext context, int i) => SizedBox(width: 13.w),
        itemBuilder: (BuildContext context, int index) {
          final HomeCategoryModel item = items[index];
          final String title = (item.titleDisplay != null && item.titleDisplay!.trim().isNotEmpty)
              ? item.titleDisplay!.trim()
              : AppStrings.of(locale, item.titleKey);
          final String subtitle = (item.countDisplay != null && item.countDisplay!.trim().isNotEmpty)
              ? item.countDisplay!.trim()
              : AppStrings.of(locale, item.countKey);
          return _CategoryCell(
            title: title,
            subtitle: subtitle,
            imageUrl: item.imageUrl,
          );
        },
      ),
    );
  }
}

final CacheManager _homeCategoryCacheManager = CacheManager(
  Config(
    'homeCategoryImageCache',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 200,
    repo: JsonCacheInfoRepository(databaseName: 'homeCategoryImageCache'),
  ),
);

/// Category tile — image-only card with the label/count underneath, matching
/// the design (rounded image, no surrounding white card).
class _CategoryCell extends StatelessWidget {
  const _CategoryCell({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: double.infinity,
              height: 124.h,
              color: AppColors.brandBlue.withValues(alpha: 0.08),
              child: imageUrl.trim().isNotEmpty
                  ? CachedNetworkImage(
                      cacheManager: _homeCategoryCacheManager,
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (BuildContext context, String url) =>
                          const _CategoryImageFallback(),
                      errorWidget: (BuildContext context, String url, Object error) =>
                          const _CategoryImageFallback(),
                    )
                  : const _CategoryImageFallback(),
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5.sp, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CategoryImageFallback extends StatelessWidget {
  const _CategoryImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.brandBlue.withValues(alpha: 0.16),
            AppColors.brandBlue.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, color: AppColors.brandBlue, size: 24.sp),
      ),
    );
  }
}

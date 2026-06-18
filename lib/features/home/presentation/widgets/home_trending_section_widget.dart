import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:adzmavall/features/home/presentation/widgets/home_section_title_row_widget.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Figma: very light gray pill, medium gray label.
const Color _trendingChipBackground = Color(0xFFF2F2F2);
const Color _trendingChipForeground = Color(0xFF6B7280);

class HomeTrendingSectionWidget extends StatelessWidget {
  const HomeTrendingSectionWidget({
    super.key,
    required this.tagsFuture,
    required this.storiesFuture,
  });

  final Future<List<HomeTrendingTagModel>> tagsFuture;
  final Future<List<HomeStoryModel>> storiesFuture;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        HomeSectionTitleRowWidget(
          titleKey: 'home_section_trending',
          trailingKey: 'home_show_more',
          onTrailingTap: () {},
          titleFontWeight: FontWeight.w800,
          autoSizeTexts: true,
        ),
        SizedBox(height: 14.h),
        FutureBuilder<List<HomeTrendingTagModel>>(
          future: tagsFuture,
          builder: (BuildContext context, AsyncSnapshot<List<HomeTrendingTagModel>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SizedBox(height: 36.h);
            }
            final List<HomeTrendingTagModel> tags = snapshot.data ?? const <HomeTrendingTagModel>[];
            if (tags.isEmpty) {
              return const SizedBox.shrink();
            }
            final List<String> tagLabels = <String>[];
            for (final HomeTrendingTagModel tag in tags) {
              final String label = (tag.apiLabel != null && tag.apiLabel!.trim().isNotEmpty)
                  ? tag.apiLabel!.trim()
                  : (tag.localizationKey != null && tag.localizationKey!.isNotEmpty)
                      ? AppStrings.of(locale, tag.localizationKey!)
                      : '';
              if (label.isNotEmpty) {
                tagLabels.add(label);
              }
            }
            if (tagLabels.isEmpty) {
              return const SizedBox.shrink();
            }
            const int perRow = 3;
            final int rowCount = (tagLabels.length + perRow - 1) ~/ perRow;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(rowCount, (int row) {
                final int start = row * perRow;
                final int end =
                    (start + perRow > tagLabels.length) ? tagLabels.length : start + perRow;
                final List<Widget> rowChildren = <Widget>[];
                for (int i = start; i < end; i++) {
                  if (i > start) {
                    rowChildren.add(SizedBox(width: 10.w));
                  }
                  rowChildren.add(
                    Expanded(
                      child: _TrendingTagChip(label: tagLabels[i]),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.only(bottom: row < rowCount - 1 ? 10.h : 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: rowChildren,
                  ),
                );
              }),
            );
          },
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 388.h,
          // width: 388.w,
          child: FutureBuilder<List<HomeStoryModel>>(
            future: storiesFuture,
            builder: (BuildContext context, AsyncSnapshot<List<HomeStoryModel>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: SizedBox(
                    width: 26.w,
                    height: 26.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              final List<HomeStoryModel> stories = snapshot.data ?? const <HomeStoryModel>[];
              if (stories.isEmpty) {
                return Center(
                  child: Text(
                    'No stories yet',
                    style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
                  ),
                );
              }
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stories.length,
                separatorBuilder: (BuildContext context, int index) => SizedBox(width: 16.w),
                itemBuilder: (BuildContext context, int index) {
                  return _StoryCard(story: stories[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TrendingTagChip extends StatelessWidget {
  const _TrendingTagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _trendingChipBackground,
        borderRadius: BorderRadius.circular(100.r),
      ),
      alignment: Alignment.center,
      child: AutoSizeText(
        '#$label',
        textAlign: TextAlign.center,
        maxLines: 1,
        minFontSize: 9,
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: _trendingChipForeground,
          height: 1.15,
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.story});

  final HomeStoryModel story;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: SizedBox(
        width: 301.w,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: story.imageUrl,
              fit: BoxFit.cover,
              placeholder: (BuildContext context, String url) =>
                  Container(color: const Color(0xFFE5E7EB)),
              errorWidget: (BuildContext context, String url, Object? error) =>
                  Container(color: const Color(0xFFE5E7EB)),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  //   colors: <Color>[
                  //     Colors.black.withValues(alpha: 0.15),
                  //     Colors.transparent,
                  //     Colors.black.withValues(alpha: 0.65),
                  //   ],
                  //   stops: const <double>[0, 0.5, 1],
                  // ),
                ),
              ),
            ),
            Positioned(
              top: 12.h,
              left: 12.w,
              right: 12.w,
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEBD5D8),
                      shape: BoxShape.circle,
                    ),
                    child: story.avatarUrl.isEmpty
                        ? Icon(Icons.person, color: Colors.white, size: 18.sp)
                        : ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: story.avatarUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        AutoSizeText(
                          story.userName,
                          maxLines: 1,
                          minFontSize: 10,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AutoSizeText(
                          story.userHandle,
                          maxLines: 1,
                          minFontSize: 8,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(ImageAssets.favoriteIcon, width: 24.w, height: 24.h, fit: BoxFit.contain),
                ],
              ),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 16.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AutoSizeText(
                    story.title,
                    maxLines: 1,
                    minFontSize: 11,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 17.h),
                  Row(
                    children: <Widget>[
                      Icon(Icons.favorite_rounded, color: const Color(0xFFFF3B30), size: 18.sp),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: AutoSizeText(
                          '${story.likesLabel} Likes',
                          maxLines: 1,
                          minFontSize: 8,
                          style: TextStyle(color: Colors.white, fontSize: 12.sp),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Image.asset(ImageAssets.commentIcon, width: 16.w, height: 16.h, fit: BoxFit.contain),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: AutoSizeText(
                          '${story.commentsLabel} Comment',
                          maxLines: 1,
                          minFontSize: 8,
                          textAlign: TextAlign.end,
                          style: TextStyle(color: Colors.white, fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

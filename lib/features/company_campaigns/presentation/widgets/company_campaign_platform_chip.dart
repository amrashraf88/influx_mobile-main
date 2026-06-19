import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract final class CompanyCampaignPlatformAssets {
  static String assetFor(String platform) {
    final String value = platform.trim().toLowerCase();
    if (value.contains('instagram') || value == 'ig') {
      return ImageAssets.instagramColoredIcon;
    }
    if (value.contains('tik') || value.contains('tok')) {
      return ImageAssets.homeInfluencerTiktok;
    }
    if (value.contains('youtube') || value == 'yt') {
      return ImageAssets.homeInfluencerYoutube;
    }
    if (value.contains('telegram')) {
      return ImageAssets.telegramColoredIcon;
    }
    if (value.contains('whatsapp') || value == 'wa') {
      return ImageAssets.whatsappColoredIcon;
    }
    if (value.contains('thread')) {
      return ImageAssets.threadsIcon;
    }
    if (value.contains('snap')) {
      return ImageAssets.snapchatIcon;
    }
    if (value.contains('facebook') || value == 'fb') {
      return ImageAssets.homeInfluencerFacebook;
    }
    if (value == 'x' || value.contains('twitter') || value.contains('x.com')) {
      return ImageAssets.twitterIcon;
    }
    return ImageAssets.platformsIcon;
  }
}

class CompanyCampaignPlatformChip extends StatelessWidget {
  const CompanyCampaignPlatformChip({
    super.key,
    required this.platform,
    required this.selected,
    required this.onTap,
  });

  final String platform;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: AnimatedContainer(
          width: double.infinity,
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.brandBlue.withValues(alpha: 0.12)
                : AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: selected ? AppColors.brandBlue : const Color(0xFFE1E5EC),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                CompanyCampaignPlatformAssets.assetFor(platform),
                width: 18.w,
                height: 18.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: AutoSizeText(
                  platform,
                  maxLines: 1,
                  minFontSize: 8,
                  style: TextStyle(
                    color: selected
                        ? AppColors.brandBlue
                        : AppColors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
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

class CompanyCampaignPlatformMoreChip extends StatelessWidget {
  const CompanyCampaignPlatformMoreChip({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.brandBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: const Color(0xFFE1E5EC)),
          ),
          child: AutoSizeText(
            AppStrings.of(locale, 'company_campaign_platform_more'),
            maxLines: 1,
            minFontSize: 8,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.brandBlue,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class CompanyCampaignPlatformPicker extends StatelessWidget {
  const CompanyCampaignPlatformPicker({
    super.key,
    required this.platforms,
    required this.selected,
    required this.onToggle,
    this.onMore,
  });

  final List<String> platforms;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onMore;

  static const int _columns = 3;

  @override
  Widget build(BuildContext context) {
    final List<Widget> cells = <Widget>[
      ...platforms.map((String platform) {
        final bool on = selected.contains(platform);
        return CompanyCampaignPlatformChip(
          platform: platform,
          selected: on,
          onTap: () => onToggle(platform),
        );
      }),
      CompanyCampaignPlatformMoreChip(onTap: onMore),
    ];

    final List<List<Widget>> rows = <List<Widget>>[];
    for (int i = 0; i < cells.length; i += _columns) {
      final int end = (i + _columns).clamp(0, cells.length);
      rows.add(cells.sublist(i, end));
    }

    return Column(
      children: List<Widget>.generate(rows.length, (int rowIndex) {
        final List<Widget> rowCells = rows[rowIndex];
        return Padding(
          padding: EdgeInsets.only(
            bottom: rowIndex == rows.length - 1 ? 0 : 8.h,
          ),
          child: Row(
            children: List<Widget>.generate(_columns, (int colIndex) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: colIndex == _columns - 1 ? 0 : 8.w,
                  ),
                  child: colIndex < rowCells.length
                      ? rowCells[colIndex]
                      : const SizedBox.shrink(),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

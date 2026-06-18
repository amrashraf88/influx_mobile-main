import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeWhyAdzSectionWidget extends StatefulWidget {
  const HomeWhyAdzSectionWidget({super.key, required this.features});

  final List<HomeWhyFeatureModel> features;

  @override
  State<HomeWhyAdzSectionWidget> createState() => _HomeWhyAdzSectionWidgetState();
}

class _HomeWhyAdzSectionWidgetState extends State<HomeWhyAdzSectionWidget> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _WhyTitleText(locale: locale)),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(99.r),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _TabChip(
                    label: AppStrings.of(locale, 'home_why_tab_company'),
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                  ),
                  SizedBox(width: 4.w),
                  _TabChip(
                    label: AppStrings.of(locale, 'home_why_tab_influencer'),
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...widget.features.map(
          (HomeWhyFeatureModel f) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _FeatureRow(
              icon: f.icon,
              titleKey: f.titleKey,
              titleOverride: f.titleOverride,
              iconAsset: f.iconAsset,
              iconUrl: f.iconUrl,
            ),
          ),
        ),
      ],
    );
  }
}

class _WhyTitleText extends StatelessWidget {
  const _WhyTitleText({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final String fullTitle = AppStrings.of(locale, 'home_why_title');
    const TextStyle baseStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    );
    const TextStyle highlightStyle = TextStyle(
      fontWeight: FontWeight.w700,
      color: AppColors.brandBlue,
    );

    if (fullTitle.contains('Adz')) {
      final List<String> parts = fullTitle.split('Adz');
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: baseStyle.copyWith(fontSize: 16.sp),
          children: <TextSpan>[
            TextSpan(text: parts.first),
            TextSpan(text: 'Adz', style: highlightStyle.copyWith(fontSize: 16.sp)),
            TextSpan(text: parts.length > 1 ? parts.sublist(1).join('Adz') : ''),
          ],
        ),
      );
    }

    if (fullTitle.contains('آدز')) {
      final List<String> parts = fullTitle.split('آدز');
      return RichText(
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: baseStyle.copyWith(fontSize: 14.sp),
          children: <TextSpan>[
            TextSpan(text: parts.first),
            TextSpan(text: 'آدز', style: highlightStyle.copyWith(fontSize: 14.sp)),
            TextSpan(text: parts.length > 1 ? parts.sublist(1).join('آدز') : ''),
          ],
        ),
      );
    }

    return Text(
      fullTitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: baseStyle.copyWith(fontSize: 16.sp),
    );
  }
}

class _WhyFeatureIcon extends StatelessWidget {
  const _WhyFeatureIcon({
    required this.icon,
    this.iconAsset,
    this.iconUrl,
  });

  final IconData icon;
  final String? iconAsset;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final String? url = iconUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.all(6.w),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.contain,
          placeholder: (BuildContext context, String _) => Icon(icon, color: AppColors.brandBlue, size: 22.sp),
          errorWidget: (BuildContext context, String url, Object? error) =>
              Icon(icon, color: AppColors.brandBlue, size: 22.sp),
        ),
      );
    }
    if (iconAsset == null) {
      return Icon(icon, color: AppColors.brandBlue, size: 22.sp);
    }
    return Padding(
      padding: EdgeInsets.all(9.w),
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          AppColors.brandBlue,
          BlendMode.srcIn,
        ),
        child: Image.asset(iconAsset!, fit: BoxFit.contain),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brandBlue : Colors.transparent,
      borderRadius: BorderRadius.circular(99.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: selected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.titleKey,
    this.titleOverride,
    this.iconAsset,
    this.iconUrl,
  });

  final IconData icon;
  final String titleKey;
  final String? titleOverride;
  final String? iconAsset;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final String titleText = (titleOverride != null && titleOverride!.trim().isNotEmpty)
        ? titleOverride!.trim()
        : AppStrings.of(locale, titleKey);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: _WhyFeatureIcon(
              icon: icon,
              iconAsset: iconAsset,
              iconUrl: iconUrl,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              titleText,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_star_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Design tokens for the Stars filter sheet (matches Figma).
abstract final class _FilterSheetStyle {
  static const Color chipIdleBg = Color(0xFFF0F4F8);
  static const Color chipIdleText = Color(0xFF5B6B7C);
  static const Color fieldFill = Color(0xFFF7F8FA);
  static const Color fieldBorder = Color(0xFFE1E5EC);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color resetRed = Color(0xFFE85D5D);
  static const Color sliderInactive = Color(0xFFE5E7EB);
}

Future<void> showCompanyStarsFilterSheet({
  required BuildContext context,
  required CompanyStarsFilterDraft draft,
  required VoidCallback onApplied,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (BuildContext ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 28.h, 16.w, 24.h),
        child: Center(
          child: _CompanyStarsFilterSheet(
            draft: draft,
            onApply: () {
              onApplied();
              Navigator.of(ctx).pop();
            },
            onReset: () {
              draft
                ..priceMin = 100
                ..priceMax = 200000
                ..category = 'all'
                ..platform = 'all'
                ..gender = 'all'
                ..tags = 'all'
                ..age = 'all';
              onApplied();
              Navigator.of(ctx).pop();
            },
          ),
        ),
      );
    },
  );
}

class _CompanyStarsFilterSheet extends StatefulWidget {
  const _CompanyStarsFilterSheet({
    required this.draft,
    required this.onApply,
    required this.onReset,
  });

  final CompanyStarsFilterDraft draft;
  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  State<_CompanyStarsFilterSheet> createState() =>
      _CompanyStarsFilterSheetState();
}

class _CompanyStarsFilterSheetState extends State<_CompanyStarsFilterSheet> {
  late double _priceSlider;
  RangeValues _followerRange = const RangeValues(0.15, 0.75);

  @override
  void initState() {
    super.initState();
    _priceSlider = widget.draft.priceMin.clamp(100, 200000);
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final CompanyStarsFilterDraft d = widget.draft;
    final double maxH = MediaQuery.sizeOf(context).height * 0.78;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _Header(
              locale: locale,
              onClose: () => Navigator.of(context).pop(),
              onReset: widget.onReset,
            ),
            const Divider(height: 1, thickness: 1, color: _FilterSheetStyle.divider),
            Flexible(
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(8.r),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SectionTitle(
                        AppStrings.of(locale, 'company_stars_filter_price'),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: <Widget>[
                          const Expanded(child: _PriceField(hint: '00 000')),
                          SizedBox(width: 10.w),
                          const Expanded(child: _PriceField(hint: '00 000')),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4.h,
                          activeTrackColor: AppColors.brandBlue,
                          inactiveTrackColor: _FilterSheetStyle.sliderInactive,
                          thumbColor: AppColors.brandBlue,
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: Slider(
                          value: _priceSlider,
                          min: 100,
                          max: 200000,
                          onChanged: (double v) {
                            setState(() {
                              _priceSlider = v;
                              d.priceMin = v;
                            });
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '100 SAR',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '200,000 SAR',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _ChipSection(
                        title: AppStrings.of(
                          locale,
                          'company_stars_filter_category',
                        ),
                        options: <String>[
                          'all',
                          'sport',
                          'fashion',
                          'news',
                        ],
                        selected: d.category,
                        label: (String k) => _Labels.category(locale, k),
                        onPick: (String v) =>
                            setState(() => d.category = v),
                      ),
                      SizedBox(height: 18.h),
                      _SectionTitle(
                        AppStrings.of(locale, 'company_stars_filter_followers'),
                      ),
                      SizedBox(height: 8.h),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4.h,
                          activeTrackColor: AppColors.brandBlue,
                          inactiveTrackColor: _FilterSheetStyle.sliderInactive,
                          thumbColor: AppColors.brandBlue,
                          rangeThumbShape: const RoundRangeSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: SliderComponentShape.noOverlay,
                        ),
                        child: RangeSlider(
                          values: _followerRange,
                          onChanged: (RangeValues v) {
                            setState(() => _followerRange = v);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '1k',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '100M',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _ChipSection(
                        title: AppStrings.of(
                          locale,
                          'company_stars_filter_platform',
                        ),
                        options: <String>[
                          'all',
                          'facebook',
                          'tiktok',
                          'instagram',
                        ],
                        selected: d.platform,
                        label: (String k) => _Labels.platform(locale, k),
                        onPick: (String v) =>
                            setState(() => d.platform = v),
                      ),
                      SizedBox(height: 18.h),
                      _ChipSection(
                        title: AppStrings.of(
                          locale,
                          'company_stars_filter_gender',
                        ),
                        options: <String>['all', 'male', 'female'],
                        selected: d.gender,
                        label: (String k) => _Labels.gender(locale, k),
                        onPick: (String v) => setState(() => d.gender = v),
                      ),
                      SizedBox(height: 18.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: _CountryCityDropdown(
                              label: AppStrings.of(
                                locale,
                                'company_stars_filter_country',
                              ),
                              hint: AppStrings.of(
                                locale,
                                'company_create_select',
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: _CountryCityDropdown(
                              label: AppStrings.of(
                                locale,
                                'company_stars_filter_city',
                              ),
                              hint: AppStrings.of(
                                locale,
                                'company_create_select',
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _ChipSection(
                        title: AppStrings.of(
                          locale,
                          'company_stars_filter_tags',
                        ),
                        options: <String>[
                          'all',
                          'sport',
                          'fashion',
                          'news',
                        ],
                        selected: d.tags,
                        label: (String k) => _Labels.category(locale, k),
                        onPick: (String v) => setState(() => d.tags = v),
                      ),
                      SizedBox(height: 18.h),
                      _ChipSection(
                        title: AppStrings.of(
                          locale,
                          'company_stars_filter_age',
                        ),
                        options: <String>['all', '15-20', '21-25'],
                        selected: d.age,
                        label: (String k) => _Labels.age(locale, k),
                        onPick: (String v) => setState(() => d.age = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 18.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: FilledButton(
                  onPressed: widget.onApply,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Text(
                    AppStrings.of(locale, 'company_stars_filter_apply'),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.locale,
    required this.onClose,
    required this.onReset,
  });

  final Locale locale;
  final VoidCallback onClose;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 6.h, 4.w, 6.h),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, size: 22.sp, color: AppColors.textPrimary),
            padding: EdgeInsets.all(8.w),
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
          ),
          Expanded(
            child: Text(
              AppStrings.of(locale, 'company_stars_filter_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: onReset,
            style: TextButton.styleFrom(
              foregroundColor: _FilterSheetStyle.resetRed,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
            ),
            child: Text(
              AppStrings.of(locale, 'company_stars_filter_reset'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.label,
    required this.onPick,
  });

  final String title;
  final List<String> options;
  final String selected;
  final String Function(String key) label;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionTitle(title),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((String key) {
            final bool on = selected == key;
            return _FilterPillChip(
              label: label(key),
              selected: on,
              onTap: () => onPick(key),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FilterPillChip extends StatelessWidget {
  const _FilterPillChip({
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
      color: selected ? AppColors.brandBlue : _FilterSheetStyle.chipIdleBg,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.white : _FilterSheetStyle.chipIdleText,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13.sp,
          color: const Color(0xFFB0B7C3),
        ),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Align(
            alignment: Alignment.centerRight,
            widthFactor: 1,
            child: Text(
              'SAR',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        suffixIconConstraints: BoxConstraints(minWidth: 40.w),
        filled: true,
        fillColor: _FilterSheetStyle.fieldFill,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _FilterSheetStyle.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.brandBlue, width: 1),
        ),
      ),
    );
  }
}

class _CountryCityDropdown extends StatelessWidget {
  const _CountryCityDropdown({
    required this.label,
    required this.hint,
  });

  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _FilterSheetStyle.fieldBorder),
          ),
          child: Row(
            children: <Widget>[
              Icon(Icons.flag, color: Colors.green.shade700, size: 18.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 22.sp,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

abstract final class _Labels {
  static String category(Locale locale, String key) {
    switch (key) {
      case 'sport':
        return AppStrings.of(locale, 'company_star_cat_sports');
      case 'fashion':
        return AppStrings.of(locale, 'company_star_cat_fashion');
      case 'news':
        return AppStrings.of(locale, 'company_star_cat_news');
      default:
        return AppStrings.of(locale, 'company_campaign_filter_all');
    }
  }

  static String platform(Locale locale, String key) {
    switch (key) {
      case 'facebook':
        return 'Facebook';
      case 'tiktok':
        return 'TikTok';
      case 'instagram':
        return 'Instagram';
      default:
        return AppStrings.of(locale, 'company_campaign_filter_all');
    }
  }

  static String gender(Locale locale, String key) {
    switch (key) {
      case 'male':
        return AppStrings.of(locale, 'profile_gender_male');
      case 'female':
        return AppStrings.of(locale, 'profile_gender_female');
      default:
        return AppStrings.of(locale, 'company_campaign_filter_all');
    }
  }

  static String age(Locale locale, String key) {
    switch (key) {
      case '15-20':
        return AppStrings.of(locale, 'company_stars_filter_age_15_20');
      case '21-25':
        return AppStrings.of(locale, 'company_stars_filter_age_21_25');
      default:
        return AppStrings.of(locale, 'company_campaign_filter_all');
    }
  }
}

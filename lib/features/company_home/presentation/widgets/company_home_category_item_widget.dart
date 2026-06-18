import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_home/presentation/models/company_home_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Round icon tile + caption used in the "Categories" section.
class CompanyHomeCategoryItemWidget extends StatelessWidget {
  const CompanyHomeCategoryItemWidget({
    super.key,
    required this.category,
    this.index = 0,
    this.onTap,
  });

  final CompanyHomeCategory category;

  /// Position in the row — used to pick a design icon when the label does not
  /// match a known category, so the icons always look intentional.
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final String label = (category.titleOverride ?? '').trim().isNotEmpty
        ? category.titleOverride!.trim()
        : AppStrings.of(locale, category.titleKey);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: <Widget>[
          Container(
            width: 56.w,
            height: 56.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDFE1E7)),
            ),
            child: Icon(
              _categoryIcon(label, index),
              size: 26.sp,
              color: AppColors.brandBlue,
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Design icon set for the "Categories" row, in the same order as the mockup:
/// Natural Disaster, Sick Person, Health Assistance, Education Support.
const List<IconData> _designCategoryIcons = <IconData>[
  Icons.volunteer_activism, // hand holding a heart
  Icons.groups, // group of people
  Icons.monitor_heart, // heart with pulse line
  Icons.menu_book, // open book
];

/// Picks the icon that matches the category label (English or Arabic). Falls
/// back to the design icon at [index] so unknown categories still look right.
IconData _categoryIcon(String label, int index) {
  final String l = label.toLowerCase();

  bool has(List<String> words) => words.any(l.contains);

  if (has(<String>['disaster', 'كارث', 'طبيع', 'إغاث', 'اغاث'])) {
    return Icons.volunteer_activism;
  }
  if (has(<String>['sick', 'patient', 'person', 'people', 'مريض', 'مرض', 'مرضى'])) {
    return Icons.groups;
  }
  if (has(<String>['health', 'medic', 'care', 'صح', 'طب', 'علاج'])) {
    return Icons.monitor_heart;
  }
  if (has(<String>['edu', 'school', 'learn', 'book', 'تعليم', 'دراس', 'كتاب', 'مدرس'])) {
    return Icons.menu_book;
  }
  return _designCategoryIcons[index % _designCategoryIcons.length];
}

import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_account/data/company_account_view_data.dart';
import 'package:adzmavall/features/company_account/presentation/models/company_account_models.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_sub_page_sheet.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyLanguagePage extends StatefulWidget {
  const CompanyLanguagePage({super.key});

  @override
  State<CompanyLanguagePage> createState() => _CompanyLanguagePageState();
}

class _CompanyLanguagePageState extends State<CompanyLanguagePage> {
  String _selected = 'en';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final List<CompanyLanguageOption> items = CompanyAccountViewData.languages
        .where(
          (CompanyLanguageOption o) =>
              o.title.toLowerCase().contains(_query.toLowerCase()) ||
              o.subtitle.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return CompanyAccountSubPageSheet(
      title: AppStrings.of(locale, 'company_account_language'),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: TextField(
              onChanged: (String v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: AppStrings.of(
                  locale,
                  'company_account_language_search_hint',
                ),
                prefixIcon: Icon(Icons.search_rounded, size: 22.sp),
                hintStyle: TextStyle(
                  color: const Color(0xFFB0B7C3),
                  fontSize: 13.sp,
                ),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: Color(0xFFE1E5EC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: const BorderSide(color: AppColors.brandBlue),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 16.h),
              itemCount: items.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                indent: 52.w,
                endIndent: 16.w,
                color: const Color(0xFFE5E7EB),
              ),
              itemBuilder: (BuildContext context, int index) {
                final CompanyLanguageOption option = items[index];
                final String subtitle = option.code == 'en'
                    ? AppStrings.of(locale, 'company_account_language_device')
                    : option.subtitle;

                return InkWell(
                  onTap: () => setState(() => _selected = option.code),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      children: <Widget>[
                        Radio<String>(
                          value: option.code,
                          groupValue: _selected,
                          activeColor: AppColors.brandBlue,
                          onChanged: (String? v) {
                            if (v != null) {
                              setState(() => _selected = v);
                            }
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                option.title,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

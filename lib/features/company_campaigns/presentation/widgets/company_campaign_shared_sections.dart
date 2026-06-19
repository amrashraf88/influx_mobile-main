import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/widgets/app_feedback.dart';
import 'package:adzmavall/features/company_campaigns/data/company_campaigns_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_platform_chip.dart';
import 'package:adzmavall/features/profile/presentation/widgets/profile_form_widgets.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyCampaignPortfolioSection extends StatefulWidget {
  const CompanyCampaignPortfolioSection({
    super.key,
    this.initialFiles,
    this.onFilesChanged,
  });

  final List<String>? initialFiles;
  final ValueChanged<List<String>>? onFilesChanged;

  @override
  State<CompanyCampaignPortfolioSection> createState() =>
      _CompanyCampaignPortfolioSectionState();
}

class _CompanyCampaignPortfolioSectionState
    extends State<CompanyCampaignPortfolioSection> {
  static const int _maxFileBytes = 5 * 1024 * 1024;

  late List<String> _files;

  @override
  void initState() {
    super.initState();
    _files = List<String>.from(widget.initialFiles ?? <String>[]);
  }

  Future<void> _pickFiles() async {
    final Locale locale = Localizations.localeOf(context);
    final FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: true,
      withReadStream: false,
    );
    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final List<String> accepted = <String>[];
    int skippedLarge = 0;
    for (final PlatformFile file in result.files) {
      final String name = file.name;
      if (name.isEmpty) {
        continue;
      }
      if (file.size > _maxFileBytes) {
        skippedLarge += 1;
        continue;
      }
      if (!_files.contains(name)) {
        accepted.add(name);
      }
    }

    if (accepted.isNotEmpty) {
      setState(() => _files.addAll(accepted));
      widget.onFilesChanged?.call(_files);
    }

    if (!mounted) {
      return;
    }
    if (accepted.isNotEmpty) {
      showAppFeedback(
        context,
        message: accepted.length == 1
            ? accepted.first
            : '${accepted.length} files added',
        type: AppFeedbackType.success,
      );
    }
    if (skippedLarge > 0) {
      final String msg = skippedLarge == 1
          ? AppStrings.of(locale, 'profile_file_skipped_large_one')
          : AppStrings.of(
              locale,
              'profile_file_skipped_large_many',
            ).replaceAll('{count}', '$skippedLarge');
      showAppFeedback(context, message: msg, type: AppFeedbackType.error);
    }
  }

  void _removeFile(String name) {
    setState(() => _files.remove(name));
    widget.onFilesChanged?.call(_files);
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return ProfileSectionCard(
      title: AppStrings.of(locale, 'profile_works_portfolio_title'),
      subtitle: AppStrings.of(locale, 'profile_works_portfolio_subtitle'),
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _pickFiles,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F7),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFB8C0CC)),
              ),
              child: Column(
                children: <Widget>[
                  Image.asset(
                    ImageAssets.fileUploadIcon,
                    width: 40.w,
                    height: 40.h,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppStrings.of(
                      locale,
                      'profile_portfolio_upload_area_title',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    AppStrings.of(locale, 'profile_portfolio_upload_area_desc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  FilledButton(
                    onPressed: _pickFiles,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    child: Text(AppStrings.of(locale, 'profile_browse_files')),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_files.isNotEmpty) ...<Widget>[
          SizedBox(height: 12.h),
          for (final String name in _files)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F7),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFE1E5EC)),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.brandBlue,
                      size: 22.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _removeFile(name),
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 22.sp,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.h,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class CompanyCampaignPlatformSection extends StatefulWidget {
  const CompanyCampaignPlatformSection({
    super.key,
    Set<String>? initialSelected,
    this.onChanged,
  }) : initialSelected = initialSelected ?? const <String>{'Instagram'};

  final Set<String> initialSelected;
  final ValueChanged<Set<String>>? onChanged;

  @override
  State<CompanyCampaignPlatformSection> createState() =>
      _CompanyCampaignPlatformSectionState();
}

class _CompanyCampaignPlatformSectionState
    extends State<CompanyCampaignPlatformSection> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return ProfileSectionCard(
      title: AppStrings.of(locale, 'company_campaign_choose_platform'),
      children: <Widget>[
        CompanyCampaignPlatformPicker(
          platforms: CompanyCampaignsViewData.platformOptions,
          selected: _selected,
          onToggle: (String platform) {
            setState(() {
              if (_selected.contains(platform)) {
                _selected.remove(platform);
              } else {
                _selected.add(platform);
              }
              widget.onChanged?.call(Set<String>.from(_selected));
            });
          },
        ),
      ],
    );
  }
}

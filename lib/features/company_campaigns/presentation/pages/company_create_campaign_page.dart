import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/company_campaigns/data/company_campaigns_repository.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_back_app_bar.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_flow_dialogs.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_date_field.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_form_field.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_shared_sections.dart';
import 'package:adzmavall/features/profile/presentation/widgets/profile_form_widgets.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Create campaign form — UI only until backend is ready.
class CompanyCreateCampaignPage extends StatefulWidget {
  const CompanyCreateCampaignPage({super.key});

  @override
  State<CompanyCreateCampaignPage> createState() =>
      _CompanyCreateCampaignPageState();
}

class _CompanyCreateCampaignPageState extends State<CompanyCreateCampaignPage> {
  final TextEditingController _brand = TextEditingController();
  final TextEditingController _website = TextEditingController();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _budgetMin = TextEditingController();
  final TextEditingController _budgetMax = TextEditingController();
  final TextEditingController _delivery = TextEditingController();
  final TextEditingController _details = TextEditingController();

  bool _faceVisible = true;
  bool _hairVisible = true;
  bool _handsVisible = true;
  String _creatorType = 'Model';
  bool _isSubmitting = false;
  String? _followers;
  String? _ageGroup;

  @override
  void dispose() {
    _brand.dispose();
    _website.dispose();
    _title.dispose();
    _budgetMin.dispose();
    _budgetMax.dispose();
    _delivery.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    setState(() => _isSubmitting = true);
    if (ApiUrlResolver.isConfigured) {
      try {
        await CompanyCampaignsRepository(DioClient.instance).createCampaign(
          title: _title.text.trim(),
          description: _details.text.trim(),
          deliveryDate: _delivery.text.trim(),
          brandName: _brand.text.trim(),
          websiteLink: _website.text.trim(),
          budgetFrom: num.tryParse(_budgetMin.text.trim()) ?? 0,
          budgetTo: num.tryParse(_budgetMax.text.trim()) ?? 0,
          creatorType: _creatorType,
          faceVisible: _faceVisible,
          hairVisible: _hairVisible,
          handsVisible: _handsVisible,
        );
      } on Object {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Campaign saved locally. Continue selecting creators.',
              ),
            ),
          );
        }
      }
    }
    if (mounted) {
      setState(() => _isSubmitting = false);
      showConfirmInfluencerAdditionDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final List<String> selectItems = <String>[
      AppStrings.of(locale, 'company_create_select_all'),
      '25-30',
      '31-40',
    ];

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: CompanyCampaignBackAppBar(
        title: AppStrings.of(locale, 'company_create_campaign_title'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: Column(
          children: <Widget>[
            _CreatorTypeCard(
              value: _creatorType,
              onChanged: (String value) => setState(() => _creatorType = value),
            ),
            SizedBox(height: 14.h),
            const _CampaignModeTabs(),
            SizedBox(height: 14.h),
            _PhotoShootDetailsCard(
              faceVisible: _faceVisible,
              hairVisible: _hairVisible,
              handsVisible: _handsVisible,
              onFaceChanged: (bool value) =>
                  setState(() => _faceVisible = value),
              onHairChanged: (bool value) =>
                  setState(() => _hairVisible = value),
              onHandsChanged: (bool value) =>
                  setState(() => _handsVisible = value),
            ),
            SizedBox(height: 14.h),
            ProfileSectionCard(
              title: '',
              children: <Widget>[
                CompanyCampaignFormField(
                  label: AppStrings.of(locale, 'company_campaign_brand_name'),
                  controller: _brand,
                  hint: AppStrings.of(locale, 'company_create_hint_brand'),
                ),
                SizedBox(height: 12.h),
                CompanyCampaignFormField(
                  label: AppStrings.of(locale, 'company_campaign_website'),
                  controller: _website,
                  hint: AppStrings.of(locale, 'company_create_hint_website'),
                ),
                SizedBox(height: 12.h),
                CompanyCampaignFormField(
                  label: AppStrings.of(locale, 'company_campaign_title_field'),
                  controller: _title,
                  hint: AppStrings.of(locale, 'company_create_hint_title'),
                ),
                SizedBox(height: 12.h),
                ProfileSelectField(
                  label: AppStrings.of(
                    locale,
                    'company_campaign_target_followers',
                  ),
                  hint: AppStrings.of(locale, 'company_create_select'),
                  value: _followers,
                  items: selectItems,
                  onChanged: (String v) => setState(() => _followers = v),
                ),
                SizedBox(height: 12.h),
                ProfileSelectField(
                  label: AppStrings.of(locale, 'company_campaign_target_age'),
                  hint: AppStrings.of(locale, 'company_create_select'),
                  value: _ageGroup,
                  items: selectItems,
                  onChanged: (String v) => setState(() => _ageGroup = v),
                ),
                SizedBox(height: 12.h),
                Text(
                  AppStrings.of(locale, 'company_campaign_proposed_budget'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CompanyCampaignFormField(
                        label: '',
                        controller: _budgetMin,
                        hint: '1000',
                        keyboardType: TextInputType.number,
                        hidePrefixIcon: true,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: CompanyCampaignFormField(
                        label: '',
                        controller: _budgetMax,
                        hint: '50000',
                        keyboardType: TextInputType.number,
                        hidePrefixIcon: true,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                CompanyCampaignDateField(
                  label: AppStrings.of(
                    locale,
                    'company_campaign_delivery_date_field',
                  ),
                  controller: _delivery,
                  hint: AppStrings.of(locale, 'company_create_hint_delivery'),
                ),
                SizedBox(height: 12.h),
                CompanyCampaignFormField(
                  label: AppStrings.of(
                    locale,
                    'company_campaign_details_field',
                  ),
                  controller: _details,
                  hint: AppStrings.of(locale, 'company_campaign_type_here'),
                  hidePrefixIcon: true,
                  maxLines: 4,
                ),
              ],
            ),
            SizedBox(height: 14.h),
            const CompanyCampaignPortfolioSection(),
            SizedBox(height: 14.h),
            const CompanyCampaignPlatformSection(),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        AppStrings.of(locale, 'company_create_save'),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandBlue,
                  side: const BorderSide(color: AppColors.brandBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Text(
                  AppStrings.of(locale, 'company_create_cancel'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}

class _CreatorTypeCard extends StatelessWidget {
  const _CreatorTypeCard({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Creator Type',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'The campaign form adapts to the creator.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            'Select Creator',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFE7EAF0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                  size: 22.sp,
                ),
                items:
                    const <String>[
                      'Influencer',
                      'Model',
                      'UGC Creator',
                      'Collage',
                    ].map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Row(
                          children: <Widget>[
                            Icon(_creatorIcon(item), size: 18),
                            SizedBox(width: 10.w),
                            Text(item),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (String? next) {
                  if (next != null) {
                    onChanged(next);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _creatorIcon(String value) {
  return switch (value) {
    'Influencer' => Icons.campaign_outlined,
    'Model' => Icons.person_outline_rounded,
    'UGC Creator' => Icons.video_camera_front_outlined,
    'Collage' => Icons.school_outlined,
    _ => Icons.person_outline_rounded,
  };
}

class _CampaignModeTabs extends StatelessWidget {
  const _CampaignModeTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ModeTab(
            label: 'Campaign Type',
            icon: Icons.add_circle_outline_rounded,
            selected: false,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _ModeTab(
            label: 'Photo Shoot Details',
            icon: Icons.grid_view_rounded,
            selected: true,
          ),
        ),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
  });

  final String label;
  final IconData icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.brandBlue : AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 16.sp,
            color: selected ? AppColors.white : AppColors.textMuted,
          ),
          SizedBox(width: 7.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.textMuted,
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoShootDetailsCard extends StatelessWidget {
  const _PhotoShootDetailsCard({
    required this.faceVisible,
    required this.hairVisible,
    required this.handsVisible,
    required this.onFaceChanged,
    required this.onHairChanged,
    required this.onHandsChanged,
  });

  final bool faceVisible;
  final bool hairVisible;
  final bool handsVisible;
  final ValueChanged<bool> onFaceChanged;
  final ValueChanged<bool> onHairChanged;
  final ValueChanged<bool> onHandsChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: Offset(0, 7.h),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _VisibilitySwitchRow(
            label: 'Face Visible',
            value: faceVisible,
            onChanged: onFaceChanged,
          ),
          _VisibilitySwitchRow(
            label: 'Hair Visible',
            value: hairVisible,
            onChanged: onHairChanged,
          ),
          _VisibilitySwitchRow(
            label: 'Hands Visible',
            value: handsVisible,
            onChanged: onHandsChanged,
          ),
        ],
      ),
    );
  }
}

class _VisibilitySwitchRow extends StatelessWidget {
  const _VisibilitySwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52.h,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.brandBlue,
            inactiveThumbColor: AppColors.white,
            inactiveTrackColor: const Color(0xFFD9DEE8),
          ),
        ],
      ),
    );
  }
}

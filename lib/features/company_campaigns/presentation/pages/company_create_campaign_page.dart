import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/widgets/app_feedback.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart'
    show ApiException;
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
import 'package:intl/intl.dart';

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
  final TextEditingController _campaignType = TextEditingController();
  final TextEditingController _contentBrief = TextEditingController();
  final TextEditingController _modelHeight = TextEditingController();
  final TextEditingController _modelWeight = TextEditingController();
  final TextEditingController _modelSize = TextEditingController();
  final TextEditingController _modelDistrict = TextEditingController();
  final TextEditingController _ugcVideoPrice = TextEditingController();
  final TextEditingController _ugcDeliveryTime = TextEditingController();
  final TextEditingController _collageDistrict = TextEditingController();
  final TextEditingController _collagePricePerSecond = TextEditingController();
  final TextEditingController _collageAccent = TextEditingController();
  final TextEditingController _collageDirections = TextEditingController();

  bool _faceVisible = true;
  bool _hairVisible = true;
  bool _handsVisible = true;
  bool _fullBodyVisible = true;
  bool _voiceOver = true;
  bool _useHook = true;
  String _creatorType = 'Model';
  bool _isSubmitting = false;
  String? _followers;
  String? _ageGroup;
  Set<String> _selectedPlatforms = const <String>{'Instagram'};

  @override
  void dispose() {
    _brand.dispose();
    _website.dispose();
    _title.dispose();
    _budgetMin.dispose();
    _budgetMax.dispose();
    _delivery.dispose();
    _details.dispose();
    _campaignType.dispose();
    _contentBrief.dispose();
    _modelHeight.dispose();
    _modelWeight.dispose();
    _modelSize.dispose();
    _modelDistrict.dispose();
    _ugcVideoPrice.dispose();
    _ugcDeliveryTime.dispose();
    _collageDistrict.dispose();
    _collagePricePerSecond.dispose();
    _collageAccent.dispose();
    _collageDirections.dispose();
    super.dispose();
  }

  Map<String, dynamic> _creatorExtraPayload() {
    final Map<String, dynamic> common = <String, dynamic>{
      'campaign_type': _campaignType.text.trim(),
      'content_brief': _contentBrief.text.trim(),
    };

    return switch (_creatorType) {
      'Model' => <String, dynamic>{
        ...common,
        'height_cm': _modelHeight.text.trim(),
        'weight_kg': _modelWeight.text.trim(),
        'model_size': _modelSize.text.trim(),
        'district': _modelDistrict.text.trim(),
        'body_visibility': _fullBodyVisible ? 'yes' : 'no',
      },
      'UGC Creator' => <String, dynamic>{
        ...common,
        'video_price': _ugcVideoPrice.text.trim(),
        'delivery_time_from_arrival': _ugcDeliveryTime.text.trim(),
        'voice_over': _voiceOver ? 'yes' : 'no',
        'use_hook': _useHook ? 'yes' : 'no',
      },
      'Collage' => <String, dynamic>{
        ...common,
        'street': _collageDistrict.text.trim(),
        'price_per_second': _collagePricePerSecond.text.trim(),
        'accent': _collageAccent.text.trim(),
        'directions': _collageDirections.text.trim(),
        'voice_over': _voiceOver ? 'yes' : 'no',
        'use_hook': _useHook ? 'yes' : 'no',
      },
      _ => common,
    };
  }

  String? _deliveryForApi(Locale locale) {
    final String raw = _delivery.text.trim();
    if (raw.isEmpty) {
      return null;
    }
    try {
      final DateTime parsed = DateFormat(
        'dd MMMM, yyyy',
        locale.languageCode,
      ).parseStrict(raw);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } on Object {
      return null;
    }
  }

  String? _targetFollowersValue(String? label) {
    final String value = label?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return null;
    if (value.contains('all') || value.contains('كل')) return 'all';
    if (value.contains('1m') || value.contains('1 m')) return 'more_than_1m';
    if (value.contains('500') && value.contains('1')) return 'from_500k_to_1m';
    if (value.contains('250') && value.contains('500')) {
      return 'from_250k_to_500k';
    }
    if (value.contains('250')) return 'less_than_250k';
    return null;
  }

  String? _targetAgeValue(String? label) {
    final String value = label?.trim().toLowerCase() ?? '';
    if (value.isEmpty) return null;
    if (value.contains('all') || value.contains('كل')) return 'all';
    if (value.contains('40') && !value.contains('31')) return 'more_than_40';
    if (value.contains('31') || value.contains('30-40')) return 'from_30_to_40';
    if (value.contains('25') || value.contains('20-30')) return 'from_20_to_30';
    if (value.contains('20')) return 'less_than_20';
    return null;
  }

  List<String> _platformValues() {
    return _selectedPlatforms
        .map((String platform) {
          final String value = platform.trim().toLowerCase();
          if (value.contains('insta')) return 'instagram';
          if (value.contains('tik')) return 'tiktok';
          if (value.contains('snap')) return 'snapchat';
          if (value == 'x' || value.contains('twitter')) return 'x';
          if (value.contains('you')) return 'youtube';
          if (value.contains('face')) return 'facebook';
          if (value.contains('linkedin')) return 'linkedin';
          if (value.contains('pinterest')) return 'pinterest';
          if (value.contains('thread')) return 'threads';
          if (value.contains('telegram')) return 'telegram';
          if (value.contains('whats')) return 'whatsapp';
          return value.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
        })
        .where((String value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
  }

  void _toast(String message, {AppFeedbackType type = AppFeedbackType.info}) {
    if (!mounted) return;
    showAppFeedback(context, message: message, type: type);
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }
    final Locale locale = Localizations.localeOf(context);
    final String title = _title.text.trim();
    final String description = _details.text.trim();
    final String? deliveryDate = _deliveryForApi(locale);
    final List<String> platforms = _platformValues();
    if (title.isEmpty) {
      _toast('Campaign title is required.', type: AppFeedbackType.error);
      return;
    }
    if (description.isEmpty) {
      _toast('Campaign details are required.', type: AppFeedbackType.error);
      return;
    }
    if (deliveryDate == null) {
      _toast(
        'Please select a valid delivery date.',
        type: AppFeedbackType.error,
      );
      return;
    }
    if (platforms.isEmpty) {
      _toast(
        'Please choose at least one platform.',
        type: AppFeedbackType.error,
      );
      return;
    }
    setState(() => _isSubmitting = true);
    if (ApiUrlResolver.isConfigured) {
      try {
        await CompanyCampaignsRepository(DioClient.instance).createCampaign(
          title: title,
          description: description,
          deliveryDate: deliveryDate,
          brandName: _brand.text.trim(),
          websiteLink: _website.text.trim(),
          budgetFrom: num.tryParse(_budgetMin.text.trim()) ?? 0,
          budgetTo: num.tryParse(_budgetMax.text.trim()) ?? 0,
          creatorType: _creatorType,
          faceVisible: _faceVisible,
          hairVisible: _hairVisible,
          handsVisible: _handsVisible,
          platforms: platforms,
          targetFollowers: _targetFollowersValue(_followers),
          targetAudienceAgeGroup: _targetAgeValue(_ageGroup),
          extraFields: _creatorExtraPayload(),
        );
      } on ApiException catch (e) {
        _toast(e.message, type: AppFeedbackType.error);
        if (mounted) setState(() => _isSubmitting = false);
        return;
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
            _CreatorDynamicSection(
              creatorType: _creatorType,
              campaignType: _campaignType,
              contentBrief: _contentBrief,
              modelHeight: _modelHeight,
              modelWeight: _modelWeight,
              modelSize: _modelSize,
              modelDistrict: _modelDistrict,
              ugcVideoPrice: _ugcVideoPrice,
              ugcDeliveryTime: _ugcDeliveryTime,
              collageDistrict: _collageDistrict,
              collagePricePerSecond: _collagePricePerSecond,
              collageAccent: _collageAccent,
              collageDirections: _collageDirections,
              faceVisible: _faceVisible,
              hairVisible: _hairVisible,
              handsVisible: _handsVisible,
              fullBodyVisible: _fullBodyVisible,
              voiceOver: _voiceOver,
              useHook: _useHook,
              onFaceChanged: (bool value) =>
                  setState(() => _faceVisible = value),
              onHairChanged: (bool value) =>
                  setState(() => _hairVisible = value),
              onHandsChanged: (bool value) =>
                  setState(() => _handsVisible = value),
              onFullBodyChanged: (bool value) =>
                  setState(() => _fullBodyVisible = value),
              onVoiceOverChanged: (bool value) =>
                  setState(() => _voiceOver = value),
              onUseHookChanged: (bool value) =>
                  setState(() => _useHook = value),
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
            CompanyCampaignPlatformSection(
              initialSelected: _selectedPlatforms,
              onChanged: (Set<String> value) =>
                  setState(() => _selectedPlatforms = value),
            ),
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
  const _CampaignModeTabs({
    required this.secondaryLabel,
    required this.secondaryIcon,
  });

  final String secondaryLabel;
  final IconData secondaryIcon;

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
            label: secondaryLabel,
            icon: secondaryIcon,
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

class _CreatorDynamicSection extends StatelessWidget {
  const _CreatorDynamicSection({
    required this.creatorType,
    required this.campaignType,
    required this.contentBrief,
    required this.modelHeight,
    required this.modelWeight,
    required this.modelSize,
    required this.modelDistrict,
    required this.ugcVideoPrice,
    required this.ugcDeliveryTime,
    required this.collageDistrict,
    required this.collagePricePerSecond,
    required this.collageAccent,
    required this.collageDirections,
    required this.faceVisible,
    required this.hairVisible,
    required this.handsVisible,
    required this.fullBodyVisible,
    required this.voiceOver,
    required this.useHook,
    required this.onFaceChanged,
    required this.onHairChanged,
    required this.onHandsChanged,
    required this.onFullBodyChanged,
    required this.onVoiceOverChanged,
    required this.onUseHookChanged,
  });

  final String creatorType;
  final TextEditingController campaignType;
  final TextEditingController contentBrief;
  final TextEditingController modelHeight;
  final TextEditingController modelWeight;
  final TextEditingController modelSize;
  final TextEditingController modelDistrict;
  final TextEditingController ugcVideoPrice;
  final TextEditingController ugcDeliveryTime;
  final TextEditingController collageDistrict;
  final TextEditingController collagePricePerSecond;
  final TextEditingController collageAccent;
  final TextEditingController collageDirections;
  final bool faceVisible;
  final bool hairVisible;
  final bool handsVisible;
  final bool fullBodyVisible;
  final bool voiceOver;
  final bool useHook;
  final ValueChanged<bool> onFaceChanged;
  final ValueChanged<bool> onHairChanged;
  final ValueChanged<bool> onHandsChanged;
  final ValueChanged<bool> onFullBodyChanged;
  final ValueChanged<bool> onVoiceOverChanged;
  final ValueChanged<bool> onUseHookChanged;

  String get _secondaryLabel {
    return switch (creatorType) {
      'Influencer' => 'Influencer Brief',
      'UGC Creator' => 'UGC Details',
      'Collage' => 'Collage Details',
      _ => 'Photo Shoot Details',
    };
  }

  IconData get _secondaryIcon {
    return switch (creatorType) {
      'Influencer' => Icons.campaign_outlined,
      'UGC Creator' => Icons.video_camera_front_outlined,
      'Collage' => Icons.school_outlined,
      _ => Icons.grid_view_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _CampaignModeTabs(
          secondaryLabel: _secondaryLabel,
          secondaryIcon: _secondaryIcon,
        ),
        SizedBox(height: 14.h),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _DetailsCard(
            key: ValueKey<String>(creatorType),
            children: switch (creatorType) {
              'Influencer' => _influencerFields(),
              'UGC Creator' => _ugcFields(),
              'Collage' => _collageFields(),
              _ => _modelFields(),
            },
          ),
        ),
      ],
    );
  }

  List<Widget> _briefFields({required String campaignHint}) {
    return <Widget>[
      CompanyCampaignFormField(
        label: 'Campaign Type',
        controller: campaignType,
        hint: campaignHint,
        prefixIcon: Icons.add_circle_outline_rounded,
      ),
      SizedBox(height: 12.h),
      CompanyCampaignFormField(
        label: 'Content Brief',
        controller: contentBrief,
        hint: 'Write the required content details',
        hidePrefixIcon: true,
        maxLines: 3,
      ),
    ];
  }

  List<Widget> _influencerFields() {
    return <Widget>[
      ..._briefFields(campaignHint: 'Story / Reel / Post'),
      SizedBox(height: 12.h),
      _VisibilitySwitchRow(
        label: 'Use Hook',
        value: useHook,
        onChanged: onUseHookChanged,
      ),
    ];
  }

  List<Widget> _modelFields() {
    return <Widget>[
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
      _VisibilitySwitchRow(
        label: 'Full Body Visible',
        value: fullBodyVisible,
        onChanged: onFullBodyChanged,
      ),
      SizedBox(height: 2.h),
      Row(
        children: <Widget>[
          Expanded(
            child: CompanyCampaignFormField(
              label: 'Height',
              controller: modelHeight,
              hint: '170 cm',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.height_rounded,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CompanyCampaignFormField(
              label: 'Weight',
              controller: modelWeight,
              hint: '60 kg',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.monitor_weight_outlined,
            ),
          ),
        ],
      ),
      SizedBox(height: 12.h),
      Row(
        children: <Widget>[
          Expanded(
            child: CompanyCampaignFormField(
              label: 'Size',
              controller: modelSize,
              hint: 'M / 38',
              prefixIcon: Icons.straighten_rounded,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CompanyCampaignFormField(
              label: 'District',
              controller: modelDistrict,
              hint: 'Riyadh',
              prefixIcon: Icons.location_on_outlined,
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _ugcFields() {
    return <Widget>[
      ..._briefFields(campaignHint: 'UGC Video / Review / Unboxing'),
      SizedBox(height: 12.h),
      Row(
        children: <Widget>[
          Expanded(
            child: CompanyCampaignFormField(
              label: 'Video Price',
              controller: ugcVideoPrice,
              hint: '1500 SAR',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.payments_outlined,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CompanyCampaignFormField(
              label: 'Delivery Time',
              controller: ugcDeliveryTime,
              hint: '3 days',
              prefixIcon: Icons.schedule_rounded,
            ),
          ),
        ],
      ),
      SizedBox(height: 12.h),
      _VisibilitySwitchRow(
        label: 'Voice Over',
        value: voiceOver,
        onChanged: onVoiceOverChanged,
      ),
      _VisibilitySwitchRow(
        label: 'Use Hook',
        value: useHook,
        onChanged: onUseHookChanged,
      ),
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
    ];
  }

  List<Widget> _collageFields() {
    return <Widget>[
      ..._briefFields(campaignHint: 'College activation / Campus content'),
      SizedBox(height: 12.h),
      Row(
        children: <Widget>[
          Expanded(
            child: CompanyCampaignFormField(
              label: 'District',
              controller: collageDistrict,
              hint: 'Campus / city',
              prefixIcon: Icons.location_on_outlined,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: CompanyCampaignFormField(
              label: 'Price / second',
              controller: collagePricePerSecond,
              hint: '50 SAR',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.payments_outlined,
            ),
          ),
        ],
      ),
      SizedBox(height: 12.h),
      CompanyCampaignFormField(
        label: 'Accent',
        controller: collageAccent,
        hint: 'Saudi / Gulf / Neutral',
        prefixIcon: Icons.record_voice_over_outlined,
      ),
      SizedBox(height: 12.h),
      CompanyCampaignFormField(
        label: 'Directions',
        controller: collageDirections,
        hint: 'Write location and shooting directions',
        hidePrefixIcon: true,
        maxLines: 3,
      ),
      SizedBox(height: 12.h),
      _VisibilitySwitchRow(
        label: 'Voice Over',
        value: voiceOver,
        onChanged: onVoiceOverChanged,
      ),
      _VisibilitySwitchRow(
        label: 'Use Hook',
        value: useHook,
        onChanged: onUseHookChanged,
      ),
    ];
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 14.h),
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
      child: Column(children: children),
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

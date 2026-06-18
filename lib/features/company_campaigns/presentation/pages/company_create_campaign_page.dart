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
        );
      } on Object {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not create the campaign. Please try again.'),
            ),
          );
        }
        return;
      }
    }
    if (mounted) {
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
                  label: AppStrings.of(
                    locale,
                    'company_campaign_title_field',
                  ),
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
                  label: AppStrings.of(
                    locale,
                    'company_campaign_target_age',
                  ),
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
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Text(
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

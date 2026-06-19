import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/company_campaigns/data/company_stars_repository.dart';
import 'package:adzmavall/features/company_campaigns/data/company_stars_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_star_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_platform_chip.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_header_background.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_profile_summary_card.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_profile_tab_bar.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_panel_card.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CompanyStarProfilePage extends StatefulWidget {
  const CompanyStarProfilePage({super.key, required this.starId});

  final String starId;

  @override
  State<CompanyStarProfilePage> createState() => _CompanyStarProfilePageState();
}

class _CompanyStarProfilePageState extends State<CompanyStarProfilePage> {
  int _tabIndex = 0;
  late CompanyStarProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = CompanyStarsViewData.profileFor(widget.starId);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!ApiUrlResolver.isConfigured) {
      return;
    }
    try {
      final CompanyStarProfile profile = await CompanyStarsRepository(
        DioClient.instance,
      ).fetchStarProfile(widget.starId);
      if (!mounted) {
        return;
      }
      setState(() => _profile = profile);
    } on Object {
      // Keep the view-data fallback already in _profile.
    }
  }

  void _requestAd() {
    context.push(RouteNames.companyRequestAdPath(widget.starId));
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final CompanyStarProfile profile = _profile;
    final double topInset = MediaQuery.paddingOf(context).top;
    final List<InfluencerProfileTabItem> tabs = <InfluencerProfileTabItem>[
      const InfluencerProfileTabItem(
        label: 'Overview',
        asset: ImageAssets.detailsIcon,
      ),
      InfluencerProfileTabItem(
        label: AppStrings.of(locale, 'company_star_tab_accounts'),
        asset: ImageAssets.categoryIcon,
      ),
      InfluencerProfileTabItem(
        label: AppStrings.of(locale, 'company_star_tab_clients'),
        asset: ImageAssets.userStarIcon,
      ),
      InfluencerProfileTabItem(
        label: AppStrings.of(locale, 'company_star_tab_ad_price'),
        asset: ImageAssets.hotPriceIcon,
      ),
      const InfluencerProfileTabItem(
        label: 'Works & Portfolio',
        asset: ImageAssets.advertisimentIcon,
      ),
      const InfluencerProfileTabItem(
        label: 'Details',
        asset: ImageAssets.viewIcon,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Stack(
          children: <Widget>[
            InfluencerHeaderBackground(height: 158.h),
            SafeArea(
              top: false,
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: topInset + 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: _ProfileBackButton(onTap: () => context.pop()),
                  ),
                  SizedBox(height: 12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: InfluencerProfileSummaryCard(
                      profile: InfluencerProfileSummaryData(
                        name: profile.name,
                        title: profile.headline,
                        bio: profile.bio,
                        avatarUrl: profile.avatarUrl,
                        mawthooqLabel: profile.mawthooqLabel,
                      ),
                      contactActions: <InfluencerContactAction>[
                        InfluencerContactAction(
                          label: AppStrings.of(locale, 'company_star_chat'),
                          asset: ImageAssets.homeBottomNavChat,
                        ),
                        const InfluencerContactAction(
                          label: 'Whatsapp',
                          asset: ImageAssets.whatsappIcon,
                        ),
                        InfluencerContactAction(
                          label: AppStrings.of(locale, 'company_star_email'),
                          asset: ImageAssets.mailIcon,
                        ),
                      ],
                      showEditButton: false,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 0),
                    child: SizedBox(
                      height: 46.h,
                      child: FilledButton(
                        onPressed: _requestAd,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandBlue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: Text(
                          AppStrings.of(locale, 'company_star_request_ad'),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  InfluencerProfileTabBar(
                    tabs: tabs,
                    selectedIndex: _tabIndex,
                    onChanged: (int index) => setState(() => _tabIndex = index),
                  ),
                  SizedBox(height: 18.h),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 100.h),
                      child: _StarTabBody(
                        tabIndex: _tabIndex,
                        profile: profile,
                        locale: locale,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
            child: SizedBox(
              height: 48.h,
              child: FilledButton(
                onPressed: _requestAd,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                ),
                child: Text(
                  AppStrings.of(locale, 'company_star_request_ad'),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StarTabBody extends StatelessWidget {
  const _StarTabBody({
    required this.tabIndex,
    required this.profile,
    required this.locale,
  });

  final int tabIndex;
  final CompanyStarProfile profile;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return switch (tabIndex) {
      0 => _OverviewPanel(profile: profile),
      1 => _AccountsPanel(profile: profile, locale: locale),
      2 => _ClientsPanel(profile: profile),
      3 => _AdPricesPanel(profile: profile, locale: locale),
      4 => _WorksPanel(profile: profile),
      _ => _DetailsPanel(profile: profile),
    };
  }
}

class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel({required this.profile});

  final CompanyStarProfile profile;

  @override
  Widget build(BuildContext context) {
    final List<_DetailField> fields = _overviewFields(profile);
    return _InfoCard(
      children: <Widget>[
        if (profile.categories.isNotEmpty) ...<Widget>[
          _SectionLabel('Categories'),
          SizedBox(height: 10.h),
          _ChipWrap(values: profile.categories),
          _PanelDivider(),
        ],
        for (final _DetailField field in fields) ...<Widget>[
          _InfoValue(label: field.label, value: field.value),
          _PanelDivider(),
        ],
        if (profile.bio.trim().isNotEmpty)
          _InfoValue(label: 'About me', value: profile.bio),
      ],
    );
  }
}

class _AccountsPanel extends StatelessWidget {
  const _AccountsPanel({required this.profile, required this.locale});

  final CompanyStarProfile profile;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    if (profile.adPrices.isEmpty) {
      return const _EmptyPanel(message: 'No social accounts available');
    }
    return _InfoCard(
      children: <Widget>[
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: profile.adPrices.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 18.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 0.74,
          ),
          itemBuilder: (BuildContext context, int index) {
            final CompanyStarAdPriceLine line = profile.adPrices[index];
            final String platform = line.platformName.trim().isNotEmpty
                ? line.platformName.trim()
                : AppStrings.of(locale, line.labelKey);
            return Column(
              children: <Widget>[
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      CompanyCampaignPlatformAssets.assetFor(platform),
                      width: 25.w,
                      height: 25.w,
                    ),
                  ),
                ),
                SizedBox(height: 9.h),
                Text(
                  platform,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (line.followersLabel.trim().isNotEmpty) ...<Widget>[
                  SizedBox(height: 4.h),
                  Text(
                    line.followersLabel.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ClientsPanel extends StatelessWidget {
  const _ClientsPanel({required this.profile});

  final CompanyStarProfile profile;

  @override
  Widget build(BuildContext context) {
    final List<String> clients = _stringList(profile.rawProfile, <String>[
      'clients',
      'brands',
      'companies',
      'previous_clients',
      'previousClients',
    ]);
    if (clients.isEmpty) {
      return const _EmptyPanel(message: 'No clients available');
    }
    return _InfoCard(children: <Widget>[_ChipWrap(values: clients)]);
  }
}

class _AdPricesPanel extends StatelessWidget {
  const _AdPricesPanel({required this.profile, required this.locale});

  final CompanyStarProfile profile;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    if (profile.adPrices.isEmpty) {
      return const _EmptyAdPrices();
    }
    return Column(
      children: profile.adPrices
          .map(
            (CompanyStarAdPriceLine line) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: _AdPriceCard(line: line, locale: locale),
            ),
          )
          .toList(),
    );
  }
}

class _WorksPanel extends StatelessWidget {
  const _WorksPanel({required this.profile});

  final CompanyStarProfile profile;

  @override
  Widget build(BuildContext context) {
    if (profile.works.isEmpty) {
      return const _EmptyPanel(message: 'No portfolio items available');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profile.works.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (BuildContext context, int index) {
        final CompanyStarWorkItem work = profile.works[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(work.imageUrl, fit: BoxFit.cover),
              if (work.title.trim().isNotEmpty)
                Positioned(
                  left: 10.w,
                  right: 10.w,
                  bottom: 10.h,
                  child: Text(
                    work.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.profile});

  final CompanyStarProfile profile;

  @override
  Widget build(BuildContext context) {
    final List<_DetailField> fields = _detailsFields(profile);
    if (fields.isEmpty) {
      return const _EmptyPanel(message: 'No details available');
    }
    return _InfoCard(
      children: <Widget>[
        for (int i = 0; i < fields.length; i += 2) ...<Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _InfoValue(
                  label: fields[i].label,
                  value: fields[i].value,
                ),
              ),
              if (i + 1 < fields.length) ...<Widget>[
                SizedBox(width: 18.w),
                Expanded(
                  child: _InfoValue(
                    label: fields[i + 1].label,
                    value: fields[i + 1].value,
                  ),
                ),
              ] else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
          if (i + 2 < fields.length) _PanelDivider(),
        ],
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return InfluencerPanelCard(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF7D8591),
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: values
          .map(
            (String value) => Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(color: const Color(0xFFE0E3E9)),
              ),
              child: Text(
                '#${value.replaceFirst(RegExp(r'^#+'), '')}',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _InfoValue extends StatelessWidget {
  const _InfoValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF7D8591),
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          value.trim().isEmpty ? '-' : value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14.sp,
            height: 1.28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PanelDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 24.h, color: const Color(0xFFE5E7EB));
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return InfluencerPanelCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 22.h),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DetailField {
  const _DetailField(this.label, this.value);

  final String label;
  final String value;
}

List<_DetailField> _overviewFields(CompanyStarProfile profile) {
  final String rateLabel = switch (profile.creatorTypeValue) {
    'collage' => 'Price Per Second (SAR)',
    'model' => 'Session Rate Per Hour (SAR)',
    _ => 'Rate (SAR)',
  };
  final List<_DetailField> fields = <_DetailField>[
    _DetailField(rateLabel, _priceRange(profile)),
    _DetailField('Location', _location(profile.rawProfile)),
    _DetailField('Age', _pickProfile(profile, <String>['age'])),
    _DetailField('Gender', _pickProfile(profile, <String>['gender'])),
  ];
  if (profile.creatorTypeValue == 'model') {
    fields.addAll(<_DetailField>[
      _DetailField(
        'Nationality',
        _pickProfile(profile, <String>['nationality']),
      ),
      _DetailField('Weight', _pickProfile(profile, <String>['weight'])),
      _DetailField('Height', _pickProfile(profile, <String>['height'])),
      _DetailField(
        'Skin Tone',
        _pickProfile(profile, <String>['skin_tone', 'skinTone']),
      ),
      _DetailField(
        'Size',
        _pickProfile(profile, <String>['size', 'model_size']),
      ),
      _DetailField(
        'Face Visible',
        _yesNo(_pickProfile(profile, <String>['face_visible', 'show_face'])),
      ),
      _DetailField(
        'Hair Visible',
        _yesNo(_pickProfile(profile, <String>['hair_visible', 'show_hair'])),
      ),
    ]);
  } else if (profile.creatorTypeValue == 'collage') {
    fields.add(
      _DetailField('Accent', _pickProfile(profile, <String>['accent'])),
    );
  }
  return fields
      .where((_DetailField field) => field.value.trim().isNotEmpty)
      .toList();
}

List<_DetailField> _detailsFields(CompanyStarProfile profile) {
  return <_DetailField>[
    _DetailField('Creator Type', profile.creatorTypeValue),
    _DetailField('City', _pickProfile(profile, <String>['city'])),
    _DetailField(
      'Direction',
      _pickProfile(profile, <String>['city_direction', 'direction']),
    ),
    _DetailField('Street', _pickProfile(profile, <String>['street'])),
    _DetailField(
      'Phone',
      _pickProfile(profile, <String>['phone', 'phone_number', 'mobile']),
    ),
    _DetailField('Mawthooq', profile.mawthooqLabel),
    _DetailField('Bio', profile.bio),
  ].where((_DetailField field) => field.value.trim().isNotEmpty).toList();
}

String _priceRange(CompanyStarProfile profile) {
  final List<num> prices = <num>[];
  for (final CompanyStarAdPriceLine line in profile.adPrices) {
    for (final String value in <String>[line.coveragePrice, line.videoPrice]) {
      final num? parsed = num.tryParse(
        value.replaceAll(RegExp(r'[^0-9.]'), ''),
      );
      if (parsed != null && parsed > 0) {
        prices.add(parsed);
      }
    }
  }
  if (prices.isEmpty) {
    return '';
  }
  prices.sort();
  if (prices.length == 1 || prices.first == prices.last) {
    return '${_formatNumber(prices.first)} SAR';
  }
  return '${_formatNumber(prices.first)} - ${_formatNumber(prices.last)} SAR';
}

String _formatNumber(num value) {
  final int whole = value.round();
  return whole.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
}

String _location(Map<String, dynamic> json) {
  final List<String> parts = <String>[
    _pickRaw(json, <String>['city']),
    _pickRaw(json, <String>['country', 'country_name', 'countryName']),
  ].where((String value) => value.trim().isNotEmpty).toList();
  return parts.join(', ');
}

String _pickProfile(CompanyStarProfile profile, List<String> keys) {
  return _pickRaw(profile.rawProfile, keys);
}

String _pickRaw(Map<String, dynamic> json, List<String> keys) {
  final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[json];
  for (final String objectKey in <String>[
    'user',
    'profile',
    'content_creator',
    'contentCreator',
    'creator',
    'details',
  ]) {
    final Object? value = json[objectKey];
    if (value is Map) {
      maps.add(Map<String, dynamic>.from(value));
    }
  }
  for (final Map<String, dynamic> map in maps) {
    for (final String key in keys) {
      final Object? value = map[key];
      if (value is Map) {
        for (final String nestedKey in <String>[
          'label',
          'name',
          'value',
          'title',
        ]) {
          final Object? nested = value[nestedKey];
          if (nested != null && nested.toString().trim().isNotEmpty) {
            return nested.toString().trim();
          }
        }
      }
      final String text = value?.toString().trim() ?? '';
      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }
  }
  return '';
}

List<String> _stringList(Map<String, dynamic> json, List<String> keys) {
  final List<String> values = <String>[];
  for (final String key in keys) {
    final Object? value = json[key];
    if (value is List) {
      values.addAll(value.map((Object? item) => item?.toString().trim() ?? ''));
    } else if (value is String) {
      values.addAll(
        value.split(RegExp(r'[,،|]')).map((String item) => item.trim()),
      );
    }
  }
  return values.where((String value) => value.isNotEmpty).toSet().toList();
}

String _yesNo(String raw) {
  final String value = raw.trim().toLowerCase();
  if (value == '1' || value == 'true' || value == 'yes') return 'Yes';
  if (value == '0' || value == 'false' || value == 'no') return 'No';
  return raw;
}

class _EmptyAdPrices extends StatelessWidget {
  const _EmptyAdPrices();

  @override
  Widget build(BuildContext context) {
    return InfluencerPanelCard(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.payments_outlined,
            color: AppColors.textMuted,
            size: 28.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'No ad prices available',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBackButton extends StatelessWidget {
  const _ProfileBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: SizedBox(
            width: 40.w,
            height: 40.w,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _AdPriceCard extends StatelessWidget {
  const _AdPriceCard({required this.line, required this.locale});

  final CompanyStarAdPriceLine line;
  final Locale locale;

  String get _platformAsset {
    final String platform = line.platformName.trim().isNotEmpty
        ? line.platformName
        : line.labelKey;
    return CompanyCampaignPlatformAssets.assetFor(platform);
  }

  @override
  Widget build(BuildContext context) {
    final String asset = _platformAsset;
    final String platformName = line.platformName.trim().isNotEmpty
        ? line.platformName.trim()
        : AppStrings.of(locale, line.labelKey);
    final String followers = line.followersLabel.trim();
    return InfluencerPanelCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(asset, width: 25.w, height: 25.h),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  platformName,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (followers.isNotEmpty) ...<Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8D8),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '$followers ${AppStrings.of(locale, 'company_star_followers')}',
                    style: TextStyle(
                      color: const Color(0xFFE6C44E),
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Container(
                width: 28.w,
                height: 28.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5F7FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.open_in_new_rounded,
                  color: const Color(0xFF6EC7EA),
                  size: 15.sp,
                ),
              ),
            ],
          ),
          Divider(height: 22.h, color: const Color(0xFFE7E9ED)),
          Row(
            children: <Widget>[
              Expanded(
                child: _PriceMetric(
                  label: AppStrings.of(locale, 'company_star_coverage'),
                  value: line.coveragePrice,
                ),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: _PriceMetric(
                  label: AppStrings.of(locale, 'company_star_video'),
                  value: line.videoPrice,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceMetric extends StatelessWidget {
  const _PriceMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final String displayValue = value.trim().isEmpty ? '-' : value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF7D8591),
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            Text(
              displayValue,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (value.trim().isNotEmpty) ...<Widget>[
              SizedBox(width: 8.w),
              Image.asset(ImageAssets.rsIcon, width: 16.w, height: 16.h),
            ],
          ],
        ),
      ],
    );
  }
}

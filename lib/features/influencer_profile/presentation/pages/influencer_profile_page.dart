import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/influencer_profile/data/creator_profile_repository.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/creator_profile_tab_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_header_background.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_profile_panels.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_profile_summary_card.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_profile_tab_bar.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfluencerProfilePage extends StatefulWidget {
  const InfluencerProfilePage({super.key});

  @override
  State<InfluencerProfilePage> createState() => _InfluencerProfilePageState();
}

class _InfluencerProfilePageState extends State<InfluencerProfilePage> {
  int _selectedTab = 0;
  late final Future<_InfluencerProfilePageData> _future = _load();

  Future<_InfluencerProfilePageData> _load() async {
    if (!ApiUrlResolver.isConfigured) {
      return _InfluencerProfilePageData.fallback();
    }

    try {
      final CreatorProfileBundle bundle = await CreatorProfileRepository(
        DioClient.instance,
      ).fetchAll();
      final Map<String, dynamic> json = bundle.profile;
      return _InfluencerProfilePageData(
        summary: _summaryFromJson(json, InfluencerProfileViewData.summary),
        rawProfile: json,
        creatorType: _pick(json, <String>[
          'creator_type',
          'creatorType',
          'type',
        ], 'influencer').toLowerCase(),
        tabData: CreatorProfileTabData.fromBundle(bundle),
      );
    } on Object {
      return _InfluencerProfilePageData.fallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';
    final double topInset = MediaQuery.paddingOf(context).top;

    return FutureBuilder<_InfluencerProfilePageData>(
      future: _future,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<_InfluencerProfilePageData> snapshot,
          ) {
            final _InfluencerProfilePageData data =
                snapshot.data ?? _InfluencerProfilePageData.fallback();

            return Directionality(
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                  systemNavigationBarColor: AppColors.white,
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
                child: Stack(
                  children: <Widget>[
                    InfluencerHeaderBackground(height: 158.h),
                    SafeArea(
                      top: false,
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(height: topInset + 25.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: InfluencerProfileSummaryCard(
                              profile: data.summary,
                            ),
                          ),
                          SizedBox(height: 18.h),
                          InfluencerProfileTabBar(
                            tabs: InfluencerProfileViewData.tabs,
                            selectedIndex: _selectedTab,
                            onChanged: (int index) {
                              setState(() => _selectedTab = index);
                            },
                          ),
                          SizedBox(height: 18.h),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: 96.h),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: InfluencerProfileTabContent(
                                  index: _selectedTab,
                                  rawProfile: data.rawProfile,
                                  creatorType: data.creatorType,
                                  tabData: data.tabData,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (snapshot.connectionState != ConnectionState.done)
                      Positioned(
                        top: topInset + 12.h,
                        right: 18.w,
                        child: SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
    );
  }
}

class _InfluencerProfilePageData {
  const _InfluencerProfilePageData({
    required this.summary,
    required this.rawProfile,
    required this.creatorType,
    required this.tabData,
  });

  factory _InfluencerProfilePageData.fallback() {
    return _InfluencerProfilePageData(
      summary: InfluencerProfileViewData.summary,
      rawProfile: const <String, dynamic>{},
      creatorType: 'influencer',
      tabData: CreatorProfileTabData.fallback(),
    );
  }

  final InfluencerProfileSummaryData summary;
  final Map<String, dynamic> rawProfile;
  final String creatorType;
  final CreatorProfileTabData tabData;
}

InfluencerProfileSummaryData _summaryFromJson(
  Map<String, dynamic> json,
  InfluencerProfileSummaryData fallback,
) {
  final String creatorType = _pick(json, <String>[
    'creator_type',
    'creatorType',
    'type',
  ], '');
  final String headline = _pick(json, <String>[
    'headline',
    'title',
    'category',
    'niche',
  ], '');
  return InfluencerProfileSummaryData(
    name: _pick(json, <String>[
      'name',
      'full_name',
      'fullName',
      'display_name',
      'displayName',
      'username',
    ], fallback.name),
    title: _creatorTitle(creatorType, headline, fallback.title),
    bio: _pick(json, <String>['bio', 'about', 'description'], fallback.bio),
    avatarUrl: _pick(json, <String>[
      'avatar_url',
      'avatarUrl',
      'profile_image_url',
      'profileImageUrl',
      'profile_photo_url',
      'profilePhotoUrl',
      'image_url',
      'imageUrl',
      'photo',
    ], fallback.avatarUrl),
    mawthooqLabel: _mawthooqLabel(json, fallback.mawthooqLabel),
  );
}

String _pick(Map<String, dynamic> json, List<String> keys, String fallback) {
  final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[json];
  for (final String objectKey in <String>[
    'user',
    'profile',
    'content_creator',
    'contentCreator',
    'creator',
  ]) {
    final Object? value = json[objectKey];
    if (value is Map) {
      maps.add(Map<String, dynamic>.from(value));
    }
  }
  for (final Map<String, dynamic> map in maps) {
    for (final String key in keys) {
      final Object? value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
  }
  return fallback;
}

String _creatorTitle(String creatorType, String headline, String fallback) {
  if (headline.trim().isNotEmpty) {
    return headline;
  }
  return switch (creatorType.trim().toLowerCase()) {
    'model' => 'Professional fashion Model',
    'ugc' => 'Professional UGC creator',
    'collage' => 'Professional fashion Collage',
    'influencer' => 'Professional fashion influencer',
    _ => fallback,
  };
}

String _mawthooqLabel(Map<String, dynamic> json, String fallback) {
  final String license = _pick(json, <String>[
    'mawthooq_license_number',
    'mawthooqLicenseNumber',
    'license_number',
    'mawthooq',
  ], '');
  if (license.isEmpty) {
    return fallback;
  }
  return 'Mawthooq Active ($license)';
}

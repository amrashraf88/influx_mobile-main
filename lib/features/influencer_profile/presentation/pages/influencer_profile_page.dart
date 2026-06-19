import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart' show ApiException;
import 'package:adzmavall/features/influencer_profile/data/creator_profile_repository.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/creator_profile_tab_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/creator_profile_form_sheets.dart';
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
  static const List<String> _platformOptions = <String>[
    'Instagram',
    'Telegram',
    'Twitter',
    'Threads',
    'WhatsApp',
    'Youtube',
    'Snapchat',
    'TikTok',
    'Facebook',
  ];

  int _selectedTab = 0;
  bool _editing = false;
  bool _loading = true;
  bool _busy = false;
  _InfluencerProfilePageData _data = _InfluencerProfilePageData.empty();

  CreatorProfileRepository get _repo =>
      CreatorProfileRepository(DioClient.instance);

  /// Tabs that hold an editable list of items (add + delete).
  bool get _isListTab =>
      _selectedTab == 0 || _selectedTab == 1 || _selectedTab == 3;

  String get _sectionTitle => switch (_selectedTab) {
    0 => 'Accounts',
    1 => 'Clients',
    2 => 'Ads Price',
    3 => 'ADS',
    4 => 'Overview',
    5 => 'Details',
    _ => '',
  };

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    if (mounted) setState(() => _loading = true);
    final _InfluencerProfilePageData loaded = await _load();
    if (!mounted) return;
    setState(() {
      _data = loaded;
      _loading = false;
    });
  }

  Future<_InfluencerProfilePageData> _load() async {
    if (!ApiUrlResolver.isConfigured) {
      return _InfluencerProfilePageData.fallback();
    }

    try {
      final CreatorProfileBundle bundle = await _repo.fetchAll();
      final Map<String, dynamic> json = bundle.profile;
      return _InfluencerProfilePageData(
        summary: _summaryFromJson(json, _emptySummary),
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

  // ---------------------------------------------------------------------------
  // Edit actions
  // ---------------------------------------------------------------------------

  Future<void> _onEditPressed() async {
    switch (_selectedTab) {
      case 0:
      case 1:
      case 3:
        setState(() => _editing = !_editing);
      case 2:
        await _editAdPrice();
      case 4:
        await _editOverview();
      case 5:
        await _editDetails();
    }
  }

  Future<void> _onAddPressed() async {
    switch (_selectedTab) {
      case 0:
        await _addAccount();
      case 1:
        await _addClient();
      case 3:
        await _addAd();
    }
  }

  Future<void> _onDeleteItem(String id) async {
    if (id.isEmpty) return;
    final bool confirmed = await _confirmDelete();
    if (!confirmed) return;
    switch (_selectedTab) {
      case 0:
        await _runWrite(() => _repo.deleteSocialAccount(id));
      case 1:
        await _runWrite(() => _repo.deleteClient(id));
      case 3:
        await _runWrite(() => _repo.deleteAd(id));
    }
  }

  Future<void> _addAccount() async {
    final Map<String, String>? r = await showCreatorFormSheet(
      context,
      title: 'Add account',
      fields: const <CreatorFormField>[
        CreatorFormField(
          key: 'platform',
          label: 'Platform',
          options: _platformOptions,
        ),
        CreatorFormField(key: 'username', label: 'Username', hint: '@username'),
        CreatorFormField(
          key: 'followers_count',
          label: 'Followers',
          number: true,
        ),
        CreatorFormField(key: 'url', label: 'Profile link', hint: 'https://'),
      ],
    );
    if (r == null) return;
    final Map<String, dynamic> body = <String, dynamic>{
      'platform': r['platform'],
      if (_has(r['username'])) 'username': r['username'],
      if (_has(r['followers_count']))
        'followers_count': int.tryParse(r['followers_count']!),
      if (_has(r['url'])) 'url': r['url'],
    };
    await _runWrite(() => _repo.createSocialAccount(body));
  }

  Future<void> _addClient() async {
    final Map<String, String>? r = await showCreatorFormSheet(
      context,
      title: 'Add client',
      fields: const <CreatorFormField>[
        CreatorFormField(key: 'name', label: 'Client name'),
        CreatorFormField(key: 'handle', label: 'Handle', hint: '@handle'),
        CreatorFormField(key: 'logo_url', label: 'Logo URL', hint: 'https://'),
      ],
    );
    if (r == null) return;
    final Map<String, dynamic> body = <String, dynamic>{
      'name': r['name'],
      if (_has(r['handle'])) 'handle': r['handle'],
      if (_has(r['logo_url'])) 'logo_url': r['logo_url'],
    };
    await _runWrite(() => _repo.createClient(body));
  }

  Future<void> _addAd() async {
    final Map<String, String>? r = await showCreatorFormSheet(
      context,
      title: 'Add ad',
      fields: const <CreatorFormField>[
        CreatorFormField(key: 'title', label: 'Title'),
        CreatorFormField(
          key: 'image_url',
          label: 'Media / image URL',
          hint: 'https://',
        ),
      ],
    );
    if (r == null) return;
    final Map<String, dynamic> body = <String, dynamic>{
      'title': r['title'],
      if (_has(r['image_url'])) 'image_url': r['image_url'],
    };
    await _runWrite(() => _repo.createAd(body));
  }

  Future<void> _editOverview() async {
    final CreatorProfileTabData d = _data.tabData;
    final Map<String, String>? r = await showCreatorFormSheet(
      context,
      title: 'Edit overview',
      fields: <CreatorFormField>[
        CreatorFormField(
          key: 'keywords',
          label: 'Keywords (comma separated)',
          initial: d.keywords
              .map((String k) => k.replaceFirst('#', ''))
              .join(', '),
          multiline: true,
        ),
        CreatorFormField(
          key: 'age_ranges',
          label: 'Audience age (comma separated)',
          initial: d.ageRanges.join(', '),
        ),
      ],
    );
    if (r == null) return;
    final Map<String, dynamic> body = <String, dynamic>{
      'keywords': _split(r['keywords']),
      'audience_age_ranges': _split(r['age_ranges']),
    };
    await _runWrite(() => _repo.updateProfile(body));
  }

  Future<void> _editAdPrice() async {
    final Map<String, String>? r = await showCreatorFormSheet(
      context,
      title: 'Edit ad prices',
      fields: const <CreatorFormField>[
        CreatorFormField(
          key: 'coverage_price',
          label: 'Coverage / story price',
          number: true,
        ),
        CreatorFormField(
          key: 'video_price',
          label: 'Video / post price',
          number: true,
        ),
      ],
    );
    if (r == null) return;
    final Map<String, dynamic> body = <String, dynamic>{
      if (_has(r['coverage_price']))
        'coverage_price': int.tryParse(r['coverage_price']!),
      if (_has(r['video_price'])) 'video_price': int.tryParse(r['video_price']!),
    };
    if (body.isEmpty) return;
    await _runWrite(() => _repo.updateProfile(body));
  }

  Future<void> _editDetails() async {
    final Map<String, dynamic> j = _data.rawProfile;
    final Map<String, String>? r = await showCreatorFormSheet(
      context,
      title: 'Edit details',
      fields: <CreatorFormField>[
        CreatorFormField(
          key: 'city',
          label: 'City',
          initial: (j['city'] ?? '').toString(),
        ),
        CreatorFormField(
          key: 'gender',
          label: 'Gender',
          initial: (j['gender'] ?? '').toString(),
        ),
        CreatorFormField(
          key: 'age',
          label: 'Age',
          number: true,
          initial: (j['age'] ?? '').toString(),
        ),
      ],
    );
    if (r == null) return;
    final Map<String, dynamic> body = <String, dynamic>{
      if (_has(r['city'])) 'city': r['city'],
      if (_has(r['gender'])) 'gender': r['gender'],
      if (_has(r['age'])) 'age': int.tryParse(r['age']!),
    };
    if (body.isEmpty) return;
    await _runWrite(() => _repo.updateProfile(body));
  }

  Future<void> _runWrite(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    String? error;
    try {
      await action();
    } on ApiException catch (e) {
      error = e.message;
    } on Object {
      error = 'Something went wrong. Please try again.';
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (error != null) {
      _toast(error);
      return;
    }
    await _reload();
    if (mounted) _toast('Saved');
  }

  Future<bool> _confirmDelete() async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Delete item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static bool _has(String? v) => v != null && v.trim().isNotEmpty;

  static List<String> _split(String? s) => (s ?? '')
      .split(RegExp(r'[,\n]'))
      .map((String e) => e.trim())
      .where((String e) => e.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';
    final double topInset = MediaQuery.paddingOf(context).top;
    final _InfluencerProfilePageData data = _data;
    // This screen is the creator's own (influencer) profile, so editing is
    // always available here. Other creator types get their own screens later.
    const bool canEdit = true;
    final bool listEditing = _editing && _isListTab;

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
                    child: InfluencerProfileSummaryCard(profile: data.summary),
                  ),
                  SizedBox(height: 18.h),
                  InfluencerProfileTabBar(
                    tabs: InfluencerProfileViewData.tabs,
                    selectedIndex: _selectedTab,
                    onChanged: (int index) {
                      setState(() {
                        _selectedTab = index;
                        _editing = false;
                      });
                    },
                  ),
                  SizedBox(height: 16.h),
                  if (canEdit)
                    Padding(
                      padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 12.h),
                      child: _SectionHeader(
                        title: _sectionTitle,
                        editing: listEditing,
                        showAdd: listEditing,
                        onAdd: _busy ? null : _onAddPressed,
                        onEdit: _busy ? null : _onEditPressed,
                      ),
                    ),
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
                          editing: listEditing,
                          onDelete: _onDeleteItem,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
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
            if (_busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x66000000),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Section title with an Edit (and optional Add) action, shown above each tab.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.editing,
    required this.showAdd,
    required this.onEdit,
    required this.onAdd,
  });

  final String title;
  final bool editing;
  final bool showAdd;
  final VoidCallback? onEdit;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (showAdd) ...<Widget>[
          _PillButton(
            label: 'Add',
            icon: Icons.add_rounded,
            background: AppColors.brandBlue,
            foreground: AppColors.white,
            onTap: onAdd,
          ),
          SizedBox(width: 8.w),
        ],
        _PillButton(
          label: editing ? 'Done' : 'Edit',
          background: AppColors.textPrimary,
          foreground: AppColors.white,
          onTap: onEdit,
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(99.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, color: foreground, size: 16.sp),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
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

  /// Empty state shown while loading / when the API returns nothing.
  factory _InfluencerProfilePageData.empty() {
    return _InfluencerProfilePageData(
      summary: _emptySummary,
      rawProfile: const <String, dynamic>{},
      creatorType: 'influencer',
      tabData: CreatorProfileTabData.empty(),
    );
  }

  /// Sample state used only when the API is not configured (pure-UI mode).
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

/// Blank summary used when the API is configured but returns no profile fields.
const InfluencerProfileSummaryData _emptySummary = InfluencerProfileSummaryData(
  name: '',
  title: '',
  bio: '',
  avatarUrl: '',
  mawthooqLabel: '',
);

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

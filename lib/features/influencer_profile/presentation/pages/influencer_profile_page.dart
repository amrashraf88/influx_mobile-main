import 'package:adzmavall/core/lookup/lookup_item.dart';
import 'package:adzmavall/core/lookup/lookup_repository.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart' show ApiException;
import 'package:adzmavall/features/influencer_profile/data/creator_profile_repository.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/creator_profile_tab_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/profile_refresh_notifier.dart';
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
    influencerProfileRefresh.addListener(_onRefreshSignal);
  }

  @override
  void dispose() {
    influencerProfileRefresh.removeListener(_onRefreshSignal);
    super.dispose();
  }

  void _onRefreshSignal() {
    // Re-entry to the Profile tab or a saved edit elsewhere: refetch, but not
    // while a write is in flight (that path reloads on its own).
    if (!_busy) _reload();
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
    // The backend validates `platform` against the social-platforms lookup, so
    // load the real options and send the lookup value (not the display label).
    List<LookupItem> platforms = const <LookupItem>[];
    try {
      platforms = await LookupRepository(
        DioClient.instance,
      ).fetchSocialPlatforms();
    } on Object {
      // Fall back to the static labels below.
    }
    if (!mounted) return;
    final List<String> options = platforms.isNotEmpty
        ? platforms.map((LookupItem p) => p.label).toList()
        : _platformOptions;

    final Map<String, String>? r = await showCreatorFormSheet(
      context,
      title: 'Add account',
      fields: <CreatorFormField>[
        CreatorFormField(key: 'platform', label: 'Platform', options: options),
        const CreatorFormField(
          key: 'username',
          label: 'Username',
          hint: '@username',
        ),
        const CreatorFormField(
          key: 'followers_count',
          label: 'Followers',
          number: true,
        ),
        const CreatorFormField(
          key: 'profile_url',
          label: 'Profile link',
          hint: 'https://',
        ),
      ],
    );
    if (r == null) return;

    final String chosen = r['platform'] ?? '';
    Object? platformValue = chosen.toLowerCase();
    for (final LookupItem p in platforms) {
      if (p.label == chosen) {
        platformValue = int.tryParse(p.value) ?? p.value;
        break;
      }
    }

    final Map<String, dynamic> body = <String, dynamic>{
      'platform': platformValue,
      if (_has(r['username'])) 'username': r['username'],
      if (_has(r['followers_count']))
        'followers_count': int.tryParse(r['followers_count']!),
      if (_has(r['profile_url'])) 'profile_url': r['profile_url'],
    };
    await _runWrite(() => _repo.createSocialAccount(body));
  }

  Future<void> _addClient() async {
    // A client links to a company from the lookup; the backend also requires
    // number_of_times, have_contract, public_status and privacy.
    List<LookupItem> companies = const <LookupItem>[];
    try {
      companies = await LookupRepository(DioClient.instance).fetchCompanies();
    } on Object {
      // Handled below.
    }
    if (!mounted) return;
    if (companies.isEmpty) {
      _toast('No companies available to link right now.');
      return;
    }

    final Map<String, String>? r = await showCreatorFormSheet(
      context,
      title: 'Add client',
      fields: <CreatorFormField>[
        CreatorFormField(
          key: 'company',
          label: 'Company',
          options: companies.map((LookupItem c) => c.label).toList(),
        ),
        const CreatorFormField(
          key: 'number_of_times',
          label: 'Number of times worked together',
          number: true,
        ),
        const CreatorFormField(
          key: 'have_contract',
          label: 'Have contract',
          options: <String>['Yes', 'No'],
        ),
        const CreatorFormField(
          key: 'public_status',
          label: 'Show publicly',
          options: <String>['Yes', 'No'],
        ),
        const CreatorFormField(
          key: 'privacy',
          label: 'Privacy',
          options: <String>['public', 'private'],
        ),
      ],
    );
    if (r == null) return;

    Object? companyId;
    for (final LookupItem c in companies) {
      if (c.label == r['company']) {
        companyId = int.tryParse(c.value) ?? c.value;
        break;
      }
    }

    final Map<String, dynamic> body = <String, dynamic>{
      if (companyId != null) 'company_id': companyId,
      'number_of_times': int.tryParse(r['number_of_times'] ?? '') ?? 0,
      'have_contract': r['have_contract'] == 'Yes',
      'public_status': r['public_status'] == 'Yes',
      'privacy': r['privacy'] ?? 'public',
    };
    await _runWrite(() => _repo.createClient(body));
  }

  Future<void> _addAd() async {
    final Map<String, String>? r = await showCreatorFormSheet(
      context,
      title: 'Add ad',
      fields: const <CreatorFormField>[
        CreatorFormField(key: 'label', label: 'Title / label'),
        CreatorFormField(
          key: 'url',
          label: 'Link (URL)',
          hint: 'https://',
        ),
      ],
    );
    if (r == null) return;
    final Map<String, dynamic> body = <String, dynamic>{
      'label': r['label'],
      if (_has(r['url'])) 'url': r['url'],
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
    final Map<String, dynamic> body = _requiredProfileBase()
      ..['keywords'] = _split(r['keywords'])
      ..['audience_age_ranges'] = _split(r['age_ranges']);
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
    final Map<String, dynamic> body = _requiredProfileBase();
    if (_has(r['coverage_price'])) {
      body['coverage_price'] = int.tryParse(r['coverage_price']!);
    }
    if (_has(r['video_price'])) {
      body['video_price'] = int.tryParse(r['video_price']!);
    }
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
          initial: (j['gender'] ?? '').toString().toLowerCase(),
          options: const <String>['male', 'female'],
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
    final Map<String, dynamic> body = _requiredProfileBase();
    if (_has(r['city'])) body['city'] = r['city'];
    if (_has(r['gender'])) body['gender'] = r['gender']!.toLowerCase();
    if (_has(r['age'])) body['age'] = int.tryParse(r['age']!);
    await _runWrite(() => _repo.updateProfile(body));
  }

  /// Pulls the fields the profile-update endpoint requires from the loaded
  /// profile so partial edits don't fail backend validation (gender,
  /// phone_number, etc. are required on every PATCH).
  Map<String, dynamic> _requiredProfileBase() {
    final Map<String, dynamic> j = _data.rawProfile;
    String? val(List<String> keys) {
      for (final String k in keys) {
        final Object? v = j[k];
        if (v == null) continue;
        if (v is Map) {
          final Object? inner = v['value'] ?? v['id'] ?? v['name'];
          final String s = inner?.toString().trim() ?? '';
          if (s.isNotEmpty) return s;
          continue;
        }
        final String s = v.toString().trim();
        if (s.isNotEmpty && s != 'null') return s;
      }
      return null;
    }

    final Map<String, dynamic> body = <String, dynamic>{};
    void put(String key, String? v) {
      if (v != null && v.isNotEmpty) body[key] = v;
    }

    put('full_name', val(<String>['full_name', 'fullName', 'name']));
    put('full_name_ar', val(<String>['full_name_ar', 'fullNameAr']));
    put('street', val(<String>['street']));
    put('city', val(<String>['city']));
    put('city_direction', val(<String>['city_direction', 'cityDirection']));
    put('gender', val(<String>['gender'])?.toLowerCase());
    put(
      'phone_number',
      val(<String>['phone_number', 'phoneNumber', 'phone']),
    );
    final String? age = val(<String>['age']);
    if (age != null) {
      final int? a = int.tryParse(age);
      if (a != null) body['age'] = a;
    }
    body['mawthooq_license_number'] =
        val(<String>[
          'mawthooq_license_number',
          'mawthooqLicenseNumber',
          'license_number',
        ]) ??
        '';
    final Object? cats = j['categories'];
    if (cats is List) {
      final List<int> ids = cats
          .map((Object? c) => c is Map ? (c['id'] ?? c['value']) : c)
          .where((Object? e) => e != null)
          .map((Object? e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
      if (ids.isNotEmpty) body['categories'] = ids;
    }
    return body;
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

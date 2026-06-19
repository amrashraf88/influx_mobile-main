import 'package:adzmavall/core/lookup/lookup_item.dart';
import 'package:adzmavall/core/lookup/lookup_repository.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart'
    show ApiException;
import 'package:adzmavall/features/influencer_profile/data/profile_edit_repository.dart';
import 'package:adzmavall/features/influencer_profile/presentation/profile_refresh_notifier.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Edit the authenticated content creator's profile. Loads current values and
/// live lookups (city / direction / categories) from the API and saves via PATCH.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    ProfileEditRepository? repository,
    LookupRepository? lookupRepository,
  }) : _repository = repository,
       _lookupRepository = lookupRepository;

  final ProfileEditRepository? _repository;
  final LookupRepository? _lookupRepository;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileEditRepository _repo;
  late final LookupRepository _lookups;

  final TextEditingController _fullName = TextEditingController();
  final TextEditingController _fullNameAr = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _street = TextEditingController();
  final TextEditingController _mawthooq = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _bio = TextEditingController();

  // Gender is required by the profile-update endpoint.
  static const List<LookupItem> _genders = <LookupItem>[
    LookupItem(value: 'male', label: 'Male'),
    LookupItem(value: 'female', label: 'Female'),
  ];

  static const List<LookupItem> _yesNo = <LookupItem>[
    LookupItem(value: 'yes', label: 'Yes'),
    LookupItem(value: 'no', label: 'No'),
  ];

  static const List<LookupItem> _nationalities = <LookupItem>[
    LookupItem(value: 'saudi', label: 'Saudi'),
    LookupItem(value: 'uae', label: 'UAE'),
    LookupItem(value: 'egypt', label: 'Egypt'),
  ];

  List<LookupItem> _cities = <LookupItem>[];
  List<LookupItem> _directions = <LookupItem>[];
  List<LookupItem> _categories = <LookupItem>[];
  List<LookupItem> _sizes = <LookupItem>[];
  List<LookupItem> _skinTones = <LookupItem>[];
  List<LookupItem> _accents = <LookupItem>[];

  String _creatorType = 'influencer';

  // Type-specific controllers.
  final TextEditingController _height = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _sessionPrice = TextEditingController();
  final TextEditingController _videoPrice = TextEditingController();
  final TextEditingController _deliveryTime = TextEditingController();
  final TextEditingController _clipPrice = TextEditingController();

  String? _city;
  String? _direction;
  String? _gender;
  String? _nationality;
  String? _size;
  String? _skinTone;
  String? _accent;
  String? _faceVisible;
  String? _showHair;
  String? _bodyVisible;
  String? _voiceOver;
  String? _useHook;
  final Set<String> _selectedCategories = <String>{};

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = widget._repository ?? ProfileEditRepository(DioClient.instance);
    _lookups = widget._lookupRepository ?? LookupRepository(DioClient.instance);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Map<String, dynamic> p = await _repo.fetchProfile();
      // Lookups (best-effort; ignore individual failures).
      try {
        _cities = await _lookups.fetchCities();
      } catch (_) {}
      try {
        _directions = await _lookups.fetchCityDirections();
      } catch (_) {}
      try {
        _categories = (await _lookups.fetchCategories()).items;
      } catch (_) {}

      _creatorType = _creatorTypeFromJson(p);

      // Type-specific lookups (best-effort).
      if (_creatorType == 'model') {
        try {
          _sizes = await _lookups.fetchModelCreatorSizes();
        } catch (_) {}
        try {
          _skinTones = await _lookups.fetchModelCreatorSkinTones();
        } catch (_) {}
      } else if (_creatorType == 'collage') {
        try {
          _accents = await _lookups.fetchModelCreatorAccents();
        } catch (_) {}
      }

      _fullName.text = _str(p['full_name']);
      _fullNameAr.text = _str(p['full_name_ar']);
      _age.text = _str(p['age']);
      _street.text = _str(p['street']);
      _mawthooq.text = _mawthooqFrom(p);
      _phone.text = _str(p['phone_number']).isNotEmpty
          ? _str(p['phone_number'])
          : _str(p['phone']);
      _bio.text = <String>['bio', 'about', 'description']
          .map((String k) => _str(p[k]))
          .firstWhere((String s) => s.isNotEmpty, orElse: () => '');
      _city = _valueOf(p['city']);
      _direction = _valueOf(p['city_direction']);
      _gender = _valueOf(p['gender'])?.toLowerCase();

      // Type-specific fields.
      _height.text = _str(p['height']).isNotEmpty
          ? _str(p['height'])
          : _str(p['height_cm']);
      _weight.text = _str(p['weight']).isNotEmpty
          ? _str(p['weight'])
          : _str(p['weight_kg']);
      _sessionPrice.text = _str(p['session_price_per_hour']);
      _videoPrice.text = _str(p['video_price']);
      _deliveryTime.text = _str(p['deliverability_time']).isNotEmpty
          ? _str(p['deliverability_time'])
          : _str(p['delivery_time_from_arrival']);
      _clipPrice.text = _str(p['clip_price_per_second']);
      _nationality = _valueOf(p['nationality'])?.toLowerCase();
      _size = _valueOf(p['size']);
      _skinTone = _valueOf(p['skin_tone']);
      _accent = _valueOf(p['accent']);
      _faceVisible = _yesNoStr(p['face_visibility']);
      _showHair = _yesNoStr(p['show_hair']);
      _bodyVisible = _yesNoStr(p['body_visibility']);
      _voiceOver = _yesNoStr(p['voice_over']);
      _useHook = _yesNoStr(p['use_hook']);
      final Object? cats = p['categories'];
      if (cats is List) {
        for (final Object? c in cats) {
          if (c is Map && c['id'] != null) {
            _selectedCategories.add(c['id'].toString());
          }
        }
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Could not load your profile.';
    }
    if (mounted) setState(() => _loading = false);
  }

  String _str(Object? v) =>
      (v == null || v.toString() == 'null') ? '' : v.toString();

  String _creatorTypeFromJson(Map<String, dynamic> p) {
    for (final String key in <String>['creator_type', 'creatorType', 'type']) {
      final Object? value = p[key];
      if (value is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(value);
        for (final String nestedKey in <String>[
          'value',
          'label',
          'name',
          'title',
          'slug',
          'key',
        ]) {
          final Object? nested = map[nestedKey];
          final String s = _str(nested).toLowerCase().trim();
          if (s.isNotEmpty) return s;
        }
      }
      final String s = _str(value).toLowerCase().trim();
      if (s.isNotEmpty && s != 'null') return s;
    }
    return 'influencer';
  }

  /// Normalises a boolean-ish value to 'yes' / 'no' (or null when unknown).
  String? _yesNoStr(Object? v) {
    if (v == null) return null;
    if (v is bool) return v ? 'yes' : 'no';
    final String s = v.toString().toLowerCase().trim();
    if (s == 'yes' || s == 'true' || s == '1') return 'yes';
    if (s == 'no' || s == 'false' || s == '0') return 'no';
    return null;
  }

  /// The Mawthooq number is nested under `mawthooq_profile` in the API
  /// response, with a few flat fallbacks.
  String _mawthooqFrom(Map<String, dynamic> p) {
    final Object? m = p['mawthooq_profile'];
    if (m is Map) {
      final String nested = _str(m['license_number'] ?? m['number']);
      if (nested.isNotEmpty) return nested;
    }
    for (final String k in <String>[
      'mawthooq_license_number',
      'mawthooqLicenseNumber',
      'license_number',
      'mawthooq',
    ]) {
      final String s = _str(p[k]);
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  String? _valueOf(Object? v) {
    if (v == null) return null;
    if (v is Map) return v['value']?.toString();
    return v.toString();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    final Map<String, dynamic> body = <String, dynamic>{
      'full_name': _fullName.text.trim(),
      'full_name_ar': _fullNameAr.text.trim(),
      if (int.tryParse(_age.text.trim()) != null)
        'age': int.parse(_age.text.trim()),
      if (_city != null) 'city': _city,
      // Required by the backend (validation.required otherwise).
      if (_gender != null && _gender!.isNotEmpty) 'gender': _gender,
      'phone_number': _phone.text.trim(),
      'bio': _bio.text.trim(),
      'categories': _selectedCategories
          .map(int.tryParse)
          .whereType<int>()
          .toList(),
    };

    void putInt(String key, TextEditingController c) {
      final int? n = int.tryParse(c.text.trim());
      if (n != null) body[key] = n;
    }

    void putStr(String key, String value) {
      if (value.trim().isNotEmpty) body[key] = value.trim();
    }

    switch (_creatorType) {
      case 'model':
        if (_nationality != null) body['nationality'] = _nationality;
        putInt('height', _height);
        putInt('weight', _weight);
        if (_size != null) body['size'] = _size;
        if (_skinTone != null) body['skin_tone'] = _skinTone;
        putInt('session_price_per_hour', _sessionPrice);
        if (_bodyVisible != null) body['body_visibility'] = _bodyVisible;
        if (_faceVisible != null) body['face_visibility'] = _faceVisible;
        if (_showHair != null) body['show_hair'] = _showHair;
        if (_direction != null) body['city_direction'] = _direction;
        putStr('street', _street.text);
      case 'ugc':
        putInt('video_price', _videoPrice);
        putInt('deliverability_time', _deliveryTime);
        if (_voiceOver != null) body['voice_over'] = _voiceOver;
        if (_useHook != null) body['use_hook'] = _useHook;
        if (_faceVisible != null) body['face_visibility'] = _faceVisible;
        if (_showHair != null) body['show_hair'] = _showHair;
      case 'collage':
        putInt('clip_price_per_second', _clipPrice);
        if (_accent != null) body['accent'] = _accent;
        if (_direction != null) body['city_direction'] = _direction;
        putStr('street', _street.text);
      default: // influencer
        if (_direction != null) body['city_direction'] = _direction;
        putStr('street', _street.text);
        final String mawthooq = _mawthooq.text.trim();
        if (mawthooq.isNotEmpty) body['mawthooq_license_number'] = mawthooq;
    }
    try {
      await _repo.updateProfile(body);
      // Tell the Profile / Settings screens to refetch fresh data.
      requestInfluencerProfileRefresh();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.of(context).maybePop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not save changes.');
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _fullNameAr.dispose();
    _age.dispose();
    _street.dispose();
    _mawthooq.dispose();
    _phone.dispose();
    _bio.dispose();
    _height.dispose();
    _weight.dispose();
    _sessionPrice.dispose();
    _videoPrice.dispose();
    _deliveryTime.dispose();
    _clipPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.pageBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp),
          color: AppColors.fgPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.fgPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_error != null) ...<Widget>[
                      Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    _field('Full Name', _fullName),
                    _field('Full Name (Arabic)', _fullNameAr),
                    _field(
                      'Phone Number',
                      _phone,
                      keyboard: TextInputType.phone,
                    ),
                    _field('Age', _age, keyboard: TextInputType.number),
                    _dropdown(
                      'Gender',
                      _genders,
                      _gender,
                      (String? v) => setState(() => _gender = v),
                    ),
                    if (_cities.isNotEmpty)
                      _dropdown(
                        'City',
                        _cities,
                        _city,
                        (String? v) => setState(() => _city = v),
                      ),
                    if (_directions.isNotEmpty)
                      _dropdown(
                        'City Direction',
                        _directions,
                        _direction,
                        (String? v) => setState(() => _direction = v),
                      ),
                    _field('Street', _street),
                    _field('Bio', _bio, maxLines: 4),
                    if (_creatorType == 'influencer')
                      _field('Mawthooq License Number', _mawthooq),
                    if (_creatorType == 'model') ...<Widget>[
                      _dropdown(
                        'Nationality',
                        _nationalities,
                        _nationality,
                        (String? v) => setState(() => _nationality = v),
                      ),
                      _field(
                        'Height (cm)',
                        _height,
                        keyboard: TextInputType.number,
                      ),
                      _field(
                        'Weight (kg)',
                        _weight,
                        keyboard: TextInputType.number,
                      ),
                      if (_sizes.isNotEmpty)
                        _dropdown(
                          'Size',
                          _sizes,
                          _size,
                          (String? v) => setState(() => _size = v),
                        ),
                      if (_skinTones.isNotEmpty)
                        _dropdown(
                          'Skin tone',
                          _skinTones,
                          _skinTone,
                          (String? v) => setState(() => _skinTone = v),
                        ),
                      _field(
                        'Session price / hour',
                        _sessionPrice,
                        keyboard: TextInputType.number,
                      ),
                      _dropdown(
                        'Full body visible',
                        _yesNo,
                        _bodyVisible,
                        (String? v) => setState(() => _bodyVisible = v),
                      ),
                      _dropdown(
                        'Face visible',
                        _yesNo,
                        _faceVisible,
                        (String? v) => setState(() => _faceVisible = v),
                      ),
                      _dropdown(
                        'Hair visible',
                        _yesNo,
                        _showHair,
                        (String? v) => setState(() => _showHair = v),
                      ),
                    ],
                    if (_creatorType == 'ugc') ...<Widget>[
                      _field(
                        'Video price',
                        _videoPrice,
                        keyboard: TextInputType.number,
                      ),
                      _field(
                        'Delivery time (from arrival)',
                        _deliveryTime,
                        keyboard: TextInputType.number,
                      ),
                      _dropdown(
                        'Voice over',
                        _yesNo,
                        _voiceOver,
                        (String? v) => setState(() => _voiceOver = v),
                      ),
                      _dropdown(
                        'Use hook',
                        _yesNo,
                        _useHook,
                        (String? v) => setState(() => _useHook = v),
                      ),
                      _dropdown(
                        'Face visible',
                        _yesNo,
                        _faceVisible,
                        (String? v) => setState(() => _faceVisible = v),
                      ),
                      _dropdown(
                        'Hair visible',
                        _yesNo,
                        _showHair,
                        (String? v) => setState(() => _showHair = v),
                      ),
                    ],
                    if (_creatorType == 'collage') ...<Widget>[
                      _field(
                        'Clip price / second',
                        _clipPrice,
                        keyboard: TextInputType.number,
                      ),
                      if (_accents.isNotEmpty)
                        _dropdown(
                          'Accent',
                          _accents,
                          _accent,
                          (String? v) => setState(() => _accent = v),
                        ),
                    ],
                    if (_categories.isNotEmpty) ...<Widget>[
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.fgPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: _categories.map((LookupItem c) {
                          final bool sel = _selectedCategories.contains(
                            c.value,
                          );
                          return InkWell(
                            onTap: () => setState(() {
                              if (sel) {
                                _selectedCategories.remove(c.value);
                              } else {
                                _selectedCategories.add(c.value);
                              }
                            }),
                            borderRadius: BorderRadius.circular(800.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 8.h,
                              ),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.brandBlue
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(800.r),
                                border: Border.all(
                                  color: sel
                                      ? AppColors.brandBlue
                                      : AppColors.borderPrimary,
                                ),
                              ),
                              child: Text(
                                c.label,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: sel
                                      ? AppColors.white
                                      : AppColors.fgSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.h),
                    ],
                    SizedBox(height: 8.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandBlue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(800.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? SizedBox(
                                width: 22.w,
                                height: 22.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.fgPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.borderPrimary),
            ),
            child: TextField(
              controller: controller,
              keyboardType: maxLines > 1 ? TextInputType.multiline : keyboard,
              maxLines: maxLines,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
              style: TextStyle(fontSize: 14.sp, color: AppColors.fgPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
    String label,
    List<LookupItem> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    final bool valid = items.any((LookupItem i) => i.value == value);
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.fgPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.borderPrimary),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: valid ? value : null,
                hint: Text(
                  'Select',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.fgQuaternary,
                  ),
                ),
                items: items
                    .map(
                      (LookupItem i) => DropdownMenuItem<String>(
                        value: i.value,
                        child: Text(
                          i.label,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.fgPrimary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

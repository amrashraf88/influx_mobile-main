import 'package:adzmavall/core/lookup/lookup_item.dart';
import 'package:adzmavall/core/lookup/lookup_repository.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart' show ApiException;
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

  List<LookupItem> _cities = <LookupItem>[];
  List<LookupItem> _directions = <LookupItem>[];
  List<LookupItem> _categories = <LookupItem>[];

  String? _city;
  String? _direction;
  String? _gender;
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
      'street': _street.text.trim(),
      'mawthooq_license_number': _mawthooq.text.trim(),
      if (_city != null) 'city': _city,
      if (_direction != null) 'city_direction': _direction,
      // Required by the backend (validation.required otherwise).
      if (_gender != null && _gender!.isNotEmpty) 'gender': _gender,
      'phone_number': _phone.text.trim(),
      'bio': _bio.text.trim(),
      'categories': _selectedCategories
          .map(int.tryParse)
          .whereType<int>()
          .toList(),
    };
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
                    _field('Mawthooq License Number', _mawthooq),
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
                          final bool sel = _selectedCategories.contains(c.value);
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
                                color: sel ? AppColors.brandBlue : AppColors.white,
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
              keyboardType: maxLines > 1
                  ? TextInputType.multiline
                  : keyboard,
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

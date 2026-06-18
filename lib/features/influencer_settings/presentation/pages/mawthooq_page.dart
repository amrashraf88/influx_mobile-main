import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart' show ApiException;
import 'package:adzmavall/features/influencer_profile/data/profile_edit_repository.dart';
import 'package:adzmavall/features/influencer_settings/presentation/widgets/settings_sub_app_bar.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Mawthooq license details, loaded from the content-creator profile.
class MawthooqPage extends StatefulWidget {
  const MawthooqPage({super.key, ProfileEditRepository? repository})
    : _repository = repository;

  final ProfileEditRepository? _repository;

  @override
  State<MawthooqPage> createState() => _MawthooqPageState();
}

class _MawthooqPageState extends State<MawthooqPage> {
  late final ProfileEditRepository _repo;
  bool _loading = true;
  String? _error;
  String _licenseNumber = '';
  String _status = '';
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _repo = widget._repository ?? ProfileEditRepository(DioClient.instance);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Map<String, dynamic> p = await _repo.fetchProfile();
      final Object? m = p['mawthooq_profile'];
      final Map<String, dynamic> mp =
          m is Map ? Map<String, dynamic>.from(m) : <String, dynamic>{};
      if (!mounted) return;
      setState(() {
        _licenseNumber = (mp['license_number'] ??
                p['mawthooq_license_number'] ??
                '')
            .toString();
        _status = (mp['status'] ?? '').toString();
        _verified = mp['is_verified'] == true;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _error = 'Could not load license details.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _verified || _status.toLowerCase() == 'active' ||
        _status.toLowerCase() == 'valid';
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: const SettingsSubAppBar(title: 'Mawthooq License'),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
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
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColors.borderSecondary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.verified_user_outlined,
                              size: 22.sp,
                              color: AppColors.brandBlue,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Mawthooq',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.fgPrimary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: (active ? AppColors.success : AppColors.error)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(800.r),
                              ),
                              child: Text(
                                active ? 'Active' : 'Not verified',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: active
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 18.h),
                        _row('License Number',
                            _licenseNumber.isEmpty ? '—' : _licenseNumber),
                        SizedBox(height: 12.h),
                        _row('Status', _status.isEmpty ? '—' : _status),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(fontSize: 13.sp, color: AppColors.fgQuaternary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.fgPrimary,
          ),
        ),
      ],
    );
  }
}

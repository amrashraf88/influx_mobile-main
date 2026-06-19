import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/widgets/app_feedback.dart';
import 'package:adzmavall/features/influencer_settings/data/settings_repository.dart';
import 'package:adzmavall/features/influencer_settings/presentation/widgets/settings_sub_app_bar.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App-level settings: notifications, location, agreement and delete account.
class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _notifications = true;
  bool _location = false;
  bool _savingNotifications = false;

  SettingsRepository get _repo => SettingsRepository(DioClient.instance);

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!ApiUrlResolver.isConfigured) return;
    try {
      final bool enabled = await _repo.fetchNotificationsEnabled();
      if (mounted) setState(() => _notifications = enabled);
    } on Object {
      // Keep the default; the toggle still works locally.
    }
  }

  Future<void> _setNotifications(bool value) async {
    if (_savingNotifications) return;
    final bool previous = _notifications;
    setState(() {
      _notifications = value;
      _savingNotifications = true;
    });
    if (!ApiUrlResolver.isConfigured) {
      setState(() => _savingNotifications = false);
      return;
    }
    try {
      await _repo.setNotificationsEnabled(value);
    } on Object {
      if (mounted) {
        setState(() => _notifications = previous);
        showAppFeedback(
          context,
          message: 'Could not update notifications',
          type: AppFeedbackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _savingNotifications = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: const SettingsSubAppBar(title: 'Settings'),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          children: <Widget>[
            _card(
              Column(
                children: <Widget>[
                  _toggle(
                    Icons.notifications_none_rounded,
                    'Notification',
                    _notifications,
                    _setNotifications,
                  ),
                  const Divider(height: 1),
                  _toggle(
                    Icons.location_on_outlined,
                    'Location',
                    _location,
                    (bool v) => setState(() => _location = v),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _card(
              Column(
                children: <Widget>[
                  _nav(
                    Icons.description_outlined,
                    'Add Mavall unified services Agreement',
                    false,
                  ),
                  const Divider(height: 1),
                  _nav(Icons.delete_outline_rounded, 'Delete Account', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.borderSecondary),
    ),
    child: child,
  );

  Widget _toggle(
    IconData icon,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SizedBox(
      height: 56.h,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22.sp, color: AppColors.fgSecondary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.fgPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: AppColors.white,
            activeTrackColor: AppColors.brandBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _nav(IconData icon, String label, bool destructive) {
    final Color color = destructive ? AppColors.error : AppColors.fgPrimary;
    return InkWell(
      onTap: () {},
      child: SizedBox(
        height: 56.h,
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              size: 22.sp,
              color: destructive ? AppColors.error : AppColors.fgSecondary,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.sp,
              color: AppColors.fgQuinary,
            ),
          ],
        ),
      ),
    );
  }
}

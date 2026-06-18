import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_menu_panel.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_sub_page_sheet.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyAccountSettingsPage extends StatefulWidget {
  const CompanyAccountSettingsPage({super.key});

  @override
  State<CompanyAccountSettingsPage> createState() =>
      _CompanyAccountSettingsPageState();
}

class _CompanyAccountSettingsPageState extends State<CompanyAccountSettingsPage> {
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return CompanyAccountSubPageSheet(
      title: AppStrings.of(locale, 'company_account_settings'),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppStrings.of(locale, 'company_account_settings_general'),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            _SettingsCard(
              children: <Widget>[
                _SettingsRow(
                  icon: Icons.notifications_none_rounded,
                  title: AppStrings.of(locale, 'company_account_notification'),
                  trailing: Switch.adaptive(
                    value: _notificationsOn,
                    activeThumbColor: AppColors.white,
                    activeTrackColor: AppColors.brandBlue,
                    onChanged: (bool v) => setState(() => _notificationsOn = v),
                  ),
                ),
                const Divider(height: 1, color: CompanyAccountStyle.cardBorder),
                _SettingsRow(
                  icon: Icons.location_on_outlined,
                  title: AppStrings.of(locale, 'company_account_location'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Egypt',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                        ),
                      ),
                      Icon(
                        isRtl
                            ? Icons.chevron_left_rounded
                            : Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        size: 22.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _SettingsCard(
              children: <Widget>[
                _SettingsRow(
                  icon: Icons.info_outline_rounded,
                  title: AppStrings.of(locale, 'company_account_agreement'),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            _SettingsCard(
              children: <Widget>[
                _SettingsRow(
                  icon: Icons.delete_outline_rounded,
                  title: AppStrings.of(locale, 'company_account_delete_account'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: CompanyAccountStyle.cardBorder),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 22.sp, color: AppColors.textPrimary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

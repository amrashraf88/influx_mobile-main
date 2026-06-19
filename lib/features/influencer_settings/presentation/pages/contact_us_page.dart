import 'package:adzmavall/core/widgets/app_feedback.dart';
import 'package:adzmavall/features/influencer_settings/presentation/widgets/settings_sub_app_bar.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class _Contact {
  const _Contact(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}

/// Contact Us — support channels. Tapping a row copies the value.
class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  static const List<_Contact> _contacts = <_Contact>[
    _Contact(Icons.email_outlined, 'Email', 'support@adzmavall.com'),
    _Contact(Icons.phone_outlined, 'Phone', '+966 55 555 5555'),
    _Contact(Icons.chat_outlined, 'WhatsApp', '+966 55 555 5555'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: const SettingsSubAppBar(title: 'Contact Us'),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          itemCount: _contacts.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (BuildContext context, int index) {
            final _Contact c = _contacts[index];
            return InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () {
                Clipboard.setData(ClipboardData(text: c.value));
                showAppFeedback(
                  context,
                  message: '${c.label} copied',
                  type: AppFeedbackType.success,
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.borderSecondary),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40.w,
                      height: 40.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.brandBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        c.icon,
                        size: 20.sp,
                        color: AppColors.brandBlue,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            c.label,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.fgQuaternary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            c.value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.fgPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.copy_rounded,
                      size: 18.sp,
                      color: AppColors.fgQuinary,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

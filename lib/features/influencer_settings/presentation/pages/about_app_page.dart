import 'package:adzmavall/features/influencer_settings/presentation/widgets/settings_sub_app_bar.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// About / Privacy Policy screen.
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  static const List<String> _paragraphs = <String>[
    'Welcome to Adz Mavall. This Privacy Policy explains how we collect, use and protect your personal information when you use our application.',
    'We collect the following types of information: personal information (name, email address, phone number) and any other details you provide. We use this information to operate and improve the service.',
    'We use cookies and similar technologies to improve your experience. By using the app you consent to the practices described in this policy.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: const SettingsSubAppBar(title: 'About App'),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.fgPrimary,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'Last updated: December 2025',
                style: TextStyle(fontSize: 11.sp, color: AppColors.fgQuaternary),
              ),
              SizedBox(height: 16.h),
              for (final String p in _paragraphs) ...<Widget>[
                Text(
                  p,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.6,
                    color: AppColors.fgTertiary,
                  ),
                ),
                SizedBox(height: 14.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

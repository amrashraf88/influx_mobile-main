import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthFlowHeaderWidget extends StatelessWidget {
  const AuthFlowHeaderWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.showStar = true,
    this.centerText = false,
  });

  final String title;
  final String subtitle;
  final bool showStar;
  final bool centerText;

  @override
  Widget build(BuildContext context) {
    final align = centerText ? TextAlign.center : TextAlign.start;
    final cross = centerText ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    Widget titledText(String text, TextStyle style) {
      final Widget textWidget = Text(
        text,
        textAlign: align,
        style: style,
      );
      if (centerText) {
        return SizedBox(width: double.infinity, child: textWidget);
      }
      return textWidget;
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
      child: Column(
        crossAxisAlignment: cross,
        children: <Widget>[
          if (showStar) ...<Widget>[
            SizedBox(height: 56.h),
            Image.asset(ImageAssets.loginflowstaricon, width: 40.w, height: 40.h),
            SizedBox(height: 16.h),
          ],
          titledText(
            title,
            TextStyle(
              color: AppColors.white,
              fontSize: 30.sp,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16.h),
          titledText(
            subtitle,
            TextStyle(
              color: AppColors.white.withValues(alpha: 0.92),
              fontSize: 16.sp,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

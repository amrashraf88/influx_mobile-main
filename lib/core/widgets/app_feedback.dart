import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AppFeedbackType { success, error, info }

void showAppFeedback(
  BuildContext context, {
  required String message,
  AppFeedbackType type = AppFeedbackType.info,
}) {
  final _FeedbackStyle style = _styleFor(type);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 18.h),
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 3),
        content: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: style.borderColor),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.10),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: style.backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  style.icon,
                  color: style.foregroundColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
}

_FeedbackStyle _styleFor(AppFeedbackType type) {
  switch (type) {
    case AppFeedbackType.success:
      return const _FeedbackStyle(
        icon: Icons.check_rounded,
        foregroundColor: AppColors.successGreen,
        backgroundColor: AppColors.successBg,
        borderColor: Color(0xFFC8F3D6),
      );
    case AppFeedbackType.error:
      return const _FeedbackStyle(
        icon: Icons.close_rounded,
        foregroundColor: AppColors.danger,
        backgroundColor: Color(0xFFFFE8E8),
        borderColor: Color(0xFFFECACA),
      );
    case AppFeedbackType.info:
      return const _FeedbackStyle(
        icon: Icons.info_outline_rounded,
        foregroundColor: AppColors.brandBlue,
        backgroundColor: AppColors.softBlue,
        borderColor: Color(0xFFD7E8FF),
      );
  }
}

class _FeedbackStyle {
  const _FeedbackStyle({
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color borderColor;
}

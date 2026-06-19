import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_flow_header_widget.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_header_grid_painter.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CreatorTypeSelectionPage extends StatelessWidget {
  const CreatorTypeSelectionPage({super.key});

  static const List<_CreatorTypeOption> _options = <_CreatorTypeOption>[
    _CreatorTypeOption(
      value: 'influencer',
      titleEn: 'Influencer',
      titleAr: 'مؤثر',
      subtitleEn: 'Social accounts, audience, and content pricing.',
      subtitleAr: 'حسابات السوشيال والجمهور وأسعار المحتوى.',
      icon: Icons.campaign_rounded,
    ),
    _CreatorTypeOption(
      value: 'ugc',
      titleEn: 'UGC Creator',
      titleAr: 'صانع محتوى UGC',
      subtitleEn: 'Video, voice-over, hooks, and delivery details.',
      subtitleAr: 'فيديوهات وتعليق صوتي وهوكات ومدة التسليم.',
      icon: Icons.video_camera_front_rounded,
    ),
    _CreatorTypeOption(
      value: 'model',
      titleEn: 'Model',
      titleAr: 'موديل',
      subtitleEn: 'Measurements, visibility, and session pricing.',
      subtitleAr: 'المقاسات والظهور وسعر جلسة التصوير.',
      icon: Icons.face_retouching_natural_rounded,
    ),
    _CreatorTypeOption(
      value: 'collage',
      titleEn: 'Collage',
      titleAr: 'كولاج',
      subtitleEn: 'Location, accent, and clip pricing.',
      subtitleAr: 'الموقع واللهجة وسعر المقطع.',
      icon: Icons.school_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: <Widget>[
                SizedBox(
                  height: 300.h,
                  width: double.infinity,
                  child: CustomPaint(
                    foregroundPainter: AuthHeaderGridPainter(),
                    child: Container(
                      color: AppColors.brandBlue,
                      padding: EdgeInsets.only(top: 72.h),
                      child: AuthFlowHeaderWidget(
                        showStar: false,
                        centerText: true,
                        title: isArabic
                            ? 'اختر نوع\nصانع المحتوى'
                            : 'Choose creator\ntype',
                        subtitle: isArabic
                            ? 'هنجهز فورم التسجيل حسب اختيارك.'
                            : 'The registration form adapts to your type.',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 60.h,
                  left: 16.w,
                  child: _BackButton(
                    onPressed: () => context.pop(),
                    isArabic: isArabic,
                  ),
                ),
                Positioned.fill(
                  top: 252.h,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
                    child: Column(
                      children: <Widget>[
                        for (final _CreatorTypeOption option
                            in _options) ...<Widget>[
                          _CreatorTypeCard(
                            option: option,
                            isArabic: isArabic,
                            onTap: () {
                              context.push(
                                RouteNames.authPhonePath(
                                  account: 'influencer',
                                  creatorType: option.value,
                                  mode: 'register',
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 12.h),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CreatorTypeCard extends StatelessWidget {
  const _CreatorTypeCard({
    required this.option,
    required this.isArabic,
    required this.onTap,
  });

  final _CreatorTypeOption option;
  final bool isArabic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(22.r),
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: <Widget>[
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: AppColors.brandBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  option.icon,
                  color: AppColors.brandBlue,
                  size: 25.sp,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      isArabic ? option.titleAr : option.titleEn,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      isArabic ? option.subtitleAr : option.subtitleEn,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                isArabic
                    ? Icons.keyboard_arrow_left_rounded
                    : Icons.keyboard_arrow_right_rounded,
                color: const Color(0xFF9CA3AF),
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed, required this.isArabic});

  final VoidCallback onPressed;
  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46.w,
      height: 46.w,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: AppColors.white.withValues(alpha: 0.92),
          foregroundColor: const Color(0xFF64748B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Icon(
          isArabic
              ? Icons.keyboard_arrow_right_rounded
              : Icons.keyboard_arrow_left_rounded,
          size: 28.sp,
        ),
      ),
    );
  }
}

class _CreatorTypeOption {
  const _CreatorTypeOption({
    required this.value,
    required this.titleEn,
    required this.titleAr,
    required this.subtitleEn,
    required this.subtitleAr,
    required this.icon,
  });

  final String value;
  final String titleEn;
  final String titleAr;
  final String subtitleEn;
  final String subtitleAr;
  final IconData icon;
}

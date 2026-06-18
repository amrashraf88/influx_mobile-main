import 'dart:ui' as ui;

import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeWelcomeCardWidget extends StatelessWidget {
  const HomeWelcomeCardWidget({super.key, this.content});

  /// When non-null, overrides bundled copy / illustration from [ApiEndpoints.homeWelcomePath].
  final HomeWelcomeCardContent? content;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final String title = (content?.title != null && content!.title!.trim().isNotEmpty)
        ? content!.title!.trim()
        : AppStrings.of(locale, 'home_welcome_card_title');
    final String body = (content?.body != null && content!.body!.trim().isNotEmpty)
        ? content!.body!.trim()
        : AppStrings.of(locale, 'home_welcome_card_body');
    final String cta = (content?.ctaLabel != null && content!.ctaLabel!.trim().isNotEmpty)
        ? content!.ctaLabel!.trim()
        : AppStrings.of(locale, 'home_welcome_card_cta');
    final String? illustrationUrl = content?.illustrationUrl?.trim();
    return Container(
      width: double.infinity,
      height: 150.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF1B7FEC), Color(0xFF0B5FCB)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.brandBlue.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: <Widget>[
            // Soft decorative circle, matching the design's translucent orb.
            Positioned(
              right: -30.w,
              top: -30.h,
              child: Container(
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          body,
                          style: TextStyle(
                            fontSize: 10.sp,
                            height: 1.2,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: FilledButton(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              cta,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandBlue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _WelcomeIllustration(illustrationUrl: illustrationUrl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration({required this.illustrationUrl});

  final String? illustrationUrl;

  @override
  Widget build(BuildContext context) {
    final Widget image = illustrationUrl != null && illustrationUrl!.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: illustrationUrl!,
              fit: BoxFit.contain,
              width: 99.w,
              height: 80.h,
              placeholder: (BuildContext context, String url) => Image.asset(
                ImageAssets.homeWelcomeCard,
                fit: BoxFit.contain,
                width: 99.w,
                height: 80.h,
              ),
              errorWidget: (BuildContext context, String url, Object? _) =>
                  Image.asset(
                ImageAssets.homeWelcomeCard,
                fit: BoxFit.contain,
                width: 99.w,
                height: 80.h,
              ),
            ),
          )
        : Image.asset(
            ImageAssets.homeWelcomeCard,
            fit: BoxFit.contain,
            width: 99.w,
            height: 80.h,
          );

    return SizedBox(
      width: 104.w,
      height: 84.h,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Soft blurred glow behind the icon cluster, matching design blur feel.
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Opacity(opacity: 0.28, child: image),
          ),
          image,
        ],
      ),
    );
  }
}

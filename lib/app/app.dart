import 'package:adzmavall/core/localization/app_locale.dart';
import 'package:adzmavall/core/routes/app_router.dart';
import 'package:adzmavall/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdzMavallApp extends StatelessWidget {
  const AdzMavallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Adz Mavall',
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
          supportedLocales: AppLocale.supportedLocales,
          localizationsDelegates: AppLocale.localizationsDelegates,
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return AppLocale.english;
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
            return AppLocale.english;
          },
        );
      },
    );
  }
}

import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Home hero header — clean blue gradient that matches the
/// `linear-gradient(165deg, #2A8DF2 0%, #0066D6 100%)` design token.
class HomeStarHeaderWidget extends StatelessWidget {
  const HomeStarHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 158.h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          // 165deg ≈ from top (slightly left) to bottom (slightly right).
          begin: Alignment(-0.4, -1),
          end: Alignment(0.4, 1),
          colors: AppColors.heroGradient,
        ),
      ),
      child: Padding(padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h)),
    );
  }
}

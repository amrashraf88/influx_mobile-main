import 'package:adzmavall/features/auth/presentation/cubit/account_type_cubit.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AccountTypeOptionTileWidget extends StatelessWidget {
  const AccountTypeOptionTileWidget({
    super.key,
    required this.option,
    required this.selected,
    required this.title,
    required this.description,
    required this.leading,
    required this.onTap,
  });

  final AccountTypeOption option;
  final AccountTypeOption selected;
  final String title;
  final String description;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selected == option;
    final Color borderColor = isSelected
        ? AppColors.brandBlue
        : const Color(0xFFE2E8F0);
    final Color radioBorder = isSelected
        ? AppColors.brandBlue
        : const Color(0xFFCBD5E1);
    final Color radioOuterFill =
        isSelected ? AppColors.white : Colors.transparent;
    final Color radioInnerFill =
        isSelected ? AppColors.brandBlue : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  leading,
                  const Spacer(),
                  Container(
                    width: 20.w,
                    height: 20.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: radioBorder, width: 2),
                      color: radioOuterFill,
                    ),
                    child: Center(
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: radioInnerFill,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14.sp,

                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                textScaler: TextScaler.linear(0.85),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.2,
                  // fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

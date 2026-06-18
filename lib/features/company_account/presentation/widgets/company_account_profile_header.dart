import 'package:adzmavall/features/company_account/presentation/models/company_account_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyAccountProfileHeader extends StatelessWidget {
  const CompanyAccountProfileHeader({super.key, required this.profile});

  final CompanyAccountProfile profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _Avatar(imageUrl: profile.avatarUrl),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.verified_rounded, color: AppColors.white, size: 18.sp),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            profile.phone,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      height: 96.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 2.w),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (BuildContext context, String url) =>
            const ColoredBox(color: Color(0xFFEFF4F9)),
        errorWidget: (BuildContext context, String url, Object error) =>
            const ColoredBox(
              color: Color(0xFFEFF4F9),
              child: Icon(Icons.storefront_rounded, color: AppColors.brandBlue),
            ),
      ),
    );
  }
}

import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/pages/edit_profile_page.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfluencerProfileSummaryCard extends StatelessWidget {
  const InfluencerProfileSummaryCard({
    super.key,
    required this.profile,
    this.contactActions,
    this.showEditButton = true,
  });

  final InfluencerProfileSummaryData profile;
  final List<InfluencerContactAction>? contactActions;
  final bool showEditButton;

  @override
  Widget build(BuildContext context) {
    final List<InfluencerContactAction> actions =
        contactActions ?? InfluencerProfileViewData.contactActions;
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 10.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ProfileAvatar(size: 88.w, imageUrl: profile.avatarUrl),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    _MawthooqBadge(label: profile.mawthooqLabel),
                    SizedBox(height: 18.h),
                    const _SocialShortcutRow(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          profile.name,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.brandBlue,
                          size: 19.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      profile.title,
                      style: TextStyle(
                        color: const Color(0xFFB1B5BE),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const _ShareButton(),
                  if (showEditButton) ...<Widget>[
                    SizedBox(width: 10.w),
                    const _EditProfileButton(),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            profile.bio,
            style: TextStyle(
              color: const Color(0xFF747B86),
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
          SizedBox(height: 16.h),
          _ContactActionsRow(actions: actions),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.size, required this.imageUrl});

  final double size;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 3.w),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
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
              child: Icon(Icons.person_rounded, color: AppColors.brandBlue),
            ),
      ),
    );
  }
}

class _MawthooqBadge extends StatelessWidget {
  const _MawthooqBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE6FAED),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 11.w,
            height: 11.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF23B45B), width: 1.w),
            ),
            child: Center(
              child: Container(
                width: 5.w,
                height: 5.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF23B45B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF17883F),
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialShortcutRow extends StatelessWidget {
  const _SocialShortcutRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _SocialShortcut(asset: ImageAssets.facebookRectangleIcon),
        SizedBox(width: 8.w),
        const _SocialShortcut(asset: ImageAssets.instagramIcon),
        SizedBox(width: 8.w),
        _SocialShortcut(asset: ImageAssets.homeInfluencerTiktok),
        SizedBox(width: 8.w),
        _SocialShortcut(asset: ImageAssets.homeInfluencerYoutube),
      ],
    );
  }
}

class _SocialShortcut extends StatelessWidget {
  const _SocialShortcut({this.asset});

  final String? asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.tagBackground),
      ),
      child: Center(
        child: Image.asset(asset!, width: 16.w, height: 16.h),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.tagBackground),
      ),
      child: Center(
        child: Image.asset(
          ImageAssets.shareProfileIcon,
          width: 16.w,
          height: 16.h,
        ),
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999.r),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const EditProfilePage()),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            'Edit',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactActionsRow extends StatelessWidget {
  const _ContactActionsRow({required this.actions});

  final List<InfluencerContactAction> actions;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(8.r)),
      child: Container(
        height: 49.h,
        color: const Color(0xFFEFF9FF),
        child: Row(
          children: <Widget>[
            for (int i = 0; i < actions.length; i++) ...<Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      actions[i].asset,
                      width: 16.w,
                      height: 16.h,
                      fit: BoxFit.scaleDown,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      actions[i].label,
                      style: TextStyle(
                        color: const Color(0xFF4D5968),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (i != actions.length - 1)
                Container(width: 1.w, color: const Color(0xFFE0EEF7)),
            ],
          ],
        ),
      ),
    );
  }
}

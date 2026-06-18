import 'package:adzmavall/features/influencer_settings/presentation/influencer_settings_static_menu.dart';
import 'package:adzmavall/features/influencer_settings/presentation/models/influencer_settings_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfluencerSettingsPanel extends StatelessWidget {
  const InfluencerSettingsPanel({
    super.key,
    required this.profile,
    required this.onAction,
  });

  final InfluencerSettingsProfile profile;
  final void Function(InfluencerSettingsAction action, String label) onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(13.w, 20.h, 13.w, 18.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (profile.shouldShowVerificationCard) ...<Widget>[
            Text('Profile', style: _sectionTitleStyle),
            SizedBox(height: 12.h),
            _VerificationCard(
              profile: profile,
              onTap: () => onAction(
                InfluencerSettingsAction.verifyAccount,
                'Verify account',
              ),
            ),
            SizedBox(height: 20.h),
          ],
          for (
            int index = 0;
            index < InfluencerSettingsStaticMenu.sections.length;
            index++
          ) ...<Widget>[
            _SettingsSection(
              section: InfluencerSettingsStaticMenu.sections[index],
              onAction: onAction,
            ),
            if (index != InfluencerSettingsStaticMenu.sections.length - 1)
              SizedBox(height: 24.h),
          ],
        ],
      ),
    );
  }
}

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.profile, required this.onTap});

  final InfluencerSettingsProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Verify Your Account : ${profile.verificationPercent}%',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 12.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: profile.verificationProgress,
                    minHeight: 7.h,
                    backgroundColor: const Color(0xFFDADDE2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brandBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 18.w),
          SizedBox(
            height: 39.h,
            width: 88.w,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.brandBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Verify',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.section, required this.onAction});

  final InfluencerSettingsSection section;
  final void Function(InfluencerSettingsAction action, String label) onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(section.title, style: _sectionTitleStyle),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: <Widget>[
              for (
                int index = 0;
                index < section.items.length;
                index++
              ) ...<Widget>[
                _MenuRow(
                  item: section.items[index],
                  onTap: () => onAction(
                    section.items[index].action,
                    section.items[index].title,
                  ),
                ),
                if (index != section.items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 10.w,
                    endIndent: 10.w,
                    color: const Color(0xFFE5E7EB),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.onTap});

  final InfluencerSettingsMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 18.h),
          child: Row(
            children: <Widget>[
              _SettingIcon(icon: Icons.image),
              SizedBox(width: 15.w),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (item.statusLabel != null)
                _StatusChip(label: item.statusLabel!)
              else if (item.trailingText != null)
                _WalletAmount(value: item.trailingText!),
              SizedBox(width: 8.w),
              Icon(
                isRtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.textPrimary,
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  const _SettingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24.w,
      child: Icon(icon, color: AppColors.textPrimary, size: 22.sp),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFF25B861),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _WalletAmount extends StatelessWidget {
  const _WalletAmount({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(
            color: AppColors.brandBlue,
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(width: 5.w),
        Image.asset(
          ImageAssets.rsIcon,
          width: 18.w,
          height: 18.w,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

TextStyle get _sectionTitleStyle => TextStyle(
  color: AppColors.textSecondary,
  fontSize: 14.sp,
  fontWeight: FontWeight.w600,
);

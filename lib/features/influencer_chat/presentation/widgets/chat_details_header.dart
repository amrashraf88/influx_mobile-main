import 'package:adzmavall/features/influencer_chat/presentation/models/influencer_chat_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatDetailsHeader extends StatelessWidget {
  const ChatDetailsHeader({
    super.key,
    required this.thread,
    required this.onBack,
    required this.onVoiceCall,
    required this.onVideoCall,
  });

  final InfluencerChatThread thread;
  final VoidCallback onBack;
  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 18.h, 14.w, 12.h),
      child: Row(
        children: <Widget>[
          _HeaderIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              thread.participant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _PlainIconButton(icon: Icons.call_outlined, onTap: onVoiceCall),
          SizedBox(width: 14.w),
          _PlainIconButton(icon: Icons.videocam_outlined, onTap: onVideoCall),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFE6ECF3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
      ),
    );
  }
}

class _PlainIconButton extends StatelessWidget {
  const _PlainIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Icon(icon, color: AppColors.textPrimary, size: 24.sp),
    );
  }
}

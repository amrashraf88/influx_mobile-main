import 'package:adzmavall/features/influencer_chat/presentation/models/influencer_chat_models.dart';
import 'package:adzmavall/features/influencer_chat/presentation/widgets/chat_avatar.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ChatThreadTile extends StatelessWidget {
  const ChatThreadTile({super.key, required this.thread, required this.onTap});

  final InfluencerChatThread thread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final InfluencerChatMessage? lastMessage = thread.lastMessage;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ChatAvatar(
              imageUrl: thread.participant.avatarUrl,
              fallbackText: thread.participant.name,
              size: 52.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      thread.participant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      thread.isTyping
                          ? thread.participant.subtitle ?? 'Typing...'
                          : lastMessage?.text ??
                                thread.participant.subtitle ??
                                '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: thread.isTyping
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: thread.isTyping
                            ? AppColors.brandBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  _relativeTime(thread.updatedAt),
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: const Color(0xFFB6C0CD),
                  ),
                ),
                SizedBox(height: 8.h),
                if (thread.unreadCount > 0)
                  Container(
                    width: 18.w,
                    height: 18.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.brandBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      thread.unreadCount.toString(),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime value) {
    final Duration diff = DateTime.now().difference(value);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes.clamp(1, 59)} min ago';
    }
    return DateFormat('h:mm a').format(value);
  }
}

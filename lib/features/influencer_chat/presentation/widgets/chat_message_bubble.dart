import 'package:adzmavall/features/influencer_chat/presentation/models/influencer_chat_models.dart';
import 'package:adzmavall/features/influencer_chat/presentation/widgets/chat_voice_message_player.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.voicePlaybackActiveId,
  });

  final InfluencerChatMessage message;
  final ValueNotifier<String?>? voicePlaybackActiveId;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment alignment = message.isMine
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final Color background = message.isMine
        ? AppColors.brandBlue
        : AppColors.white;
    final Color foreground = message.isMine
        ? AppColors.white
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: alignment,
      children: <Widget>[
        Align(
          alignment: message.isMine
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 245.w),
            child: Container(
              margin: EdgeInsets.only(bottom: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(message.isMine ? 18.r : 4.r),
                  topRight: Radius.circular(message.isMine ? 4.r : 18.r),
                  bottomLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(18.r),
                ),
              ),
              child: _MessageContent(
                message: message,
                foreground: foreground,
                voicePlaybackActiveId: voicePlaybackActiveId,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: message.isMine ? 0 : 170.w,
            right: message.isMine ? 10.w : 0,
            bottom: 12.h,
          ),
          child: Text(
            DateFormat('h:mm a').format(message.sentAt),
            style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _MessageContent extends StatelessWidget {
  const _MessageContent({
    required this.message,
    required this.foreground,
    this.voicePlaybackActiveId,
  });

  final InfluencerChatMessage message;
  final Color foreground;
  final ValueNotifier<String?>? voicePlaybackActiveId;

  @override
  Widget build(BuildContext context) {
    return switch (message.type) {
      InfluencerChatMessageType.text => Text(
        message.text,
        style: _textStyle(foreground),
      ),
      InfluencerChatMessageType.file => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.insert_drive_file_outlined,
            color: foreground,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  message.fileName ?? message.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _textStyle(
                    foreground,
                  ).copyWith(fontWeight: FontWeight.w700),
                ),
                if (message.fileSizeLabel != null)
                  Text(
                    message.fileSizeLabel!,
                    style: _textStyle(foreground).copyWith(
                      fontSize: 10.sp,
                      color: foreground.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      InfluencerChatMessageType.voice => switch (voicePlaybackActiveId) {
        null => Text(
          _formatDuration(message.voiceDuration),
          style: _textStyle(foreground),
        ),
        final ValueNotifier<String?> n => ChatVoiceMessagePlayer(
          message: message,
          foreground: foreground,
          activeMessageId: n,
        ),
      },
    };
  }

  TextStyle _textStyle(Color color) {
    return TextStyle(
      color: color,
      fontSize: 12.sp,
      height: 1.35,
      fontWeight: FontWeight.w500,
    );
  }

  String _formatDuration(Duration? duration) {
    final int totalSeconds = duration?.inSeconds ?? 0;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

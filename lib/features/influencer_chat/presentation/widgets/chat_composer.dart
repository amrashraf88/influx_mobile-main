import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSend,
    required this.onAttachFile,
    required this.onRecordVoice,
    this.isSending = false,
    this.isRecording = false,
  });

  final ValueChanged<String> onSend;
  final VoidCallback onAttachFile;
  final VoidCallback onRecordVoice;
  final bool isSending;
  final bool isRecording;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _controller.text.trim();
    if (text.isEmpty || widget.isSending) {
      return;
    }
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.pageBackground,
      padding: EdgeInsets.fromLTRB(
        14.w,
        10.h,
        14.w,
        MediaQuery.paddingOf(context).bottom + 14.h,
      ),
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFFBFEFFF).withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type here...',
                  hintStyle: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
              ),
            ),
            _ComposerIcon(
              icon: Icons.add_rounded,
              onTap: widget.isSending ? null : widget.onAttachFile,
            ),
            SizedBox(width: 10.w),
            _ComposerIcon(
              icon: widget.isRecording
                  ? Icons.stop_circle_outlined
                  : Icons.mic_none_rounded,
              color: widget.isRecording
                  ? const Color(0xFFE11D48)
                  : AppColors.brandBlue,
              onTap: widget.isSending ? null : widget.onRecordVoice,
            ),
            SizedBox(width: 10.w),
            _ComposerIcon(
              icon: widget.isSending
                  ? Icons.hourglass_top_rounded
                  : Icons.send_rounded,
              onTap: widget.isSending ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerIcon extends StatelessWidget {
  const _ComposerIcon({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Icon(
        icon,
        color: onTap == null
            ? AppColors.textSecondary.withValues(alpha: 0.45)
            : color ?? AppColors.brandBlue,
        size: 24.sp,
      ),
    );
  }
}

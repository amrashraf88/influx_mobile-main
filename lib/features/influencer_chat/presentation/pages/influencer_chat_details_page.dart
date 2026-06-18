import 'package:adzmavall/features/influencer_chat/presentation/cubit/influencer_chat_cubit.dart';
import 'package:adzmavall/features/influencer_chat/presentation/models/influencer_chat_models.dart';
import 'package:adzmavall/features/influencer_chat/presentation/widgets/chat_composer.dart';
import 'package:adzmavall/features/influencer_chat/presentation/widgets/chat_details_header.dart';
import 'package:adzmavall/features/influencer_chat/presentation/widgets/chat_empty_state.dart';
import 'package:adzmavall/features/influencer_chat/presentation/widgets/chat_message_bubble.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InfluencerChatDetailsPage extends StatelessWidget {
  const InfluencerChatDetailsPage({super.key, required this.threadId});

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfluencerChatCubit>(
      create: (_) => InfluencerChatCubit()..loadThread(threadId),
      child: const _InfluencerChatDetailsView(),
    );
  }
}

class _InfluencerChatDetailsView extends StatefulWidget {
  const _InfluencerChatDetailsView();

  @override
  State<_InfluencerChatDetailsView> createState() =>
      _InfluencerChatDetailsViewState();
}

class _InfluencerChatDetailsViewState
    extends State<_InfluencerChatDetailsView> {
  final ValueNotifier<String?> _activeVoiceMessageId = ValueNotifier<String?>(
    null,
  );

  @override
  void dispose() {
    _activeVoiceMessageId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<InfluencerChatCubit, InfluencerChatState>(
            builder: (BuildContext context, InfluencerChatState state) {
              final InfluencerChatThread? thread = state.selectedThread;
              if (state.isLoading && thread == null) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              if (thread == null) {
                return ChatEmptyState(
                  title: 'Chat not found',
                  message:
                      state.errorMessage ??
                      'This conversation is not available.',
                );
              }

              return Column(
                children: <Widget>[
                  ChatDetailsHeader(
                    thread: thread,
                    onBack: context.pop,
                    onVoiceCall: () =>
                        _startCall(context, InfluencerChatCallType.voice),
                    onVideoCall: () =>
                        _startCall(context, InfluencerChatCallType.video),
                  ),
                  if (state.isRecording) const _RecordingBanner(),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(14.w, 6.h, 14.w, 12.h),
                      itemCount: thread.messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ChatMessageBubble(
                          message: thread.messages[index],
                          voicePlaybackActiveId: _activeVoiceMessageId,
                        );
                      },
                    ),
                  ),
                  if (state.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFFE11D48),
                        ),
                      ),
                    ),
                  ChatComposer(
                    isSending: state.isSending,
                    isRecording: state.isRecording,
                    onSend: context.read<InfluencerChatCubit>().sendMessage,
                    onAttachFile: context
                        .read<InfluencerChatCubit>()
                        .pickAndSendFile,
                    onRecordVoice: context
                        .read<InfluencerChatCubit>()
                        .toggleVoiceRecording,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _startCall(
    BuildContext context,
    InfluencerChatCallType type,
  ) async {
    final InfluencerChatCubit cubit = context.read<InfluencerChatCubit>();
    await cubit.startCall(type);
    if (!context.mounted || cubit.state.activeCallType == null) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _ActiveCallSheet(
          type: type,
          participantName: cubit.state.selectedThread?.participant.name ?? '',
          onEnd: () {
            cubit.endCall();
            Navigator.of(sheetContext).pop();
          },
        );
      },
    );
    if (context.mounted) {
      cubit.endCall();
    }
  }
}

class _RecordingBanner extends StatelessWidget {
  const _RecordingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF2),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.fiber_manual_record_rounded,
            color: const Color(0xFFE11D48),
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Recording voice message... tap the mic again to send',
              style: TextStyle(
                color: const Color(0xFFE11D48),
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveCallSheet extends StatelessWidget {
  const _ActiveCallSheet({
    required this.type,
    required this.participantName,
    required this.onEnd,
  });

  final InfluencerChatCallType type;
  final String participantName;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final bool isVideo = type == InfluencerChatCallType.video;
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.fromLTRB(
        22.w,
        24.h,
        22.w,
        MediaQuery.paddingOf(context).bottom + 22.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 66.w,
            height: 66.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEAF6FF),
            ),
            child: Icon(
              isVideo ? Icons.videocam_rounded : Icons.call_rounded,
              color: AppColors.brandBlue,
              size: 34.sp,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            '${isVideo ? 'Video' : 'Voice'} call',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            participantName.isEmpty
                ? 'Connecting...'
                : 'Connecting with $participantName...',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 22.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onEnd,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                padding: EdgeInsets.symmetric(vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22.r),
                ),
              ),
              icon: Icon(Icons.call_end_rounded, size: 20.sp),
              label: Text(
                'End call',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

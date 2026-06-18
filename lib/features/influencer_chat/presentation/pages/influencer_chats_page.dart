import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/influencer_chat/presentation/cubit/influencer_chat_cubit.dart';
import 'package:adzmavall/features/influencer_chat/presentation/models/influencer_chat_models.dart';
import 'package:adzmavall/features/influencer_chat/presentation/widgets/chat_empty_state.dart';
import 'package:adzmavall/features/influencer_chat/presentation/widgets/chat_search_row.dart';
import 'package:adzmavall/features/influencer_chat/presentation/widgets/chat_thread_tile.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InfluencerChatsPage extends StatelessWidget {
  const InfluencerChatsPage({super.key, this.isBrand});

  /// When non-null, forces the brand/creator chat endpoints. When null, the
  /// cubit falls back to the role persisted at login.
  final bool? isBrand;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfluencerChatCubit>(
      create: (_) => InfluencerChatCubit(isBrand: isBrand)..loadThreads(),
      child: Builder(
        builder: (BuildContext context) {
          final Locale locale = Localizations.localeOf(context);
          final bool isArabic = locale.languageCode == 'ar';
          return Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 34.h),
                  Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const ChatSearchRow(),
                  SizedBox(height: 12.h),
                  const Expanded(child: _ChatThreadsList()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChatThreadsList extends StatelessWidget {
  const _ChatThreadsList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfluencerChatCubit, InfluencerChatState>(
      builder: (BuildContext context, InfluencerChatState state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        if (state.errorMessage != null && state.threads.isEmpty) {
          return ChatEmptyState(
            title: 'Unable to load chats',
            message: state.errorMessage!,
          );
        }

        final List<InfluencerChatThread> threads = state.filteredThreads;
        if (threads.isEmpty) {
          return const ChatEmptyState();
        }

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 112.h),
          itemCount: threads.length,
          itemBuilder: (BuildContext context, int index) {
            final InfluencerChatThread thread = threads[index];
            return ChatThreadTile(
              thread: thread,
              onTap: () =>
                  context.push(RouteNames.influencerChatDetailsPath(thread.id)),
            );
          },
        );
      },
    );
  }
}

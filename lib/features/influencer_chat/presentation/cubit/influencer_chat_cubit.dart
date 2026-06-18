import 'dart:io';

import 'package:adzmavall/core/auth/auth_token_storage.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/influencer_chat/data/influencer_chat_api_repository.dart';
import 'package:adzmavall/features/influencer_chat/data/influencer_chat_repository.dart';
import 'package:adzmavall/features/influencer_chat/presentation/models/influencer_chat_models.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

part 'influencer_chat_state.dart';

enum _MicAvailability { ready, denied, missingPlugin }

class InfluencerChatCubit extends Cubit<InfluencerChatState> {
  InfluencerChatCubit({InfluencerChatRepository? repository, bool? isBrand})
    : _repository = repository ?? _defaultRepository(isBrand),
      super(const InfluencerChatState());

  static InfluencerChatRepository _defaultRepository(bool? isBrand) {
    if (ApiUrlResolver.isConfigured) {
      // Use the explicit flag when the route knows the role (company tab),
      // otherwise fall back to the role persisted at login.
      final bool brand = isBrand ?? AuthTokenStorage.instance.isBrand;
      return InfluencerChatApiRepository(
        DioClient.instance,
        scope: brand ? ChatApiScope.brand : ChatApiScope.influencer,
      );
    }
    return InfluencerChatMockRepository();
  }

  final InfluencerChatRepository _repository;

  /// Created lazily so opening chat does not touch native channels before plugins are ready.
  AudioRecorder? _audioRecorder;

  static const String _missingRecorderHint =
      'Voice recording needs a fresh native build. Fully stop the app, then run '
      'flutter clean, flutter pub get, and flutter run (not hot restart).';

  Future<_MicAvailability> _prepareMicrophone() async {
    if (_audioRecorder != null) {
      try {
        final bool ok = await _audioRecorder!.hasPermission();
        return ok ? _MicAvailability.ready : _MicAvailability.denied;
      } on MissingPluginException {
        return _MicAvailability.missingPlugin;
      }
    }
    AudioRecorder? created;
    try {
      created = AudioRecorder();
      final bool ok = await created.hasPermission();
      if (!ok) {
        await created.dispose();
        return _MicAvailability.denied;
      }
      _audioRecorder = created;
      return _MicAvailability.ready;
    } on MissingPluginException {
      if (created != null) {
        await created.dispose();
      }
      return _MicAvailability.missingPlugin;
    }
  }

  Future<void> loadThreads() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final List<InfluencerChatThread> threads = await _repository
          .fetchThreads();
      emit(state.copyWith(isLoading: false, threads: threads));
    } on Object {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to load chats right now.',
        ),
      );
    }
  }

  Future<void> loadThread(String threadId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final InfluencerChatThread? thread = await _repository.fetchThread(
        threadId,
      );
      emit(
        state.copyWith(
          isLoading: false,
          selectedThread: thread,
          clearSelectedThread: thread == null,
          threads: _upsertThread(thread),
          errorMessage: thread == null ? 'Chat thread was not found.' : null,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to load this chat right now.',
        ),
      );
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  Future<void> sendMessage(String text) async {
    final String trimmed = text.trim();
    final InfluencerChatThread? thread = state.selectedThread;
    if (trimmed.isEmpty || thread == null || state.isSending) {
      return;
    }

    emit(state.copyWith(isSending: true, clearError: true));
    try {
      final InfluencerChatMessage message = await _repository.sendMessage(
        threadId: thread.id,
        text: trimmed,
      );
      _emitMessageSent(thread, message);
    } on Object {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: 'Message was not sent. Please try again.',
        ),
      );
    }
  }

  Future<void> pickAndSendFile() async {
    final InfluencerChatThread? thread = state.selectedThread;
    if (thread == null || state.isSending) {
      return;
    }
    final FilePickerResult? result = await FilePicker.pickFiles();
    final PlatformFile? file = result?.files.single;
    if (file == null) {
      return;
    }

    emit(state.copyWith(isSending: true, clearError: true));
    try {
      final InfluencerChatMessage message = await _repository.sendFile(
        threadId: thread.id,
        fileName: file.name,
        filePath: file.path,
        fileSize: file.size,
      );
      _emitMessageSent(thread, message);
    } on Object {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: 'File was not sent. Please try again.',
        ),
      );
    }
  }

  Future<void> toggleVoiceRecording() async {
    final InfluencerChatThread? thread = state.selectedThread;
    if (thread == null || state.isSending) {
      return;
    }

    if (!state.isRecording) {
      try {
        final _MicAvailability mic = await _prepareMicrophone();
        switch (mic) {
          case _MicAvailability.missingPlugin:
            emit(state.copyWith(errorMessage: _missingRecorderHint));
            return;
          case _MicAvailability.denied:
            emit(
              state.copyWith(
                errorMessage:
                    'Microphone permission is required to record voice.',
              ),
            );
            return;
          case _MicAvailability.ready:
            break;
        }

        final AudioRecorder recorder = _audioRecorder!;

        final DateTime startedAt = DateTime.now();
        final Directory directory = await getTemporaryDirectory();
        final String path =
            '${directory.path}${Platform.pathSeparator}adz_voice_${startedAt.microsecondsSinceEpoch}.m4a';
        try {
          await recorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path,
          );
        } on MissingPluginException {
          emit(
            state.copyWith(
              isRecording: false,
              clearRecordingStartedAt: true,
              clearRecordingFilePath: true,
              errorMessage: _missingRecorderHint,
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            isRecording: true,
            recordingStartedAt: startedAt,
            recordingFilePath: path,
            clearError: true,
          ),
        );
      } on MissingPluginException {
        emit(
          state.copyWith(
            isRecording: false,
            clearRecordingStartedAt: true,
            clearRecordingFilePath: true,
            errorMessage: _missingRecorderHint,
          ),
        );
      } on Object {
        emit(
          state.copyWith(
            isRecording: false,
            clearRecordingStartedAt: true,
            clearRecordingFilePath: true,
            errorMessage: 'Unable to start voice recording.',
          ),
        );
      }
      return;
    }

    final DateTime startedAt = state.recordingStartedAt ?? DateTime.now();
    final String? expectedPath = state.recordingFilePath;
    final Duration duration = DateTime.now().difference(startedAt);
    emit(
      state.copyWith(
        isRecording: false,
        isSending: true,
        clearRecordingStartedAt: true,
        clearRecordingFilePath: true,
        clearError: true,
      ),
    );
    try {
      final String? recordedPath = await _audioRecorder?.stop();
      final String? voicePath = recordedPath ?? expectedPath;
      if (voicePath == null || !File(voicePath).existsSync()) {
        throw StateError('Recorded voice file was not created.');
      }
      final InfluencerChatMessage message = await _repository.sendVoiceNote(
        threadId: thread.id,
        duration: duration.inSeconds < 1
            ? const Duration(seconds: 1)
            : duration,
        filePath: voicePath,
      );
      _emitMessageSent(thread, message);
    } on Object {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: 'Voice message was not sent. Please try again.',
        ),
      );
    }
  }

  Future<void> startCall(InfluencerChatCallType type) async {
    final InfluencerChatThread? thread = state.selectedThread;
    if (thread == null) {
      return;
    }

    emit(state.copyWith(activeCallType: type, clearError: true));
    try {
      await _repository.startCall(threadId: thread.id, type: type);
    } on Object {
      emit(
        state.copyWith(
          clearActiveCall: true,
          errorMessage: 'Unable to start the call right now.',
        ),
      );
    }
  }

  void endCall() {
    emit(state.copyWith(clearActiveCall: true));
  }

  @override
  Future<void> close() async {
    final AudioRecorder? recorder = _audioRecorder;
    if (recorder != null) {
      if (state.isRecording) {
        await recorder.stop();
      }
      await recorder.dispose();
      _audioRecorder = null;
    }
    return super.close();
  }

  void _emitMessageSent(
    InfluencerChatThread thread,
    InfluencerChatMessage message,
  ) {
    final InfluencerChatThread updatedThread = thread.copyWith(
      messages: <InfluencerChatMessage>[...thread.messages, message],
      updatedAt: message.sentAt,
      unreadCount: 0,
    );
    emit(
      state.copyWith(
        isSending: false,
        selectedThread: updatedThread,
        threads: _upsertThread(updatedThread),
      ),
    );
  }

  List<InfluencerChatThread> _upsertThread(InfluencerChatThread? thread) {
    if (thread == null) {
      return state.threads;
    }
    final List<InfluencerChatThread> updated = List<InfluencerChatThread>.from(
      state.threads,
    );
    final int index = updated.indexWhere(
      (InfluencerChatThread item) => item.id == thread.id,
    );
    if (index == -1) {
      updated.add(thread);
    } else {
      updated[index] = thread;
    }
    updated.sort(
      (InfluencerChatThread a, InfluencerChatThread b) =>
          b.updatedAt.compareTo(a.updatedAt),
    );
    return updated;
  }
}

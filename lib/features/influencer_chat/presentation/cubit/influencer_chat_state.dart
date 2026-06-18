part of 'influencer_chat_cubit.dart';

class InfluencerChatState extends Equatable {
  const InfluencerChatState({
    this.isLoading = false,
    this.isSending = false,
    this.isRecording = false,
    this.recordingStartedAt,
    this.recordingFilePath,
    this.activeCallType,
    this.threads = const <InfluencerChatThread>[],
    this.selectedThread,
    this.searchQuery = '',
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSending;
  final bool isRecording;
  final DateTime? recordingStartedAt;
  final String? recordingFilePath;
  final InfluencerChatCallType? activeCallType;
  final List<InfluencerChatThread> threads;
  final InfluencerChatThread? selectedThread;
  final String searchQuery;
  final String? errorMessage;

  List<InfluencerChatThread> get filteredThreads {
    final String q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      return threads;
    }
    return threads
        .where((InfluencerChatThread thread) {
          final InfluencerChatMessage? lastMessage = thread.lastMessage;
          return thread.participant.name.toLowerCase().contains(q) ||
              (thread.participant.subtitle?.toLowerCase().contains(q) ??
                  false) ||
              (lastMessage?.text.toLowerCase().contains(q) ?? false);
        })
        .toList(growable: false);
  }

  InfluencerChatState copyWith({
    bool? isLoading,
    bool? isSending,
    bool? isRecording,
    DateTime? recordingStartedAt,
    bool clearRecordingStartedAt = false,
    String? recordingFilePath,
    bool clearRecordingFilePath = false,
    InfluencerChatCallType? activeCallType,
    bool clearActiveCall = false,
    List<InfluencerChatThread>? threads,
    InfluencerChatThread? selectedThread,
    bool clearSelectedThread = false,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InfluencerChatState(
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isRecording: isRecording ?? this.isRecording,
      recordingStartedAt: clearRecordingStartedAt
          ? null
          : recordingStartedAt ?? this.recordingStartedAt,
      recordingFilePath: clearRecordingFilePath
          ? null
          : recordingFilePath ?? this.recordingFilePath,
      activeCallType: clearActiveCall
          ? null
          : activeCallType ?? this.activeCallType,
      threads: threads ?? this.threads,
      selectedThread: clearSelectedThread
          ? null
          : selectedThread ?? this.selectedThread,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    isSending,
    isRecording,
    recordingStartedAt,
    recordingFilePath,
    activeCallType,
    threads,
    selectedThread,
    searchQuery,
    errorMessage,
  ];
}

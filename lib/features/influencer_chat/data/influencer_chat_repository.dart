import 'package:adzmavall/features/influencer_chat/presentation/models/influencer_chat_models.dart';

abstract interface class InfluencerChatRepository {
  Future<List<InfluencerChatThread>> fetchThreads();

  Future<InfluencerChatThread?> fetchThread(String threadId);

  Future<InfluencerChatMessage> sendMessage({
    required String threadId,
    required String text,
  });

  Future<InfluencerChatMessage> sendFile({
    required String threadId,
    required String fileName,
    required String? filePath,
    required int fileSize,
  });

  Future<InfluencerChatMessage> sendVoiceNote({
    required String threadId,
    required Duration duration,
    required String filePath,
  });

  Future<void> startCall({
    required String threadId,
    required InfluencerChatCallType type,
  });
}

class InfluencerChatMockRepository implements InfluencerChatRepository {
  InfluencerChatMockRepository({List<InfluencerChatThread>? seedThreads})
    : _threads = seedThreads == null
          ? _sharedThreads
          : List<InfluencerChatThread>.from(seedThreads);

  final List<InfluencerChatThread> _threads;

  @override
  Future<List<InfluencerChatThread>> fetchThreads() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<InfluencerChatThread>.unmodifiable(_sortedThreads);
  }

  @override
  Future<InfluencerChatThread?> fetchThread(String threadId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final int index = _threads.indexWhere(
      (InfluencerChatThread thread) =>
          thread.id == threadId || thread.orderId == threadId,
    );
    if (index == -1) {
      return null;
    }
    final InfluencerChatThread thread = _threads[index].copyWith(
      unreadCount: 0,
    );
    _threads[index] = thread;
    return thread;
  }

  @override
  Future<InfluencerChatMessage> sendMessage({
    required String threadId,
    required String text,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _appendLocalMessage(threadId: threadId, text: text);
  }

  @override
  Future<InfluencerChatMessage> sendFile({
    required String threadId,
    required String fileName,
    required String? filePath,
    required int fileSize,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _appendLocalMessage(
      threadId: threadId,
      text: fileName,
      type: InfluencerChatMessageType.file,
      fileName: fileName,
      filePath: filePath,
      fileSizeLabel: _formatFileSize(fileSize),
    );
  }

  @override
  Future<InfluencerChatMessage> sendVoiceNote({
    required String threadId,
    required Duration duration,
    required String filePath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _appendLocalMessage(
      threadId: threadId,
      text: 'Voice message',
      type: InfluencerChatMessageType.voice,
      voiceDuration: duration,
      voiceFilePath: filePath,
    );
  }

  @override
  Future<void> startCall({
    required String threadId,
    required InfluencerChatCallType type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final bool exists = _threads.any(
      (InfluencerChatThread thread) =>
          thread.id == threadId || thread.orderId == threadId,
    );
    if (!exists) {
      throw StateError('Chat thread was not found.');
    }
  }

  InfluencerChatMessage _appendLocalMessage({
    required String threadId,
    required String text,
    InfluencerChatMessageType type = InfluencerChatMessageType.text,
    String? fileName,
    String? filePath,
    String? fileSizeLabel,
    Duration? voiceDuration,
    String? voiceFilePath,
  }) {
    final int index = _threads.indexWhere(
      (InfluencerChatThread thread) =>
          thread.id == threadId || thread.orderId == threadId,
    );
    if (index == -1) {
      throw StateError('Chat thread was not found.');
    }

    final DateTime now = DateTime.now();
    final InfluencerChatMessage message = InfluencerChatMessage(
      id: 'local-${now.microsecondsSinceEpoch}',
      threadId: _threads[index].id,
      text: text,
      sentAt: now,
      isMine: true,
      type: type,
      fileName: fileName,
      filePath: filePath,
      fileSizeLabel: fileSizeLabel,
      voiceDuration: voiceDuration,
      voiceFilePath: voiceFilePath,
    );
    _threads[index] = _threads[index].copyWith(
      messages: <InfluencerChatMessage>[..._threads[index].messages, message],
      updatedAt: now,
      unreadCount: 0,
      isTyping: false,
    );
    return message;
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) {
      return '0 KB';
    }
    final double kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    }
    final double mb = kb / 1024;
    return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
  }

  List<InfluencerChatThread> get _sortedThreads {
    final List<InfluencerChatThread> copy = List<InfluencerChatThread>.from(
      _threads,
    );
    copy.sort(
      (InfluencerChatThread a, InfluencerChatThread b) =>
          b.updatedAt.compareTo(a.updatedAt),
    );
    return copy;
  }

  static final DateTime _baseTime = DateTime(2026, 4, 30, 20, 56);

  static final List<InfluencerChatThread>
  _sampleThreads = <InfluencerChatThread>[
    InfluencerChatThread(
      id: 'order-1',
      orderId: 'order-1',
      participant: const InfluencerChatParticipant(
        id: 'client-morni',
        name: 'Morni',
        subtitle: 'Danette Creme Caramel',
        avatarUrl:
            'https://images.unsplash.com/photo-1512316609839-ce289d3eba0a?w=200&h=200&fit=crop',
      ),
      updatedAt: _baseTime,
      unreadCount: 2,
      messages: <InfluencerChatMessage>[
        InfluencerChatMessage(
          id: 'msg-1',
          threadId: 'order-1',
          text: "Alex, let's meet this weekend. I'll check with Dave too",
          sentAt: DateTime(2026, 4, 30, 20, 27),
          isMine: false,
        ),
        InfluencerChatMessage(
          id: 'msg-2',
          threadId: 'order-1',
          text: "Sure. Let's aim for saturday",
          sentAt: DateTime(2026, 4, 30, 20, 45),
          isMine: true,
        ),
        InfluencerChatMessage(
          id: 'msg-3',
          threadId: 'order-1',
          text: "I'm visiting mom this sunday",
          sentAt: _baseTime,
          isMine: true,
        ),
      ],
    ),
    InfluencerChatThread(
      id: 'order-2',
      orderId: 'order-2',
      participant: const InfluencerChatParticipant(
        id: 'client-caftan-slm',
        name: 'Caftan SLM',
        subtitle: 'Ramon is typing...',
        avatarUrl:
            'https://images.unsplash.com/photo-1521335629791-ce4aec67dd53?w=200&h=200&fit=crop',
      ),
      updatedAt: DateTime(2026, 4, 30, 20, 49),
      unreadCount: 1,
      isTyping: true,
      messages: <InfluencerChatMessage>[
        InfluencerChatMessage(
          id: 'msg-4',
          threadId: 'order-2',
          text: 'Hi, nice to meet you. How can I help?',
          sentAt: DateTime(2026, 4, 30, 20, 49),
          isMine: false,
        ),
      ],
    ),
    InfluencerChatThread(
      id: 'order-3',
      orderId: 'order-3',
      participant: const InfluencerChatParticipant(
        id: 'client-caftan-media',
        name: 'Caftan SLM',
        subtitle: 'Campaign brief',
        avatarUrl:
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=200&h=200&fit=crop',
      ),
      updatedAt: DateTime(2026, 4, 30, 20, 46),
      messages: <InfluencerChatMessage>[
        InfluencerChatMessage(
          id: 'msg-5',
          threadId: 'order-3',
          text: 'Hi, nice to meet you. How can I help?',
          sentAt: DateTime(2026, 4, 30, 20, 46),
          isMine: false,
        ),
      ],
    ),
  ];

  static final List<InfluencerChatThread> _sharedThreads =
      List<InfluencerChatThread>.from(_sampleThreads);
}

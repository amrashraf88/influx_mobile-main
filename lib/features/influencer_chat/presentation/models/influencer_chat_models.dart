import 'package:equatable/equatable.dart';

enum InfluencerChatMessageType { text, file, voice }

enum InfluencerChatCallType { voice, video }

class InfluencerChatParticipant extends Equatable {
  const InfluencerChatParticipant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.subtitle,
  });

  final String id;
  final String name;
  final String avatarUrl;
  final String? subtitle;

  @override
  List<Object?> get props => <Object?>[id, name, avatarUrl, subtitle];
}

class InfluencerChatMessage extends Equatable {
  const InfluencerChatMessage({
    required this.id,
    required this.threadId,
    required this.text,
    required this.sentAt,
    required this.isMine,
    this.type = InfluencerChatMessageType.text,
    this.fileName,
    this.filePath,
    this.fileSizeLabel,
    this.voiceDuration,
    this.voiceFilePath,
  });

  final String id;
  final String threadId;
  final String text;
  final DateTime sentAt;
  final bool isMine;
  final InfluencerChatMessageType type;
  final String? fileName;
  final String? filePath;
  final String? fileSizeLabel;
  final Duration? voiceDuration;
  final String? voiceFilePath;

  @override
  List<Object?> get props => <Object?>[
    id,
    threadId,
    text,
    sentAt,
    isMine,
    type,
    fileName,
    filePath,
    fileSizeLabel,
    voiceDuration,
    voiceFilePath,
  ];
}

class InfluencerChatThread extends Equatable {
  const InfluencerChatThread({
    required this.id,
    required this.participant,
    required this.messages,
    required this.updatedAt,
    this.orderId,
    this.unreadCount = 0,
    this.isTyping = false,
  });

  final String id;
  final String? orderId;
  final InfluencerChatParticipant participant;
  final List<InfluencerChatMessage> messages;
  final DateTime updatedAt;
  final int unreadCount;
  final bool isTyping;

  InfluencerChatMessage? get lastMessage {
    if (messages.isEmpty) {
      return null;
    }
    return messages.last;
  }

  InfluencerChatThread copyWith({
    List<InfluencerChatMessage>? messages,
    DateTime? updatedAt,
    int? unreadCount,
    bool? isTyping,
  }) {
    return InfluencerChatThread(
      id: id,
      orderId: orderId,
      participant: participant,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
      unreadCount: unreadCount ?? this.unreadCount,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    orderId,
    participant,
    messages,
    updatedAt,
    unreadCount,
    isTyping,
  ];
}

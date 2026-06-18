import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_media.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/influencer_chat/data/influencer_chat_repository.dart';
import 'package:adzmavall/features/influencer_chat/presentation/models/influencer_chat_models.dart';
import 'package:dio/dio.dart';

/// Which side of the chat API to call. Brands and content creators share the
/// same UI but hit different endpoint trees (`/brand/chats` vs
/// `/influencer/chats`).
enum ChatApiScope { influencer, brand }

/// Live implementation of [InfluencerChatRepository] backed by the chat
/// endpoints — `/influencer/chats` for creators, `/brand/chats` for brands.
///
/// Threads and messages are parsed defensively. When the API returns nothing
/// usable, the repository falls back to [InfluencerChatMockRepository] so the
/// chat screens keep rendering until the backend is fully populated.
class InfluencerChatApiRepository implements InfluencerChatRepository {
  InfluencerChatApiRepository(
    this._dio, {
    this.scope = ChatApiScope.influencer,
  }) : _fallback = InfluencerChatMockRepository();

  final Dio _dio;
  final ChatApiScope scope;
  final InfluencerChatMockRepository _fallback;

  bool get _isBrand => scope == ChatApiScope.brand;

  String get _listPath =>
      _isBrand ? ApiEndpoints.brandChatsPath : ApiEndpoints.influencerChatsPath;

  String _detailPath(String id) =>
      _isBrand ? ApiEndpoints.brandChatPath(id) : ApiEndpoints.influencerChatPath(id);

  String _messagesPath(String id) => _isBrand
      ? ApiEndpoints.brandChatMessagesPath(id)
      : ApiEndpoints.influencerChatMessagesPath(id);

  String _filesPath(String id) => _isBrand
      ? ApiEndpoints.brandChatFilesPath(id)
      : ApiEndpoints.influencerChatFilesPath(id);

  String _voicePath(String id) => _isBrand
      ? ApiEndpoints.brandChatVoicePath(id)
      : ApiEndpoints.influencerChatVoicePath(id);

  String _callPath(String id) => _isBrand
      ? ApiEndpoints.brandChatCallPath(id)
      : ApiEndpoints.influencerChatCallPath(id);

  @override
  Future<List<InfluencerChatThread>> fetchThreads() async {
    try {
      final String url = ApiUrlResolver.resolve(_listPath);
      final Response<dynamic> res = await _dio.get<dynamic>(url);
      final List<InfluencerChatThread> threads = _extractList(res.data)
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> e) =>
                _threadFromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      if (threads.isNotEmpty) {
        return threads;
      }
    } on Object {
      // Fall through to sample data.
    }
    return _fallback.fetchThreads();
  }

  @override
  Future<InfluencerChatThread?> fetchThread(String threadId) async {
    try {
      final String url = ApiUrlResolver.resolve(_detailPath(threadId));
      final Response<dynamic> res = await _dio.get<dynamic>(url);
      final Map<String, dynamic>? map = _extractMap(res.data);
      if (map != null && map.isNotEmpty) {
        return _threadFromJson(map);
      }
    } on Object {
      // Fall through to sample data.
    }
    return _fallback.fetchThread(threadId);
  }

  @override
  Future<InfluencerChatMessage> sendMessage({
    required String threadId,
    required String text,
  }) async {
    try {
      final String url = ApiUrlResolver.resolve(_messagesPath(threadId));
      await _dio.post<dynamic>(url, data: <String, dynamic>{'body': text});
    } on Object {
      // Optimistic message returned below regardless.
    }
    return _localMessage(threadId: threadId, text: text);
  }

  @override
  Future<InfluencerChatMessage> sendFile({
    required String threadId,
    required String fileName,
    required String? filePath,
    required int fileSize,
  }) async {
    try {
      final String url = ApiUrlResolver.resolve(_filesPath(threadId));
      await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{'file_name': fileName, 'size': fileSize},
      );
    } on Object {
      // Optimistic message below.
    }
    return _localMessage(
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
    try {
      final String url = ApiUrlResolver.resolve(_voicePath(threadId));
      await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{'duration': duration.inSeconds},
      );
    } on Object {
      // Optimistic message below.
    }
    return _localMessage(
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
    try {
      final String url = ApiUrlResolver.resolve(_callPath(threadId));
      await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{
          'type': type == InfluencerChatCallType.video ? 'video' : 'voice',
        },
      );
    } on Object {
      // Calling is best-effort; ignore failures here.
    }
  }

  // ---------------------------------------------------------------------------
  // Parsing helpers
  // ---------------------------------------------------------------------------

  static InfluencerChatMessage _localMessage({
    required String threadId,
    required String text,
    InfluencerChatMessageType type = InfluencerChatMessageType.text,
    String? fileName,
    String? filePath,
    String? fileSizeLabel,
    Duration? voiceDuration,
    String? voiceFilePath,
  }) {
    final DateTime now = DateTime.now();
    return InfluencerChatMessage(
      id: 'local-${now.microsecondsSinceEpoch}',
      threadId: threadId,
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
  }

  static InfluencerChatThread _threadFromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final String id = pick(<String>['id', 'uuid', 'chat_id']);
    final Object? participantRaw =
        json['participant'] ?? json['user'] ?? json['contact'] ?? json['brand'];
    final InfluencerChatParticipant participant = participantRaw is Map
        ? _participantFromJson(Map<String, dynamic>.from(participantRaw))
        : InfluencerChatParticipant(
            id: id,
            name: pick(<String>['name', 'title', 'participant_name']),
            avatarUrl: ApiMedia.resolve(
              pick(<String>['avatar_url', 'image_url', 'logo']),
            ),
            subtitle: pick(<String>['subtitle', 'last_message']),
          );

    final Object? messagesRaw = json['messages'] ?? json['items'];
    final List<InfluencerChatMessage> messages = messagesRaw is List
        ? messagesRaw
              .whereType<Map<dynamic, dynamic>>()
              .map(
                (Map<dynamic, dynamic> e) =>
                    _messageFromJson(Map<String, dynamic>.from(e), id),
              )
              .toList()
        : <InfluencerChatMessage>[];

    final int unread = int.tryParse(
          pick(<String>['unread_count', 'unread', 'unreadCount']),
        ) ??
        0;

    return InfluencerChatThread(
      id: id.isEmpty ? 'chat' : id,
      orderId: pick(<String>['order_id', 'campaign_request_id']),
      participant: participant,
      messages: messages,
      updatedAt: _parseDate(pick(<String>['updated_at', 'last_message_at'])),
      unreadCount: unread,
    );
  }

  static InfluencerChatParticipant _participantFromJson(
    Map<String, dynamic> json,
  ) {
    String pick(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    return InfluencerChatParticipant(
      id: pick(<String>['id', 'uuid']),
      name: pick(<String>['name', 'full_name', 'company_name', 'display_name']),
      avatarUrl: ApiMedia.resolve(
        pick(<String>['avatar_url', 'image_url', 'logo', 'photo']),
      ),
      subtitle: pick(<String>['subtitle', 'title', 'campaign']),
    );
  }

  static InfluencerChatMessage _messageFromJson(
    Map<String, dynamic> json,
    String threadId,
  ) {
    String pick(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final Object? mineRaw =
        json['is_mine'] ?? json['mine'] ?? json['is_sender'];
    final bool isMine = mineRaw is bool
        ? mineRaw
        : mineRaw?.toString().toLowerCase() == 'true';

    return InfluencerChatMessage(
      id: pick(<String>['id', 'uuid']),
      threadId: threadId,
      text: pick(<String>['body', 'text', 'message', 'content']),
      sentAt: _parseDate(pick(<String>['created_at', 'sent_at', 'date'])),
      isMine: isMine,
    );
  }

  static DateTime _parseDate(String raw) {
    if (raw.isEmpty) {
      return DateTime.now();
    }
    return DateTime.tryParse(raw) ?? DateTime.now();
  }

  static String _formatFileSize(int bytes) {
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

  static List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      for (final String key in <String>[
        'data',
        'results',
        'items',
        'chats',
        'threads',
      ]) {
        final Object? v = map[key];
        if (v is List<dynamic>) {
          return v;
        }
      }
    }
    return const <dynamic>[];
  }

  static Map<String, dynamic>? _extractMap(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner = map['data'] ?? map['result'] ?? map['chat'];
      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }
      return map;
    }
    return null;
  }
}

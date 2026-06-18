import 'package:adzmavall/core/lookup/lookup_item.dart';

class LookupPageResult {
  const LookupPageResult({
    required this.items,
    required this.currentPage,
    required this.hasMore,
    this.lastPage,
    this.nextPage,
  });

  final List<LookupItem> items;
  final int currentPage;
  final bool hasMore;
  final int? lastPage;
  final int? nextPage;
}

abstract final class LookupPageParser {
  static LookupPageResult parse(
    dynamic data, {
    List<String> listKeys = const <String>[
      'data',
      'categories',
      'results',
      'items',
    ],
  }) {
    if (data is! Map) {
      return const LookupPageResult(
        items: <LookupItem>[],
        currentPage: 1,
        hasMore: false,
      );
    }

    final Map<String, dynamic> root = Map<String, dynamic>.from(data);
    final Map<String, dynamic> scope = _paginationScope(root);
    final List<dynamic> raw = _extractList(scope, listKeys);
    final List<LookupItem> items = raw
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> e) =>
              LookupItem.fromJson(Map<String, dynamic>.from(e)),
        )
        .where((LookupItem item) => item.value.isNotEmpty && item.label.isNotEmpty)
        .toList();

    final int currentPage = _readInt(scope['current_page']) ??
        _readInt(_meta(scope)['current_page']) ??
        1;
    final int? lastPage = _readInt(scope['last_page']) ??
        _readInt(_meta(scope)['last_page']);
    final bool hasMore = _resolveHasMore(scope, currentPage: currentPage, lastPage: lastPage);
    final int? nextPage = hasMore
        ? (_readInt(scope['next_page']) ??
              _readInt(_meta(scope)['next_page']) ??
              currentPage + 1)
        : null;

    return LookupPageResult(
      items: items,
      currentPage: currentPage,
      hasMore: hasMore,
      lastPage: lastPage,
      nextPage: nextPage,
    );
  }

  static Map<String, dynamic> _paginationScope(Map<String, dynamic> root) {
    final Object? data = root['data'];
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      if (_containsList(map, const <String>['data', 'categories', 'items']) ||
          map.containsKey('current_page') ||
          map.containsKey('meta') ||
          map.containsKey('links')) {
        return map;
      }
    }
    return root;
  }

  static bool _containsList(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      if (map[key] is List) {
        return true;
      }
    }
    return false;
  }

  static List<dynamic> _extractList(
    Map<String, dynamic> scope,
    List<String> listKeys,
  ) {
    for (final String key in listKeys) {
      final Object? value = scope[key];
      if (value is List<dynamic>) {
        return value;
      }
    }
    return const <dynamic>[];
  }

  static Map<String, dynamic> _meta(Map<String, dynamic> scope) {
    final Object? meta = scope['meta'];
    if (meta is Map) {
      return Map<String, dynamic>.from(meta);
    }
    return const <String, dynamic>{};
  }

  static Map<String, dynamic> _links(Map<String, dynamic> scope) {
    final Object? links = scope['links'];
    if (links is Map) {
      return Map<String, dynamic>.from(links);
    }
    return const <String, dynamic>{};
  }

  static bool _resolveHasMore(
    Map<String, dynamic> scope, {
    required int currentPage,
    required int? lastPage,
  }) {
    final Object? hasMore = scope['has_more'] ?? _meta(scope)['has_more'];
    if (hasMore is bool) {
      return hasMore;
    }

    final String? nextPageUrl = scope['next_page_url']?.toString();
    if (nextPageUrl != null && nextPageUrl.trim().isNotEmpty) {
      return true;
    }

    final Object? nextLink = _links(scope)['next'];
    if (nextLink != null && nextLink.toString().trim().isNotEmpty) {
      return true;
    }

    if (lastPage != null) {
      return currentPage < lastPage;
    }

    return false;
  }

  static int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}

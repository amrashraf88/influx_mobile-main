/// Normalizes list payloads from typical REST wrappers.
abstract final class HomeApiResponse {
  static List<dynamic> listFrom(
    dynamic data, {
    List<String> mapKeys = const <String>['data', 'results', 'items'],
  }) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      for (final String key in mapKeys) {
        final Object? v = map[key];
        if (v is List<dynamic>) {
          return v;
        }
      }
    }
    return const <dynamic>[];
  }
}

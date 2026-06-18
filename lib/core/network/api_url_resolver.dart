import 'package:adzmavall/core/config/api_endpoints.dart';

/// Builds absolute URLs from [ApiEndpoints] paths and [ApiEndpoints.baseUrl].
abstract final class ApiUrlResolver {
  static bool get isConfigured => _baseUrl.isNotEmpty;

  static String get configureHint =>
      'Set API_BASE_URL (e.g. flutter run --dart-define=API_BASE_URL=${ApiEndpoints.defaultBaseUrl})';

  static String get _baseUrl => ApiEndpoints.baseUrl.trim();

  static String resolve(String path) {
    if (!isConfigured) {
      throw ArgumentError(configureHint);
    }
    return path.startsWith('/') ? '$_baseUrl$path' : '$_baseUrl/$path';
  }
}

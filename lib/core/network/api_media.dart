import 'package:adzmavall/core/config/api_endpoints.dart';

/// Normalizes image/media URLs coming from the API.
///
/// The backend often returns relative paths (e.g. `/storage/x.jpg`) or empty
/// values. Passing those straight to `CachedNetworkImage` throws
/// `Invalid argument(s): No host specified in URI`. This helper turns a raw
/// value into either an absolute `http(s)` URL or an empty string (so image
/// widgets fall back to their placeholder).
abstract final class ApiMedia {
  /// Returns an absolute URL, or `''` when the value is empty/unusable.
  static String resolve(Object? raw) {
    final String s = raw?.toString().trim() ?? '';
    if (s.isEmpty) {
      return '';
    }

    final Uri? uri = Uri.tryParse(s);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return s; // Already absolute (http/https/...).
    }

    // Treat anything else as a path relative to the API origin.
    final String base = ApiEndpoints.baseUrl.trim();
    if (base.isEmpty) {
      return '';
    }
    final String origin = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    return s.startsWith('/') ? '$origin$s' : '$origin/$s';
  }
}

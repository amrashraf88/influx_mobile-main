import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart' show ApiException;
import 'package:dio/dio.dart';

/// Aggregates everything the creator profile screen needs from the live API:
/// the profile itself plus the linked social accounts, clients and ads.
///
/// Each list endpoint is fetched independently and failures are swallowed
/// (returning an empty list) so one slow/broken endpoint never blanks the whole
/// screen — the presentation layer falls back to static sample data when a
/// section comes back empty.
class CreatorProfileRepository {
  CreatorProfileRepository(this._dio);

  final Dio _dio;

  /// Loads the profile and its related collections concurrently.
  Future<CreatorProfileBundle> fetchAll() async {
    final List<dynamic> results = await Future.wait(<Future<dynamic>>[
      _fetchMap(ApiEndpoints.authUserProfileContentCreatorPath),
      _fetchList(ApiEndpoints.authUserSocialAccountsPath),
      _fetchList(ApiEndpoints.authUserClientsPath),
      _fetchList(ApiEndpoints.authUserAdsPath),
    ]);

    return CreatorProfileBundle(
      profile: results[0] as Map<String, dynamic>,
      socialAccounts: results[1] as List<Map<String, dynamic>>,
      clients: results[2] as List<Map<String, dynamic>>,
      ads: results[3] as List<Map<String, dynamic>>,
    );
  }

  Future<Map<String, dynamic>> _fetchMap(String path) async {
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(
        ApiUrlResolver.resolve(path),
      );
      return _unwrapMap(res.data);
    } on Object {
      return <String, dynamic>{};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchList(String path) async {
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(
        ApiUrlResolver.resolve(path),
      );
      return _unwrapList(res.data);
    } on Object {
      return const <Map<String, dynamic>>[];
    }
  }

  // ---------------------------------------------------------------------------
  // Writes — each throws [ApiException] with a human message on failure so the
  // caller can surface it in a snackbar.
  // ---------------------------------------------------------------------------

  /// `PATCH /auth/user/profile/content-creator` — update profile fields
  /// (used by the Overview / Ad Price edit forms).
  Future<void> updateProfile(Map<String, dynamic> body) =>
      _write(() => _dio.patch<dynamic>(
            ApiUrlResolver.resolve(
              ApiEndpoints.authUserProfileContentCreatorPath,
            ),
            data: body,
          ));

  /// `POST /auth/user/social-accounts` — add a linked social account.
  Future<void> createSocialAccount(Map<String, dynamic> body) =>
      _write(() => _dio.post<dynamic>(
            ApiUrlResolver.resolve(ApiEndpoints.authUserSocialAccountsPath),
            data: body,
          ));

  /// `PATCH /auth/user/social-accounts/{id}` — update a linked account
  /// (e.g. its ad `prices`).
  Future<void> updateSocialAccount(String id, Map<String, dynamic> body) =>
      _write(() => _dio.patch<dynamic>(
            ApiUrlResolver.resolve(ApiEndpoints.authUserSocialAccountPath(id)),
            data: body,
          ));

  /// `DELETE /auth/user/social-accounts/{id}`.
  Future<void> deleteSocialAccount(String id) =>
      _write(() => _dio.delete<dynamic>(
            ApiUrlResolver.resolve(ApiEndpoints.authUserSocialAccountPath(id)),
          ));

  /// `POST /auth/user/clients` — add a client.
  Future<void> createClient(Map<String, dynamic> body) =>
      _write(() => _dio.post<dynamic>(
            ApiUrlResolver.resolve(ApiEndpoints.authUserClientsPath),
            data: body,
          ));

  /// `DELETE /auth/user/clients/{id}`.
  Future<void> deleteClient(String id) =>
      _write(() => _dio.delete<dynamic>(
            ApiUrlResolver.resolve(ApiEndpoints.authUserClientPath(id)),
          ));

  /// `POST /auth/user/ads` — add an ad / portfolio item.
  Future<void> createAd(Map<String, dynamic> body) =>
      _write(() => _dio.post<dynamic>(
            ApiUrlResolver.resolve(ApiEndpoints.authUserAdsPath),
            data: body,
          ));

  /// `DELETE /auth/user/ads/{id}`.
  Future<void> deleteAd(String id) =>
      _write(() => _dio.delete<dynamic>(
            ApiUrlResolver.resolve(ApiEndpoints.authUserAdPath(id)),
          ));

  Future<void> _write(Future<Response<dynamic>> Function() request) async {
    try {
      await request();
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  static Map<String, dynamic> _unwrapMap(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner = map['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return map;
    }
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _unwrapList(dynamic data) {
    List<dynamic>? list;
    if (data is List) {
      list = data;
    } else if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      for (final String key in <String>[
        'data',
        'results',
        'items',
        'records',
      ]) {
        final Object? v = map[key];
        if (v is List) {
          list = v;
          break;
        }
        // Some APIs nest the list one level deeper, e.g. { data: { items: [] } }.
        if (v is Map) {
          final Map<String, dynamic> inner = Map<String, dynamic>.from(v);
          for (final String innerKey in <String>['items', 'results', 'data']) {
            final Object? innerV = inner[innerKey];
            if (innerV is List) {
              list = innerV;
              break;
            }
          }
        }
        if (list != null) break;
      }
    }
    return (list ?? const <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) => Map<String, dynamic>.from(e))
        .toList();
  }
}

/// Immutable container for everything the profile screen loads in one pass.
class CreatorProfileBundle {
  const CreatorProfileBundle({
    required this.profile,
    required this.socialAccounts,
    required this.clients,
    required this.ads,
  });

  const CreatorProfileBundle.empty()
    : profile = const <String, dynamic>{},
      socialAccounts = const <Map<String, dynamic>>[],
      clients = const <Map<String, dynamic>>[],
      ads = const <Map<String, dynamic>>[];

  final Map<String, dynamic> profile;
  final List<Map<String, dynamic>> socialAccounts;
  final List<Map<String, dynamic>> clients;
  final List<Map<String, dynamic>> ads;
}

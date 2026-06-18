import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:dio/dio.dart';

/// Loads top influencers for the home horizontal list.
///
/// Expected JSON shapes (any of):
/// - `[ {...}, {...} ]`
/// - `{ "data": [ ... ] }` / `results` / `influencers` / `items`
///
/// Each object is mapped with flexible keys — see [HomeInfluencerModel.fromJson].
class TopInfluencersRepository {
  TopInfluencersRepository(this._dio);

  final Dio _dio;

  Future<List<HomeInfluencerModel>> fetchTopInfluencers() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.topInfluencersPath),
    );
    final List<dynamic> raw = _extractList(response.data);
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) => HomeInfluencerModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      for (final String key in <String>['data', 'results', 'influencers', 'items']) {
        final Object? v = map[key];
        if (v is List<dynamic>) {
          return v;
        }
      }
    }
    return const <dynamic>[];
  }
}

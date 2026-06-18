import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:dio/dio.dart';

/// Loads trending stories used under the Trending section on Home.
class TopStoriesRepository {
  TopStoriesRepository(this._dio);

  final Dio _dio;

  Future<List<HomeStoryModel>> fetchTopStories() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.topStoriesPath),
    );
    final List<dynamic> raw = _extractList(response.data);
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) => HomeStoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      for (final String key in <String>['data', 'results', 'stories', 'items']) {
        final Object? v = map[key];
        if (v is List<dynamic>) {
          return v;
        }
      }
    }
    return const <dynamic>[];
  }
}

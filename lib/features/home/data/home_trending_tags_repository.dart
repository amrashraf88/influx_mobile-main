import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/home/data/home_api_response.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:dio/dio.dart';

/// Loads trending topic chips above the stories row.
///
/// Accepts `[ "Fashion", "Tech" ]`, `[ { "label": "Fashion" } ], or wrapped lists.
class HomeTrendingTagsRepository {
  HomeTrendingTagsRepository(this._dio);

  final Dio _dio;

  Future<List<HomeTrendingTagModel>> fetchTrendingTags() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.homeTrendingTagsPath),
    );
    final List<dynamic> raw = HomeApiResponse.listFrom(
      response.data,
      mapKeys: const <String>['data', 'results', 'tags', 'items', 'topics'],
    );
    final List<HomeTrendingTagModel> out = <HomeTrendingTagModel>[];
    for (final dynamic e in raw) {
      if (e is String) {
        final String t = e.trim();
        if (t.isEmpty) {
          continue;
        }
        final String noHash = t.startsWith('#') ? t.substring(1) : t;
        out.add(HomeTrendingTagModel(apiLabel: noHash));
      } else if (e is Map) {
        out.add(HomeTrendingTagModel.fromJson(Map<String, dynamic>.from(e)));
      }
    }
    return out;
  }
}

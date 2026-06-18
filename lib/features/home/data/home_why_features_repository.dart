import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/home/data/home_api_response.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:dio/dio.dart';

/// Optional “Why Adz” rows from the backend (copy, optional remote icons).
class HomeWhyFeaturesRepository {
  HomeWhyFeaturesRepository(this._dio);

  final Dio _dio;

  Future<List<HomeWhyFeatureModel>> fetchWhyFeatures() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.homeWhyFeaturesPath),
    );
    final List<dynamic> raw = HomeApiResponse.listFrom(
      response.data,
      mapKeys: const <String>['data', 'results', 'features', 'items', 'rows'],
    );
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) => HomeWhyFeatureModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

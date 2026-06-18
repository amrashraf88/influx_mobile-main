import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/home/data/home_api_response.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:dio/dio.dart';

/// Loads category tiles for the home horizontal list.
///
/// JSON: `[ {...} ]` or `{ "data": [ ... ] }` (also `categories`, `results`, `items`).
class HomeCategoriesRepository {
  HomeCategoriesRepository(this._dio);

  final Dio _dio;

  Future<List<HomeCategoryModel>> fetchCategories() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.homeCategoriesPath),
    );
    final List<dynamic> raw = HomeApiResponse.listFrom(
      response.data,
      mapKeys: const <String>['data', 'results', 'categories', 'items'],
    );
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> e) => HomeCategoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

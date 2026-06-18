import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:dio/dio.dart';

/// Optional JSON object for the blue welcome card on Home.
class HomeWelcomeRepository {
  HomeWelcomeRepository(this._dio);

  final Dio _dio;

  Future<HomeWelcomeCardContent?> fetchWelcomeContent() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.homeWelcomePath),
    );
    final Object? data = response.data;
    if (data is! Map) {
      return null;
    }
    return HomeWelcomeCardContent.fromJson(Map<String, dynamic>.from(data));
  }
}

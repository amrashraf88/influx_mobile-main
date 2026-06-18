import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/company_home/presentation/models/company_home_models.dart';
import 'package:dio/dio.dart';

/// Loads data for the registered company home page.
///
/// Each method throws when [ApiUrlResolver.isConfigured] is false so the page can
/// fall back to [CompanyHomeViewData] until the backend is ready.
class CompanyHomeRepository {
  CompanyHomeRepository(this._dio);

  final Dio _dio;

  Future<CompanyHomeSummary> fetchSummary() async {
    final Map<String, dynamic> raw = await _getMap(
      ApiEndpoints.companyHomeSummaryPath,
    );
    return CompanyHomeSummary.fromJson(raw);
  }

  Future<List<CompanyHomeCampaign>> fetchCurrentCampaigns() async {
    final List<dynamic> raw = await _getList(
      ApiEndpoints.companyCurrentCampaignsPath,
    );
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> e) =>
              CompanyHomeCampaign.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<List<CompanyHomeCategory>> fetchCategories() async {
    final List<dynamic> raw = await _getList(
      ApiEndpoints.companyHomeCategoriesPath,
    );
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> e) =>
              CompanyHomeCategory.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<List<CompanyHomeInfluencer>> fetchInfluencers() async {
    final List<dynamic> raw = await _getList(
      ApiEndpoints.companyHomeInfluencersPath,
    );
    return raw
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> e) =>
              CompanyHomeInfluencer.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  Future<Map<String, dynamic>> _getMap(String path) async {
    final String url = ApiUrlResolver.resolve(path);
    final Response<dynamic> response = await _dio.get<dynamic>(url);
    final dynamic data = response.data;
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner = map['data'] ?? map['result'] ?? map['payload'];
      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }
      return map;
    }
    return <String, dynamic>{};
  }

  Future<List<dynamic>> _getList(String path) async {
    final String url = ApiUrlResolver.resolve(path);
    final Response<dynamic> response = await _dio.get<dynamic>(url);
    return _extractList(response.data);
  }

  static List<dynamic> _extractList(dynamic data) {
    if (data is List<dynamic>) {
      return data;
    }
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      for (final String key in <String>[
        'data',
        'results',
        'items',
        'campaigns',
        'categories',
        'influencers',
      ]) {
        final Object? v = map[key];
        if (v is List<dynamic>) {
          return v;
        }
      }
    }
    return const <dynamic>[];
  }
}

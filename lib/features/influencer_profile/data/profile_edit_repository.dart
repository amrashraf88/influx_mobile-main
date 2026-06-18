import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart' show ApiException;
import 'package:dio/dio.dart';

/// Loads and updates the authenticated content creator's profile
/// (`/auth/user/profile/content-creator`).
class ProfileEditRepository {
  ProfileEditRepository(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> fetchProfile() async {
    final String url = ApiUrlResolver.resolve(
      ApiEndpoints.authUserProfileContentCreatorPath,
    );
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(url);
      return _unwrap(res.data);
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    final String url = ApiUrlResolver.resolve(
      ApiEndpoints.authUserProfileContentCreatorPath,
    );
    try {
      final Response<dynamic> res = await _dio.patch<dynamic>(url, data: body);
      return _unwrap(res.data);
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  static Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner = map['data'];
      if (inner is Map) return Map<String, dynamic>.from(inner);
      return map;
    }
    return <String, dynamic>{};
  }
}

import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:dio/dio.dart';

/// Optional search placeholder text from the backend.
class HomeSearchHintRepository {
  HomeSearchHintRepository(this._dio);

  final Dio _dio;

  Future<String?> fetchSearchHint() async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.homeSearchHintPath),
    );
    final Object? data = response.data;
    if (data is! Map) {
      return null;
    }
    final Map<String, dynamic> map = Map<String, dynamic>.from(data);
    Map<String, dynamic> inner = map;
    final Object? wrapped = map['data'] ?? map['payload'] ?? map['search'];
    if (wrapped is Map) {
      inner = Map<String, dynamic>.from(wrapped);
    }
    final String? hint = _pickFromMap(inner, <String>[
      'hint',
      'placeholder',
      'search_hint',
      'searchHint',
      'query_placeholder',
      'queryPlaceholder',
      'text',
    ]);
    if (hint == null || hint.trim().isEmpty) {
      return null;
    }
    return hint.trim();
  }
}

String? _pickFromMap(Map<String, dynamic> map, List<String> keys) {
  for (final String k in keys) {
    final Object? v = map[k];
    if (v != null && v.toString().trim().isNotEmpty) {
      return v.toString();
    }
  }
  return null;
}

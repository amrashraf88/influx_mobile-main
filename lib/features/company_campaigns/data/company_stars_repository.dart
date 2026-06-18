import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_media.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/company_campaigns/data/company_stars_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_star_models.dart';
import 'package:dio/dio.dart';

/// Loads the "Stars" directory (content creators a brand can hire) from
/// `GET /brand/content-creators`.
///
/// Parsing tolerates backend key drift; callers fall back to
/// [CompanyStarsViewData] when the list is empty or the call fails.
class CompanyStarsRepository {
  CompanyStarsRepository(this._dio);

  final Dio _dio;

  Future<List<CompanyStarListItem>> fetchStars() async {
    final String url = ApiUrlResolver.resolve(
      ApiEndpoints.brandContentCreatorsPath,
    );
    final Response<dynamic> res = await _dio.get<dynamic>(url);
    return _extractList(res.data)
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> e) =>
              CompanyStarListItem.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  /// Fetches one creator's profile via `GET /brand/content-creators/{id}`.
  /// Missing fields keep the [CompanyStarsViewData.profileFor] values.
  Future<CompanyStarProfile> fetchStarProfile(String id) async {
    final CompanyStarProfile base = CompanyStarsViewData.profileFor(id);
    final String url = ApiUrlResolver.resolve(
      ApiEndpoints.brandContentCreatorPath(id),
    );
    final Response<dynamic> res = await _dio.get<dynamic>(url);
    final Map<String, dynamic> json = _extractMap(res.data);
    if (json.isEmpty) {
      return base;
    }

    String pick(List<String> keys, String fallback) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return fallback;
    }

    return CompanyStarProfile(
      id: pick(<String>['id', 'uuid'], base.id),
      name: pick(<String>['name', 'full_name', 'display_name'], base.name),
      headline: pick(<String>[
        'headline',
        'title',
        'category',
        'niche',
      ], base.headline),
      bio: pick(<String>['bio', 'about', 'description'], base.bio),
      avatarUrl: ApiMedia.resolve(
        pick(<String>['avatar_url', 'image_url', 'photo'], base.avatarUrl),
      ),
      coverImageUrl: ApiMedia.resolve(
        pick(<String>['cover_image_url', 'cover', 'image'], base.coverImageUrl),
      ),
      mawthooqLabel: pick(<String>[
        'mawthooq_label',
        'maroof',
        'license_number',
      ], base.mawthooqLabel),
      adPrices: base.adPrices,
    );
  }

  static Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner =
          map['data'] ?? map['result'] ?? map['content_creator'];
      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }
      return map;
    }
    return <String, dynamic>{};
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
        'content_creators',
        'creators',
        'contentCreators',
      ]) {
        final Object? v = map[key];
        if (v is List<dynamic>) {
          return v;
        }
        if (v is Map) {
          final List<dynamic> nested = _extractList(v);
          if (nested.isNotEmpty) {
            return nested;
          }
        }
      }
    }
    return const <dynamic>[];
  }
}

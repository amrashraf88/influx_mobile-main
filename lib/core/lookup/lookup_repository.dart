import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/lookup/lookup_item.dart';
import 'package:adzmavall/core/lookup/lookup_page_result.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart';
import 'package:dio/dio.dart';

class LookupRepository {
  LookupRepository(this._dio);

  final Dio _dio;

  Future<LookupPageResult> fetchCategories({int page = 1}) => _fetchLookupPage(
    ApiEndpoints.lookupCategoriesPath,
    page: page,
    listKeys: const <String>['data', 'categories', 'results', 'items'],
  );

  Future<List<LookupItem>> fetchCities() => _fetchLookupList(
    ApiEndpoints.lookupCitiesPath,
    mapKeys: const <String>['data', 'cities', 'results', 'items'],
  );

  Future<List<LookupItem>> fetchCityDirections() => _fetchLookupList(
    ApiEndpoints.lookupCityDirectionsPath,
    mapKeys: const <String>[
      'data',
      'city_directions',
      'cityDirections',
      'directions',
      'results',
      'items',
    ],
  );

  Future<List<LookupItem>> fetchSocialPlatforms() => _fetchLookupList(
    ApiEndpoints.lookupSocialPlatformsPath,
    mapKeys: const <String>[
      'data',
      'social_platforms',
      'socialPlatforms',
      'platforms',
      'results',
      'items',
    ],
  );

  Future<List<LookupItem>> fetchContentCreatorTypes() => _fetchLookupList(
    ApiEndpoints.lookupContentCreatorTypesPath,
    mapKeys: const <String>[
      'data',
      'content_creator_types',
      'contentCreatorTypes',
      'creator_types',
      'creatorTypes',
      'results',
      'items',
    ],
  );

  Future<List<LookupItem>> fetchModelCreatorAccents() => _fetchLookupList(
    ApiEndpoints.lookupModelCreatorAccentsPath,
    mapKeys: const <String>[
      'data',
      'model_content_creator_accents',
      'modelContentCreatorAccents',
      'accents',
      'results',
      'items',
    ],
  );

  Future<List<LookupItem>> fetchModelCreatorSizes() => _fetchLookupList(
    ApiEndpoints.lookupModelCreatorSizesPath,
    mapKeys: const <String>[
      'data',
      'model_content_creator_sizes',
      'modelContentCreatorSizes',
      'sizes',
      'results',
      'items',
    ],
  );

  Future<List<LookupItem>> fetchModelCreatorSkinTones() => _fetchLookupList(
    ApiEndpoints.lookupModelCreatorSkinTonesPath,
    mapKeys: const <String>[
      'data',
      'model_content_creator_skin_tones',
      'modelContentCreatorSkinTones',
      'skin_tones',
      'skinTones',
      'results',
      'items',
    ],
  );

  Future<List<LookupItem>> fetchCompanies() => _fetchLookupList(
    ApiEndpoints.lookupCompaniesPath,
    mapKeys: const <String>['data', 'companies', 'results', 'items'],
  );

  Future<List<LookupItem>> fetchNotificationTypes() => _fetchLookupList(
    ApiEndpoints.lookupNotificationTypesPath,
    mapKeys: const <String>[
      'data',
      'notifications_types',
      'notificationTypes',
      'notification_types',
      'results',
      'items',
    ],
  );

  Future<List<LookupItem>> fetchUserStates() => _fetchLookupList(
    ApiEndpoints.lookupUserStatesPath,
    mapKeys: const <String>[
      'data',
      'user_states',
      'userStates',
      'states',
      'results',
      'items',
    ],
  );

  Future<List<LookupItem>> fetchAdContentTypes({
    required String socialPlatform,
  }) async {
    final LookupPageResult page = await _fetchLookupPage(
      ApiEndpoints.lookupAdContentTypesPath,
      page: 1,
      listKeys: const <String>[
        'data',
        'ad_content_types',
        'adContentTypes',
        'content_types',
        'contentTypes',
        'results',
        'items',
      ],
      queryParameters: <String, String>{
        'social_platform': socialPlatform.trim().toLowerCase(),
      },
    );
    return page.items;
  }

  Future<LookupPageResult> _fetchLookupPage(
    String path, {
    required int page,
    required List<String> listKeys,
    Map<String, String>? queryParameters,
  }) async {
    final String url = ApiUrlResolver.resolve(path);
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        url,
        queryParameters: <String, dynamic>{
          'page': page,
          if (queryParameters != null) ...queryParameters,
        },
      );
      return LookupPageParser.parse(
        response.data,
        listKeys: listKeys,
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  Future<List<LookupItem>> _fetchLookupList(
    String path, {
    required List<String> mapKeys,
  }) async {
    final LookupPageResult page = await _fetchLookupPage(
      path,
      page: 1,
      listKeys: mapKeys,
    );
    return page.items;
  }
}

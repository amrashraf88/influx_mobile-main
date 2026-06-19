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
    final List<CompanyStarListItem> stars = <CompanyStarListItem>[];
    final Set<String> seenIds = <String>{};
    String? nextUrl = url;
    int page = 1;

    for (int guard = 0; guard < 200 && nextUrl != null; guard += 1) {
      final Response<dynamic> res = await _dio.get<dynamic>(
        nextUrl,
        queryParameters: nextUrl == url
            ? <String, dynamic>{'page': page, 'per_page': 100}
            : null,
      );
      final _StarsPage pageResult = _StarsPage.fromResponse(res.data);
      for (final CompanyStarListItem star in pageResult.items) {
        final String key = star.id.isNotEmpty
            ? star.id
            : '${star.name}-${star.coverImageUrl}';
        if (seenIds.add(key)) {
          stars.add(star);
        }
      }

      nextUrl = pageResult.nextUrl;
      if (nextUrl == null && pageResult.nextPage != null) {
        page = pageResult.nextPage!;
        nextUrl = url;
      }
    }

    return stars;
  }

  /// Loads a single page of the stars directory for infinite scrolling.
  ///
  /// [perPage] defaults to 10; pass an optional [type] (e.g. `model`, `ugc`)
  /// to scope the page to one creator type, or leave it null for all types.
  Future<CompanyStarsPageResult> fetchStarsPage({
    required int page,
    int perPage = 10,
    String? type,
    String? search,
  }) async {
    final String url = ApiUrlResolver.resolve(
      ApiEndpoints.brandContentCreatorsPath,
    );
    final Map<String, dynamic> query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };

    final Response<dynamic> res = await _dio.get<dynamic>(
      url,
      queryParameters: query,
    );
    final _StarsPage pageResult = _StarsPage.fromResponse(res.data);

    // Trust pagination metadata when present; otherwise assume there is more
    // while the server keeps returning a full page.
    final bool hasMore =
        pageResult.nextUrl != null ||
        pageResult.nextPage != null ||
        pageResult.items.length >= perPage;

    return CompanyStarsPageResult(
      items: pageResult.items,
      hasMore: hasMore,
      page: page,
    );
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

    final List<Map<String, dynamic>> profileMaps = _nestedMaps(json);

    String pick(List<String> keys, String fallback) =>
        _pickFromMaps(profileMaps, keys, fallback);

    final List<CompanyStarAdPriceLine> adPrices = _parseAdPrices(json);
    final String creatorType = _creatorTypeFrom(
      pick(<String>['creator_type', 'creatorType', 'type', 'category'], ''),
    );

    return CompanyStarProfile(
      id: pick(<String>['id', 'uuid'], base.id),
      name: pick(<String>[
        'name',
        'full_name',
        'fullName',
        'display_name',
        'displayName',
        'username',
      ], base.name),
      headline: pick(<String>[
        'headline',
        'title',
        'category',
        'niche',
        'creator_type',
        'creatorType',
      ], base.headline),
      bio: pick(<String>['bio', 'about', 'description'], base.bio),
      avatarUrl: ApiMedia.resolve(
        pick(<String>[
          'avatar_url',
          'avatarUrl',
          'image_url',
          'imageUrl',
          'profile_image_url',
          'profileImageUrl',
          'photo',
          'image',
          'url',
          'path',
        ], base.avatarUrl),
      ),
      coverImageUrl: ApiMedia.resolve(
        pick(<String>[
          'cover_image_url',
          'coverImageUrl',
          'cover',
          'cover_image',
          'coverImage',
        ], base.coverImageUrl),
      ),
      mawthooqLabel: pick(<String>[
        'mawthooq_label',
        'mawthooqLabel',
        'mawthooq',
        'mawthooq_status',
        'mawthooqStatus',
        'maroof',
        'license_number',
        'licenseNumber',
      ], base.mawthooqLabel),
      adPrices: adPrices,
      creatorTypeValue: creatorType.isNotEmpty
          ? creatorType
          : base.creatorTypeValue,
      categories: _parseStringList(json, <String>[
        'categories',
        'tags',
        'keywords',
        'interests',
        'niches',
      ]),
      works: _parseWorks(json),
      rawProfile: json,
    );
  }

  static String _creatorTypeFrom(String raw) {
    final String value = raw.trim().toLowerCase();
    if (value.contains('ugc') || value.contains('user generated')) return 'ugc';
    if (value.contains('collage') || value.contains('college')) {
      return 'collage';
    }
    if (value.contains('model')) return 'model';
    if (value.contains('influencer')) return 'influencer';
    return value;
  }

  static List<String> _parseStringList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final List<String> values = <String>[];
    void add(Object? value) {
      if (value is List) {
        for (final Object? item in value) {
          add(item);
        }
        return;
      }
      final String text = _stringify(value).trim();
      if (text.isEmpty || text == 'null') {
        return;
      }
      for (final String part in text.split(RegExp(r'[,،\n|]'))) {
        final String clean = part.trim().replaceFirst(RegExp(r'^#+'), '');
        if (clean.isNotEmpty && !values.contains(clean)) {
          values.add(clean);
        }
      }
    }

    for (final Map<String, dynamic> map in _nestedMaps(json)) {
      for (final String key in keys) {
        add(map[key]);
      }
    }
    return values;
  }

  static List<CompanyStarWorkItem> _parseWorks(Map<String, dynamic> json) {
    final List<dynamic> rows = <dynamic>[
      ..._extractNamedLists(json, <String>[
        'works',
        'portfolio',
        'ads',
        'media',
        'gallery',
        'items',
      ]),
    ];
    final List<CompanyStarWorkItem> works = <CompanyStarWorkItem>[];
    for (final Object? row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(row);
      final String image = ApiMedia.resolve(
        _pickFromMaps(
          <Map<String, dynamic>>[map, ..._nestedMaps(map).skip(1)],
          <String>[
            'image_url',
            'imageUrl',
            'thumbnail_url',
            'thumbnailUrl',
            'cover_url',
            'coverUrl',
            'media_url',
            'mediaUrl',
            'image',
            'thumbnail',
            'cover',
            'url',
            'path',
          ],
        ),
      );
      if (image.isEmpty) {
        continue;
      }
      works.add(
        CompanyStarWorkItem(
          id: _pickFromMaps(
            <Map<String, dynamic>>[map],
            <String>['id', 'uuid'],
          ),
          title: _pickFromMaps(
            <Map<String, dynamic>>[map],
            <String>['title', 'name', 'label', 'caption'],
          ),
          imageUrl: image,
        ),
      );
    }
    return works;
  }

  static List<CompanyStarAdPriceLine> _parseAdPrices(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rows = <dynamic>[
      ..._extractNamedLists(json, <String>[
        'ad_prices',
        'adPrices',
        'prices',
        'platform_prices',
        'platformPrices',
        'social_prices',
        'socialPrices',
        'accounts',
        'social_accounts',
        'socialAccounts',
        'platforms',
      ]),
    ];

    return rows
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> row) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(row);
          final String platform = _pickFromMaps(
            <Map<String, dynamic>>[map, ..._nestedMaps(map).skip(1)],
            <String>[
              'platform',
              'platform_name',
              'platformName',
              'name',
              'label',
              'type',
              'social',
            ],
          );
          final String labelKey = _platformLabelKey(platform);
          final String followers = _pickFromMaps(
            <Map<String, dynamic>>[map, ..._nestedMaps(map).skip(1)],
            <String>[
              'followers',
              'followers_count',
              'followersCount',
              'followers_label',
              'followersLabel',
              'count',
              'audience',
            ],
          );
          final String coverage = _pickPrice(map, <String>[
            'coverage_price',
            'coveragePrice',
            'coverage',
            'story_price',
            'storyPrice',
            'post_price',
            'postPrice',
            'price',
          ]);
          final String video = _pickPrice(map, <String>[
            'video_price',
            'videoPrice',
            'reel_price',
            'reelPrice',
            'tiktok_price',
            'tiktokPrice',
            'price_video',
            'priceVideo',
            'price',
          ]);
          if (coverage.isEmpty && video.isEmpty) {
            return null;
          }
          return CompanyStarAdPriceLine(
            labelKey: labelKey,
            platformName: platform,
            followersLabel: _formatMetric(followers),
            coveragePrice: _formatMoney(coverage),
            videoPrice: _formatMoney(video),
          );
        })
        .whereType<CompanyStarAdPriceLine>()
        .toList();
  }

  static List<dynamic> _extractNamedLists(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final List<dynamic> lists = <dynamic>[];
    void visit(Object? value) {
      if (value is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(value);
        for (final String key in keys) {
          final Object? candidate = map[key];
          if (candidate is List) {
            lists.addAll(candidate);
          }
          if (candidate is Map) {
            lists.add(candidate);
          }
        }
        for (final Object? child in map.values) {
          if (child is Map) {
            visit(child);
          }
        }
      }
    }

    visit(json);
    return lists;
  }

  static List<Map<String, dynamic>> _nestedMaps(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[json];
    for (final String key in <String>[
      'user',
      'profile',
      'content_creator',
      'contentCreator',
      'creator',
      'media',
      'image',
      'avatar',
    ]) {
      final Object? value = json[key];
      if (value is Map) {
        maps.add(Map<String, dynamic>.from(value));
      }
    }
    return maps;
  }

  static String _pickFromMaps(
    List<Map<String, dynamic>> maps,
    List<String> keys, [
    String fallback = '',
  ]) {
    for (final Map<String, dynamic> map in maps) {
      for (final String key in keys) {
        final Object? value = map[key];
        final String text = _stringify(value).trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return fallback;
  }

  static String _pickPrice(Map<String, dynamic> map, List<String> keys) {
    final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[
      map,
      ..._nestedMaps(map).skip(1),
    ];
    for (final String direct in keys) {
      final String value = _pickFromMaps(maps, <String>[direct]);
      if (value.isNotEmpty) {
        return value;
      }
    }
    for (final String groupKey in <String>[
      'prices',
      'ad_prices',
      'adPrices',
      'rate',
      'rates',
    ]) {
      final Object? group = map[groupKey];
      if (group is Map) {
        final String value = _pickFromMaps(<Map<String, dynamic>>[
          Map<String, dynamic>.from(group),
        ], keys);
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return '';
  }

  static String _stringify(Object? value) {
    if (value is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      for (final String key in <String>[
        'label',
        'name',
        'title',
        'value',
        'count',
        'amount',
        'price',
      ]) {
        final Object? nested = map[key];
        if (nested != null && nested.toString().trim().isNotEmpty) {
          return nested.toString();
        }
      }
      return '';
    }
    return value?.toString() ?? '';
  }

  static String _platformLabelKey(String value) {
    final String lower = value.toLowerCase();
    if (lower.contains('snap')) {
      return 'company_star_platform_snapchat';
    }
    if (lower.contains('tik') || lower.contains('tok')) {
      return 'company_star_platform_tiktok';
    }
    if (lower.contains('whats')) {
      return 'company_star_platform_whatsapp';
    }
    return value.trim().isEmpty
        ? 'company_star_platform_snapchat'
        : value.trim();
  }

  static String _formatMoney(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    final String cleaned = trimmed
        .replaceAll(
          RegExp(r'\s*(SAR|ريال|ر\.س|﷼)\s*', caseSensitive: false),
          '',
        )
        .trim();
    final num? numeric = num.tryParse(cleaned.replaceAll(',', ''));
    if (numeric == null) {
      return cleaned;
    }
    return _compactNumber(numeric, money: true);
  }

  static String _formatMetric(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.contains(RegExp(r'[kKmM]'))) {
      return trimmed;
    }
    final num? numeric = num.tryParse(trimmed.replaceAll(',', ''));
    if (numeric == null) {
      return trimmed;
    }
    return _compactNumber(numeric);
  }

  static String _compactNumber(num value, {bool money = false}) {
    if (money || value.abs() < 1000) {
      return value % 1 == 0
          ? value.toInt().toString().replaceAllMapped(
              RegExp(r'\B(?=(\d{3})+(?!\d))'),
              (_) => ',',
            )
          : value.toString();
    }
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}m';
    }
    return '${(value / 1000).toStringAsFixed(1)}k';
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

/// One page of the stars directory plus whether more pages remain.
class CompanyStarsPageResult {
  const CompanyStarsPageResult({
    required this.items,
    required this.hasMore,
    required this.page,
  });

  final List<CompanyStarListItem> items;
  final bool hasMore;
  final int page;
}

class _StarsPage {
  const _StarsPage({
    required this.items,
    required this.nextUrl,
    required this.nextPage,
  });

  final List<CompanyStarListItem> items;
  final String? nextUrl;
  final int? nextPage;

  factory _StarsPage.fromResponse(dynamic data) {
    final Map<String, dynamic>? root = data is Map
        ? Map<String, dynamic>.from(data)
        : null;
    if (root == null) {
      return _StarsPage(
        items: CompanyStarsRepository._extractList(data)
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (Map<dynamic, dynamic> e) =>
                  CompanyStarListItem.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        nextUrl: null,
        nextPage: null,
      );
    }

    final Map<String, dynamic> scope = _paginationScope(root);
    final List<CompanyStarListItem> items =
        CompanyStarsRepository._extractList(scope)
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (Map<dynamic, dynamic> e) =>
                  CompanyStarListItem.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();

    final Map<String, dynamic> meta = _map(scope['meta']);
    final Map<String, dynamic> links = _map(scope['links']);
    final int currentPage =
        _readInt(scope['current_page']) ??
        _readInt(meta['current_page']) ??
        _readInt(scope['page']) ??
        1;
    final int? lastPage =
        _readInt(scope['last_page']) ?? _readInt(meta['last_page']);
    final String? nextUrl = _readUrl(
      scope['next_page_url'] ??
          meta['next_page_url'] ??
          links['next'] ??
          scope['next'],
    );

    int? nextPage = _readInt(scope['next_page']) ?? _readInt(meta['next_page']);
    final bool hasMore =
        nextUrl != null ||
        _readBool(scope['has_more']) == true ||
        _readBool(meta['has_more']) == true ||
        (lastPage != null && currentPage < lastPage);
    if (hasMore && nextPage == null && nextUrl == null) {
      nextPage = currentPage + 1;
    }

    return _StarsPage(items: items, nextUrl: nextUrl, nextPage: nextPage);
  }

  static Map<String, dynamic> _paginationScope(Map<String, dynamic> root) {
    final Object? data = root['data'];
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      if (_containsPagination(map) ||
          CompanyStarsRepository._extractList(map).isNotEmpty) {
        return map;
      }
    }
    return root;
  }

  static bool _containsPagination(Map<String, dynamic> map) {
    return map.containsKey('current_page') ||
        map.containsKey('last_page') ||
        map.containsKey('next_page_url') ||
        map.containsKey('meta') ||
        map.containsKey('links');
  }

  static Map<String, dynamic> _map(Object? value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return const <String, dynamic>{};
  }

  static int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static bool? _readBool(Object? value) {
    if (value is bool) {
      return value;
    }
    final String text = value?.toString().toLowerCase().trim() ?? '';
    if (text == 'true' || text == '1') {
      return true;
    }
    if (text == 'false' || text == '0') {
      return false;
    }
    return null;
  }

  static String? _readUrl(Object? value) {
    final String text = value?.toString().trim() ?? '';
    if (text.isEmpty || text == 'null') {
      return null;
    }
    return text;
  }
}

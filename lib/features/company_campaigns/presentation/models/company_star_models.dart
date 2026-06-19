import 'package:adzmavall/core/network/api_media.dart';
import 'package:equatable/equatable.dart';

enum CompanyStarCategory { all, influencer, model, ugc, collage }

class CompanyStarListItem extends Equatable {
  const CompanyStarListItem({
    required this.id,
    required this.name,
    required this.location,
    required this.categoriesLabel,
    required this.startingPriceLabel,
    required this.coverImageUrl,
    required this.isFavorite,
    this.creatorTypeValue = 'influencer',
    this.youtubeFollowers = '',
    this.tiktokFollowers = '',
    this.facebookFollowers = '',
  });

  final String id;
  final String name;
  final String location;
  final String categoriesLabel;
  final String startingPriceLabel;
  final String coverImageUrl;
  final bool isFavorite;
  final String creatorTypeValue;
  final String youtubeFollowers;
  final String tiktokFollowers;
  final String facebookFollowers;

  /// Tolerant parser for `GET /brand/content-creators` rows.
  factory CompanyStarListItem.fromJson(Map<String, dynamic> json) {
    String stringify(Object? value) {
      if (value is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(value);
        for (final String key in <String>['label', 'name', 'title', 'value']) {
          final Object? nested = map[key];
          if (nested != null && nested.toString().trim().isNotEmpty) {
            return nested.toString();
          }
        }
      }
      return value?.toString() ?? '';
    }

    String pick(List<String> keys, [String fallback = '']) {
      for (final String k in keys) {
        final Object? v = json[k];
        final String text = stringify(v).trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
      return fallback;
    }

    String pickNested(List<String> keys, [String fallback = '']) {
      final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[json];
      for (final String objectKey in <String>[
        'user',
        'profile',
        'content_creator',
        'contentCreator',
        'creator',
        'media',
        'image',
        'avatar',
      ]) {
        final Object? value = json[objectKey];
        if (value is Map) {
          maps.add(Map<String, dynamic>.from(value));
        }
      }
      for (final Map<String, dynamic> map in maps) {
        for (final String k in keys) {
          final Object? v = map[k];
          final String text = stringify(v).trim();
          if (text.isNotEmpty) {
            return text;
          }
        }
      }
      return fallback;
    }

    String pickCreatorTypeValue() {
      for (final String key in <String>[
        'creator_type',
        'creatorType',
        'type',
        'category',
      ]) {
        final Object? value = json[key];
        if (value is Map) {
          final Object? rawValue =
              value['value'] ?? value['key'] ?? value['id'];
          if (rawValue != null && rawValue.toString().trim().isNotEmpty) {
            return _normalizeCreatorType(rawValue.toString());
          }
        }
      }
      return _normalizeCreatorType(
        pickNested(<String>[
          'creator_type',
          'creatorType',
          'type',
          'category',
        ], 'influencer'),
      );
    }

    final Object? favRaw =
        json['is_favorite'] ?? json['favorite'] ?? json['favorited'];
    final bool isFavorite = favRaw is bool
        ? favRaw
        : favRaw?.toString().toLowerCase() == 'true';

    final Object? cityRaw = json['city'] ?? json['location'];
    final String location = cityRaw is Map
        ? (Map<String, dynamic>.from(cityRaw)['name']?.toString() ?? '')
        : pickNested(<String>[
            'location',
            'city',
            'address',
            'country',
            'country_name',
            'countryName',
          ]);

    final List<dynamic> socialRows = _extractNamedLists(json, <String>[
      'accounts',
      'social_accounts',
      'socialAccounts',
      'platforms',
      'ad_prices',
      'adPrices',
      'prices',
    ]);
    final String youtubeFollowers = _pickSocialFollowers(socialRows, <String>[
      'youtube',
      'you tube',
      'yt',
    ]);
    final String tiktokFollowers = _pickSocialFollowers(socialRows, <String>[
      'tiktok',
      'tik tok',
    ]);
    final String facebookFollowers = _pickSocialFollowers(socialRows, <String>[
      'facebook',
      'fb',
    ]);
    final String startingPrice = pickNested(<String>[
      'starting_price_label',
      'starting_price',
      'startingPrice',
      'min_price',
      'minPrice',
      'price',
    ], _pickLowestPrice(socialRows));

    return CompanyStarListItem(
      id: pick(<String>['id', 'uuid']),
      name: pickNested(<String>[
        'name',
        'full_name',
        'fullName',
        'display_name',
        'displayName',
        'username',
      ], 'Creator'),
      location: location,
      categoriesLabel: pickNested(<String>[
        'categories_label',
        'categoriesLabel',
        'category',
        'niche',
        'type',
        'creator_type',
        'creatorType',
      ], 'Influencer'),
      startingPriceLabel: startingPrice,
      coverImageUrl: ApiMedia.resolve(
        pickNested(<String>[
          'cover_image_url',
          'coverImageUrl',
          'image_url',
          'imageUrl',
          'avatar_url',
          'avatarUrl',
          'profile_image_url',
          'profileImageUrl',
          'profile_photo_url',
          'profilePhotoUrl',
          'url',
          'path',
          'photo',
          'cover',
          'image',
        ]),
      ),
      isFavorite: isFavorite,
      creatorTypeValue: pickCreatorTypeValue(),
      youtubeFollowers: _formatMetric(
        pickNested(<String>[
          'youtube_followers',
          'youtubeFollowers',
          'yt_followers',
          'ytFollowers',
        ], youtubeFollowers),
      ),
      tiktokFollowers: _formatMetric(
        pickNested(<String>[
          'tiktok_followers',
          'tiktokFollowers',
          'tik_tok_followers',
          'tikTokFollowers',
        ], tiktokFollowers),
      ),
      facebookFollowers: _formatMetric(
        pickNested(<String>[
          'facebook_followers',
          'facebookFollowers',
          'fb_followers',
          'fbFollowers',
        ], facebookFollowers),
      ),
    );
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
          } else if (candidate is Map) {
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

  static String _pickSocialFollowers(
    List<dynamic> rows,
    List<String> platformNames,
  ) {
    for (final Object? row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(row);
      final String platform = _stringify(
        map['platform'] ??
            map['platform_name'] ??
            map['platformName'] ??
            map['name'] ??
            map['label'] ??
            map['type'],
      ).toLowerCase();
      if (!platformNames.any(platform.contains)) {
        continue;
      }
      for (final String key in <String>[
        'followers',
        'followers_count',
        'followersCount',
        'followers_label',
        'followersLabel',
        'count',
        'audience',
      ]) {
        final String value = _stringify(map[key]).trim();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return '';
  }

  static String _pickLowestPrice(List<dynamic> rows) {
    num? lowest;
    String label = '';
    for (final Object? row in rows) {
      if (row is! Map) {
        continue;
      }
      final Map<String, dynamic> map = Map<String, dynamic>.from(row);
      for (final String key in <String>[
        'starting_price',
        'startingPrice',
        'min_price',
        'minPrice',
        'coverage_price',
        'coveragePrice',
        'story_price',
        'storyPrice',
        'post_price',
        'postPrice',
        'video_price',
        'videoPrice',
        'price',
      ]) {
        final String raw = _stringify(map[key]).trim();
        final num? price = num.tryParse(raw.replaceAll(',', ''));
        if (price != null && (lowest == null || price < lowest)) {
          lowest = price;
          label = raw;
        }
      }
    }
    return label;
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

  static String _formatMetric(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.contains(RegExp(r'[kKmM]'))) {
      return trimmed;
    }
    final num? numeric = num.tryParse(trimmed.replaceAll(',', ''));
    if (numeric == null) {
      return trimmed;
    }
    if (numeric.abs() >= 1000000) {
      return '${(numeric / 1000000).toStringAsFixed(1)}m';
    }
    if (numeric.abs() >= 1000) {
      return '${(numeric / 1000).toStringAsFixed(1)}k';
    }
    return numeric % 1 == 0 ? numeric.toInt().toString() : numeric.toString();
  }

  static String _normalizeCreatorType(String value) {
    final String lower = value.trim().toLowerCase();
    if (lower.contains('ugc') || lower.contains('user generated')) {
      return 'ugc';
    }
    if (lower.contains('collage') || lower.contains('college')) {
      return 'collage';
    }
    if (lower.contains('model')) {
      return 'model';
    }
    return 'influencer';
  }

  CompanyStarListItem copyWith({bool? isFavorite}) {
    return CompanyStarListItem(
      id: id,
      name: name,
      location: location,
      categoriesLabel: categoriesLabel,
      startingPriceLabel: startingPriceLabel,
      coverImageUrl: coverImageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      creatorTypeValue: creatorTypeValue,
      youtubeFollowers: youtubeFollowers,
      tiktokFollowers: tiktokFollowers,
      facebookFollowers: facebookFollowers,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    location,
    categoriesLabel,
    startingPriceLabel,
    coverImageUrl,
    isFavorite,
    creatorTypeValue,
  ];
}

/// UI-only filter draft until the stars API exists.
class CompanyStarsFilterDraft {
  double priceMin = 100;
  double priceMax = 200000;
  String category = 'all';
  String platform = 'all';
  String gender = 'all';
  String tags = 'all';
  String age = 'all';
}

class CompanyStarAdPriceLine extends Equatable {
  const CompanyStarAdPriceLine({
    required this.labelKey,
    required this.coveragePrice,
    required this.videoPrice,
    this.followersLabel = '',
    this.platformName = '',
  });

  final String labelKey;
  final String coveragePrice;
  final String videoPrice;
  final String followersLabel;
  final String platformName;

  @override
  List<Object?> get props => <Object?>[
    labelKey,
    coveragePrice,
    videoPrice,
    followersLabel,
    platformName,
  ];
}

class CompanyStarProfile extends Equatable {
  const CompanyStarProfile({
    required this.id,
    required this.name,
    required this.headline,
    required this.bio,
    required this.avatarUrl,
    required this.coverImageUrl,
    required this.mawthooqLabel,
    required this.adPrices,
    this.creatorTypeValue = 'influencer',
    this.categories = const <String>[],
    this.works = const <CompanyStarWorkItem>[],
    this.rawProfile = const <String, dynamic>{},
  });

  final String id;
  final String name;
  final String headline;
  final String bio;
  final String avatarUrl;
  final String coverImageUrl;
  final String mawthooqLabel;
  final List<CompanyStarAdPriceLine> adPrices;
  final String creatorTypeValue;
  final List<String> categories;
  final List<CompanyStarWorkItem> works;
  final Map<String, dynamic> rawProfile;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    headline,
    bio,
    avatarUrl,
    coverImageUrl,
    mawthooqLabel,
    adPrices,
    creatorTypeValue,
    categories,
    works,
    rawProfile,
  ];
}

class CompanyStarWorkItem extends Equatable {
  const CompanyStarWorkItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String imageUrl;

  @override
  List<Object?> get props => <Object?>[id, title, imageUrl];
}

class CompanyRequestAdPlatform extends Equatable {
  const CompanyRequestAdPlatform({
    required this.id,
    required this.name,
    required this.followersLabel,
    required this.lines,
  });

  final String id;
  final String name;
  final String followersLabel;
  final List<CompanyRequestAdLine> lines;

  @override
  List<Object?> get props => <Object?>[id, name, followersLabel, lines];
}

class CompanyRequestAdLine extends Equatable {
  const CompanyRequestAdLine({
    required this.typeKey,
    required this.priceLabel,
    this.quantity = 0,
  });

  final String typeKey;
  final String priceLabel;
  final int quantity;

  CompanyRequestAdLine copyWith({int? quantity}) {
    return CompanyRequestAdLine(
      typeKey: typeKey,
      priceLabel: priceLabel,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => <Object?>[typeKey, priceLabel, quantity];
}

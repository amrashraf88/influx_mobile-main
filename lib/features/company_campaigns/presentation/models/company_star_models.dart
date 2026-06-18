import 'package:adzmavall/core/network/api_media.dart';
import 'package:equatable/equatable.dart';

enum CompanyStarCategory { all, sports, fashion, news }

class CompanyStarListItem extends Equatable {
  const CompanyStarListItem({
    required this.id,
    required this.name,
    required this.location,
    required this.categoriesLabel,
    required this.startingPriceLabel,
    required this.coverImageUrl,
    required this.isFavorite,
    this.youtubeFollowers = '399.6k',
    this.tiktokFollowers = '399.6k',
    this.facebookFollowers = '399.6k',
  });

  final String id;
  final String name;
  final String location;
  final String categoriesLabel;
  final String startingPriceLabel;
  final String coverImageUrl;
  final bool isFavorite;
  final String youtubeFollowers;
  final String tiktokFollowers;
  final String facebookFollowers;

  /// Tolerant parser for `GET /brand/content-creators` rows.
  factory CompanyStarListItem.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys, [String fallback = '']) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
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
          if (v != null && v.toString().trim().isNotEmpty) {
            return v.toString();
          }
        }
      }
      return fallback;
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
      ]),
      startingPriceLabel: pickNested(<String>[
        'starting_price_label',
        'starting_price',
        'startingPrice',
        'min_price',
        'minPrice',
        'price',
      ]),
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
      youtubeFollowers: pickNested(<String>[
        'youtube_followers',
        'youtubeFollowers',
        'yt_followers',
        'ytFollowers',
      ], '399.6k'),
      tiktokFollowers: pickNested(<String>[
        'tiktok_followers',
        'tiktokFollowers',
        'tik_tok_followers',
        'tikTokFollowers',
      ], '399.6k'),
      facebookFollowers: pickNested(<String>[
        'facebook_followers',
        'facebookFollowers',
        'fb_followers',
        'fbFollowers',
      ], '399.6k'),
    );
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
  });

  final String labelKey;
  final String coveragePrice;
  final String videoPrice;

  @override
  List<Object?> get props => <Object?>[labelKey, coveragePrice, videoPrice];
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
  });

  final String id;
  final String name;
  final String headline;
  final String bio;
  final String avatarUrl;
  final String coverImageUrl;
  final String mawthooqLabel;
  final List<CompanyStarAdPriceLine> adPrices;

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
  ];
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeCategoryModel {
  final String titleKey;
  final String countKey;
  final String imageUrl;

  /// When set (e.g. from API), shown instead of [titleKey] via [AppStrings].
  final String? titleDisplay;

  /// When set (e.g. from API), shown instead of [countKey] via [AppStrings].
  final String? countDisplay;

  const HomeCategoryModel({
    required this.titleKey,
    required this.countKey,
    required this.imageUrl,
    this.titleDisplay,
    this.countDisplay,
  });

  factory HomeCategoryModel.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final String titleDisplay = pickString(<String>['title', 'name', 'label', 'category_name', 'categoryName']);
    final String countDisplay = pickString(<String>[
      'count_label',
      'countLabel',
      'subtitle',
      'influencers_label',
      'influencersLabel',
      'count',
      'influencers_count',
      'influencersCount',
    ]);
    return HomeCategoryModel(
      titleKey: pickString(<String>['title_key', 'titleKey', 'localization_key', 'localizationKey']),
      countKey: pickString(<String>['count_key', 'countKey', 'count_localization_key', 'countLocalizationKey'])
          .ifEmptyUse('home_influencers_count'),
      imageUrl: pickString(<String>[
        'image_url',
        'imageUrl',
        'cover_url',
        'coverUrl',
        'thumbnail',
        'thumbnail_url',
        'thumbnailUrl',
      ]),
      titleDisplay: titleDisplay.isEmpty ? null : titleDisplay,
      countDisplay: countDisplay.isEmpty ? null : countDisplay,
    );
  }
}

class HomeInfluencerModel {
  final String name;
  final String location;
  final String niche;
  final String priceLabel;
  final String coverImageUrl;
  final String youtubeFollowersLabel;
  final String tiktokFollowersLabel;
  final String facebookFollowersLabel;

  const HomeInfluencerModel({
    required this.name,
    required this.location,
    required this.niche,
    required this.priceLabel,
    this.coverImageUrl = '',
    this.youtubeFollowersLabel = '—',
    this.tiktokFollowersLabel = '—',
    this.facebookFollowersLabel = '—',
  });

  factory HomeInfluencerModel.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final String priceRaw = pickString(<String>[
      'price_label',
      'priceLabel',
      'starting_price',
      'startingPrice',
      'price_display',
      'priceDisplay',
    ]);
    final Object? priceValue = json['price'] ?? json['amount'] ?? json['starting_from'];
    String priceLabel = priceRaw;
    if (priceLabel.isEmpty && priceValue != null) {
      if (priceValue is num) {
        priceLabel = NumberFormat.currency(symbol: r'$', decimalDigits: 0).format(priceValue);
      } else {
        priceLabel = priceValue.toString();
      }
    }

    String niche = pickString(<String>['niche', 'category', 'vertical', 'specialty']);
    if (niche.isEmpty) {
      final Object? cats = json['categories'] ?? json['tags'];
      if (cats is List<dynamic>) {
        niche = cats.map((dynamic e) => e.toString()).where((String s) => s.isNotEmpty).join(', ');
      } else {
        niche = pickString(<String>['categories']);
      }
    }

    return HomeInfluencerModel(
      name: pickString(<String>['name', 'full_name', 'fullName', 'display_name', 'displayName']),
      location: pickString(<String>[
        'location',
        'city',
        'address',
        'country',
        'region',
      ]),
      niche: niche.isEmpty ? '—' : niche,
      priceLabel: priceLabel.isEmpty ? '—' : priceLabel,
      coverImageUrl: pickString(<String>[
        'cover_image_url',
        'coverImageUrl',
        'cover_image',
        'coverImage',
        'image_url',
        'imageUrl',
        'photo',
        'avatar',
        'avatar_url',
        'avatarUrl',
        'thumbnail',
        'thumbnail_url',
        'thumbnailUrl',
      ]),
      youtubeFollowersLabel: pickString(<String>[
        'youtube_followers',
        'youtubeFollowers',
        'youtube',
        'yt_followers',
        'ytFollowers',
      ]).ifEmptyUse('—'),
      tiktokFollowersLabel: pickString(<String>[
        'tiktok_followers',
        'tiktokFollowers',
        'tiktok',
        'tt_followers',
      ]).ifEmptyUse('—'),
      facebookFollowersLabel: pickString(<String>[
        'facebook_followers',
        'facebookFollowers',
        'facebook',
        'fb_followers',
        'fbFollowers',
      ]).ifEmptyUse('—'),
    );
  }
}

extension on String {
  String ifEmptyUse(String fallback) => isEmpty ? fallback : this;
}

class HomeWhyFeatureModel {
  final IconData icon;
  final String titleKey;
  final String? iconAsset;

  /// Plain title from API; when non-empty, overrides [titleKey] localization.
  final String? titleOverride;

  /// Remote icon; when set, used instead of [icon] / [iconAsset].
  final String? iconUrl;

  const HomeWhyFeatureModel({
    required this.icon,
    required this.titleKey,
    this.iconAsset,
    this.titleOverride,
    this.iconUrl,
  });

  factory HomeWhyFeatureModel.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final String titleOverride = pickString(<String>['title', 'label', 'heading', 'name']);
    final String iconUrl = pickString(<String>['icon_url', 'iconUrl', 'image_url', 'imageUrl']);
    final String iconAsset = pickString(<String>['icon_asset', 'iconAsset', 'local_icon', 'localIcon']);
    final String titleKey = pickString(<String>['title_key', 'titleKey', 'key']).ifEmptyUse('home_why_item_1');

    return HomeWhyFeatureModel(
      icon: Icons.auto_awesome_outlined,
      titleKey: titleKey,
      iconAsset: iconAsset.isEmpty ? null : iconAsset,
      titleOverride: titleOverride.isEmpty ? null : titleOverride,
      iconUrl: iconUrl.isEmpty ? null : iconUrl,
    );
  }
}

/// Trending topic chip: either a localized [localizationKey] or raw [apiLabel].
/// At least one should be non-empty at runtime (enforced in [fromJson]).
class HomeTrendingTagModel {
  const HomeTrendingTagModel({
    this.localizationKey,
    this.apiLabel,
  });

  final String? localizationKey;
  final String? apiLabel;

  factory HomeTrendingTagModel.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final String label = pickString(<String>['label', 'tag', 'name', 'text', 'title', 'hashtag']);
    if (label.isNotEmpty) {
      final String trimmed = label.startsWith('#') ? label.substring(1) : label;
      return HomeTrendingTagModel(apiLabel: trimmed);
    }
    final String key = pickString(<String>['localization_key', 'localizationKey', 'key', 'title_key', 'titleKey']);
    return HomeTrendingTagModel(localizationKey: key.isEmpty ? 'home_tag_trending_1' : key);
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

/// Optional welcome card content from [ApiEndpoints.homeWelcomePath].
class HomeWelcomeCardContent {
  const HomeWelcomeCardContent({
    this.title,
    this.body,
    this.ctaLabel,
    this.illustrationUrl,
  });

  final String? title;
  final String? body;
  final String? ctaLabel;

  /// When set, shown instead of the bundled asset in [HomeWelcomeCardWidget].
  final String? illustrationUrl;

  factory HomeWelcomeCardContent.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> map = json;
    final Object? data = json['data'] ?? json['welcome'] ?? json['payload'];
    if (data is Map) {
      map = Map<String, dynamic>.from(data);
    }

    return HomeWelcomeCardContent(
      title: _pickFromMap(map, <String>['title', 'heading', 'welcome_title', 'welcomeTitle']),
      body: _pickFromMap(map, <String>['body', 'subtitle', 'description', 'message', 'text']),
      ctaLabel: _pickFromMap(map, <String>['cta', 'cta_label', 'ctaLabel', 'button', 'button_label', 'buttonLabel']),
      illustrationUrl: _pickFromMap(
        map,
        <String>[
          'illustration_url',
          'illustrationUrl',
          'image_url',
          'imageUrl',
          'hero_image',
          'heroImage',
        ],
      ),
    );
  }
}

class HomeStoryModel {
  final String userName;
  final String userHandle;
  final String title;
  final String imageUrl;
  final String likesLabel;
  final String commentsLabel;
  final String avatarUrl;

  const HomeStoryModel({
    required this.userName,
    required this.userHandle,
    required this.title,
    required this.imageUrl,
    this.likesLabel = '0',
    this.commentsLabel = '0',
    this.avatarUrl = '',
  });

  factory HomeStoryModel.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    return HomeStoryModel(
      userName: pickString(<String>['user_name', 'userName', 'name', 'author_name', 'authorName']),
      userHandle: pickString(<String>['user_handle', 'userHandle', 'handle', 'username']),
      title: pickString(<String>['title', 'caption', 'headline', 'story_title', 'storyTitle']),
      imageUrl: pickString(<String>[
        'image_url',
        'imageUrl',
        'cover_image_url',
        'coverImageUrl',
        'story_image',
        'storyImage',
        'thumbnail',
      ]),
      likesLabel: pickString(<String>['likes_label', 'likesLabel', 'likes', 'like_count', 'likeCount'])
          .ifEmptyUse('0'),
      commentsLabel:
          pickString(<String>['comments_label', 'commentsLabel', 'comments', 'comment_count', 'commentCount'])
              .ifEmptyUse('0'),
      avatarUrl: pickString(<String>['avatar_url', 'avatarUrl', 'user_avatar', 'userAvatar', 'profile_image']),
    );
  }
}

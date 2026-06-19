import 'package:adzmavall/core/network/api_media.dart';
import 'package:adzmavall/features/influencer_profile/data/creator_profile_repository.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/utils/imageassets.dart';

/// A single social account row in the "Accounts" tab.
class CreatorAccountMetric {
  const CreatorAccountMetric({
    required this.id,
    required this.label,
    required this.asset,
    required this.followers,
  });

  /// Backend id (empty for sample/fallback rows that cannot be deleted).
  final String id;
  final String label;
  final String asset;
  final String followers;
}

/// A single client logo in the "Clients" tab.
class CreatorClientItem {
  const CreatorClientItem({
    required this.id,
    required this.name,
    required this.handle,
    required this.logoUrl,
  });

  final String id;
  final String name;
  final String handle;
  final String logoUrl;
}

/// A single platform pricing card in the "Ad Price" tab.
class CreatorAdPriceItem {
  const CreatorAdPriceItem({
    required this.id,
    required this.label,
    required this.asset,
    required this.followers,
    required this.coverage,
    required this.videoPrice,
  });

  final String id;
  final String label;
  final String asset;
  final String followers;
  final String coverage;
  final String videoPrice;
}

/// A single ad preview in the "Ads" tab.
class CreatorAdPreviewItem {
  const CreatorAdPreviewItem({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String imageUrl;
}

/// Everything the profile tabs render, built from the live API bundle with a
/// graceful fall back to [InfluencerProfileViewData] sample data per-section.
class CreatorProfileTabData {
  const CreatorProfileTabData({
    required this.accounts,
    required this.clients,
    required this.clientCategories,
    required this.adPriceItems,
    required this.ads,
    required this.keywords,
    required this.ageRanges,
    required this.platforms,
  });

  final List<CreatorAccountMetric> accounts;
  final List<CreatorClientItem> clients;
  final List<String> clientCategories;
  final List<CreatorAdPriceItem> adPriceItems;
  final List<CreatorAdPreviewItem> ads;
  final List<String> keywords;
  final List<String> ageRanges;
  final List<String> platforms;

  /// Empty data — shown when the API is configured but returns nothing.
  factory CreatorProfileTabData.empty() {
    return const CreatorProfileTabData(
      accounts: <CreatorAccountMetric>[],
      clients: <CreatorClientItem>[],
      clientCategories: <String>[],
      adPriceItems: <CreatorAdPriceItem>[],
      ads: <CreatorAdPreviewItem>[],
      keywords: <String>[],
      ageRanges: <String>[],
      platforms: <String>[],
    );
  }

  /// Sample data used only before the API is configured (pure-UI mode).
  factory CreatorProfileTabData.fallback() {
    return CreatorProfileTabData(
      accounts: InfluencerProfileViewData.accountMetrics
          .map(
            (InfluencerAccountMetric m) => CreatorAccountMetric(
              id: '',
              label: m.label,
              asset: m.asset,
              followers: '399.6k',
            ),
          )
          .toList(),
      clients: InfluencerProfileViewData.clients
          .map(
            (InfluencerClientItem c) => CreatorClientItem(
              id: '',
              name: c.name,
              handle: '',
              logoUrl: c.logoUrl,
            ),
          )
          .toList(),
      clientCategories: InfluencerProfileViewData.clientCategories,
      adPriceItems: InfluencerProfileViewData.adPriceItems
          .map(
            (InfluencerAdPriceItem p) => CreatorAdPriceItem(
              id: '',
              label: p.label,
              asset: p.asset ?? ImageAssets.instagramColoredIcon,
              followers: '399.6k',
              coverage: '17,600',
              videoPrice: '3,500',
            ),
          )
          .toList(),
      ads: InfluencerProfileViewData.adPreviews
          .map(
            (InfluencerAdPreviewItem a) => CreatorAdPreviewItem(
              id: '',
              title: a.title,
              imageUrl: a.imageUrl,
            ),
          )
          .toList(),
      keywords: InfluencerProfileViewData.keywords,
      ageRanges: const <String>['18-25'],
      platforms: const <String>['Tiktok', 'Instagram'],
    );
  }

  /// Builds tab data straight from the API bundle. Sections the API leaves
  /// empty stay empty (no sample data is injected).
  factory CreatorProfileTabData.fromBundle(CreatorProfileBundle bundle) {
    final List<CreatorAccountMetric> accounts = bundle.socialAccounts
        .map(_accountFromJson)
        .where((CreatorAccountMetric a) => a.label.isNotEmpty)
        .toList();

    final List<CreatorClientItem> clients = bundle.clients
        .map(_clientFromJson)
        .where((CreatorClientItem c) => c.name.isNotEmpty)
        .toList();

    final List<CreatorAdPriceItem> adPriceItems = bundle.socialAccounts
        .map(_adPriceFromJson)
        .where((CreatorAdPriceItem p) => p.label.isNotEmpty)
        .toList();

    final List<CreatorAdPreviewItem> ads = bundle.ads
        .map(_adPreviewFromJson)
        .where((CreatorAdPreviewItem a) => a.title.isNotEmpty)
        .toList();

    final List<String> keywords = _stringList(bundle.profile, <String>[
      'keywords',
      'tags',
      'hashtags',
      'interests',
    ], prefixHash: true);

    final List<String> platforms = accounts.isNotEmpty
        ? accounts.map((CreatorAccountMetric a) => a.label).toSet().toList()
        : _stringList(bundle.profile, <String>['platforms'], prefixHash: false);

    final List<String> ageRanges = _stringList(bundle.profile, <String>[
      'audience_age_ranges',
      'audienceAgeRanges',
      'age_ranges',
      'ageRanges',
    ], prefixHash: false);

    final List<String> clientCategories = _stringList(bundle.profile, <String>[
      'client_categories',
      'clientCategories',
    ], prefixHash: false);

    return CreatorProfileTabData(
      accounts: accounts,
      clients: clients,
      clientCategories: clientCategories,
      adPriceItems: adPriceItems,
      ads: ads,
      keywords: keywords,
      ageRanges: ageRanges,
      platforms: platforms,
    );
  }

  // ---------------------------------------------------------------------------
  // Per-row mappers
  // ---------------------------------------------------------------------------

  static CreatorAccountMetric _accountFromJson(Map<String, dynamic> json) {
    final String platform = _extractPlatform(json);
    return CreatorAccountMetric(
      id: _pickId(json),
      label: _platformLabel(platform),
      asset: _platformAsset(platform),
      followers: _formatCount(
        _pick(json, <String>[
          'statistics.followers_count',
          'statistics.followers',
          'stats.followers_count',
          'stats.followers',
          'metrics.followers_count',
          'metrics.followers',
          'account.followers_count',
          'account.followers',
          'social_account.followers_count',
          'social_account.followers',
          'followers_count',
          'follower_count',
          'followersCount',
          'followerCount',
          'followers_count_formatted',
          'followersCountFormatted',
          'followers_number',
          'followersNumber',
          'number_of_followers',
          'numberOfFollowers',
          'total_followers',
          'totalFollowers',
          'followers',
          'audience_size',
          'audienceSize',
          'subscribers',
          'subscribers_count',
          'subscribersCount',
          'fans_count',
          'fansCount',
        ]),
      ),
    );
  }

  static CreatorClientItem _clientFromJson(Map<String, dynamic> json) {
    return CreatorClientItem(
      id: _pickId(json),
      name: _pick(json, <String>[
        'name',
        'client_name',
        'clientName',
        'title',
        'company_name',
        'companyName',
      ]),
      handle: _pick(json, <String>[
        'handle',
        'username',
        'user_name',
        'account',
      ]),
      logoUrl: ApiMedia.resolve(
        _pick(json, <String>[
          'logo_url',
          'logoUrl',
          'logo',
          'image_url',
          'imageUrl',
          'image',
          'icon',
        ]),
      ),
    );
  }

  static CreatorAdPriceItem _adPriceFromJson(Map<String, dynamic> json) {
    final String platform = _extractPlatform(json);
    return CreatorAdPriceItem(
      id: _pickId(json),
      label: _platformLabel(platform),
      asset: _platformAsset(platform),
      followers: _formatCount(
        _pick(json, <String>[
          'statistics.followers_count',
          'statistics.followers',
          'stats.followers_count',
          'stats.followers',
          'metrics.followers_count',
          'metrics.followers',
          'account.followers_count',
          'account.followers',
          'social_account.followers_count',
          'social_account.followers',
          'followers_count',
          'follower_count',
          'followersCount',
          'followerCount',
          'followers_count_formatted',
          'followersCountFormatted',
          'followers_number',
          'followersNumber',
          'number_of_followers',
          'numberOfFollowers',
          'total_followers',
          'totalFollowers',
          'followers',
          'audience_size',
          'audienceSize',
          'subscribers',
          'subscribers_count',
          'subscribersCount',
          'fans_count',
          'fansCount',
        ]),
      ),
      coverage: _formatPrice(
        _pick(json, <String>[
          'coverage_price',
          'coveragePrice',
          'story_price',
          'storyPrice',
          'coverage',
        ]),
        '17,600',
      ),
      videoPrice: _formatPrice(
        _pick(json, <String>[
          'video_price',
          'videoPrice',
          'post_price',
          'postPrice',
          'price',
        ]),
        '3,500',
      ),
    );
  }

  static CreatorAdPreviewItem _adPreviewFromJson(Map<String, dynamic> json) {
    return CreatorAdPreviewItem(
      id: _pickId(json),
      title: _pick(json, <String>[
        'label',
        'title',
        'name',
        'ad_name',
        'adName',
        'client_name',
        'clientName',
      ]),
      imageUrl: ApiMedia.resolve(
        _pick(json, <String>[
          'image_url',
          'imageUrl',
          'thumbnail_url',
          'thumbnailUrl',
          'thumbnail',
          'cover_url',
          'coverUrl',
          'cover',
          'media_url',
          'mediaUrl',
          'image',
          'video_url',
          'videoUrl',
          'url',
        ]),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  static String _pick(Map<String, dynamic> json, List<String> keys) {
    String stringify(Object? value) {
      if (value is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(value);
        for (final String key in <String>[
          'label',
          'name',
          'title',
          'value',
          'slug',
          'key',
        ]) {
          final Object? nested = map[key];
          if (nested != null && nested.toString().trim().isNotEmpty) {
            return nested.toString().trim();
          }
        }
      }
      return value?.toString().trim() ?? '';
    }

    Object? valueAtPath(Map<String, dynamic> map, String path) {
      Object? current = map;
      for (final String segment in path.split('.')) {
        if (current is! Map) {
          return null;
        }
        current = current[segment];
      }
      return current;
    }

    final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[json];
    final Set<Map<dynamic, dynamic>> seen = <Map<dynamic, dynamic>>{};
    void addKnownNested(Map<String, dynamic> source) {
      if (!seen.add(source)) {
        return;
      }
      for (final String objectKey in <String>[
        'data',
        'account',
        'social_account',
        'socialAccount',
        'platform',
        'social_platform',
        'socialPlatform',
        'statistics',
        'stats',
        'metrics',
        'meta',
      ]) {
        final Object? value = source[objectKey];
        if (value is Map) {
          final Map<String, dynamic> nested = Map<String, dynamic>.from(value);
          maps.add(nested);
          addKnownNested(nested);
        }
      }
    }

    addKnownNested(json);
    for (final Map<String, dynamic> map in maps) {
      for (final String key in keys) {
        final Object? value = key.contains('.')
            ? valueAtPath(map, key)
            : map[key];
        final String text = stringify(value);
        if (text.isNotEmpty && text != 'null') {
          return text;
        }
      }
    }
    return '';
  }

  static String _pickId(Map<String, dynamic> json) =>
      _pick(json, <String>['id', '_id', 'uuid', 'uid']);

  /// Resolves a platform name/slug from a social account row. The API may send
  /// the platform as a plain string, a nested object ({name, slug, id}) or an
  /// id referenced by another key — handle them all so the icon/label resolve.
  static String _extractPlatform(Map<String, dynamic> json) {
    const List<String> keys = <String>[
      'platform',
      'platform_name',
      'platformName',
      'social_platform',
      'socialPlatform',
      'social_platform_name',
      'name',
      'type',
      'slug',
    ];
    for (final String key in keys) {
      final Object? v = json[key];
      if (v == null) continue;
      if (v is Map) {
        final Map<String, dynamic> m = Map<String, dynamic>.from(v);
        for (final String nk in <String>[
          'slug',
          'name',
          'title',
          'label',
          'value',
          'key',
        ]) {
          final Object? nv = m[nk];
          if (nv != null && nv.toString().trim().isNotEmpty) {
            return nv.toString().trim();
          }
        }
        continue;
      }
      final String s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    final String nested = _pick(json, <String>[
      'account.platform',
      'account.platform_name',
      'account.platformName',
      'account.name',
      'social_account.platform',
      'social_account.platform_name',
      'social_account.platformName',
      'social_account.name',
      'socialAccount.platform',
      'socialAccount.platformName',
      'socialAccount.name',
      'platform.slug',
      'platform.name',
      'platform.label',
      'social_platform.slug',
      'social_platform.name',
      'social_platform.label',
      'socialPlatform.slug',
      'socialPlatform.name',
      'socialPlatform.label',
    ]);
    if (nested.isNotEmpty) {
      return nested;
    }
    return '';
  }

  static List<String> _stringList(
    Map<String, dynamic> json,
    List<String> keys, {
    required bool prefixHash,
  }) {
    final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[json];
    for (final String objectKey in <String>[
      'profile',
      'content_creator',
      'contentCreator',
      'creator',
    ]) {
      final Object? value = json[objectKey];
      if (value is Map) maps.add(Map<String, dynamic>.from(value));
    }
    for (final Map<String, dynamic> map in maps) {
      for (final String key in keys) {
        final Object? value = map[key];
        if (value is List && value.isNotEmpty) {
          return value
              .map((Object? e) => _normalizeTag(e, prefixHash: prefixHash))
              .where((String s) => s.isNotEmpty)
              .toList();
        }
        if (value is String && value.trim().isNotEmpty) {
          return value
              .split(RegExp(r'[,\n]'))
              .map((String e) => _normalizeTag(e, prefixHash: prefixHash))
              .where((String s) => s.isNotEmpty)
              .toList();
        }
      }
    }
    return const <String>[];
  }

  static String _normalizeTag(Object? raw, {required bool prefixHash}) {
    String s = raw?.toString().trim() ?? '';
    if (s.isEmpty) return '';
    if (prefixHash && !s.startsWith('#')) {
      s = '#${s.replaceFirst(RegExp(r'^#+'), '')}';
    }
    return s;
  }

  static String _platformLabel(String platform) {
    final String key = platform.trim().toLowerCase();
    if (key.isEmpty) return '';
    return switch (key) {
      'instagram' || 'insta' || 'ig' => 'Instagram',
      'telegram' || 'tg' => 'Telegram',
      'twitter' || 'x' => 'Twitter',
      'threads' => 'Threads',
      'whatsapp' || 'whats_app' => 'WhatsApp',
      'youtube' || 'yt' => 'Youtube',
      'snapchat' || 'snap' => 'Snap',
      'tiktok' || 'tik_tok' || 'tik tok' => 'Tik Tok',
      'facebook' || 'fb' => 'Facebook',
      _ => platform.trim(),
    };
  }

  static String _platformAsset(String platform) {
    final String key = platform.trim().toLowerCase();
    return switch (key) {
      'instagram' || 'insta' || 'ig' => ImageAssets.instagramColoredIcon,
      'telegram' || 'tg' => ImageAssets.telegramColoredIcon,
      'twitter' || 'x' => ImageAssets.twitterIcon,
      'threads' => ImageAssets.threadsIcon,
      'whatsapp' || 'whats_app' => ImageAssets.whatsappColoredIcon,
      'youtube' || 'yt' => ImageAssets.homeInfluencerYoutube,
      'snapchat' || 'snap' => ImageAssets.snapchatIcon,
      'tiktok' || 'tik_tok' || 'tik tok' => ImageAssets.homeInfluencerTiktok,
      'facebook' || 'fb' => ImageAssets.homeInfluencerFacebook,
      _ => ImageAssets.instagramColoredIcon,
    };
  }

  /// Formats a raw follower count (e.g. `399600`) into `399.6k`.
  static String _formatCount(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) return '';
    if (RegExp(r'^\d+([.,]\d+)?\s*[kKmMbB]$').hasMatch(value)) {
      final String compact = value.replaceAll(' ', '').replaceAll(',', '.');
      final String suffix = compact.substring(compact.length - 1).toLowerCase();
      return '${compact.substring(0, compact.length - 1)}$suffix';
    }
    final num? n = num.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (n == null) return raw;
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    }
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return n.toString();
  }

  /// Formats a raw price with thousands separators, or returns [fallback].
  static String _formatPrice(String raw, String fallback) {
    if (raw.isEmpty) return fallback;
    final num? n = num.tryParse(raw.replaceAll(RegExp(r'[^0-9.]'), ''));
    if (n == null) return raw;
    final String fixed = n == n.roundToDouble()
        ? n.toInt().toString()
        : n.toString();
    return fixed.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

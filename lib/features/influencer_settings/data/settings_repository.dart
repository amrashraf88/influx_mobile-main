import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_media.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart'
    show ApiException;
import 'package:adzmavall/features/influencer_settings/presentation/models/influencer_settings_models.dart';
import 'package:dio/dio.dart';

/// Backs the settings screen: profile header, sign-out and notification toggle.
class SettingsRepository {
  SettingsRepository(this._dio);

  final Dio _dio;

  /// `GET /auth/user/profile/content-creator` → header profile.
  Future<InfluencerSettingsProfile> fetchProfile() async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.authUserProfileContentCreatorPath),
    );
    return _profileFromJson(_unwrap(res.data));
  }

  /// `POST /auth/logout` — invalidate the server session (best-effort).
  Future<void> logout() async {
    try {
      await _dio.post<dynamic>(
        ApiUrlResolver.resolve(ApiEndpoints.authLogoutPath),
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  /// `GET /application/users/notification-settings`.
  Future<bool> fetchNotificationsEnabled() async {
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(
        ApiUrlResolver.resolve(
          ApiEndpoints.applicationUserNotificationSettingsPath,
        ),
      );
      return _readEnabled(_unwrap(res.data));
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  /// `POST /application/users/notification-settings`.
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await _dio.post<dynamic>(
        ApiUrlResolver.resolve(
          ApiEndpoints.applicationUserNotificationSettingsPath,
        ),
        data: <String, dynamic>{
          'notifications_enabled': enabled,
          'push_notifications': enabled,
        },
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  // ---------------------------------------------------------------------------

  static InfluencerSettingsProfile _profileFromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[json];
      for (final String objectKey in <String>[
        'user',
        'profile',
        'content_creator',
        'contentCreator',
      ]) {
        final Object? v = json[objectKey];
        if (v is Map) maps.add(Map<String, dynamic>.from(v));
      }
      for (final Map<String, dynamic> map in maps) {
        for (final String key in keys) {
          final Object? value = map[key];
          if (value is Map) {
            final Map<String, dynamic> nested = Map<String, dynamic>.from(
              value,
            );
            for (final String nestedKey in <String>[
              'label',
              'name',
              'title',
              'value',
              'slug',
              'key',
            ]) {
              final Object? nestedValue = nested[nestedKey];
              if (nestedValue != null &&
                  nestedValue.toString().trim().isNotEmpty) {
                return nestedValue.toString().trim();
              }
            }
          }
          if (value != null && value.toString().trim().isNotEmpty) {
            return value.toString().trim();
          }
        }
      }
      return '';
    }

    final String creatorType = pick(<String>[
      'creator_type',
      'creatorType',
      'type',
    ]).toLowerCase();
    final String headline = pick(<String>[
      'headline',
      'title',
      'category',
      'niche',
    ]);

    final String percentRaw = pick(<String>[
      'verification_percent',
      'verificationPercent',
      'profile_completion',
      'profileCompletion',
      'completion_percent',
    ]);
    final int? percent = int.tryParse(
      percentRaw.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    return InfluencerSettingsProfile(
      name: pick(<String>[
        'name',
        'full_name',
        'fullName',
        'display_name',
        'username',
      ]),
      title: headline.isNotEmpty ? headline : _creatorTitle(creatorType),
      avatarUrl: ApiMedia.resolve(
        pick(<String>[
          'avatar_url',
          'avatarUrl',
          'profile_image_url',
          'profileImageUrl',
          'profile_picture_url',
          'image_url',
          'imageUrl',
          'photo',
        ]),
      ),
      // Unknown ⇒ 100 so the "complete your profile" card stays hidden.
      verificationPercent: percent ?? 100,
    );
  }

  static String _creatorTitle(String creatorType) {
    return switch (creatorType) {
      'model' => 'Professional fashion Model',
      'ugc' => 'Professional UGC creator',
      'collage' => 'Professional fashion Collage',
      'influencer' => 'Professional fashion influencer',
      _ => '',
    };
  }

  static bool _readEnabled(Map<String, dynamic> json) {
    for (final String key in <String>[
      'notifications_enabled',
      'notificationsEnabled',
      'push_notifications',
      'pushNotifications',
      'push',
      'enabled',
      'notifications',
    ]) {
      final Object? v = json[key];
      if (v is bool) return v;
      final String s = v?.toString().toLowerCase().trim() ?? '';
      if (s == 'true' || s == '1' || s == 'on') return true;
      if (s == 'false' || s == '0' || s == 'off') return false;
    }
    return true;
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

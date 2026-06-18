import 'package:adzmavall/features/profile/presentation/cubit/influencer_profile_cubit.dart';

abstract final class ContentCreatorRegistrationMapper {
  /// Default password sent with registration (the flow is OTP-based and has no
  /// password field in the UI). Matches the value used in the API collection.
  static const String defaultPassword = '12345678';

  static Map<String, dynamic> toRequestBody(InfluencerProfileState state) {
    final Map<String, dynamic> body = <String, dynamic>{
      // The backend matches the completed OTP verification by phone, so the
      // phone (digits only, same form sent to otp-verifications/initiate) MUST
      // be included or registration fails with `invalid_otp`.
      'phone': _digits(state.phone),
      'password': defaultPassword,
      'creator_type': state.creatorKind,
      'full_name': state.name.trim(),
      'full_name_ar': state.fullNameArabic.trim(),
      'gender': state.gender.name,
      'age': _parseInt(state.age),
      'categories': _parseCategoryIds(state.selectedCategories),
    };

    if (state.creatorImageId != null) {
      body['creator_image'] = state.creatorImageId;
    }

    switch (state.creatorKind) {
      case 'influencer':
        body.addAll(_influencerFields(state));
      case 'model':
        body.addAll(_modelFields(state));
      case 'ugc':
        body.addAll(_ugcFields(state));
      case 'collage':
        body.addAll(_collageFields(state));
    }

    body.removeWhere((String _, dynamic value) => value == null);
    return body;
  }

  static Map<String, dynamic> _influencerFields(InfluencerProfileState state) {
    return <String, dynamic>{
      'city': _nonEmpty(state.city),
      'city_direction': _nonEmpty(state.direction),
      'street': _nonEmpty(state.district),
      'mawthooq_license_number': _nonEmpty(state.mawthoqCertificateNumber),
      'social_accounts': _mapSocialAccounts(state.socialAccounts),
    };
  }

  static Map<String, dynamic> _modelFields(InfluencerProfileState state) {
    final Map<String, String> fields = state.creatorFields;
    return <String, dynamic>{
      'city': _nonEmpty(state.city),
      'nationality': _mapNationality(fields['nationality']),
      'height': _parseInt(fields['height_cm']),
      'weight': _parseInt(fields['weight_kg']),
      'size': _slug(fields['size']),
      'skin_tone': _slug(fields['skin_tone']),
      'body_visibility': _yesNo(state.creatorToggles['show_full_body'] ?? true),
      'session_price_per_hour': _parseInt(fields['session_rate_per_hour']),
      'city_direction': _nonEmpty(fields['direction']),
      'street': _nonEmpty(fields['district']),
      'face_visibility': _yesNo(state.creatorToggles['face_visible'] ?? true),
      'show_hair': _yesNo(state.creatorToggles['hair_visible'] ?? true),
    };
  }

  static Map<String, dynamic> _ugcFields(InfluencerProfileState state) {
    final Map<String, String> fields = state.creatorFields;
    return <String, dynamic>{
      'city': _nonEmpty(state.city),
      'voice_over': _yesNo(state.creatorToggles['voice_over'] ?? true),
      'use_hook': _yesNo(state.creatorToggles['use_hook'] ?? true),
      'video_price': _parseInt(fields['video_price']),
      'deliverability_time': _parseInt(fields['delivery_time_from_arrival']),
      'face_visibility': _yesNo(state.creatorToggles['face_visible'] ?? true),
      'show_hair': _yesNo(state.creatorToggles['hair_visible'] ?? true),
    };
  }

  static Map<String, dynamic> _collageFields(InfluencerProfileState state) {
    final Map<String, String> fields = state.creatorFields;
    return <String, dynamic>{
      'city': _nonEmpty(state.city),
      'city_direction': _nonEmpty(fields['directions']),
      'street': _nonEmpty(fields['collage_district']),
      'clip_price_per_second': _parseInt(fields['price_per_second']),
      'accent': _slug(fields['accent']),
    };
  }

  static List<int> _parseCategoryIds(Set<String> categories) {
    return categories
        .map((String value) => int.tryParse(value.trim()))
        .whereType<int>()
        .toList();
  }

  static List<Map<String, dynamic>> _mapSocialAccounts(
    List<InfluencerSocialAccountEntry> accounts,
  ) {
    return accounts
        .where(
          (InfluencerSocialAccountEntry account) =>
              account.platform.trim().isNotEmpty &&
              account.handle.trim().isNotEmpty,
        )
        .map((InfluencerSocialAccountEntry account) {
          return <String, dynamic>{
            'platform': account.platform.trim(),
            'url': _socialUrl(account.platform, account.handle),
            'prices': _mapSocialPrices(account),
          };
        })
        .where((Map<String, dynamic> account) {
          final List<dynamic> prices = account['prices'] as List<dynamic>;
          return prices.isNotEmpty;
        })
        .toList();
  }

  static List<Map<String, dynamic>> _mapSocialPrices(
    InfluencerSocialAccountEntry account,
  ) {
    final List<Map<String, dynamic>> prices = <Map<String, dynamic>>[];
    for (final MapEntry<String, String> entry in account.prices.entries) {
      final int? price = _parseInt(entry.value);
      final String contentType = entry.key.trim().toLowerCase();
      if (price != null && contentType.isNotEmpty) {
        prices.add(<String, dynamic>{
          'content_type': contentType,
          'price': price,
        });
      }
    }
    return prices;
  }

  static String _socialUrl(String platform, String handle) {
    final String trimmed = handle.trim();
    if (trimmed.contains('://')) {
      return trimmed;
    }

    final String normalized = trimmed.startsWith('@')
        ? trimmed.substring(1)
        : trimmed;

    return switch (platform.trim().toLowerCase()) {
      'instagram' => 'https://instagram.com/$normalized',
      'tiktok' => 'https://tiktok.com/@$normalized',
      'snapchat' => 'https://snapchat.com/add/$normalized',
      'x' || 'twitter' => 'https://x.com/$normalized',
      _ => trimmed,
    };
  }

  /// Digits only, matching the identifier sent to otp-verifications/initiate
  /// (e.g. `+966 55 …` → `96655…`).
  static String _digits(String? value) =>
      (value ?? '').replaceAll(RegExp(r'\D'), '');

  static String? _nonEmpty(String? value) {
    final String trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  static String? _slug(String? value) {
    final String trimmed = value?.trim().toLowerCase() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  static int? _parseInt(String? value) {
    if (value == null) {
      return null;
    }
    return int.tryParse(value.trim());
  }

  static String _yesNo(bool value) => value ? 'yes' : 'no';

  static String? _mapNationality(String? value) {
    final String normalized = value?.trim().toLowerCase() ?? '';
    if (normalized.contains('saudi')) {
      return 'saudi';
    }
    if (normalized.contains('uae') || normalized.contains('emir')) {
      return 'uae';
    }
    if (normalized.contains('egypt')) {
      return 'egypt';
    }
    return _slug(value);
  }

}

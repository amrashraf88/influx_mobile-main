import 'package:adzmavall/core/network/api_media.dart';
import 'package:equatable/equatable.dart';

/// Top-of-home summary for a registered company.
///
/// Shape follows what the future API will return for the brand’s onboarding
/// state and visual identity.
class CompanyHomeSummary extends Equatable {
  const CompanyHomeSummary({
    required this.brandTitle,
    required this.brandLogoUrl,
    required this.isUnderReview,
    this.reviewProgress = 0.6,
    this.notificationsCount = 0,
  });

  final String brandTitle;
  final String brandLogoUrl;
  final bool isUnderReview;
  final double reviewProgress;
  final int notificationsCount;

  /// Tolerant parser to absorb backend key drift before launch.
  factory CompanyHomeSummary.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final Object? underReviewRaw =
        json['is_under_review'] ??
        json['isUnderReview'] ??
        json['under_review'];
    final bool isUnderReview = underReviewRaw is bool
        ? underReviewRaw
        : underReviewRaw?.toString().toLowerCase() == 'true';

    final Object? progressRaw =
        json['review_progress'] ?? json['reviewProgress'] ?? json['progress'];
    final double progress = progressRaw is num
        ? progressRaw.toDouble().clamp(0.0, 1.0)
        : double.tryParse(progressRaw?.toString() ?? '')?.clamp(0.0, 1.0) ??
              0.6;

    final Object? notifRaw =
        json['notifications_count'] ??
        json['notificationsCount'] ??
        json['unread'];
    final int notifications = notifRaw is num
        ? notifRaw.toInt()
        : int.tryParse(notifRaw?.toString() ?? '') ?? 0;

    return CompanyHomeSummary(
      brandTitle: pickString(<String>[
        'brand_title',
        'brandTitle',
        'app_title',
        'title',
        'name',
      ]),
      brandLogoUrl: ApiMedia.resolve(pickString(<String>[
        'brand_logo_url',
        'brandLogoUrl',
        'logo_url',
        'logoUrl',
        'image_url',
        'imageUrl',
      ])),
      isUnderReview: isUnderReview,
      reviewProgress: progress,
      notificationsCount: notifications,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    brandTitle,
    brandLogoUrl,
    isUnderReview,
    reviewProgress,
    notificationsCount,
  ];
}

enum CompanyCampaignStatus { completed, pendingApproval, active }

class CompanyHomeCampaign extends Equatable {
  const CompanyHomeCampaign({
    required this.id,
    required this.title,
    required this.status,
    required this.coverImageUrl,
    required this.amountValue,
    required this.dateLabel,
    required this.code,
    required this.progress,
  });

  final String id;
  final String title;
  final CompanyCampaignStatus status;
  final String coverImageUrl;
  final num amountValue;
  final String dateLabel;
  final String code;
  final double progress;

  factory CompanyHomeCampaign.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final String statusRaw = pickString(<String>[
      'status',
      'state',
    ]).toLowerCase();
    final CompanyCampaignStatus status;
    if (statusRaw.contains('complete')) {
      status = CompanyCampaignStatus.completed;
    } else if (statusRaw.contains('pending')) {
      status = CompanyCampaignStatus.pendingApproval;
    } else {
      status = CompanyCampaignStatus.active;
    }

    final Object? amountRaw =
        json['amount'] ?? json['raised'] ?? json['amount_value'];
    final num amount = amountRaw is num
        ? amountRaw
        : num.tryParse(amountRaw?.toString() ?? '') ?? 0;

    final Object? progressRaw = json['progress'] ?? json['progressPercent'];
    final double progress = progressRaw is num
        ? progressRaw.toDouble().clamp(0.0, 1.0)
        : double.tryParse(progressRaw?.toString() ?? '')?.clamp(0.0, 1.0) ??
              0.0;

    return CompanyHomeCampaign(
      id: pickString(<String>['id', 'uuid']),
      title: pickString(<String>['title', 'name', 'campaign_title']),
      status: status,
      coverImageUrl: ApiMedia.resolve(pickString(<String>[
        'cover_image_url',
        'coverImageUrl',
        'image_url',
        'imageUrl',
        'cover',
      ])),
      amountValue: amount,
      dateLabel: pickString(<String>[
        'date_label',
        'dateLabel',
        'date',
        'created_at_label',
      ]),
      code: pickString(<String>['code', 'reference', 'ref', 'campaign_code']),
      progress: progress,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    status,
    coverImageUrl,
    amountValue,
    dateLabel,
    code,
    progress,
  ];
}

class CompanyHomeCategory extends Equatable {
  const CompanyHomeCategory({
    required this.id,
    required this.titleKey,
    required this.iconCodePoint,
    this.titleOverride,
  });

  final String id;
  final String titleKey;
  final int iconCodePoint;

  /// When non-null, takes precedence over [titleKey].
  final String? titleOverride;

  factory CompanyHomeCategory.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final String titleOverride = pickString(<String>['title', 'name', 'label']);
    return CompanyHomeCategory(
      id: pickString(<String>['id', 'uuid']),
      titleKey: pickString(<String>[
        'title_key',
        'titleKey',
        'localization_key',
      ]).ifEmptyUse('company_home_category_natural_disaster'),
      iconCodePoint: int.tryParse(
        pickString(<String>['icon_code_point', 'iconCodePoint']),
      ).orFallback(),
      titleOverride: titleOverride.isEmpty ? null : titleOverride,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    titleKey,
    iconCodePoint,
    titleOverride,
  ];
}

class CompanyHomeInfluencer extends Equatable {
  const CompanyHomeInfluencer({
    required this.id,
    required this.name,
    required this.handle,
    required this.coverImageUrl,
    required this.avatarUrl,
    required this.tagLabel,
  });

  final String id;
  final String name;
  final String handle;
  final String coverImageUrl;
  final String avatarUrl;
  final String tagLabel;

  factory CompanyHomeInfluencer.fromJson(Map<String, dynamic> json) {
    String pickString(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    return CompanyHomeInfluencer(
      id: pickString(<String>['id', 'uuid']),
      name: pickString(<String>['name', 'full_name', 'display_name']),
      handle: pickString(<String>['handle', 'username', 'user_handle']),
      coverImageUrl: ApiMedia.resolve(pickString(<String>[
        'cover_image_url',
        'coverImageUrl',
        'image_url',
        'photo',
      ])),
      avatarUrl: ApiMedia.resolve(pickString(<String>[
        'avatar_url',
        'avatarUrl',
        'profile_image',
      ])),
      tagLabel: pickString(<String>[
        'tag_label',
        'tagLabel',
        'category',
        'niche',
      ]),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    handle,
    coverImageUrl,
    avatarUrl,
    tagLabel,
  ];
}

extension on String {
  String ifEmptyUse(String fallback) => isEmpty ? fallback : this;
}

extension on int? {
  int orFallback() => this ?? 0;
}

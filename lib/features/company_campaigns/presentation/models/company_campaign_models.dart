import 'package:equatable/equatable.dart';

/// List filter chips on the campaigns tab.
enum CompanyCampaignFilter {
  all,
  completed,
  cancelled,
  newPending,
  pendingClientReview,
}

/// Campaign lifecycle status (UI + future API mapping).
enum CompanyCampaignListStatus {
  completed,
  newPendingApproval,
  cancelled,
  pendingClientReview,
}

class CompanyCampaignListItem extends Equatable {
  const CompanyCampaignListItem({
    required this.id,
    required this.title,
    required this.status,
    required this.coverImageUrl,
    required this.amountValue,
    required this.dateLabel,
    required this.code,
    required this.progressSegmentsFilled,
  });

  final String id;
  final String title;
  final CompanyCampaignListStatus status;
  final String coverImageUrl;
  final num amountValue;
  final String dateLabel;
  final String code;

  /// Filled segments out of 4 for the segmented progress bar.
  final int progressSegmentsFilled;

  /// Tolerant parser for `GET /auth/campaigns` rows (key names may drift before
  /// the backend payload is finalized).
  factory CompanyCampaignListItem.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(v);
          for (final String nestedKey in <String>[
            'value',
            'label',
            'name',
            'title',
          ]) {
            final Object? nested = map[nestedKey];
            if (nested != null && nested.toString().trim().isNotEmpty) {
              return nested.toString();
            }
          }
        }
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final String statusRaw = pick(<String>['status', 'state']).toLowerCase();
    final CompanyCampaignListStatus status;
    if (statusRaw.contains('complete') || statusRaw.contains('approved')) {
      status = CompanyCampaignListStatus.completed;
    } else if (statusRaw.contains('cancel') ||
        statusRaw.contains('decline') ||
        statusRaw.contains('reject')) {
      status = CompanyCampaignListStatus.cancelled;
    } else if (statusRaw.contains('review')) {
      status = CompanyCampaignListStatus.pendingClientReview;
    } else {
      status = CompanyCampaignListStatus.newPendingApproval;
    }

    final Object? amountRaw =
        json['amount'] ??
        json['budget'] ??
        json['amount_value'] ??
        json['total'] ??
        json['budget_to'] ??
        json['budget_from'];
    final num amount = amountRaw is num
        ? amountRaw
        : num.tryParse(amountRaw?.toString() ?? '') ?? 0;

    final Object? segmentsRaw =
        json['progress_segments_filled'] ?? json['progress_segments'];
    final int segments = segmentsRaw is num
        ? segmentsRaw.toInt().clamp(0, 4)
        : _defaultSegments(status);

    return CompanyCampaignListItem(
      id: pick(<String>['id', 'uuid']),
      title: pick(<String>['title', 'name', 'campaign_title']),
      status: status,
      coverImageUrl: pick(<String>[
        'cover_image_url',
        'coverImageUrl',
        'image_url',
        'cover',
        'image',
      ]),
      amountValue: amount,
      dateLabel: pick(<String>[
        'date_label',
        'dateLabel',
        'delivery_date',
        'date',
        'created_at',
      ]),
      code: pick(<String>['code', 'reference', 'ref', 'number', 'id']),
      progressSegmentsFilled: segments,
    );
  }

  static int _defaultSegments(CompanyCampaignListStatus status) {
    switch (status) {
      case CompanyCampaignListStatus.completed:
      case CompanyCampaignListStatus.cancelled:
        return 4;
      case CompanyCampaignListStatus.pendingClientReview:
        return 3;
      case CompanyCampaignListStatus.newPendingApproval:
        return 1;
    }
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
    progressSegmentsFilled,
  ];
}

class CompanyCampaignCreatorSummary extends Equatable {
  const CompanyCampaignCreatorSummary({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.priceLabel,
    this.platforms = const <String>[],
  });

  final String id;
  final String name;
  final String avatarUrl;
  final CompanyCampaignListStatus status;
  final String priceLabel;
  final List<String> platforms;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    avatarUrl,
    status,
    priceLabel,
    platforms,
  ];
}

/// Full campaign detail for the details screen (mock until API).
class CompanyCampaignDetail extends Equatable {
  const CompanyCampaignDetail({
    required this.id,
    required this.title,
    required this.status,
    required this.coverImageUrl,
    required this.statusLabelKey,
    required this.deliveryDateLabel,
    required this.progressSegmentsFilled,
    required this.creators,
    required this.brandName,
    required this.website,
    required this.campaignTitle,
    required this.targetFollowers,
    required this.targetAgeGroup,
    required this.budgetMin,
    required this.budgetMax,
    required this.deliveryDateField,
    required this.detailsText,
    required this.attachedFileName,
    required this.selectedPlatforms,
    this.availablePlatforms = const <String>[],
  });

  factory CompanyCampaignDetail.empty(String id) {
    return CompanyCampaignDetail(
      id: id,
      title: '',
      status: CompanyCampaignListStatus.newPendingApproval,
      coverImageUrl: '',
      statusLabelKey: 'company_home_campaign_status_pending',
      deliveryDateLabel: '',
      progressSegmentsFilled: 1,
      creators: const <CompanyCampaignCreatorSummary>[],
      brandName: '',
      website: '',
      campaignTitle: '',
      targetFollowers: '',
      targetAgeGroup: '',
      budgetMin: '',
      budgetMax: '',
      deliveryDateField: '',
      detailsText: '',
      attachedFileName: '',
      selectedPlatforms: const <String>{},
      availablePlatforms: const <String>[],
    );
  }

  final String id;
  final String title;
  final CompanyCampaignListStatus status;
  final String coverImageUrl;
  final String statusLabelKey;
  final String deliveryDateLabel;
  final int progressSegmentsFilled;
  final List<CompanyCampaignCreatorSummary> creators;
  final String brandName;
  final String website;
  final String campaignTitle;
  final String targetFollowers;
  final String targetAgeGroup;
  final String budgetMin;
  final String budgetMax;
  final String deliveryDateField;
  final String detailsText;
  final String attachedFileName;
  final Set<String> selectedPlatforms;
  final List<String> availablePlatforms;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    status,
    coverImageUrl,
    statusLabelKey,
    deliveryDateLabel,
    progressSegmentsFilled,
    creators,
    brandName,
    website,
    campaignTitle,
    targetFollowers,
    targetAgeGroup,
    budgetMin,
    budgetMax,
    deliveryDateField,
    detailsText,
    attachedFileName,
    selectedPlatforms,
    availablePlatforms,
  ];
}

class CompanyCampaignInfluencerDetail extends Equatable {
  const CompanyCampaignInfluencerDetail({
    required this.id,
    required this.name,
    required this.headline,
    required this.avatarUrl,
    required this.statusLabelKey,
    required this.priceLabel,
    required this.files,
    required this.links,
    required this.orderLines,
    required this.totalWithTax,
    required this.depositAmount,
    required this.releasedAmount,
    this.socialPlatforms = const <String>[],
  });

  final String id;
  final String name;
  final String headline;
  final String avatarUrl;
  final String statusLabelKey;
  final String priceLabel;
  final List<String> socialPlatforms;
  final List<({String name, String sizeLabel})> files;
  final List<String> links;
  final List<({String labelKey, String value})> orderLines;
  final String totalWithTax;
  final String depositAmount;
  final String releasedAmount;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    headline,
    avatarUrl,
    statusLabelKey,
    priceLabel,
    socialPlatforms,
    files,
    links,
    orderLines,
    totalWithTax,
    depositAmount,
    releasedAmount,
  ];
}

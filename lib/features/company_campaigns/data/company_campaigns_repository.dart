import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_media.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart'
    show ApiException;
import 'package:adzmavall/features/company_campaigns/data/company_campaigns_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';
import 'package:dio/dio.dart';

/// Loads the authenticated brand's campaigns from `GET /auth/campaigns` and a
/// single campaign from `GET /brand/campaigns/{id}`.
///
/// Parsing tolerates backend key drift; callers fall back to
/// [CompanyCampaignsViewData] when the list is empty or the call fails.
class CompanyCampaignsRepository {
  CompanyCampaignsRepository(this._dio);

  final Dio _dio;

  Future<List<CompanyCampaignListItem>> fetchCampaigns() async {
    final String url = ApiUrlResolver.resolve(ApiEndpoints.authCampaignsPath);
    final Response<dynamic> res = await _dio.get<dynamic>(url);
    return _extractList(res.data)
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (Map<dynamic, dynamic> e) =>
              CompanyCampaignListItem.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
  }

  /// Fetches one campaign's full detail from the live brand API.
  Future<CompanyCampaignDetail> fetchCampaignDetail(String id) async {
    final CompanyCampaignDetail base = CompanyCampaignDetail.empty(id);
    final String url = ApiUrlResolver.resolve(
      ApiEndpoints.brandCampaignPath(id),
    );
    final Response<dynamic> res = await _dio.get<dynamic>(url);
    final Map<String, dynamic> json = _extractMap(res.data);
    if (json.isEmpty) {
      return base;
    }

    String pick(List<String> keys, String fallback) {
      return _pickFromMaps(
        <Map<String, dynamic>>[json, ..._nestedMaps(json)],
        keys,
        fallback,
      );
    }

    final String title = pick(<String>[
      'title',
      'name',
      'campaign_title',
    ], base.title);
    final CompanyCampaignListStatus status = _statusFromRaw(
      pick(<String>['status', 'state'], ''),
      base.status,
    );
    final List<CompanyCampaignCreatorSummary> creators = _parseCreators(json);
    final Set<String> selectedPlatforms = _parsePlatforms(json);
    final List<String> availablePlatforms = selectedPlatforms
        .where((String p) => p.trim().isNotEmpty)
        .toList();
    final String attachment = pick(<String>[
      'attached_file_name',
      'attachedFileName',
      'attachment_name',
      'file_name',
      'fileName',
    ], base.attachedFileName);

    return CompanyCampaignDetail(
      id: pick(<String>['id', 'uuid'], base.id),
      title: title,
      status: status,
      coverImageUrl: ApiMedia.resolve(
        pick(<String>[
          'cover_image_url',
          'image_url',
          'cover',
          'image',
        ], base.coverImageUrl),
      ),
      statusLabelKey: _statusLabelKey(status, base.statusLabelKey),
      deliveryDateLabel: pick(<String>[
        'delivery_date',
        'date_label',
        'date',
      ], base.deliveryDateLabel),
      progressSegmentsFilled: _progressSegments(json, status),
      creators: creators,
      brandName: pick(<String>['brand_name', 'company_name'], base.brandName),
      website: pick(<String>[
        'website_link',
        'website',
        'website_url',
      ], base.website),
      campaignTitle: title,
      targetFollowers: pick(<String>[
        'target_followers',
        'followers',
      ], base.targetFollowers),
      targetAgeGroup: pick(<String>[
        'target_age_group',
        'age_group',
      ], base.targetAgeGroup),
      budgetMin: pick(<String>['budget_from', 'budget_min'], base.budgetMin),
      budgetMax: pick(<String>['budget_to', 'budget_max'], base.budgetMax),
      deliveryDateField: pick(<String>[
        'delivery_date',
      ], base.deliveryDateField),
      detailsText: pick(<String>[
        'description',
        'details',
        'brief',
      ], base.detailsText),
      attachedFileName: attachment,
      selectedPlatforms: selectedPlatforms,
      availablePlatforms: availablePlatforms,
    );
  }

  Future<CompanyCampaignInfluencerDetail> fetchCampaignInfluencerDetail(
    String campaignRequestId,
  ) async {
    final CompanyCampaignInfluencerDetail base =
        CompanyCampaignInfluencerDetail.empty(campaignRequestId);
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(
        ApiEndpoints.brandCampaignRequestPath(campaignRequestId),
      ),
    );
    final Map<String, dynamic> json = _extractMap(res.data);
    if (json.isEmpty) {
      return base;
    }
    final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[
      json,
      ..._nestedMaps(json),
    ];
    String pick(List<String> keys, String fallback) =>
        _pickFromMaps(maps, keys, fallback);

    final List<String> platforms = _parsePlatforms(json).toList();
    final List<({String name, String sizeLabel})> files =
        await _fetchDeliverableFiles(campaignRequestId, _parseFiles(json));
    final List<String> links = await _fetchDeliverableLinks(
      campaignRequestId,
      _parseLinks(json),
    );
    final String total = pick(<String>[
      'total_with_tax',
      'totalWithTax',
      'total',
      'amount',
      'price',
      'budget',
    ], base.totalWithTax);

    return CompanyCampaignInfluencerDetail(
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
        'creator_type',
        'creatorType',
        'type',
      ], base.headline),
      avatarUrl: ApiMedia.resolve(
        pick(<String>[
          'avatar_url',
          'avatarUrl',
          'profile_image_url',
          'profileImageUrl',
          'image_url',
          'imageUrl',
          'photo',
        ], base.avatarUrl),
      ),
      statusLabelKey: _statusLabelKey(
        _statusFromRaw(
          pick(<String>['status', 'state'], ''),
          CompanyCampaignListStatus.pendingClientReview,
        ),
        base.statusLabelKey,
      ),
      priceLabel: pick(<String>[
        'price_label',
        'priceLabel',
        'price',
        'amount',
        'total',
        'budget',
      ], base.priceLabel),
      socialPlatforms: platforms.isEmpty ? base.socialPlatforms : platforms,
      files: files,
      links: links,
      orderLines: _orderLines(json, base.orderLines),
      totalWithTax: total,
      depositAmount: pick(<String>[
        'deposit_amount',
        'depositAmount',
        'deposit',
      ], base.depositAmount),
      releasedAmount: pick(<String>[
        'released_amount',
        'releasedAmount',
        'released',
      ], base.releasedAmount),
    );
  }

  /// Creates a campaign via `POST /brand/campaigns`.
  Future<void> createCampaign({
    required String title,
    required String description,
    required String deliveryDate,
    required String brandName,
    required String websiteLink,
    required num budgetFrom,
    required num budgetTo,
    required String creatorType,
    required bool faceVisible,
    required bool hairVisible,
    required bool handsVisible,
    required List<String> platforms,
    String? targetFollowers,
    String? targetAudienceAgeGroup,
    Map<String, dynamic> extraFields = const <String, dynamic>{},
  }) async {
    final String url = ApiUrlResolver.resolve(ApiEndpoints.brandCampaignsPath);
    try {
      await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{
          'title': title,
          'description': description,
          'delivery_date': deliveryDate,
          if (brandName.trim().isNotEmpty) 'brand_name': brandName,
          if (websiteLink.trim().isNotEmpty) 'website_link': websiteLink,
          if (budgetFrom > 0) 'budget_from': budgetFrom,
          if (budgetTo > 0) 'budget_to': budgetTo,
          if (targetFollowers != null && targetFollowers.trim().isNotEmpty)
            'target_followers': targetFollowers,
          if (targetAudienceAgeGroup != null &&
              targetAudienceAgeGroup.trim().isNotEmpty)
            'target_audience_age_group': targetAudienceAgeGroup,
          'platforms': platforms,
          'creator_type': _creatorTypeValue(creatorType),
          'face_visibility': faceVisible ? 'yes' : 'no',
          'show_hair': hairVisible ? 'yes' : 'no',
          'hands_visibility': handsVisible ? 'yes' : 'no',
          ...extraFields,
        },
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  Future<Map<String, dynamic>> createCampaignRequest({
    required String campaignId,
    required Map<String, dynamic> body,
  }) async {
    try {
      final Response<dynamic> res = await _dio.post<dynamic>(
        ApiUrlResolver.resolve(
          ApiEndpoints.brandCampaignRequestsPath(campaignId),
        ),
        data: body,
      );
      return _extractMap(res.data);
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  static String _creatorTypeValue(String label) {
    return switch (label) {
      'Influencer' => 'influencer',
      'Model' => 'model',
      'UGC Creator' => 'ugc',
      'Collage' => 'collage',
      _ => label.toLowerCase().replaceAll(' ', '_'),
    };
  }

  static Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner = map['data'] ?? map['result'] ?? map['campaign'];
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
        'campaigns',
      ]) {
        final Object? v = map[key];
        if (v is List<dynamic>) {
          return v;
        }
      }
    }
    return const <dynamic>[];
  }

  static List<Map<String, dynamic>> _nestedMaps(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[];
    for (final String key in <String>[
      'brand',
      'company',
      'creator',
      'content_creator',
      'contentCreator',
      'influencer',
      'request',
      'campaign_request',
      'campaignRequest',
      'profile',
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

    for (final Map<String, dynamic> map in maps) {
      for (final String key in keys) {
        final String text = stringify(map[key]);
        if (text.isNotEmpty) {
          return text;
        }
      }
    }
    return fallback;
  }

  static CompanyCampaignListStatus _statusFromRaw(
    String raw,
    CompanyCampaignListStatus fallback,
  ) {
    final String status = raw.toLowerCase();
    if (status.contains('complete') || status.contains('approved')) {
      return CompanyCampaignListStatus.completed;
    }
    if (status.contains('cancel') ||
        status.contains('decline') ||
        status.contains('reject')) {
      return CompanyCampaignListStatus.cancelled;
    }
    if (status.contains('review')) {
      return CompanyCampaignListStatus.pendingClientReview;
    }
    if (status.trim().isEmpty) {
      return fallback;
    }
    return CompanyCampaignListStatus.newPendingApproval;
  }

  static String _statusLabelKey(
    CompanyCampaignListStatus status,
    String fallback,
  ) {
    return switch (status) {
      CompanyCampaignListStatus.completed =>
        'company_campaign_status_approved_completed',
      CompanyCampaignListStatus.cancelled =>
        'company_campaign_status_cancelled',
      CompanyCampaignListStatus.pendingClientReview =>
        'company_campaign_status_pending_client',
      CompanyCampaignListStatus.newPendingApproval =>
        'company_home_campaign_status_pending',
    };
  }

  static int _progressSegments(
    Map<String, dynamic> json,
    CompanyCampaignListStatus status,
  ) {
    final Object? raw =
        json['progress_segments_filled'] ?? json['progress_segments'];
    if (raw is num) {
      return raw.toInt().clamp(0, 4);
    }
    return switch (status) {
      CompanyCampaignListStatus.completed ||
      CompanyCampaignListStatus.cancelled => 4,
      CompanyCampaignListStatus.pendingClientReview => 3,
      CompanyCampaignListStatus.newPendingApproval => 1,
    };
  }

  static List<CompanyCampaignCreatorSummary> _parseCreators(
    Map<String, dynamic> json,
  ) {
    final List<dynamic> rows = <dynamic>[
      ..._extractNamedLists(json, <String>[
        'creators',
        'content_creators',
        'contentCreators',
        'influencers',
        'requests',
        'campaign_requests',
        'campaignRequests',
      ]),
    ];
    return rows
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> row) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(row);
          final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[
            map,
            ..._nestedMaps(map),
          ];
          final String id = _pickFromMaps(maps, <String>['id', 'uuid']);
          return CompanyCampaignCreatorSummary(
            id: id,
            name: _pickFromMaps(maps, <String>[
              'name',
              'full_name',
              'fullName',
              'display_name',
              'displayName',
              'username',
            ], 'Creator'),
            avatarUrl: ApiMedia.resolve(
              _pickFromMaps(maps, <String>[
                'avatar_url',
                'avatarUrl',
                'profile_image_url',
                'profileImageUrl',
                'image_url',
                'imageUrl',
                'photo',
              ]),
            ),
            status: _statusFromRaw(
              _pickFromMaps(maps, <String>['status', 'state']),
              CompanyCampaignListStatus.newPendingApproval,
            ),
            priceLabel: _pickFromMaps(maps, <String>[
              'price_label',
              'priceLabel',
              'price',
              'amount',
              'total',
            ], '0'),
            platforms: _parsePlatforms(map).toList(),
          );
        })
        .where((CompanyCampaignCreatorSummary c) => c.id.trim().isNotEmpty)
        .toList();
  }

  static Set<String> _parsePlatforms(Map<String, dynamic> json) {
    final Set<String> platforms = <String>{};
    for (final String key in <String>[
      'platform',
      'platform_name',
      'platformName',
      'social',
    ]) {
      final Object? value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        platforms.add(value.toString().trim());
      }
    }
    for (final dynamic item in _extractNamedLists(json, <String>[
      'platforms',
      'social_platforms',
      'socialPlatforms',
      'social_accounts',
      'socialAccounts',
      'accounts',
      'items',
      'ugc_items',
      'ugcItems',
      'model_items',
      'modelItems',
      'collage_items',
      'collageItems',
    ])) {
      if (item is String) {
        platforms.add(item);
      } else if (item is Map) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);
        platforms.add(
          _pickFromMaps(
            <Map<String, dynamic>>[map],
            <String>[
              'platform',
              'platform_name',
              'platformName',
              'name',
              'label',
              'type',
              'value',
            ],
          ),
        );
      }
    }
    platforms.removeWhere((String p) => p.trim().isEmpty);
    return platforms;
  }

  static List<({String name, String sizeLabel})> _parseFiles(
    Map<String, dynamic> json,
  ) {
    return _extractNamedLists(json, <String>[
      'files',
      'attachments',
      'deliverable_files',
      'deliverableFiles',
    ]).whereType<Map<dynamic, dynamic>>().map((Map<dynamic, dynamic> row) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(row);
      return (
        name: _pickFromMaps(
          <Map<String, dynamic>>[map],
          <String>['name', 'file_name', 'fileName', 'title'],
          'File',
        ),
        sizeLabel: _pickFromMaps(
          <Map<String, dynamic>>[map],
          <String>['size_label', 'sizeLabel', 'size'],
        ),
      );
    }).toList();
  }

  Future<List<({String name, String sizeLabel})>> _fetchDeliverableFiles(
    String campaignRequestId,
    List<({String name, String sizeLabel})> fallback,
  ) async {
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(
        ApiUrlResolver.resolve(
          ApiEndpoints.applicationCampaignRequestDeliverableFilesPath(
            campaignRequestId,
          ),
        ),
      );
      final List<({String name, String sizeLabel})> files =
          _extractList(res.data).whereType<Map<dynamic, dynamic>>().map((
            Map<dynamic, dynamic> row,
          ) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(row);
            final Map<String, dynamic>? file = map['file'] is Map
                ? Map<String, dynamic>.from(map['file'] as Map)
                : null;
            final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[
              ?file,
              map,
            ];
            return (
              name: _pickFromMaps(maps, <String>[
                'name',
                'file_name',
                'fileName',
                'title',
                'url',
              ], 'File'),
              sizeLabel: _pickFromMaps(maps, <String>[
                'size_label',
                'sizeLabel',
                'size',
                'mime_type',
              ]),
            );
          }).toList();
      return files.isEmpty ? fallback : files;
    } on Object {
      return fallback;
    }
  }

  static List<String> _parseLinks(Map<String, dynamic> json) {
    return _extractNamedLists(json, <String>[
          'links',
          'urls',
          'deliverable_links',
          'deliverableLinks',
        ])
        .map((dynamic item) {
          if (item is Map) {
            return _pickFromMaps(
              <Map<String, dynamic>>[Map<String, dynamic>.from(item)],
              <String>['url', 'link', 'value'],
            );
          }
          return item.toString();
        })
        .where((String link) => link.trim().isNotEmpty)
        .toList();
  }

  Future<List<String>> _fetchDeliverableLinks(
    String campaignRequestId,
    List<String> fallback,
  ) async {
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(
        ApiUrlResolver.resolve(
          ApiEndpoints.applicationCampaignRequestDeliverableLinksPath(
            campaignRequestId,
          ),
        ),
      );
      final List<String> links = _extractList(res.data)
          .map((dynamic item) {
            if (item is Map) {
              return _pickFromMaps(
                <Map<String, dynamic>>[Map<String, dynamic>.from(item)],
                <String>['url', 'link', 'value'],
              );
            }
            return item.toString();
          })
          .where((String link) => link.trim().isNotEmpty)
          .toList();
      return links.isEmpty ? fallback : links;
    } on Object {
      return fallback;
    }
  }

  static List<({String labelKey, String value})> _orderLines(
    Map<String, dynamic> json,
    List<({String labelKey, String value})> fallback,
  ) {
    final List<({String labelKey, String value})> rows =
        <({String labelKey, String value})>[
          (
            labelKey: 'company_campaign_order_total',
            value: _pickFromMaps(
              <Map<String, dynamic>>[json],
              <String>['subtotal', 'sub_total', 'amount', 'price', 'budget'],
            ),
          ),
          (
            labelKey: 'company_campaign_order_listing_fee',
            value: _pickFromMaps(
              <Map<String, dynamic>>[json],
              <String>['platform_fee', 'platformFee', 'listing_fee'],
            ),
          ),
          (
            labelKey: 'company_campaign_order_before_vat',
            value: _pickFromMaps(
              <Map<String, dynamic>>[json],
              <String>['before_vat', 'beforeVat', 'before_tax'],
            ),
          ),
          (
            labelKey: 'company_campaign_order_tax',
            value: _pickFromMaps(
              <Map<String, dynamic>>[json],
              <String>['tax', 'vat', 'tax_amount', 'taxAmount'],
            ),
          ),
        ];
    rows.removeWhere((({String labelKey, String value}) row) {
      return row.value.trim().isEmpty;
    });
    return rows.isEmpty ? fallback : rows;
  }

  static List<dynamic> _extractNamedLists(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final List<dynamic> rows = <dynamic>[];
    for (final String key in keys) {
      final Object? value = json[key];
      if (value is List) {
        rows.addAll(value);
      }
    }
    for (final Map<String, dynamic> map in _nestedMaps(json)) {
      for (final String key in keys) {
        final Object? value = map[key];
        if (value is List) {
          rows.addAll(value);
        }
      }
    }
    return rows;
  }
}

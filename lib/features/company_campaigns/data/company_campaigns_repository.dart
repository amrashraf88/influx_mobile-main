import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_media.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
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

  /// Fetches one campaign's full detail. Any field the API omits keeps the
  /// matching [CompanyCampaignsViewData.detailFor] value so the screen stays
  /// complete.
  Future<CompanyCampaignDetail> fetchCampaignDetail(String id) async {
    final CompanyCampaignDetail base = CompanyCampaignsViewData.detailFor(id);
    final String url = ApiUrlResolver.resolve(
      ApiEndpoints.brandCampaignPath(id),
    );
    final Response<dynamic> res = await _dio.get<dynamic>(url);
    final Map<String, dynamic> json = _extractMap(res.data);
    if (json.isEmpty) {
      return base;
    }

    String pick(List<String> keys, String fallback) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return fallback;
    }

    final String title = pick(<String>[
      'title',
      'name',
      'campaign_title',
    ], base.title);

    return CompanyCampaignDetail(
      id: pick(<String>['id', 'uuid'], base.id),
      title: title,
      status: base.status,
      coverImageUrl: ApiMedia.resolve(pick(<String>[
        'cover_image_url',
        'image_url',
        'cover',
        'image',
      ], base.coverImageUrl)),
      statusLabelKey: base.statusLabelKey,
      deliveryDateLabel: pick(<String>[
        'delivery_date',
        'date_label',
        'date',
      ], base.deliveryDateLabel),
      progressSegmentsFilled: base.progressSegmentsFilled,
      creators: base.creators,
      brandName: pick(<String>[
        'brand_name',
        'company_name',
      ], base.brandName),
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
      attachedFileName: base.attachedFileName,
      selectedPlatforms: base.selectedPlatforms,
      availablePlatforms: base.availablePlatforms,
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
  }) async {
    final String url = ApiUrlResolver.resolve(ApiEndpoints.brandCampaignsPath);
    await _dio.post<dynamic>(
      url,
      data: <String, dynamic>{
        'title': title,
        'description': description,
        'delivery_date': deliveryDate,
        'brand_name': brandName,
        'website_link': websiteLink,
        'budget_from': budgetFrom,
        'budget_to': budgetTo,
      },
    );
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
}

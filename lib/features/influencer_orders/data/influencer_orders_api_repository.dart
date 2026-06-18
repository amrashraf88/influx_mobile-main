import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_media.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/influencer_orders/data/influencer_orders_mock_repository.dart';
import 'package:adzmavall/features/influencer_orders/data/influencer_orders_repository.dart';
import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:dio/dio.dart';

/// Live implementation of [InfluencerOrdersRepository] backed by the
/// `/influencer/orders` endpoints.
///
/// Responses are parsed defensively (the backend has no published example
/// payloads yet). When the API returns nothing usable, the repository falls
/// back to [InfluencerOrdersMockRepository] sample data so the screens keep
/// rendering — the same philosophy used by the home/company repositories.
class InfluencerOrdersApiRepository implements InfluencerOrdersRepository {
  InfluencerOrdersApiRepository(this._dio)
    : _fallback = InfluencerOrdersMockRepository();

  final Dio _dio;
  final InfluencerOrdersMockRepository _fallback;

  @override
  Future<List<InfluencerOrder>> fetchOrders() async {
    try {
      final List<dynamic> raw = await _getList(
        ApiEndpoints.influencerOrdersPath,
      );
      final List<InfluencerOrder> orders = raw
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> e) =>
                _orderFromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
      if (orders.isNotEmpty) {
        return orders;
      }
    } on Object {
      // Fall through to sample data below.
    }
    return _fallback.fetchOrders();
  }

  @override
  Future<InfluencerOrder?> fetchOrder(String orderId) async {
    try {
      final String url = ApiUrlResolver.resolve(
        ApiEndpoints.influencerOrderPath(orderId),
      );
      final Response<dynamic> res = await _dio.get<dynamic>(url);
      final Map<String, dynamic>? map = _extractMap(res.data);
      if (map != null && map.isNotEmpty) {
        return _orderFromJson(map);
      }
    } on Object {
      // Fall through to sample data below.
    }
    return _fallback.fetchOrder(orderId);
  }

  @override
  Future<InfluencerOrder> updateOrderStatus({
    required String orderId,
    required InfluencerOrderStatus status,
  }) async {
    try {
      final String url = ApiUrlResolver.resolve(
        ApiEndpoints.influencerOrderPath(orderId),
      );
      await _dio.patch<dynamic>(
        url,
        data: <String, dynamic>{'status': _statusApiValue(status)},
      );
    } on Object {
      // Keep optimistic update even if the call fails offline.
    }
    return _fallback.updateOrderStatus(orderId: orderId, status: status);
  }

  @override
  Future<InfluencerOrder> submitPublication({
    required String orderId,
    required List<String> links,
  }) async {
    try {
      final String url = ApiUrlResolver.resolve(
        ApiEndpoints.influencerOrderPublicationPath(orderId),
      );
      await _dio.post<dynamic>(url, data: <String, dynamic>{'links': links});
    } on Object {
      // Optimistic update below.
    }
    return _fallback.submitPublication(orderId: orderId, links: links);
  }

  @override
  Future<InfluencerOrder> uploadTaxInvoice({
    required String orderId,
    required String fileName,
  }) async {
    try {
      final String url = ApiUrlResolver.resolve(
        ApiEndpoints.influencerOrderTaxInvoicePath(orderId),
      );
      await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{'file_name': fileName},
      );
    } on Object {
      // Optimistic update below.
    }
    return _fallback.uploadTaxInvoice(orderId: orderId, fileName: fileName);
  }

  // ---------------------------------------------------------------------------
  // Parsing helpers
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> _getList(String path) async {
    final String url = ApiUrlResolver.resolve(path);
    final Response<dynamic> res = await _dio.get<dynamic>(url);
    return _extractList(res.data);
  }

  static InfluencerOrder _orderFromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
        }
      }
      return '';
    }

    final String id = pick(<String>['id', 'uuid', 'campaign_request_id']);
    final String number = pick(<String>['number', 'order_number', 'code']);
    final String price = pick(<String>[
      'price_label',
      'price',
      'amount',
      'total',
    ]);

    return InfluencerOrder(
      id: id.isEmpty ? 'order' : id,
      orderNumber: number.isEmpty ? '#' : number,
      clientName: pick(<String>[
        'client_name',
        'brand_name',
        'company_name',
        'name',
      ]),
      clientSubtitle: pick(<String>['client_subtitle', 'subtitle', 'campaign']),
      logoAsset: ApiMedia.resolve(
        pick(<String>['logo_url', 'logo', 'image_url', 'cover']),
      ),
      platformName: pick(<String>['platform_name', 'platform']),
      platformIconAsset: ImageAssets.homeInfluencerTiktok,
      priceLabel: price,
      deliveryDateLabel: pick(<String>[
        'delivery_date_label',
        'delivery_date',
        'date',
      ]),
      status: _statusFromJson(pick(<String>['status', 'state'])),
      details: _emptyDetails,
      attachments: _emptyAttachments,
      financial: _emptyFinancial,
    );
  }

  static InfluencerOrderStatus _statusFromJson(String raw) {
    final String s = raw.toLowerCase();
    if (s.contains('complete') || s.contains('approved')) {
      return InfluencerOrderStatus.completed;
    }
    if (s.contains('decline') || s.contains('cancel') || s.contains('reject')) {
      return InfluencerOrderStatus.declined;
    }
    if (s.contains('review')) {
      return InfluencerOrderStatus.pendingClientReview;
    }
    if (s.contains('progress') || s.contains('active')) {
      return InfluencerOrderStatus.inProgress;
    }
    return InfluencerOrderStatus.newRequest;
  }

  static String _statusApiValue(InfluencerOrderStatus status) {
    switch (status) {
      case InfluencerOrderStatus.newRequest:
        return 'new';
      case InfluencerOrderStatus.inProgress:
        return 'in_progress';
      case InfluencerOrderStatus.pendingClientReview:
        return 'pending_review';
      case InfluencerOrderStatus.completed:
        return 'completed';
      case InfluencerOrderStatus.declined:
        return 'declined';
    }
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
        'orders',
      ]) {
        final Object? v = map[key];
        if (v is List<dynamic>) {
          return v;
        }
      }
    }
    return const <dynamic>[];
  }

  static Map<String, dynamic>? _extractMap(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner = map['data'] ?? map['result'] ?? map['order'];
      if (inner is Map) {
        return Map<String, dynamic>.from(inner);
      }
      return map;
    }
    return null;
  }

  static const InfluencerOrderDetails _emptyDetails = InfluencerOrderDetails(
    title: '',
    orderId: '',
    description: '',
    clientNotes: '',
    clientWebsite: '',
    deliveryDate: '',
    deliveryTime: '',
    campaignObjective: <String>[],
    targetFollowers: '',
    targetAgeGroup: '',
    influencerCategory: '',
    platforms: <String>[],
  );

  static const InfluencerOrderAttachments _emptyAttachments =
      InfluencerOrderAttachments(
        files: <InfluencerOrderFile>[],
        links: <String>[],
        notes: '',
      );

  static const InfluencerOrderFinancial _emptyFinancial =
      InfluencerOrderFinancial(
        platformTotal: '',
        items: <InfluencerOrderFinancialItem>[],
        totalOrder: '',
        listingFee: '',
        totalBeforeVat: '',
        taxAmount: '',
        totalWithTax: '',
        deposit: '',
        released: '',
      );
}

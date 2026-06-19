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
        pick(<String>['logo_asset', 'logo_url', 'logo', 'image_url', 'cover']),
      ),
      platformName: pick(<String>['platform_name', 'platform']),
      platformIconAsset: () {
        final String icon = ApiMedia.resolve(
          pick(<String>['platform_icon_asset', 'platform_icon']),
        );
        return icon.isNotEmpty ? icon : ImageAssets.homeInfluencerTiktok;
      }(),
      priceLabel: price,
      deliveryDateLabel: pick(<String>[
        'delivery_date_label',
        'delivery_date',
        'date',
      ]),
      status: _statusFromJson(pick(<String>['status', 'state'])),
      details: _detailsFromJson(json['details']),
      attachments: _attachmentsFromJson(json['attachments']),
      financial: _financialFromJson(json['financial']),
      publicationLinks: _stringList(json['publication_links']),
    );
  }

  static String _s(Object? v) =>
      (v == null || v.toString() == 'null') ? '' : v.toString();

  static List<String> _stringList(Object? v) {
    if (v is List) {
      return v
          .map((Object? e) => _s(e).trim())
          .where((String s) => s.isNotEmpty)
          .toList();
    }
    if (v is String && v.trim().isNotEmpty) {
      return <String>[v.trim()];
    }
    return const <String>[];
  }

  static InfluencerOrderDetails _detailsFromJson(Object? raw) {
    if (raw is! Map) return _emptyDetails;
    final Map<String, dynamic> m = Map<String, dynamic>.from(raw);
    String g(List<String> keys) {
      for (final String k in keys) {
        final String s = _s(m[k]).trim();
        if (s.isNotEmpty) return s;
      }
      return '';
    }

    return InfluencerOrderDetails(
      title: g(<String>['title']),
      orderId: g(<String>['order_id', 'id']),
      description: g(<String>['description']),
      clientNotes: g(<String>['client_notes', 'notes']),
      clientWebsite: g(<String>['client_website', 'website']),
      deliveryDate: g(<String>['delivery_date']),
      deliveryTime: g(<String>['delivery_time']),
      campaignObjective: _stringList(m['campaign_objective']),
      targetFollowers: g(<String>['target_followers']),
      targetAgeGroup: g(<String>['target_age_group']),
      influencerCategory: g(<String>['influencer_category']),
      platforms: _stringList(m['platforms']),
    );
  }

  static InfluencerOrderAttachments _attachmentsFromJson(Object? raw) {
    if (raw is! Map) return _emptyAttachments;
    final Map<String, dynamic> m = Map<String, dynamic>.from(raw);
    final Object? filesRaw = m['files'];
    final List<InfluencerOrderFile> files =
        (filesRaw is List ? filesRaw : const <dynamic>[])
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> f) {
              final Map<String, dynamic> fm = Map<String, dynamic>.from(f);
              return InfluencerOrderFile(
                name: _s(fm['name']),
                sizeLabel: _s(fm['size_label'] ?? fm['size']),
              );
            })
            .toList();
    final Object? taxPath = m['tax_invoice_path'];
    return InfluencerOrderAttachments(
      files: files,
      links: _stringList(m['links']),
      notes: _s(m['notes']),
      taxInvoicePath: _s(taxPath).isEmpty ? null : _s(taxPath),
    );
  }

  static InfluencerOrderFinancial _financialFromJson(Object? raw) {
    if (raw is! Map) return _emptyFinancial;
    final Map<String, dynamic> m = Map<String, dynamic>.from(raw);
    final Object? itemsRaw = m['items'];
    final List<InfluencerOrderFinancialItem> items =
        (itemsRaw is List ? itemsRaw : const <dynamic>[])
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> i) {
              final Map<String, dynamic> im = Map<String, dynamic>.from(i);
              return InfluencerOrderFinancialItem(
                label: _s(im['label'] ?? im['name']),
                amount: _s(im['amount'] ?? im['value'] ?? im['price']),
                icon: _s(im['icon']),
              );
            })
            .toList();
    return InfluencerOrderFinancial(
      platformTotal: _s(m['platform_total']),
      items: items,
      totalOrder: _s(m['total_order']),
      listingFee: _s(m['listing_fee']),
      totalBeforeVat: _s(m['total_before_vat']),
      taxAmount: _s(m['tax_amount']),
      totalWithTax: _s(m['total_with_tax']),
      deposit: _s(m['deposit']),
      released: _s(m['released']),
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

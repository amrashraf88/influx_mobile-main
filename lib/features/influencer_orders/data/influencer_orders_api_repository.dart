import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_media.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart'
    show ApiException;
import 'package:adzmavall/features/influencer_orders/data/influencer_orders_repository.dart';
import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:dio/dio.dart';

/// Live implementation of [InfluencerOrdersRepository] backed by the
/// `/influencer/orders` endpoints.
///
/// Responses are parsed defensively (the backend has no published example
/// payloads yet). When the API returns nothing usable, the repository falls
/// back to empty/null instead of injecting sample orders.
class InfluencerOrdersApiRepository implements InfluencerOrdersRepository {
  InfluencerOrdersApiRepository(this._dio);

  final Dio _dio;

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
      return const <InfluencerOrder>[];
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
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
      return null;
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
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
      final Response<dynamic> res = await _dio.patch<dynamic>(
        url,
        data: <String, dynamic>{'status': _statusApiValue(status)},
      );
      final Map<String, dynamic>? map = _extractMap(res.data);
      if (map != null && map.isNotEmpty) {
        return _orderFromJson(map);
      }
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
    throw const ApiException('Unexpected order update response.');
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
      final Response<dynamic> res = await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{'links': links},
      );
      final Map<String, dynamic>? map = _extractMap(res.data);
      if (map != null && map.isNotEmpty) {
        return _orderFromJson(map);
      }
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
    throw const ApiException('Unexpected publication response.');
  }

  @override
  Future<InfluencerOrder> uploadTaxInvoice({
    required String orderId,
    required String fileName,
    required String filePath,
  }) async {
    try {
      final int mediaId = await _uploadMedia(filePath);
      final String url = ApiUrlResolver.resolve(
        ApiEndpoints.influencerOrderTaxInvoicePath(orderId),
      );
      final Response<dynamic> res = await _dio.post<dynamic>(
        url,
        data: <String, dynamic>{'file_name': fileName, 'media_id': mediaId},
      );
      final Map<String, dynamic>? map = _extractMap(res.data);
      if (map != null && map.isNotEmpty) {
        return _orderFromJson(map);
      }
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
    throw const ApiException('Unexpected tax invoice response.');
  }

  // ---------------------------------------------------------------------------
  // Parsing helpers
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> _getList(String path) async {
    final String url = ApiUrlResolver.resolve(path);
    final Response<dynamic> res = await _dio.get<dynamic>(url);
    return _extractList(res.data);
  }

  Future<int> _uploadMedia(String filePath) async {
    final Response<dynamic> res = await _dio.post<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.applicationMediaPath),
      data: FormData.fromMap(<String, dynamic>{
        'type': 'any',
        'attachment': await MultipartFile.fromFile(filePath),
      }),
    );
    final Map<String, dynamic>? map = _extractMap(res.data);
    final Object? id = map?['id'];
    if (id is num) {
      return id.toInt();
    }
    final int? parsed = int.tryParse(id?.toString() ?? '');
    if (parsed != null) {
      return parsed;
    }
    throw const ApiException('Unable to upload the selected file.');
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
        if (icon.isNotEmpty) return icon;
        return _platformIconAsset(pick(<String>['platform_name', 'platform']));
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

  /// Maps a platform name (English or Arabic) to its icon asset.
  static String _platformIconAsset(String rawName) {
    final String name = rawName.trim();
    final String s = name.toLowerCase();
    bool has(List<String> needles) =>
        needles.any((String n) => s.contains(n) || name.contains(n));

    if (has(<String>[
      'instagram',
      'insta',
      'إنستقرام',
      'انستقرام',
      'إنستجرام',
      'انستجرام',
      'انستغرام',
    ])) {
      return ImageAssets.instagramColoredIcon;
    }
    if (has(<String>['tiktok', 'tik tok', 'tik_tok', 'تيك توك', 'تيكتوك'])) {
      return ImageAssets.homeInfluencerTiktok;
    }
    if (has(<String>['snap', 'سناب'])) {
      return ImageAssets.snapchatIcon;
    }
    if (has(<String>['youtube', 'يوتيوب', 'يوتوب'])) {
      return ImageAssets.homeInfluencerYoutube;
    }
    if (has(<String>['whatsapp', 'whats', 'واتس', 'واتساب'])) {
      return ImageAssets.whatsappColoredIcon;
    }
    if (has(<String>['telegram', 'تيليجرام', 'تليجرام', 'تلجرام'])) {
      return ImageAssets.telegramColoredIcon;
    }
    if (has(<String>['threads', 'ثريد'])) {
      return ImageAssets.threadsIcon;
    }
    if (has(<String>['facebook', 'فيس بوك', 'فيسبوك'])) {
      return ImageAssets.homeInfluencerFacebook;
    }
    if (has(<String>['twitter', 'تويتر', 'إكس', 'اكس'])) {
      return ImageAssets.twitterIcon;
    }
    return ImageAssets.instagramColoredIcon;
  }

  /// Parses a money string ("10500", "10,500", "$75.50") to a number.
  static num? _money(Object? v) {
    final String s = _s(v);
    if (s.isEmpty) return null;
    return num.tryParse(s.replaceAll(RegExp(r'[^0-9.\-]'), ''));
  }

  /// Formats a number back to a plain string (no decimals when whole).
  static String _fmtMoney(num n) {
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(2);
  }

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
    // Listing fee and VAT are both 15%. The backend sometimes returns 0 for
    // them, so compute from the order total when that happens.
    const double listingRate = 0.15;
    const double vatRate = 0.15;

    final num base =
        _money(m['total_order']) ?? _money(m['platform_total']) ?? 0;
    final num apiListing = _money(m['listing_fee']) ?? 0;
    final num listing = apiListing > 0 ? apiListing : base * listingRate;
    final num beforeVat = _money(m['total_before_vat']) ?? base;
    final num apiTax = _money(m['tax_amount']) ?? 0;
    final num tax = apiTax > 0 ? apiTax : beforeVat * vatRate;
    final num apiWithTax = _money(m['total_with_tax']) ?? 0;
    final num withTax = (apiTax > 0 && apiWithTax > 0)
        ? apiWithTax
        : beforeVat + tax;

    return InfluencerOrderFinancial(
      platformTotal: _s(m['platform_total']),
      items: items,
      totalOrder: _fmtMoney(base),
      listingFee: _fmtMoney(listing),
      totalBeforeVat: _fmtMoney(beforeVat),
      taxAmount: _fmtMoney(tax),
      totalWithTax: _fmtMoney(withTax),
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
      for (final String key in <String>['data', 'results', 'items', 'orders']) {
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

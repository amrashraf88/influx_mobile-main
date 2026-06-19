import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_media.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/company_account/data/company_account_view_data.dart';
import 'package:adzmavall/features/company_account/presentation/models/company_account_models.dart';
import 'package:dio/dio.dart';

/// Loads the authenticated brand's account header from
/// `GET /auth/user/profile/brand`.
class CompanyAccountRepository {
  CompanyAccountRepository(this._dio);

  final Dio _dio;

  Future<CompanyAccountProfile> fetchProfile() async {
    final String url = ApiUrlResolver.resolve(
      ApiEndpoints.authUserProfileBrandPath,
    );
    final Response<dynamic> res = await _dio.get<dynamic>(url);
    final Map<String, dynamic> json = _extractMap(res.data);

    String pick(List<String> keys) {
      String stringify(Object? value) {
        if (value is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(value);
          for (final String nestedKey in <String>[
            'label',
            'name',
            'title',
            'value',
            'slug',
            'key',
          ]) {
            final Object? nested = map[nestedKey];
            if (nested != null && nested.toString().trim().isNotEmpty) {
              return nested.toString().trim();
            }
          }
        }
        return value?.toString().trim() ?? '';
      }

      for (final String k in keys) {
        final Object? v = json[k];
        final String text = stringify(v);
        if (text.isNotEmpty) {
          return text;
        }
      }
      return '';
    }

    final CompanyAccountProfile fallback = CompanyAccountViewData.profile;
    final String name = pick(<String>[
      'company_name',
      'name',
      'brand_name',
      'display_name',
    ]);
    final String phone = pick(<String>['phone_number', 'phone', 'mobile']);
    final String avatar = pick(<String>[
      'logo_url',
      'logo',
      'profile_image_url',
      'profileImageUrl',
      'image_url',
      'avatar_url',
      'image',
    ]);

    return CompanyAccountProfile(
      name: name.isEmpty ? fallback.name : name,
      phone: phone.isEmpty ? fallback.phone : phone,
      avatarUrl: ApiMedia.resolve(avatar.isEmpty ? fallback.avatarUrl : avatar),
      walletBalance: fallback.walletBalance,
    );
  }

  Future<List<CompanyBillItem>> fetchBills() async {
    final Response<dynamic> res = await _dio.get<dynamic>(
      ApiUrlResolver.resolve(ApiEndpoints.authCampaignsPath),
    );
    return _extractList(res.data)
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> row) {
          final Map<String, dynamic> json = Map<String, dynamic>.from(row);
          String pick(List<String> keys) {
            for (final String key in keys) {
              final Object? value = json[key];
              if (value != null && value.toString().trim().isNotEmpty) {
                return value.toString().trim();
              }
            }
            return '';
          }

          final Object? totalRaw =
              json['total_paid'] ??
              json['paid_total'] ??
              json['amount'] ??
              json['total'] ??
              json['budget'];
          final num total = totalRaw is num
              ? totalRaw
              : num.tryParse(totalRaw?.toString() ?? '') ?? 0;

          return CompanyBillItem(
            campaignId: pick(<String>[
              'code',
              'reference',
              'ref',
              'number',
              'id',
              'uuid',
            ]),
            totalPaid: total == 0
                ? pick(<String>['total_paid_label'])
                : '$total',
            invoiceUrl: pick(<String>[
              'invoice_url',
              'invoiceUrl',
              'bill_url',
              'billUrl',
              'receipt_url',
              'receiptUrl',
            ]),
          );
        })
        .where(
          (CompanyBillItem bill) =>
              bill.campaignId.trim().isNotEmpty ||
              bill.totalPaid.trim().isNotEmpty,
        )
        .toList();
  }

  static Map<String, dynamic> _extractMap(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner = map['data'] ?? map['result'] ?? map['profile'];
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
        'bills',
        'invoices',
      ]) {
        final Object? value = map[key];
        if (value is List<dynamic>) {
          return value;
        }
      }
    }
    return const <dynamic>[];
  }
}

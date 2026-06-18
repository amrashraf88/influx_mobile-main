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
      for (final String k in keys) {
        final Object? v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) {
          return v.toString();
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
}

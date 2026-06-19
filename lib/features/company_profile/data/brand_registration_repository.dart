import 'package:adzmavall/core/auth/auth_token_storage.dart';
import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart';
import 'package:adzmavall/features/profile/data/content_creator_registration_mapper.dart';
import 'package:dio/dio.dart';

class BrandRegistrationRepository {
  BrandRegistrationRepository(this._dio);

  final Dio _dio;

  Future<void> registerBrand(Map<String, dynamic> draft) async {
    final String url = ApiUrlResolver.resolve(ApiEndpoints.registerBrandPath);
    final Map<String, dynamic> body = Map<String, dynamic>.from(draft);
    final String documentPath =
        body.remove('business_register_document')?.toString().trim() ?? '';
    final String profileImagePath =
        body.remove('profile_picture_local_path')?.toString().trim() ?? '';

    body['phone'] = _digits(body['phone']);
    body['password'] ??= ContentCreatorRegistrationMapper.defaultPassword;

    final String? otpId = AuthTokenStorage.instance.otpVerificationId;
    if (otpId != null && otpId.isNotEmpty) {
      body['otp_verification_id'] = otpId;
    }

    body.removeWhere((String _, dynamic value) {
      if (value == null) {
        return true;
      }
      if (value is String) {
        return value.trim().isEmpty;
      }
      if (value is Iterable) {
        return value.isEmpty;
      }
      return false;
    });

    try {
      if (documentPath.isNotEmpty || profileImagePath.isNotEmpty) {
        if (documentPath.isNotEmpty) {
          body['business_register_document'] = await MultipartFile.fromFile(
            documentPath,
          );
        }
        if (profileImagePath.isNotEmpty) {
          body['profile_picture'] = await MultipartFile.fromFile(
            profileImagePath,
          );
        }
        await _dio.post<dynamic>(url, data: FormData.fromMap(body));
        return;
      }
      await _dio.post<dynamic>(url, data: body);
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  static String _digits(Object? value) =>
      (value?.toString() ?? '').replaceAll(RegExp(r'\D'), '');
}

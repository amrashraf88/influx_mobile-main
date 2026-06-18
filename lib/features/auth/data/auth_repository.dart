import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/models/otp_models.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<OtpInitiateResult> initiateOtp({
    required OtpAuthType type,
    required String identifier,
  }) async {
    final String url = ApiUrlResolver.resolve(ApiEndpoints.otpInitiatePath);
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        url,
        data: <String, String>{
          'type': type.apiValue,
          'identifier': identifier,
        },
      );
      return _parseInitiateResponse(response.data);
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  Future<OtpCompleteResult> completeOtp({
    required String verificationId,
    required String code,
  }) async {
    final String path = ApiEndpoints.otpCompletePath(verificationId);
    final String url = ApiUrlResolver.resolve(path);
    try {
      final Response<dynamic> response = await _dio.post<dynamic>(
        url,
        data: <String, String>{'code': code},
      );
      return _parseCompleteResponse(response.data);
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  static OtpInitiateResult _parseInitiateResponse(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner = map['data'];
      if (inner is Map) {
        return OtpInitiateResult.fromJson(Map<String, dynamic>.from(inner));
      }
      return OtpInitiateResult.fromJson(map);
    }
    throw const ApiException('Unexpected OTP initiate response.');
  }

  static OtpCompleteResult _parseCompleteResponse(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? inner = map['data'];
      if (inner is Map) {
        return OtpCompleteResult.fromJson(Map<String, dynamic>.from(inner));
      }
      return OtpCompleteResult.fromJson(map);
    }
    throw const ApiException('Unexpected OTP complete response.');
  }
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

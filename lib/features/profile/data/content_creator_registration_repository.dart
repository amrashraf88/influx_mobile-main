import 'package:adzmavall/core/auth/auth_token_storage.dart';
import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart';
import 'package:adzmavall/features/profile/data/content_creator_registration_mapper.dart';
import 'package:adzmavall/features/profile/presentation/cubit/influencer_profile_cubit.dart';
import 'package:dio/dio.dart';

class ContentCreatorRegistrationRepository {
  ContentCreatorRegistrationRepository(this._dio);

  final Dio _dio;

  Future<void> registerContentCreator(InfluencerProfileState state) async {
    final String url = ApiUrlResolver.resolve(ApiEndpoints.registerContentCreatorPath);
    final Map<String, dynamic> body =
        ContentCreatorRegistrationMapper.toRequestBody(state);

    // Link the registration to the verified OTP. The backend returns this id
    // from `otp-verifications/{id}/complete`; without it registration fails
    // with `invalid_otp`.
    final String? otpId = AuthTokenStorage.instance.otpVerificationId;
    if (otpId != null && otpId.isNotEmpty) {
      body['otp_verification_id'] = otpId;
    }

    try {
      await _dio.post<dynamic>(url, data: body);
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }
}

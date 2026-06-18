import 'package:adzmavall/core/routes/route_names.dart';

/// Decides where to go after a successful OTP complete.
abstract final class AuthPostOtpNavigator {
  static String routeAfterOtp({
    required String accountType,
    required String displayPhone,
    required bool hasExistingAccount,
  }) {
    if (hasExistingAccount) {
      if (accountType == 'company') {
        return RouteNames.companyHomePath(
          phone: displayPhone,
          registered: true,
        );
      }
      return RouteNames.influencerHome;
    }

    if (accountType == 'company') {
      return Uri(
        path: RouteNames.profileCompanyComplete,
        queryParameters: <String, String>{
          'phone': displayPhone,
          'account': accountType,
        },
      ).toString();
    }

    return Uri(
      path: RouteNames.profileInfluencerComplete,
      queryParameters: <String, String>{
        'phone': displayPhone,
        'account': accountType,
      },
    ).toString();
  }
}

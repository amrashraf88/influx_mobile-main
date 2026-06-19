import 'package:adzmavall/core/routes/route_names.dart';

/// Decides where to go after a successful OTP complete.
abstract final class AuthPostOtpNavigator {
  static String routeAfterOtp({
    required String accountType,
    required String displayPhone,
    required bool hasExistingAccount,
    String? creatorType,
    String? mode,
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

    if (mode == 'register' &&
        (creatorType == null || creatorType.trim().isEmpty)) {
      return RouteNames.authCreatorType;
    }

    return RouteNames.profileInfluencerCompletePath(
      phone: displayPhone,
      account: accountType,
      creatorType: creatorType,
    );
  }
}

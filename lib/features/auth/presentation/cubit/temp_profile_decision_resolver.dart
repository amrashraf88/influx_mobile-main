import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/auth/data/temp_auth_data.dart';
import 'package:adzmavall/features/auth/presentation/cubit/account_type_cubit.dart';

enum TempProfileDestination {
  companyHome,
  companyCompleteProfile,
  influencerHome,
  influencerCompleteProfile,
}

/// Post-OTP navigation using [TempAuthData] only; replace with API-driven logic later.
abstract final class TempProfileDecisionResolver {
  static TempProfileDestination resolve({
    required String accountType,
    required String phone,
  }) {
    final AccountTypeOption option = _parseAccountType(accountType);
    if (option == AccountTypeOption.company) {
      if (TempAuthData.registeredCompanyPhonesWithCompleteProfile.contains(
        phone.trim(),
      )) {
        return TempProfileDestination.companyHome;
      }

      return TempProfileDestination.companyCompleteProfile;
    }

    if (TempAuthData.registeredInfluencerPhonesWithCompleteProfile.contains(
      phone.trim(),
    )) {
      return TempProfileDestination.influencerHome;
    }

    return TempProfileDestination.influencerCompleteProfile;
  }

  static String routeForDestination(TempProfileDestination destination) {
    return switch (destination) {
      TempProfileDestination.companyHome => RouteNames.companyHome,
      TempProfileDestination.companyCompleteProfile =>
        RouteNames.profileCompanyComplete,
      TempProfileDestination.influencerHome => RouteNames.influencerHome,
      TempProfileDestination.influencerCompleteProfile =>
        RouteNames.profileInfluencerComplete,
    };
  }

  /// Same as [routeForDestination] but forwards the phone in the query so the
  /// company shell can decide between the registered and marketing home.
  static String routeForDestinationWithPhone(
    TempProfileDestination destination,
    String phone,
  ) {
    return switch (destination) {
      TempProfileDestination.companyHome => RouteNames.companyHomePath(
        phone: phone,
      ),
      TempProfileDestination.companyCompleteProfile =>
        RouteNames.profileCompanyComplete,
      TempProfileDestination.influencerHome => RouteNames.influencerHome,
      TempProfileDestination.influencerCompleteProfile =>
        RouteNames.profileInfluencerComplete,
    };
  }

  static String mainRouteForAccountType(String accountType) {
    final AccountTypeOption option = _parseAccountType(accountType);
    return option == AccountTypeOption.company
        ? RouteNames.companyHome
        : RouteNames.influencerHome;
  }

  static AccountTypeOption _parseAccountType(String value) {
    return AccountTypeOption.values.firstWhere(
      (AccountTypeOption option) => option.name == value,
      orElse: () => AccountTypeOption.influencer,
    );
  }
}

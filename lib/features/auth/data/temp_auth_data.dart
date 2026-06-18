/// Local-only auth and profile routing data until the backend is connected.
///
/// All phone checks here are stand-ins for future API responses such as
/// “user exists”, “profile complete”, or “needs onboarding”.
abstract final class TempAuthData {
  /// Phones treated as an existing company with a completed profile (login → home).
  static const Set<String> registeredCompanyPhonesWithCompleteProfile =
      <String>{'+966555555555'};

  /// Phones treated as an existing influencer with a completed profile (login → home).
  static const Set<String> registeredInfluencerPhonesWithCompleteProfile =
      <String>{'+966555555555'};
}

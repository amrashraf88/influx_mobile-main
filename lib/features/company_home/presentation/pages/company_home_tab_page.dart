import 'package:adzmavall/features/auth/data/temp_auth_data.dart';
import 'package:adzmavall/features/company_home/presentation/pages/company_home_registered_page.dart';
import 'package:adzmavall/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';

/// Decides which home a company sees:
///   - registered  → [CompanyHomeRegisteredPage] (data-filled)
///   - not yet     → marketing [HomePage] (the "skip login" landing screen)
///
/// The decision is purely temp-data based against [TempAuthData] until the
/// backend returns the same flag. [forceRegistered] is used for the
/// post-signup success transition where the user hasn't been added to the
/// temp registered set but is effectively registered for the rest of the run.
class CompanyHomeTabPage extends StatelessWidget {
  const CompanyHomeTabPage({
    super.key,
    required this.phone,
    this.forceRegistered = false,
  });

  final String phone;
  final bool forceRegistered;

  bool get _isRegistered =>
      forceRegistered ||
      TempAuthData.registeredCompanyPhonesWithCompleteProfile.contains(
        phone.trim(),
      );

  @override
  Widget build(BuildContext context) {
    if (_isRegistered) {
      return const CompanyHomeRegisteredPage();
    }
    return const HomePage(showInfluencerMarketingBottomNav: false);
  }
}

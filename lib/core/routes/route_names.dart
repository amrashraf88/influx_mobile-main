abstract final class RouteNames {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String companyHome = '/home/company';
  static const String companyChat = '/company/chat';
  static const String companyStars = '/company/stars';
  static const String companyCampaigns = '/company/campaigns';
  static const String companyCampaignDetails = '/company/campaign/:campaignId';
  static const String companyCampaignInfluencerDetails =
      '/company/campaign/:campaignId/influencer/:influencerId';
  static const String companyCreateCampaign = '/company/campaign/create';
  static const String companyStarsBrowse = '/company/stars/browse';
  static const String companyStarProfile = '/company/stars/profile/:starId';
  static const String companyRequestAd = '/company/request-ad/:starId';
  static const String companyAccount = '/company/account';
  static const String companyAccountWallet = '/company/account/wallet';
  static const String companyAccountBills = '/company/account/bills';
  static const String companyAccountLanguage = '/company/account/language';
  static const String companyAccountSettings = '/company/account/settings';
  static const String companyAccountAbout = '/company/account/about';
  static const String companyAccountContact = '/company/account/contact';
  static const String influencerHome = '/influencer/home';
  static const String influencerProfile = '/influencer/profile';
  static const String influencerOrders = '/influencer/orders';
  static const String influencerOrderDetails = '/influencer/orders/:orderId';
  static const String influencerChats = '/influencer/chats';
  static const String influencerChatDetails = '/influencer/chats/:threadId';
  static const String influencerSettings = '/influencer/settings';
  static const String authAccountType = '/auth/account-type';
  static const String authCreatorType = '/auth/creator-type';
  static const String authPhone = '/auth/phone';
  static const String authVerification = '/auth/verification';
  static const String profileInfluencerComplete =
      '/profile/influencer/complete';
  static const String profileCompanyComplete = '/profile/company/complete';
  static const String profileCompanyRegistrationSuccess =
      '/profile/company/registration-success';

  static String influencerOrderDetailsPath(String orderId) {
    return '/influencer/orders/$orderId';
  }

  static String influencerChatDetailsPath(String threadId) {
    return '/influencer/chats/$threadId';
  }

  /// Company home with the user's phone forwarded so the tab can pick the
  /// registered vs marketing home using [TempAuthData] (and later the API).
  ///
  /// Pass [registered] true for the post-signup success transition: the home
  /// shell will then show the registered (data-filled) home regardless of any
  /// temp-data lookup.
  static String companyCampaignDetailsPath(String campaignId) {
    return '/company/campaign/$campaignId';
  }

  static String companyCampaignInfluencerDetailsPath({
    required String campaignId,
    required String influencerId,
  }) {
    return '/company/campaign/$campaignId/influencer/$influencerId';
  }

  static String companyStarProfilePath(String starId) {
    return '/company/stars/profile/$starId';
  }

  static String companyRequestAdPath(String starId) {
    return '/company/request-ad/$starId';
  }

  static String companyHomePath({String? phone, bool registered = false}) {
    final Map<String, String> qp = <String, String>{
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone,
      if (registered) 'registered': 'true',
    };
    if (qp.isEmpty) {
      return companyHome;
    }
    return Uri(path: companyHome, queryParameters: qp).toString();
  }

  static String authPhonePath({
    required String account,
    String? creatorType,
    String? mode,
  }) {
    return Uri(
      path: authPhone,
      queryParameters: <String, String>{
        'account': account,
        if (creatorType != null && creatorType.trim().isNotEmpty)
          'creatorType': creatorType,
        if (mode != null && mode.trim().isNotEmpty) 'mode': mode,
      },
    ).toString();
  }

  static String profileInfluencerCompletePath({
    required String phone,
    String account = 'influencer',
    String? creatorType,
  }) {
    return Uri(
      path: profileInfluencerComplete,
      queryParameters: <String, String>{
        'phone': phone,
        'account': account,
        if (creatorType != null && creatorType.trim().isNotEmpty)
          'creatorType': creatorType,
      },
    ).toString();
  }
}

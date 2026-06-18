/// Backend origin without a trailing slash.
///
/// Pass at build/run time, for example:
/// `flutter run --dart-define=API_BASE_URL=${ApiEndpoints.defaultBaseUrl}`
///
/// When empty, the home screen uses [HomeViewData] fallbacks so the app still
/// runs before the API is wired.
abstract final class ApiEndpoints {
  /// Production API origin (`https://adzmavall.com/api/v1`) — matches the
  /// Adzmavall Postman collection. Switch to the test API at build/run time:
  /// `--dart-define=API_BASE_URL=https://test.api.adzmavall.com`.
  static const String defaultBaseUrl = 'https://adzmavall.com';

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );

  static const String apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: 'v1',
  );

  static String _v1(String suffix) => '/api/$apiVersion/$suffix';

  // ---------------------------------------------------------------------------
  // Meta & health
  // ---------------------------------------------------------------------------

  /// `GET` — API metadata.
  static String get apiMetaPath => '/api/$apiVersion';

  /// `GET` — health check.
  static String get healthPath => _v1('health');

  /// `GET` — verify a Mawthooq (Maroof) license number.
  static String mawthooqVerifyPath(String licenseNumber) =>
      _v1('mawthooq/verify/$licenseNumber');

  // ---------------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------------

  /// `POST` — body: `{ type, identifier }` (country code + phone, no `+`).
  static String get otpInitiatePath =>
      _v1('auth/otp-verifications/initiate');

  /// `POST` — body: `{ code }`.
  static String otpCompletePath(String verificationId) =>
      _v1('auth/otp-verifications/$verificationId/complete');

  /// `POST` — invalidate the current session.
  static String get authLogoutPath => _v1('auth/logout');

  /// `POST` — register a brand account (Bearer token required).
  static String get registerBrandPath => _v1('auth/register/brand');

  /// `POST` — register a content creator (Bearer token required).
  static String get registerContentCreatorPath =>
      _v1('auth/register/content-creator');

  /// `GET` — list campaign requests for the authenticated user.
  static String get authCampaignRequestsPath => _v1('auth/campaign-requests');

  /// `GET` — list campaigns for the authenticated user.
  static String get authCampaignsPath => _v1('auth/campaigns');

  /// `GET` — wallet balance and summary.
  static String get authWalletPath => _v1('auth/wallet');

  /// `GET` — wallet transaction history.
  static String get authWalletTransactionsPath =>
      _v1('auth/wallet/transactions');

  /// `GET` / `PUT` / `PATCH` — brand profile.
  static String get authUserProfileBrandPath => _v1('auth/user/profile/brand');

  /// `GET` / `PUT` / `PATCH` — content creator profile.
  static String get authUserProfileContentCreatorPath =>
      _v1('auth/user/profile/content-creator');

  /// `PUT` — body: current and new password fields.
  static String get authUserChangePasswordPath =>
      _v1('auth/user/change-password');

  /// `GET` / `POST` — user ads.
  static String get authUserAdsPath => _v1('auth/user/ads');

  /// `GET` / `PUT` / `PATCH` / `DELETE` — single ad.
  static String authUserAdPath(String adId) => _v1('auth/user/ads/$adId');

  /// `GET` / `POST` — user clients.
  static String get authUserClientsPath => _v1('auth/user/clients');

  /// `GET` / `PUT` / `PATCH` / `DELETE` — single client.
  static String authUserClientPath(String clientId) =>
      _v1('auth/user/clients/$clientId');

  /// `GET` / `POST` — linked social accounts.
  static String get authUserSocialAccountsPath =>
      _v1('auth/user/social-accounts');

  /// `GET` / `PUT` / `PATCH` / `DELETE` — single social account.
  static String authUserSocialAccountPath(String socialAccountId) =>
      _v1('auth/user/social-accounts/$socialAccountId');

  // ---------------------------------------------------------------------------
  // Lookup (Bearer token required)
  // ---------------------------------------------------------------------------

  static String get lookupCategoriesPath => _v1('lookup/categories');

  static String get lookupCitiesPath => _v1('lookup/cities');

  static String get lookupCityDirectionsPath => _v1('lookup/city-directions');

  static String get lookupCompaniesPath => _v1('lookup/companies');

  static String get lookupSocialPlatformsPath => _v1('lookup/social-platforms');

  static String get lookupContentCreatorTypesPath =>
      _v1('lookup/content-creator-types');

  static String get lookupModelCreatorAccentsPath =>
      _v1('lookup/model-content-creator-accents');

  static String get lookupModelCreatorSizesPath =>
      _v1('lookup/model-content-creator-sizes');

  static String get lookupModelCreatorSkinTonesPath =>
      _v1('lookup/model-content-creator-skin-tones');

  static String get lookupAdContentTypesPath => _v1('lookup/ad-content-types');

  static String get lookupNotificationTypesPath =>
      _v1('lookup/notifications-types');

  static String get lookupUserStatesPath => _v1('lookup/user-states');

  // ---------------------------------------------------------------------------
  // Home
  // ---------------------------------------------------------------------------

  static String get homeCategoriesPath => _v1('home/categories');

  static String get homeSearchHintPath => _v1('home/search-hint');

  static String get homeTrendingTagsPath => _v1('home/trending-tags');

  static String get homeWelcomePath => _v1('home/welcome');

  static String get homeWhyFeaturesPath => _v1('home/why-features');

  // ---------------------------------------------------------------------------
  // Stories & influencers
  // ---------------------------------------------------------------------------

  static String get topStoriesPath => _v1('stories/top');

  static String get topInfluencersPath => _v1('influencers/top');

  // ---------------------------------------------------------------------------
  // Company home
  // ---------------------------------------------------------------------------

  static String get companyHomeSummaryPath => _v1('company/home/summary');

  static String get companyCurrentCampaignsPath => _v1('company/home/campaigns');

  static String get companyHomeCategoriesPath => _v1('company/home/categories');

  static String get companyHomeInfluencersPath => _v1('company/home/influencers');

  // ---------------------------------------------------------------------------
  // Influencer (content creator app)
  // ---------------------------------------------------------------------------

  static String get influencerOrdersPath => _v1('influencer/orders');

  static String influencerOrderPath(String campaignRequestId) =>
      _v1('influencer/orders/$campaignRequestId');

  static String influencerOrderPublicationPath(String campaignRequestId) =>
      _v1('influencer/orders/$campaignRequestId/publication');

  static String influencerOrderTaxInvoicePath(String campaignRequestId) =>
      _v1('influencer/orders/$campaignRequestId/tax-invoice');

  static String get influencerChatsPath => _v1('influencer/chats');

  static String influencerChatPath(String chatId) =>
      _v1('influencer/chats/$chatId');

  static String influencerChatMessagesPath(String chatId) =>
      _v1('influencer/chats/$chatId/messages');

  static String influencerChatFilesPath(String chatId) =>
      _v1('influencer/chats/$chatId/files');

  static String influencerChatVoicePath(String chatId) =>
      _v1('influencer/chats/$chatId/voice');

  static String influencerChatCallPath(String chatId) =>
      _v1('influencer/chats/$chatId/call');

  // ---------------------------------------------------------------------------
  // Brand
  // ---------------------------------------------------------------------------

  static String get brandCampaignsPath => _v1('brand/campaigns');

  static String brandCampaignPath(String campaignId) =>
      _v1('brand/campaigns/$campaignId');

  static String brandCampaignRequestsPath(String campaignId) =>
      _v1('brand/campaigns/$campaignId/requests');

  static String get brandCampaignsAiBriefPath => _v1('brand/campaigns/ai-brief');

  static String brandCampaignRequestPath(String campaignRequestId) =>
      _v1('brand/campaign-requests/$campaignRequestId');

  static String brandCampaignRequestCompletePath(String campaignRequestId) =>
      _v1('brand/campaign-requests/$campaignRequestId/complete');

  static String brandCampaignRequestReleasePath(String campaignRequestId) =>
      _v1('brand/campaign-requests/$campaignRequestId/release');

  static String get brandContentCreatorsPath => _v1('brand/content-creators');

  static String brandContentCreatorPath(String contentCreatorId) =>
      _v1('brand/content-creators/$contentCreatorId');

  /// `POST` — toggle favorite state for a content creator.
  static String brandContentCreatorFavoriteTogglePath(
    String contentCreatorId,
  ) =>
      _v1('brand/content-creators/$contentCreatorId/favorite-toggle');

  static String get brandChatsPath => _v1('brand/chats');

  static String brandChatPath(String chatId) => _v1('brand/chats/$chatId');

  static String brandChatMessagesPath(String chatId) =>
      _v1('brand/chats/$chatId/messages');

  static String brandChatFilesPath(String chatId) =>
      _v1('brand/chats/$chatId/files');

  static String brandChatVoicePath(String chatId) =>
      _v1('brand/chats/$chatId/voice');

  static String brandChatCallPath(String chatId) =>
      _v1('brand/chats/$chatId/call');

  // ---------------------------------------------------------------------------
  // Content creator (campaign requests)
  // ---------------------------------------------------------------------------

  static String contentCreatorCampaignRequestPath(String campaignRequestId) =>
      _v1('content-creator/campaign-requests/$campaignRequestId');

  static String contentCreatorCampaignRequestApprovePath(
    String campaignRequestId,
  ) =>
      _v1('content-creator/campaign-requests/$campaignRequestId/approve');

  static String contentCreatorCampaignRequestRejectPath(
    String campaignRequestId,
  ) =>
      _v1('content-creator/campaign-requests/$campaignRequestId/reject');

  static String contentCreatorCampaignRequestAttachAdPath(
    String campaignRequestId,
  ) =>
      _v1('content-creator/campaign-requests/$campaignRequestId/attach-ad');

  static String contentCreatorCampaignRequestCompletePath(
    String campaignRequestId,
  ) =>
      _v1('content-creator/campaign-requests/$campaignRequestId/complete');

  // ---------------------------------------------------------------------------
  // Application (shared authenticated features)
  // ---------------------------------------------------------------------------

  static String get applicationMediaPath => _v1('application/media');

  static String applicationMediaItemPath(String mediaId) =>
      _v1('application/media/$mediaId');

  static String get applicationNotificationsPath =>
      _v1('application/notifications');

  static String get applicationNotificationsInsightsPath =>
      _v1('application/notifications/insights');

  static String get applicationNotificationsMarkAllReadPath =>
      _v1('application/notifications/mark-all-read');

  static String applicationNotificationMarkReadPath(String notificationId) =>
      _v1('application/notifications/$notificationId/mark-read');

  static String get applicationUserNotificationSettingsPath =>
      _v1('application/users/notification-settings');

  static String get applicationWalletChargeCardPath =>
      _v1('application/wallet/charge/card');

  static String get applicationWalletChargeCardCallbackPath =>
      _v1('application/wallet/charge/card/callback');

  static String get applicationWalletChargeTransferReceiptPath =>
      _v1('application/wallet/charge/transfer-receipt');

  static String get applicationWalletWithdrawPath =>
      _v1('application/wallet/withdraw');

  static String applicationCampaignRequestDeliverableFilesPath(
    String campaignRequestId,
  ) =>
      _v1(
        'application/campaign-requests/$campaignRequestId/deliverable-files',
      );

  static String applicationCampaignRequestDeliverableLinksPath(
    String campaignRequestId,
  ) =>
      _v1(
        'application/campaign-requests/$campaignRequestId/deliverable-links',
      );

  static String applicationCampaignRequestNotesPath(String campaignRequestId) =>
      _v1('application/campaign-requests/$campaignRequestId/notes');
}

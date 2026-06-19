import 'package:adzmavall/core/auth/auth_token_storage.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart';
import 'package:adzmavall/features/auth/presentation/cubit/account_type_cubit.dart';
import 'package:adzmavall/features/auth/presentation/cubit/auth_phone_cubit.dart';
import 'package:adzmavall/features/auth/presentation/cubit/otp_verification_cubit.dart';
import 'package:adzmavall/features/auth/presentation/pages/choose_account_type_page.dart';
import 'package:adzmavall/features/auth/presentation/pages/creator_type_selection_page.dart';
import 'package:adzmavall/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:adzmavall/features/auth/presentation/pages/phone_sign_in_page.dart';
import 'package:adzmavall/features/company_campaigns/presentation/pages/company_campaign_details_page.dart';
import 'package:adzmavall/features/company_campaigns/presentation/pages/company_campaign_influencer_details_page.dart';
import 'package:adzmavall/features/company_campaigns/presentation/pages/company_campaigns_page.dart';
import 'package:adzmavall/features/company_campaigns/presentation/pages/company_create_campaign_page.dart';
import 'package:adzmavall/features/company_campaigns/presentation/pages/company_request_ad_page.dart';
import 'package:adzmavall/features/company_campaigns/presentation/pages/company_star_profile_page.dart';
import 'package:adzmavall/features/company_campaigns/presentation/pages/company_stars_page.dart';
import 'package:adzmavall/features/company_home/presentation/pages/company_home_tab_page.dart';
import 'package:adzmavall/features/company_profile/presentation/pages/company_complete_profile_page.dart';
import 'package:adzmavall/features/company_profile/presentation/pages/company_registration_success_page.dart';
import 'package:adzmavall/features/company_account/presentation/pages/company_about_app_page.dart';
import 'package:adzmavall/features/company_account/presentation/pages/company_account_page.dart';
import 'package:adzmavall/features/company_account/presentation/pages/company_account_settings_page.dart';
import 'package:adzmavall/features/company_account/presentation/pages/company_contact_us_page.dart';
import 'package:adzmavall/features/company_account/presentation/pages/company_language_page.dart';
import 'package:adzmavall/features/company_account/presentation/pages/company_my_bills_page.dart';
import 'package:adzmavall/features/company_account/presentation/pages/company_wallet_page.dart';
import 'package:adzmavall/features/company_shell/presentation/pages/company_shell_page.dart';
import 'package:adzmavall/features/home/presentation/pages/home_page.dart';
import 'package:adzmavall/features/influencer_chat/presentation/pages/influencer_chat_details_page.dart';
import 'package:adzmavall/features/influencer_chat/presentation/pages/influencer_chats_page.dart';
import 'package:adzmavall/features/influencer_home/presentation/pages/influencer_home_page.dart';
import 'package:adzmavall/features/influencer_orders/presentation/pages/influencer_order_details_page.dart';
import 'package:adzmavall/features/influencer_orders/presentation/pages/influencer_orders_page.dart';
import 'package:adzmavall/features/influencer_profile/presentation/pages/influencer_profile_page.dart';
import 'package:adzmavall/features/influencer_settings/presentation/pages/influencer_settings_page.dart';
import 'package:adzmavall/features/influencer_shell/presentation/pages/influencer_shell_page.dart';
import 'package:adzmavall/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:adzmavall/features/profile/presentation/pages/influencer_complete_profile_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.onboarding,
    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: RouteNames.authAccountType,
        builder: (context, state) => BlocProvider<AccountTypeCubit>(
          create: (_) => AccountTypeCubit(),
          child: const ChooseAccountTypePage(),
        ),
      ),
      GoRoute(
        path: RouteNames.authCreatorType,
        builder: (context, state) => const CreatorTypeSelectionPage(),
      ),
      GoRoute(
        path: RouteNames.authPhone,
        builder: (context, state) {
          final String account =
              state.uri.queryParameters['account'] ?? 'influencer';
          final String? creatorType = state.uri.queryParameters['creatorType'];
          final String? mode = state.uri.queryParameters['mode'];
          return BlocProvider<AuthPhoneCubit>(
            create: (_) => AuthPhoneCubit(AuthRepository(DioClient.instance)),
            child: PhoneSignInPage(
              accountType: account,
              creatorType: creatorType,
              mode: mode,
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.authVerification,
        builder: (context, state) {
          final String account =
              state.uri.queryParameters['account'] ?? 'influencer';
          final String phone =
              state.uri.queryParameters['phone'] ?? '+966555555555';
          final String identifier =
              state.uri.queryParameters['identifier'] ?? '';
          final String otpId = state.uri.queryParameters['otpId'] ?? '';
          final String? creatorType = state.uri.queryParameters['creatorType'];
          final String? mode = state.uri.queryParameters['mode'];
          final bool hasExistingAccount =
              state.uri.queryParameters['hasExistingAccount'] == 'true';
          return BlocProvider<OtpVerificationCubit>(
            create: (_) => OtpVerificationCubit(
              repository: AuthRepository(DioClient.instance),
              tokenStorage: AuthTokenStorage.instance,
              verificationId: otpId,
              accountType: account,
              identifier: identifier,
              hasExistingAccount: hasExistingAccount,
            ),
            child: OtpVerificationPage(
              displayPhone: phone,
              accountType: account,
              creatorType: creatorType,
              mode: mode,
            ),
          );
        },
      ),
      GoRoute(
        path: RouteNames.profileInfluencerComplete,
        builder: (context, state) {
          final String phone =
              state.uri.queryParameters['phone'] ?? '+966555555555';
          final String? creatorType = state.uri.queryParameters['creatorType'];
          return InfluencerCompleteProfilePage(
            phone: phone,
            creatorType: creatorType,
          );
        },
      ),
      GoRoute(
        path: RouteNames.profileCompanyComplete,
        builder: (context, state) {
          final String phone =
              state.uri.queryParameters['phone'] ?? '+966555555555';
          return CompanyCompleteProfilePage(phone: phone);
        },
      ),
      GoRoute(
        path: RouteNames.profileCompanyRegistrationSuccess,
        builder: (context, state) {
          final String phone = state.uri.queryParameters['phone'] ?? '';
          return CompanyRegistrationSuccessPage(phone: phone);
        },
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return CompanyShellPage(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.companyHome,
                builder: (context, state) {
                  final String phone = state.uri.queryParameters['phone'] ?? '';
                  final bool registered =
                      state.uri.queryParameters['registered']?.toLowerCase() ==
                      'true';
                  return CompanyHomeTabPage(
                    phone: phone,
                    forceRegistered: registered,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.companyChat,
                builder: (context, state) =>
                    const InfluencerChatsPage(isBrand: true),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.companyStars,
                builder: (context, state) =>
                    const CompanyStarsPage(selectionMode: false),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.companyCampaigns,
                builder: (context, state) => const CompanyCampaignsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.companyAccount,
                builder: (context, state) => const CompanyAccountPage(),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return InfluencerShellPage(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.influencerHome,
                builder: (context, state) => const InfluencerHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.influencerOrders,
                builder: (context, state) => const InfluencerOrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.influencerProfile,
                builder: (context, state) => const InfluencerProfilePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.influencerChats,
                builder: (context, state) => const InfluencerChatsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RouteNames.influencerSettings,
                builder: (context, state) => const InfluencerSettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.companyAccountWallet,
        builder: (context, state) => const CompanyWalletPage(),
      ),
      GoRoute(
        path: RouteNames.companyAccountBills,
        builder: (context, state) => const CompanyMyBillsPage(),
      ),
      GoRoute(
        path: RouteNames.companyAccountLanguage,
        builder: (context, state) => const CompanyLanguagePage(),
      ),
      GoRoute(
        path: RouteNames.companyAccountSettings,
        builder: (context, state) => const CompanyAccountSettingsPage(),
      ),
      GoRoute(
        path: RouteNames.companyAccountAbout,
        builder: (context, state) => const CompanyAboutAppPage(),
      ),
      GoRoute(
        path: RouteNames.companyAccountContact,
        builder: (context, state) => const CompanyContactUsPage(),
      ),
      GoRoute(
        path: RouteNames.companyCreateCampaign,
        builder: (context, state) => const CompanyCreateCampaignPage(),
      ),
      GoRoute(
        path: RouteNames.companyStarsBrowse,
        builder: (context, state) =>
            const CompanyStarsPage(selectionMode: true),
      ),
      GoRoute(
        path: RouteNames.companyStarProfile,
        builder: (context, state) {
          final String starId = state.pathParameters['starId'] ?? '';
          return CompanyStarProfilePage(starId: starId);
        },
      ),
      GoRoute(
        path: RouteNames.companyRequestAd,
        builder: (context, state) {
          final String starId = state.pathParameters['starId'] ?? '';
          return CompanyRequestAdPage(starId: starId);
        },
      ),
      GoRoute(
        path: RouteNames.companyCampaignDetails,
        builder: (context, state) {
          final String campaignId = state.pathParameters['campaignId'] ?? '';
          return CompanyCampaignDetailsPage(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: RouteNames.companyCampaignInfluencerDetails,
        builder: (context, state) {
          final String campaignId = state.pathParameters['campaignId'] ?? '';
          final String influencerId =
              state.pathParameters['influencerId'] ?? '';
          return CompanyCampaignInfluencerDetailsPage(
            campaignId: campaignId,
            influencerId: influencerId,
          );
        },
      ),
      GoRoute(
        path: RouteNames.influencerOrderDetails,
        builder: (context, state) {
          final String orderId = state.pathParameters['orderId'] ?? '';
          return InfluencerOrderDetailsPage(orderId: orderId);
        },
      ),
      GoRoute(
        path: RouteNames.influencerChatDetails,
        builder: (context, state) {
          final String threadId = state.pathParameters['threadId'] ?? '';
          return InfluencerChatDetailsPage(threadId: threadId);
        },
      ),
    ],
  );
}

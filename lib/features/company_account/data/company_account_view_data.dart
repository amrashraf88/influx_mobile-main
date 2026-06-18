import 'package:adzmavall/features/company_account/presentation/models/company_account_models.dart';
import 'package:adzmavall/utils/imageassets.dart';

abstract final class CompanyAccountViewData {
  static const CompanyAccountProfile profile = CompanyAccountProfile(
    name: 'Food Brand',
    phone: '+966 55 555 5555',
    avatarUrl:
        'https://images.unsplash.com/photo-1560250097-0b93528c311a?auto=format&fit=crop&w=240&q=80',
    walletBalance: '17,600',
  );

  static const List<CompanyAccountSection> menuSections =
      <CompanyAccountSection>[
        CompanyAccountSection(
          titleKey: 'company_account_section_account',
          items: <CompanyAccountMenuItem>[
            CompanyAccountMenuItem(
              titleKey: 'company_account_wallet',
              iconAsset: ImageAssets.settingsWalletIcon,
              action: CompanyAccountMenuAction.wallet,
              trailingBalance: '17,600',
            ),
            CompanyAccountMenuItem(
              titleKey: 'company_account_my_bills',
              iconAsset: ImageAssets.homeBottomNavOrders,
              action: CompanyAccountMenuAction.myBills,
            ),
          ],
        ),
        CompanyAccountSection(
          titleKey: 'company_account_section_general',
          items: <CompanyAccountMenuItem>[
            CompanyAccountMenuItem(
              titleKey: 'company_account_language',
              iconAsset: ImageAssets.settingsLanguageIcon,
              action: CompanyAccountMenuAction.language,
            ),
            CompanyAccountMenuItem(
              titleKey: 'company_account_share_app',
              iconAsset: ImageAssets.settingsShareIcon,
              action: CompanyAccountMenuAction.shareApp,
            ),
          ],
        ),
        CompanyAccountSection(
          titleKey: 'company_account_section_support',
          items: <CompanyAccountMenuItem>[
            CompanyAccountMenuItem(
              titleKey: 'company_account_settings',
              iconAsset: ImageAssets.homeBottomNavSettings,
              action: CompanyAccountMenuAction.settings,
            ),
            CompanyAccountMenuItem(
              titleKey: 'company_account_contact_us',
              iconAsset: ImageAssets.settingsContactIcon,
              action: CompanyAccountMenuAction.contactUs,
            ),
            CompanyAccountMenuItem(
              titleKey: 'company_account_about',
              iconAsset: ImageAssets.settingsInfoIcon,
              action: CompanyAccountMenuAction.about,
            ),
          ],
        ),
      ];

  static const String pendingBalance = '\$2550.50';
  static const String totalBalance = '\$20.550';

  static const List<CompanyWalletTransaction> transactions =
      <CompanyWalletTransaction>[
        CompanyWalletTransaction(
          title: 'Office Items',
          dateLabel: 'Nov 17, 1:00 AM',
          amount: '36.800',
          isCredit: true,
          status: CompanyWalletTransactionStatus.paymentHold,
        ),
        CompanyWalletTransaction(
          title: 'Office Items',
          dateLabel: 'Nov 17, 1:00 AM',
          amount: '36.800',
          isCredit: false,
          status: CompanyWalletTransactionStatus.paymentRelease,
        ),
        CompanyWalletTransaction(
          title: 'Office Items',
          dateLabel: 'Nov 17, 1:00 AM',
          amount: '36.800',
          isCredit: true,
          status: CompanyWalletTransactionStatus.paymentHold,
        ),
      ];

  static const List<CompanyBillItem> bills = <CompanyBillItem>[
        CompanyBillItem(campaignId: '#598423', totalPaid: '32,120'),
        CompanyBillItem(campaignId: '#598424', totalPaid: '18,450'),
        CompanyBillItem(campaignId: '#598425', totalPaid: '9,200'),
      ];

  static const List<CompanyLanguageOption> languages =
      <CompanyLanguageOption>[
        CompanyLanguageOption(
          code: 'en',
          title: 'English',
          subtitle: 'Device language',
        ),
        CompanyLanguageOption(
          code: 'ar',
          title: 'Arabic',
          subtitle: 'لغة الجهاز',
        ),
        CompanyLanguageOption(
          code: 'ja',
          title: 'Japanese',
          subtitle: '繁體中文日本語',
        ),
        CompanyLanguageOption(
          code: 'ko',
          title: 'Korean',
          subtitle: '繁體中文日本語',
        ),
        CompanyLanguageOption(
          code: 'de',
          title: 'German',
          subtitle: 'Deutsch',
        ),
        CompanyLanguageOption(
          code: 'es',
          title: 'Spanish - Spain',
          subtitle: 'Español - España',
        ),
        CompanyLanguageOption(
          code: 'ru',
          title: 'Russian',
          subtitle: 'Русский',
        ),
      ];
}

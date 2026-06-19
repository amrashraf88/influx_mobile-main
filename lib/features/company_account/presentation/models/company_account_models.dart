import 'package:equatable/equatable.dart';

enum CompanyAccountMenuAction {
  wallet,
  myBills,
  language,
  shareApp,
  settings,
  contactUs,
  about,
}

enum CompanyWalletTransactionStatus { paymentHold, paymentRelease }

class CompanyAccountProfile extends Equatable {
  const CompanyAccountProfile({
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.walletBalance,
  });

  final String name;
  final String phone;
  final String avatarUrl;
  final String walletBalance;

  @override
  List<Object?> get props => <Object?>[name, phone, avatarUrl, walletBalance];
}

class CompanyAccountMenuItem extends Equatable {
  const CompanyAccountMenuItem({
    required this.titleKey,
    required this.iconAsset,
    required this.action,
    this.trailingBalance,
  });

  final String titleKey;
  final String iconAsset;
  final CompanyAccountMenuAction action;
  final String? trailingBalance;

  @override
  List<Object?> get props => <Object?>[
    titleKey,
    iconAsset,
    action,
    trailingBalance,
  ];
}

class CompanyAccountSection extends Equatable {
  const CompanyAccountSection({required this.titleKey, required this.items});

  final String titleKey;
  final List<CompanyAccountMenuItem> items;

  @override
  List<Object?> get props => <Object?>[titleKey, items];
}

class CompanyWalletTransaction extends Equatable {
  const CompanyWalletTransaction({
    required this.title,
    required this.dateLabel,
    required this.amount,
    required this.isCredit,
    required this.status,
  });

  final String title;
  final String dateLabel;
  final String amount;
  final bool isCredit;
  final CompanyWalletTransactionStatus status;

  @override
  List<Object?> get props => <Object?>[
    title,
    dateLabel,
    amount,
    isCredit,
    status,
  ];
}

class CompanyBillItem extends Equatable {
  const CompanyBillItem({
    required this.campaignId,
    required this.totalPaid,
    this.invoiceUrl = '',
  });

  final String campaignId;
  final String totalPaid;
  final String invoiceUrl;

  @override
  List<Object?> get props => <Object?>[campaignId, totalPaid, invoiceUrl];
}

class CompanyLanguageOption extends Equatable {
  const CompanyLanguageOption({
    required this.code,
    required this.title,
    required this.subtitle,
  });

  final String code;
  final String title;
  final String subtitle;

  @override
  List<Object?> get props => <Object?>[code, title, subtitle];
}

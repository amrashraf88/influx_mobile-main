import 'package:adzmavall/utils/imageassets.dart';

class InfluencerProfileSummaryData {
  const InfluencerProfileSummaryData({
    required this.name,
    required this.title,
    required this.bio,
    required this.avatarUrl,
    required this.mawthooqLabel,
  });

  final String name;
  final String title;
  final String bio;
  final String avatarUrl;
  final String mawthooqLabel;

  factory InfluencerProfileSummaryData.fromJson(Map<String, dynamic> json) {
    return InfluencerProfileSummaryData(
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      mawthooqLabel: json['mawthooq_label'] as String? ?? '',
    );
  }
}

class InfluencerProfileTabItem {
  const InfluencerProfileTabItem({required this.label, required this.asset});

  final String label;
  final String asset;
}

class InfluencerContactAction {
  const InfluencerContactAction({required this.label, required this.asset});

  final String label;
  final String asset;
}

class InfluencerAccountMetric {
  const InfluencerAccountMetric({required this.label, required this.asset});

  final String label;
  final String asset;
}

class InfluencerAdPriceItem {
  const InfluencerAdPriceItem({required this.label, this.asset});

  final String label;
  final String? asset;
}

class InfluencerClientItem {
  const InfluencerClientItem({required this.name, required this.logoUrl});

  final String name;
  final String logoUrl;

  factory InfluencerClientItem.fromJson(Map<String, dynamic> json) {
    return InfluencerClientItem(
      name: json['name'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
    );
  }
}

class InfluencerAdPreviewItem {
  const InfluencerAdPreviewItem({required this.title, required this.imageUrl});

  final String title;
  final String imageUrl;

  factory InfluencerAdPreviewItem.fromJson(Map<String, dynamic> json) {
    return InfluencerAdPreviewItem(
      title: json['title'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
    );
  }
}

abstract final class InfluencerProfileViewData {
  static const InfluencerProfileSummaryData
  summary = InfluencerProfileSummaryData(
    name: 'Alya Mostafa',
    title: 'Professional fashion influencer',
    bio:
        'Trendsetting style maven and fashion enthusiast, sharing my unique flair with the world.',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=240&q=80',
    mawthooqLabel: 'Mawthooq Active (12345)',
  );

  static const List<InfluencerProfileTabItem> tabs = <InfluencerProfileTabItem>[
    InfluencerProfileTabItem(
      label: 'Accounts',
      asset: ImageAssets.categoryIcon,
    ),
    InfluencerProfileTabItem(label: 'Clients', asset: ImageAssets.userStarIcon),
    InfluencerProfileTabItem(
      label: 'Ad Price',
      asset: ImageAssets.hotPriceIcon,
    ),
    InfluencerProfileTabItem(
      label: 'Ads',
      asset: ImageAssets.advertisimentIcon,
    ),
    InfluencerProfileTabItem(label: 'Overview', asset: ImageAssets.detailsIcon),
    InfluencerProfileTabItem(label: 'Details', asset: ImageAssets.viewIcon),
  ];

  static const List<InfluencerContactAction> contactActions =
      <InfluencerContactAction>[
        InfluencerContactAction(
          label: 'Chat with',
          asset: ImageAssets.homeBottomNavChat,
        ),
        InfluencerContactAction(
          label: 'Whatsapp',
          asset: ImageAssets.whatsappIcon,
        ),
        InfluencerContactAction(label: 'Email', asset: ImageAssets.mailIcon),
      ];

  static const List<InfluencerAccountMetric>
  accountMetrics = <InfluencerAccountMetric>[
    InfluencerAccountMetric(
      label: 'Instagram',
      asset: ImageAssets.instagramColoredIcon,
    ),
    InfluencerAccountMetric(
      label: 'Telegram',
      asset: ImageAssets.telegramColoredIcon,
    ),
    InfluencerAccountMetric(label: 'Twitter', asset: ImageAssets.twitterIcon),
    InfluencerAccountMetric(label: 'Threads', asset: ImageAssets.threadsIcon),
    InfluencerAccountMetric(
      label: 'WhatsApp',
      asset: ImageAssets.whatsappColoredIcon,
    ),
    InfluencerAccountMetric(
      asset: ImageAssets.homeInfluencerYoutube,
      label: 'Youtube',
    ),
    InfluencerAccountMetric(label: 'Snap', asset: ImageAssets.snapchatIcon),
    InfluencerAccountMetric(
      asset: ImageAssets.homeInfluencerTiktok,
      label: 'Tik Tok',
    ),
  ];

  static const List<String> clientCategories = <String>[
    'Fashion (5)',
    'Beauty&Care (20)',
    'Business (3)',
    'Beauty',
  ];

  static const List<InfluencerClientItem> clients = <InfluencerClientItem>[
    InfluencerClientItem(
      name: 'Caftan SLM',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Beauty Corner',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Black Wing',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Black Wing',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Caftan SLM',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Beauty Corner',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Caftan SLM',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Beauty Corner',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Black Wing',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Black Wing',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Caftan SLM',
      logoUrl: 'https://picsum.photos/200',
    ),
    InfluencerClientItem(
      name: 'Beauty Corner',
      logoUrl: 'https://picsum.photos/200',
    ),
  ];

  static const List<InfluencerAdPriceItem>
  adPriceItems = <InfluencerAdPriceItem>[
    InfluencerAdPriceItem(label: 'Snapchat', asset: ImageAssets.snapchatIcon),
    InfluencerAdPriceItem(
      asset: ImageAssets.homeInfluencerTiktok,
      label: 'Tik Tok',
    ),
    InfluencerAdPriceItem(label: 'Whatsapp', asset: ImageAssets.whatsappIcon),
  ];

  static const List<InfluencerAdPreviewItem>
  adPreviews = <InfluencerAdPreviewItem>[
    InfluencerAdPreviewItem(
      title: 'Black wing',
      imageUrl:
          'https://images.unsplash.com/photo-1516280440614-37939bbacd81?auto=format&fit=crop&w=420&q=80',
    ),
    InfluencerAdPreviewItem(
      title: 'Melody Hint',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=420&q=80',
    ),
  ];

  static const List<String> keywords = <String>[
    '#Music',
    '#Family and Children',
    '#Gamer',
    '#Surgeon',
    '#Video Creator',
    '#stylish',
    '#fashion',
    '#stylish',
    '#Music',
    '#Family and Children',
    '#Gamer',
    '#Surgeon',
  ];
}

import 'package:adzmavall/features/company_campaigns/presentation/models/company_star_models.dart';

abstract final class CompanyStarsViewData {
  static const List<CompanyStarListItem> stars = <CompanyStarListItem>[
    CompanyStarListItem(
      id: 'star-saif',
      name: 'Saif Mohamed',
      location: 'Riyadh, Saudi Arabia',
      categoriesLabel: 'Sports & Fashion',
      startingPriceLabel: '17,600\$',
      coverImageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
      isFavorite: true,
    ),
    CompanyStarListItem(
      id: 'star-areej',
      name: 'Areej Kareem',
      location: 'Riyadh, Saudi Arabia',
      categoriesLabel: 'Sports & Fashion',
      startingPriceLabel: '17,600\$',
      coverImageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=600&q=80',
      isFavorite: true,
    ),
    CompanyStarListItem(
      id: 'star-3',
      name: 'Saif Mohamed',
      location: 'Riyadh, Saudi Arabia',
      categoriesLabel: 'Sports & Fashion',
      startingPriceLabel: '17,600\$',
      coverImageUrl:
          'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=600&q=80',
      isFavorite: false,
    ),
    CompanyStarListItem(
      id: 'star-4',
      name: 'Areej Kareem',
      location: 'Riyadh, Saudi Arabia',
      categoriesLabel: 'Sports & Fashion',
      startingPriceLabel: '17,600\$',
      coverImageUrl:
          'https://images.unsplash.com/photo-1554151228-14d9def656e4?auto=format&fit=crop&w=600&q=80',
      isFavorite: false,
    ),
    CompanyStarListItem(
      id: 'star-melana',
      name: 'Melana Osama',
      location: 'Riyadh, Saudi Arabia',
      categoriesLabel: 'Sports & Fashion',
      startingPriceLabel: '17,600\$',
      coverImageUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80',
      isFavorite: true,
    ),
    CompanyStarListItem(
      id: 'star-6',
      name: 'Melana Osama',
      location: 'Riyadh, Saudi Arabia',
      categoriesLabel: 'Sports & Fashion',
      startingPriceLabel: '17,600\$',
      coverImageUrl:
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=600&q=80',
      isFavorite: false,
    ),
  ];

  static CompanyStarProfile profileFor(String id) {
    return const CompanyStarProfile(
      id: 'star-saif',
      name: 'Saif Mohamed',
      headline: 'Professional fashion influencer',
      bio:
          'Trendsetting style maven and fashion enthusiast, sharing my unique flair with the world. ✨',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      coverImageUrl:
          'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=900&q=80',
      mawthooqLabel: 'Mawthooq Active (12345)',
      adPrices: <CompanyStarAdPriceLine>[
        CompanyStarAdPriceLine(
          labelKey: 'company_star_platform_snapchat',
          coveragePrice: '17,600',
          videoPrice: '3,500',
        ),
        CompanyStarAdPriceLine(
          labelKey: 'company_star_platform_tiktok',
          coveragePrice: '17,600',
          videoPrice: '3,500',
        ),
        CompanyStarAdPriceLine(
          labelKey: 'company_star_platform_whatsapp',
          coveragePrice: '17,600',
          videoPrice: '3,500',
        ),
      ],
    );
  }

  static List<CompanyRequestAdPlatform> requestAdPlatforms() {
    return <CompanyRequestAdPlatform>[
      CompanyRequestAdPlatform(
        id: 'snap',
        name: 'Snapchat',
        followersLabel: '399.6k',
        lines: <CompanyRequestAdLine>[
          _line('company_request_ad_story', '17,600', quantity: 4),
          _line('company_request_ad_video', '3,500', quantity: 2),
          _line('company_request_ad_post', '17,600', quantity: 1),
          _line('company_request_ad_reel', '3,500', quantity: 0),
        ],
      ),
      CompanyRequestAdPlatform(
        id: 'tiktok',
        name: 'Tik Tok',
        followersLabel: '399.6k',
        lines: <CompanyRequestAdLine>[
          _line('company_request_ad_story', '17,600', quantity: 0),
          _line('company_request_ad_video', '3,500', quantity: 2),
          _line('company_request_ad_post', '17,600', quantity: 1),
          _line('company_request_ad_reel', '3,500', quantity: 0),
        ],
      ),
      CompanyRequestAdPlatform(
        id: 'wa',
        name: 'Whatsapp',
        followersLabel: '399.6k',
        lines: <CompanyRequestAdLine>[
          _line('company_request_ad_story', '17,600'),
          _line('company_request_ad_video', '3,500'),
          _line('company_request_ad_post', '3,500'),
          _line('company_request_ad_reel', '3,500'),
        ],
      ),
    ];
  }

  static CompanyRequestAdLine _line(
    String typeKey,
    String price, {
    int quantity = 0,
  }) {
    return CompanyRequestAdLine(
      typeKey: typeKey,
      priceLabel: price,
      quantity: quantity,
    );
  }
}

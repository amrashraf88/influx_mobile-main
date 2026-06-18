import 'package:adzmavall/features/home/presentation/models/home_models.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';

abstract final class HomeViewData {
  static const List<HomeCategoryModel> categories = <HomeCategoryModel>[
    HomeCategoryModel(
      titleKey: 'home_category_1',
      countKey: 'home_influencers_count',
      imageUrl: 'https://picsum.photos/240/160?1',
    ),
    HomeCategoryModel(
      titleKey: 'home_category_2',
      countKey: 'home_influencers_count',
      imageUrl: 'https://picsum.photos/240/160?2',
    ),
    HomeCategoryModel(
      titleKey: 'home_category_3',
      countKey: 'home_influencers_count',
      imageUrl: 'https://picsum.photos/240/160?3',
    ),
    HomeCategoryModel(
      titleKey: 'home_category_4',
      countKey: 'home_influencers_count',
      imageUrl: 'https://picsum.photos/240/160?4',
    ),
  ];

  static const List<HomeTrendingTagModel> trendingTags = <HomeTrendingTagModel>[
    HomeTrendingTagModel(localizationKey: 'home_tag_trending_1'),
    HomeTrendingTagModel(localizationKey: 'home_tag_trending_2'),
    HomeTrendingTagModel(localizationKey: 'home_tag_trending_3'),
    HomeTrendingTagModel(localizationKey: 'home_tag_trending_4'),
    HomeTrendingTagModel(localizationKey: 'home_tag_trending_5'),
    HomeTrendingTagModel(localizationKey: 'home_tag_trending_6'),
  ];

  static const List<HomeInfluencerModel> featuredInfluencers = <HomeInfluencerModel>[
    HomeInfluencerModel(
      name: 'Saif Mohamed',
      location: 'Cairo, EG',
      niche: 'Lifestyle',
      priceLabel: r'$1,200',
      coverImageUrl: 'https://picsum.photos/seed/adz-saif/600/800',
      youtubeFollowersLabel: '399.6k',
      tiktokFollowersLabel: '399.6k',
      facebookFollowersLabel: '399.6k',
    ),
    HomeInfluencerModel(
      name: 'Nour Ali',
      location: 'Dubai, AE',
      niche: 'Beauty',
      priceLabel: r'$2,400',
      coverImageUrl: 'https://picsum.photos/seed/adz-nour/600/800',
      youtubeFollowersLabel: '120k',
      tiktokFollowersLabel: '88k',
      facebookFollowersLabel: '45k',
    ),
  ];

  static const List<HomeWhyFeatureModel> whyFeatures = <HomeWhyFeatureModel>[
    HomeWhyFeatureModel(
      icon: Icons.auto_awesome_outlined,
      titleKey: 'home_why_item_1',
      iconAsset: ImageAssets.homeWhyCardFirst,
    ),
    HomeWhyFeatureModel(
      icon: Icons.folder_open_outlined,
      titleKey: 'home_why_item_2',
      iconAsset: ImageAssets.homeWhyCardSecond,
    ),
    HomeWhyFeatureModel(
      icon: Icons.campaign_outlined,
      titleKey: 'home_why_item_3',
      iconAsset: ImageAssets.homeWhyCardThird,
    ),
    HomeWhyFeatureModel(
      icon: Icons.analytics_outlined,
      titleKey: 'home_why_item_4',
      iconAsset: ImageAssets.homeWhyCardForth,
    ),
    HomeWhyFeatureModel(
      icon: Icons.verified_user_outlined,
      titleKey: 'home_why_item_5',
      iconAsset: ImageAssets.homeWhyCardFifth,
    ),
  ];

  static const List<HomeStoryModel> trendingStories = <HomeStoryModel>[
    HomeStoryModel(
      userName: 'Alyaa Mostafa',
      userHandle: '@ericfamous',
      title: 'New Style of Shiranui',
      imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80',
      likesLabel: '124k',
      commentsLabel: '2,738',
    ),
    HomeStoryModel(
      userName: 'Maya K',
      userHandle: '@maya.fits',
      title: 'Streetwear Mood',
      imageUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=900&q=80',
      likesLabel: '82k',
      commentsLabel: '1,104',
    ),
  ];
}

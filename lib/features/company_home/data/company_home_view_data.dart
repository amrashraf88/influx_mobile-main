import 'package:adzmavall/features/company_home/presentation/models/company_home_models.dart';
import 'package:flutter/material.dart';

/// Local-only fallbacks used while [ApiEndpoints.baseUrl] is empty.
///
/// These should be replaced 1:1 by the real API responses; the Page already
/// reads them only when the network is unavailable.
abstract final class CompanyHomeViewData {
  static const CompanyHomeSummary summary = CompanyHomeSummary(
    brandTitle: 'Mavall',
    brandLogoUrl: '',
    isUnderReview: true,
    reviewProgress: 0.62,
    notificationsCount: 0,
  );

  static const List<CompanyHomeCampaign>
  currentCampaigns = <CompanyHomeCampaign>[
    CompanyHomeCampaign(
      id: 'cmp-1',
      title: 'help the cild to go school',
      status: CompanyCampaignStatus.completed,
      coverImageUrl:
          'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=900&q=80',
      amountValue: 17600,
      dateLabel: '20December,2025',
      code: '#12345',
      progress: 1.0,
    ),
    CompanyHomeCampaign(
      id: 'cmp-2',
      title: 'help the cild to go school',
      status: CompanyCampaignStatus.pendingApproval,
      coverImageUrl:
          'https://images.unsplash.com/photo-1604881991720-f91add269bed?auto=format&fit=crop&w=900&q=80',
      amountValue: 17600,
      dateLabel: '20December,2025',
      code: '#12346',
      progress: 0.4,
    ),
  ];

  static List<CompanyHomeCategory> categories = <CompanyHomeCategory>[
    CompanyHomeCategory(
      id: 'cat-1',
      titleKey: 'company_home_category_natural_disaster',
      iconCodePoint: Icons.water_drop_outlined.codePoint,
    ),
    CompanyHomeCategory(
      id: 'cat-2',
      titleKey: 'company_home_category_sick_person',
      iconCodePoint: Icons.group_outlined.codePoint,
    ),
    CompanyHomeCategory(
      id: 'cat-3',
      titleKey: 'company_home_category_health_assistance',
      iconCodePoint: Icons.favorite_outline_rounded.codePoint,
    ),
    CompanyHomeCategory(
      id: 'cat-4',
      titleKey: 'company_home_category_education_support',
      iconCodePoint: Icons.menu_book_outlined.codePoint,
    ),
  ];

  static const List<CompanyHomeInfluencer>
  influencers = <CompanyHomeInfluencer>[
    CompanyHomeInfluencer(
      id: 'inf-1',
      name: 'Alyaa Mostafa',
      handle: '@iamthegreat',
      coverImageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      tagLabel: 'Fashion',
    ),
    CompanyHomeInfluencer(
      id: 'inf-2',
      name: 'Alyaa Mostafa',
      handle: '@chloelovesnature',
      coverImageUrl:
          'https://images.unsplash.com/photo-1542178243-bc20204b769f?auto=format&fit=crop&w=800&q=80',
      avatarUrl:
          'https://images.unsplash.com/photo-1554151228-14d9def656e4?auto=format&fit=crop&w=200&q=80',
      tagLabel: 'Beauty',
    ),
    CompanyHomeInfluencer(
      id: 'inf-3',
      name: 'Alyaa Mostafa',
      handle: '@sophiesparkle',
      coverImageUrl:
          'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?auto=format&fit=crop&w=800&q=80',
      avatarUrl:
          'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=200&q=80',
      tagLabel: 'Fashion',
    ),
    CompanyHomeInfluencer(
      id: 'inf-4',
      name: 'Alyaa Mostafa',
      handle: '@noahshiningstar',
      coverImageUrl:
          'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=800&q=80',
      avatarUrl:
          'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?auto=format&fit=crop&w=200&q=80',
      tagLabel: 'Travel',
    ),
  ];
}

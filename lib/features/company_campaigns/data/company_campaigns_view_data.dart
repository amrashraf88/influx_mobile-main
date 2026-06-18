import 'package:adzmavall/features/company_campaigns/presentation/models/company_campaign_models.dart';

/// Local mock data for campaign screens until the backend is ready.
abstract final class CompanyCampaignsViewData {
  static const List<CompanyCampaignListItem>
  campaigns = <CompanyCampaignListItem>[
    CompanyCampaignListItem(
      id: 'cmp-1',
      title: 'Help the child go to school',
      status: CompanyCampaignListStatus.completed,
      coverImageUrl:
          'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=900&q=80',
      amountValue: 17600,
      dateLabel: '3 influencers',
      code: '#12345',
      progressSegmentsFilled: 4,
    ),
    CompanyCampaignListItem(
      id: 'cmp-2',
      title: 'New Style Drop SS26',
      status: CompanyCampaignListStatus.newPendingApproval,
      coverImageUrl:
          'https://images.unsplash.com/photo-1604881991720-f91add269bed?auto=format&fit=crop&w=900&q=80',
      amountValue: 9200,
      dateLabel: '2 influencers',
      code: '#12346',
      progressSegmentsFilled: 1,
    ),
    CompanyCampaignListItem(
      id: 'cmp-3',
      title: 'help the cild to go school',
      status: CompanyCampaignListStatus.cancelled,
      coverImageUrl:
          'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=900&q=80',
      amountValue: 17600,
      dateLabel: '20December,2025',
      code: '#12347',
      progressSegmentsFilled: 4,
    ),
    CompanyCampaignListItem(
      id: 'cmp-4',
      title: 'help the cild to go school',
      status: CompanyCampaignListStatus.pendingClientReview,
      coverImageUrl:
          'https://images.unsplash.com/photo-1511632765486-a01980e01a18?auto=format&fit=crop&w=900&q=80',
      amountValue: 17600,
      dateLabel: '20December,2025',
      code: '#12348',
      progressSegmentsFilled: 3,
    ),
  ];

  static const List<String> platformOptions = <String>[
    'Instagram',
    'Tik Tok',
    'Youtube',
    'Telegram',
    'WhatsApp',
    'Threads',
  ];

  static const List<CompanyCampaignCreatorSummary>
  _defaultCreators = <CompanyCampaignCreatorSummary>[
    CompanyCampaignCreatorSummary(
      id: 'inf-saif',
      name: 'Saif Mohamed',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      status: CompanyCampaignListStatus.completed,
      priceLabel: '17,600\$',
      platforms: <String>['youtube', 'tiktok', 'facebook'],
    ),
    CompanyCampaignCreatorSummary(
      id: 'inf-2',
      name: 'Saif Mohamed',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=200&q=80',
      status: CompanyCampaignListStatus.pendingClientReview,
      priceLabel: '17,600\$',
      platforms: <String>['youtube', 'tiktok', 'facebook'],
    ),
  ];

  static CompanyCampaignListItem? campaignById(String id) {
    for (final CompanyCampaignListItem c in campaigns) {
      if (c.id == id) {
        return c;
      }
    }
    return null;
  }

  static CompanyCampaignDetail detailFor(String campaignId) {
    final CompanyCampaignListItem? list = campaignById(campaignId);
    final CompanyCampaignListStatus status =
        list?.status ?? CompanyCampaignListStatus.completed;
    final String statusKey = _statusLabelKey(status);
    return CompanyCampaignDetail(
      id: campaignId,
      title: list?.title ?? 'help the cild to go school',
      status: status,
      coverImageUrl:
          list?.coverImageUrl ??
          'https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?auto=format&fit=crop&w=900&q=80',
      statusLabelKey: statusKey,
      deliveryDateLabel: '20 December, 2025, 5:22 PM',
      progressSegmentsFilled: list?.progressSegmentsFilled ?? 4,
      creators: _defaultCreators,
      brandName: 'Coca cola',
      website: 'https://cocacola.com',
      campaignTitle: 'live it',
      targetFollowers: 'All',
      targetAgeGroup: '25-30',
      budgetMin: '1000',
      budgetMax: '50000',
      deliveryDateField: '05 December, 2000',
      detailsText: '',
      attachedFileName: 'File-name.csv',
      selectedPlatforms: const <String>{'Instagram'},
      availablePlatforms: platformOptions,
    );
  }

  static CompanyCampaignInfluencerDetail influencerDetail(String id) {
    return const CompanyCampaignInfluencerDetail(
      id: 'inf-saif',
      name: 'Saif Mohamed',
      headline: 'Profesional fashion influencer',
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      statusLabelKey: 'company_campaign_status_pending_client',
      priceLabel: '17,600\$',
      socialPlatforms: <String>['youtube', 'tiktok', 'facebook'],
      files: <({String name, String sizeLabel})>[
        (name: 'Search_3c.pdf', sizeLabel: '78 MB'),
      ],
      links: <String>[
        'https://example.com',
        'https://example.com',
        'https://example.com',
      ],
      orderLines: <({String labelKey, String value})>[
        (labelKey: 'company_campaign_order_total', value: '\$75.50'),
        (labelKey: 'company_campaign_order_listing_fee', value: '\$1.80'),
        (labelKey: 'company_campaign_order_before_vat', value: '\$1.80'),
        (labelKey: 'company_campaign_order_tax', value: '+\$1.00'),
      ],
      totalWithTax: '\$74.80',
      depositAmount: '\$74.80',
      releasedAmount: '\$0',
    );
  }

  static String _statusLabelKey(CompanyCampaignListStatus status) {
    switch (status) {
      case CompanyCampaignListStatus.completed:
        return 'company_campaign_status_approved_completed';
      case CompanyCampaignListStatus.newPendingApproval:
        return 'company_home_campaign_status_pending';
      case CompanyCampaignListStatus.cancelled:
        return 'company_campaign_status_cancelled';
      case CompanyCampaignListStatus.pendingClientReview:
        return 'company_campaign_status_pending_client';
    }
  }

  static bool matchesFilter(
    CompanyCampaignListItem item,
    CompanyCampaignFilter filter,
  ) {
    switch (filter) {
      case CompanyCampaignFilter.all:
        return true;
      case CompanyCampaignFilter.completed:
        return item.status == CompanyCampaignListStatus.completed;
      case CompanyCampaignFilter.cancelled:
        return item.status == CompanyCampaignListStatus.cancelled;
      case CompanyCampaignFilter.newPending:
        return item.status == CompanyCampaignListStatus.newPendingApproval;
      case CompanyCampaignFilter.pendingClientReview:
        return item.status == CompanyCampaignListStatus.pendingClientReview;
    }
  }
}

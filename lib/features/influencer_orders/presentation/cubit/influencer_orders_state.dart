part of 'influencer_orders_cubit.dart';

class InfluencerOrdersState extends Equatable {
  const InfluencerOrdersState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.orders = const <InfluencerOrder>[],
    this.selectedFilter = InfluencerOrdersFilter.all,
    this.searchQuery = '',
    this.selectedDetailTab = InfluencerOrderDetailTab.status,
    this.adDraft = const InfluencerOrderAdDraft(),
    this.errorMessage,
  });

  final bool isLoading;
  final bool isActionLoading;
  final List<InfluencerOrder> orders;
  final InfluencerOrdersFilter selectedFilter;
  final String searchQuery;
  final InfluencerOrderDetailTab selectedDetailTab;
  final InfluencerOrderAdDraft adDraft;
  final String? errorMessage;

  List<InfluencerOrder> get filteredOrders {
    final String q = searchQuery.trim().toLowerCase();
    return orders
        .where((InfluencerOrder order) {
          final bool matchesFilter = switch (selectedFilter) {
            InfluencerOrdersFilter.all => true,
            InfluencerOrdersFilter.completed =>
              order.status == InfluencerOrderStatus.completed,
            InfluencerOrdersFilter.cancelled =>
              order.status == InfluencerOrderStatus.declined,
            InfluencerOrdersFilter.newest =>
              order.status == InfluencerOrderStatus.newRequest,
            InfluencerOrdersFilter.pending =>
              order.status == InfluencerOrderStatus.inProgress ||
                  order.status == InfluencerOrderStatus.pendingClientReview,
          };
          final bool matchesSearch =
              q.isEmpty ||
              order.clientName.toLowerCase().contains(q) ||
              order.clientSubtitle.toLowerCase().contains(q) ||
              order.orderNumber.toLowerCase().contains(q);
          return matchesFilter && matchesSearch;
        })
        .toList(growable: false);
  }

  InfluencerOrder? orderById(String orderId) {
    for (final InfluencerOrder order in orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  InfluencerOrdersState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    List<InfluencerOrder>? orders,
    InfluencerOrdersFilter? selectedFilter,
    String? searchQuery,
    InfluencerOrderDetailTab? selectedDetailTab,
    InfluencerOrderAdDraft? adDraft,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InfluencerOrdersState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      orders: orders ?? this.orders,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDetailTab: selectedDetailTab ?? this.selectedDetailTab,
      adDraft: adDraft ?? this.adDraft,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    isLoading,
    isActionLoading,
    orders,
    selectedFilter,
    searchQuery,
    selectedDetailTab,
    adDraft,
    errorMessage,
  ];
}

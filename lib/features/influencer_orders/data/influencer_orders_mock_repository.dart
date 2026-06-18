import 'package:adzmavall/features/influencer_orders/data/influencer_orders_repository.dart';
import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';
import 'package:adzmavall/utils/imageassets.dart';

class InfluencerOrdersMockRepository implements InfluencerOrdersRepository {
  InfluencerOrdersMockRepository({List<InfluencerOrder>? seedOrders})
    : _orders = seedOrders == null
          ? _sharedOrders
          : List<InfluencerOrder>.from(seedOrders);

  final List<InfluencerOrder> _orders;

  @override
  Future<List<InfluencerOrder>> fetchOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List<InfluencerOrder>.unmodifiable(_orders);
  }

  @override
  Future<InfluencerOrder?> fetchOrder(String orderId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _findOrder(orderId);
  }

  @override
  Future<InfluencerOrder> updateOrderStatus({
    required String orderId,
    required InfluencerOrderStatus status,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _replaceOrder(orderId, (InfluencerOrder order) {
      return order.copyWith(status: status);
    });
  }

  @override
  Future<InfluencerOrder> submitPublication({
    required String orderId,
    required List<String> links,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _replaceOrder(orderId, (InfluencerOrder order) {
      return order.copyWith(
        status: InfluencerOrderStatus.pendingClientReview,
        publicationLinks: links,
      );
    });
  }

  @override
  Future<InfluencerOrder> uploadTaxInvoice({
    required String orderId,
    required String fileName,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    return _replaceOrder(orderId, (InfluencerOrder order) {
      return order.copyWith(
        attachments: order.attachments.copyWith(taxInvoicePath: fileName),
      );
    });
  }

  InfluencerOrder? _findOrder(String orderId) {
    for (final InfluencerOrder order in _orders) {
      if (order.id == orderId) {
        return order;
      }
    }
    return null;
  }

  InfluencerOrder _replaceOrder(
    String orderId,
    InfluencerOrder Function(InfluencerOrder order) update,
  ) {
    final int index = _orders.indexWhere(
      (InfluencerOrder order) => order.id == orderId,
    );
    if (index == -1) {
      throw StateError('Order was not found.');
    }
    final InfluencerOrder updated = update(_orders[index]);
    _orders[index] = updated;
    return updated;
  }

  static final List<InfluencerOrder> sampleOrders = <InfluencerOrder>[
    _order(
      id: 'order-1',
      orderNumber: '# 12345',
      logoAsset:
          'https://images.unsplash.com/photo-1556740749-887f6717d7e4?w=300&h=300&fit=crop',
      status: InfluencerOrderStatus.newRequest,
      priceLabel: '17,600 ر.س',
    ),
    _order(
      id: 'order-2',
      orderNumber: '# 12345',
      logoAsset:
          'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=300&h=300&fit=crop',
      status: InfluencerOrderStatus.pendingClientReview,
      priceLabel: '17,600 ر.س',
    ),
    _order(
      id: 'order-3',
      orderNumber: '# 12345',
      logoAsset:
          'https://images.unsplash.com/photo-1521335629791-ce4aec67dd53?w=300&h=300&fit=crop',
      status: InfluencerOrderStatus.inProgress,
      priceLabel: '17,600 ر.س',
    ),
    _order(
      id: 'order-4',
      orderNumber: '# 12345',
      logoAsset:
          'https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=300&h=300&fit=crop',
      status: InfluencerOrderStatus.declined,
      priceLabel: '17,600 ر.س',
    ),
    _order(
      id: 'order-5',
      orderNumber: '# 12345',
      logoAsset:
          'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=300&h=300&fit=crop',
      status: InfluencerOrderStatus.completed,
      priceLabel: '17,600 ر.س',
    ),
  ];

  static final List<InfluencerOrder> _sharedOrders = List<InfluencerOrder>.from(
    sampleOrders,
  );

  static InfluencerOrder _order({
    required String id,
    required String orderNumber,
    required String logoAsset,
    required InfluencerOrderStatus status,
    required String priceLabel,
  }) {
    return InfluencerOrder(
      id: id,
      orderNumber: orderNumber,
      clientName: 'Caftan SLM',
      clientSubtitle: 'Danette Creme Caramel',
      logoAsset: logoAsset,
      platformName: 'TikTok',
      platformIconAsset: ImageAssets.homeInfluencerTiktok,
      priceLabel: priceLabel,
      deliveryDateLabel: '20 December, 2025',
      status: status,
      details: const InfluencerOrderDetails(
        title: 'Example domain',
        orderId: '#598423',
        description:
            "Simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
        clientNotes:
            "Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.",
        clientWebsite: 'https://example.com',
        deliveryDate: 'Monday, 10 July',
        deliveryTime: '5:22 PM',
        campaignObjective: <String>[
          'Increase brand awareness',
          'Coverage Presence',
        ],
        targetFollowers: 'All',
        targetAgeGroup: '19-25 years        26-35 years',
        influencerCategory: 'Education & Learning',
        platforms: <String>['Instagram'],
      ),
      attachments: const InfluencerOrderAttachments(
        files: <InfluencerOrderFile>[
          InfluencerOrderFile(name: 'Search_3c.pdf', sizeLabel: '78 MB'),
        ],
        links: <String>[
          'https://example.com',
          'https://wherecani.com',
          'https://melodyinh.com',
        ],
        notes:
            "simply dummy text of the printing and typesetting industry.\nLorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.\nIt has survived not only five centuries, but also the leap into ele",
      ),
      financial: const InfluencerOrderFinancial(
        platformTotal: r'$17',
        items: <InfluencerOrderFinancialItem>[
          InfluencerOrderFinancialItem(
            label: 'Post',
            amount: r'$3',
            icon: ImageAssets.postIcon,
          ),
          InfluencerOrderFinancialItem(
            label: 'Live',
            amount: r'$10',
            icon: ImageAssets.videoIcon,
          ),
          InfluencerOrderFinancialItem(
            label: 'Reel',
            amount: r'$4',
            icon: ImageAssets.reelIcon,
          ),
        ],
        totalOrder: r'$75.50',
        listingFee: r'$1.80',
        totalBeforeVat: r'$1.80',
        taxAmount: r'+ $1.00',
        totalWithTax: r'$74.80',
        deposit: r'$74.80',
        released: r'$0',
      ),
    );
  }
}

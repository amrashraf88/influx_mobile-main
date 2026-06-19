import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';

abstract interface class InfluencerOrdersRepository {
  Future<List<InfluencerOrder>> fetchOrders();

  Future<InfluencerOrder?> fetchOrder(String orderId);

  Future<InfluencerOrder> updateOrderStatus({
    required String orderId,
    required InfluencerOrderStatus status,
  });

  Future<InfluencerOrder> submitPublication({
    required String orderId,
    required List<String> links,
  });

  Future<InfluencerOrder> uploadTaxInvoice({
    required String orderId,
    required String fileName,
    required String filePath,
  });
}

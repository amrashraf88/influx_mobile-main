import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/influencer_orders/data/influencer_orders_api_repository.dart';
import 'package:adzmavall/features/influencer_orders/data/influencer_orders_mock_repository.dart';
import 'package:adzmavall/features/influencer_orders/data/influencer_orders_repository.dart';
import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'influencer_orders_state.dart';

class InfluencerOrdersCubit extends Cubit<InfluencerOrdersState> {
  InfluencerOrdersCubit({InfluencerOrdersRepository? repository})
    : _repository = repository ?? _defaultRepository(),
      super(const InfluencerOrdersState());

  static InfluencerOrdersRepository _defaultRepository() {
    if (ApiUrlResolver.isConfigured) {
      return InfluencerOrdersApiRepository(DioClient.instance);
    }
    return InfluencerOrdersMockRepository();
  }

  final InfluencerOrdersRepository _repository;

  Future<void> loadOrders() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final List<InfluencerOrder> orders = await _repository.fetchOrders();
      emit(state.copyWith(isLoading: false, orders: orders));
    } on Object {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to load orders right now.',
        ),
      );
    }
  }

  Future<void> loadOrder(String orderId) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final InfluencerOrder? order = await _repository.fetchOrder(orderId);
      emit(
        state.copyWith(
          isLoading: false,
          orders: order == null ? state.orders : _upsertOrder(order),
          errorMessage: order == null ? 'Order was not found.' : null,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Unable to load this order right now.',
        ),
      );
    }
  }

  void setFilter(InfluencerOrdersFilter filter) {
    emit(state.copyWith(selectedFilter: filter));
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setDetailTab(InfluencerOrderDetailTab tab) {
    emit(state.copyWith(selectedDetailTab: tab));
  }

  Future<void> approveOrder(String orderId) async {
    await _updateOrderStatus(orderId, InfluencerOrderStatus.inProgress);
  }

  Future<void> rejectOrder(String orderId) async {
    await _updateOrderStatus(orderId, InfluencerOrderStatus.declined);
  }

  Future<void> markPendingClientReview(
    String orderId, {
    List<String>? links,
  }) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      final InfluencerOrder updated = await _repository.submitPublication(
        orderId: orderId,
        links: links ?? state.adDraft.links,
      );
      emit(
        state.copyWith(
          isActionLoading: false,
          orders: _upsertOrder(updated),
          adDraft: const InfluencerOrderAdDraft(),
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: 'Unable to submit the publication links.',
        ),
      );
    }
  }

  Future<void> completeOrder(String orderId) async {
    await _updateOrderStatus(orderId, InfluencerOrderStatus.completed);
  }

  void updateDraftLink(int index, String value) {
    final List<String> links = List<String>.from(state.adDraft.links);
    if (index >= 0 && index < links.length) {
      links[index] = value;
      emit(state.copyWith(adDraft: state.adDraft.copyWith(links: links)));
    }
  }

  void addDraftLink() {
    final List<String> links = List<String>.from(state.adDraft.links)
      ..add('https://');
    emit(state.copyWith(adDraft: state.adDraft.copyWith(links: links)));
  }

  void updateDraftNotes(String notes) {
    emit(state.copyWith(adDraft: state.adDraft.copyWith(notes: notes)));
  }

  Future<void> pickDraftFile() async {
    final FilePickerResult? result = await FilePicker.pickFiles();
    final PlatformFile? file = result?.files.single;
    if (file == null) {
      return;
    }
    emit(
      state.copyWith(
        adDraft: state.adDraft.copyWith(
          filePath: file.path,
          fileName: file.name,
        ),
      ),
    );
  }

  Future<void> pickTaxInvoice(String orderId) async {
    final FilePickerResult? result = await FilePicker.pickFiles();
    final PlatformFile? file = result?.files.single;
    if (file == null) {
      return;
    }
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      final InfluencerOrder updated = await _repository.uploadTaxInvoice(
        orderId: orderId,
        fileName: file.name,
      );
      emit(
        state.copyWith(isActionLoading: false, orders: _upsertOrder(updated)),
      );
    } on Object {
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: 'Unable to upload the tax invoice.',
        ),
      );
    }
  }

  Future<void> _updateOrderStatus(
    String orderId,
    InfluencerOrderStatus status,
  ) async {
    emit(state.copyWith(isActionLoading: true, clearError: true));
    try {
      final InfluencerOrder updated = await _repository.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      emit(
        state.copyWith(isActionLoading: false, orders: _upsertOrder(updated)),
      );
    } on Object {
      emit(
        state.copyWith(
          isActionLoading: false,
          errorMessage: 'Unable to update the order status.',
        ),
      );
    }
  }

  List<InfluencerOrder> _upsertOrder(InfluencerOrder updatedOrder) {
    final List<InfluencerOrder> updated = List<InfluencerOrder>.from(
      state.orders,
    );
    final int index = updated.indexWhere(
      (InfluencerOrder order) => order.id == updatedOrder.id,
    );
    if (index == -1) {
      updated.add(updatedOrder);
    } else {
      updated[index] = updatedOrder;
    }
    return updated;
  }
}

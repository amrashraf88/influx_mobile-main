import 'package:adzmavall/core/config/api_endpoints.dart';
import 'package:adzmavall/core/network/api_error_parser.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart'
    show ApiException;
import 'package:dio/dio.dart';

/// Wallet balance summary from `GET /auth/wallet`.
class WalletSummary {
  const WalletSummary({
    required this.balance,
    required this.heldBalance,
    required this.availableBalance,
    required this.statusLabel,
  });

  final num balance;
  final num heldBalance;
  final num availableBalance;
  final String statusLabel;

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    num n(Object? v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;
    final Object? status = json['status'];
    return WalletSummary(
      balance: n(json['balance']),
      heldBalance: n(json['held_balance']),
      availableBalance: n(json['available_balance']),
      statusLabel: status is Map ? (status['label']?.toString() ?? '') : '',
    );
  }
}

/// One row from `GET /auth/wallet/transactions`.
class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.amount,
    required this.incoming,
    required this.dateLabel,
  });

  final String title;
  final num amount;
  final bool incoming;
  final String dateLabel;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final String k in keys) {
        final Object? v = json[k];
        if (v is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(v);
          for (final String nestedKey in <String>[
            'label',
            'value',
            'name',
            'title',
          ]) {
            final Object? nested = map[nestedKey];
            if (nested != null && nested.toString().trim().isNotEmpty) {
              return nested.toString();
            }
          }
        }
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
      return '';
    }

    final num amount = json['amount'] is num
        ? json['amount'] as num
        : num.tryParse(json['amount']?.toString() ?? '') ?? 0;
    final String type = pick(<String>[
      'type',
      'direction',
      'kind',
    ]).toLowerCase();
    final bool incoming =
        type.contains('credit') ||
        type.contains('deposit') ||
        type.contains('in') ||
        amount >= 0;

    return WalletTransaction(
      title: pick(<String>[
        'title',
        'description',
        'reason',
        'name',
      ]).ifEmpty('Transaction'),
      amount: amount,
      incoming: incoming,
      dateLabel: pick(<String>['created_at_label', 'date', 'created_at']),
    );
  }
}

class WalletRepository {
  WalletRepository(this._dio);

  final Dio _dio;

  Future<WalletSummary> fetchSummary() async {
    final String url = ApiUrlResolver.resolve(ApiEndpoints.authWalletPath);
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(url);
      final dynamic data = res.data is Map ? (res.data as Map)['data'] : null;
      return WalletSummary.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  Future<List<WalletTransaction>> fetchTransactions() async {
    final String url = ApiUrlResolver.resolve(
      ApiEndpoints.authWalletTransactionsPath,
    );
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(url);
      final dynamic data = res.data is Map ? (res.data as Map)['data'] : null;
      if (data is List) {
        return data
            .whereType<Map>()
            .map(
              (Map e) =>
                  WalletTransaction.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
      return <WalletTransaction>[];
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  Future<void> chargeCard(num amount) async {
    try {
      await _dio.post<dynamic>(
        ApiUrlResolver.resolve(ApiEndpoints.applicationWalletChargeCardPath),
        data: <String, dynamic>{'amount': amount},
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }

  Future<void> withdraw(num amount) async {
    try {
      await _dio.post<dynamic>(
        ApiUrlResolver.resolve(ApiEndpoints.applicationWalletWithdrawPath),
        data: <String, dynamic>{'amount': amount},
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorParser.messageFromDio(e));
    }
  }
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}

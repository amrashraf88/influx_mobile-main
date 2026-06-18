import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart' show ApiException;
import 'package:adzmavall/features/influencer_settings/data/wallet_repository.dart';
import 'package:adzmavall/features/influencer_settings/presentation/widgets/settings_sub_app_bar.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

/// Influencer Wallet — balance + transactions loaded from the API.
class WalletPage extends StatefulWidget {
  const WalletPage({super.key, WalletRepository? repository})
    : _repository = repository;

  final WalletRepository? _repository;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final WalletRepository _repo;

  bool _loading = true;
  String? _error;
  WalletSummary? _summary;
  List<WalletTransaction> _transactions = <WalletTransaction>[];

  @override
  void initState() {
    super.initState();
    _repo = widget._repository ?? WalletRepository(DioClient.instance);
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final WalletSummary summary = await _repo.fetchSummary();
      final List<WalletTransaction> txs = await _repo.fetchTransactions();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _transactions = txs;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _error = 'Could not load your wallet.';
        _loading = false;
      });
    }
  }

  String _money(num v) => NumberFormat('#,##0.##').format(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: const SettingsSubAppBar(title: 'Wallet'),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  children: <Widget>[
                    if (_error != null) ...<Widget>[
                      Text(
                        _error!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 12.h),
                    ],
                    _balanceCard(),
                    SizedBox(height: 16.h),
                    _actions(),
                    SizedBox(height: 20.h),
                    Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.fgPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (_transactions.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.h),
                        child: Center(
                          child: Text(
                            'No transactions yet.',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.fgQuaternary,
                            ),
                          ),
                        ),
                      )
                    else
                      ..._transactions.map(_txRow),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _balanceCard() {
    final WalletSummary s = _summary ??
        const WalletSummary(
          balance: 0,
          heldBalance: 0,
          availableBalance: 0,
          statusLabel: '',
        );
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Available balance',
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _money(s.availableBalance),
            style: TextStyle(
              color: AppColors.white,
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: <Widget>[
              _mini('Held Balance', _money(s.heldBalance)),
              SizedBox(width: 24.w),
              _mini('Total Balance', _money(s.balance)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actions() {
    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 46.h,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandBlue,
                side: const BorderSide(color: AppColors.brandBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(800.r),
                ),
              ),
              onPressed: () {},
              child: const Text('Add Balance'),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SizedBox(
            height: 46.h,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(800.r),
                ),
              ),
              onPressed: () {},
              child: const Text('Withdraw'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mini(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.85),
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _txRow(WalletTransaction t) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.w,
            height: 40.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.brandBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 20.sp,
              color: AppColors.brandBlue,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  t.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.fgPrimary,
                  ),
                ),
                if (t.dateLabel.isNotEmpty)
                  Text(
                    t.dateLabel,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.fgQuaternary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${t.incoming ? '+' : '-'}${_money(t.amount.abs())}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: t.incoming ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

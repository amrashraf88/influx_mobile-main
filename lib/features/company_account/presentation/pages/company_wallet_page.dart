import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/widgets/app_feedback.dart';
import 'package:adzmavall/features/company_account/data/company_account_view_data.dart';
import 'package:adzmavall/features/company_account/presentation/models/company_account_models.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_sub_page_sheet.dart';
import 'package:adzmavall/features/influencer_settings/data/wallet_repository.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CompanyWalletPage extends StatefulWidget {
  const CompanyWalletPage({super.key});

  @override
  State<CompanyWalletPage> createState() => _CompanyWalletPageState();
}

class _CompanyWalletPageState extends State<CompanyWalletPage> {
  String _balance = CompanyAccountViewData.profile.walletBalance;
  String _pending = CompanyAccountViewData.pendingBalance;
  String _total = CompanyAccountViewData.totalBalance;
  List<CompanyWalletTransaction> _transactions =
      CompanyAccountViewData.transactions;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    if (!ApiUrlResolver.isConfigured) {
      return;
    }
    final WalletRepository repo = WalletRepository(DioClient.instance);
    try {
      final WalletSummary summary = await repo.fetchSummary();
      if (!mounted) {
        return;
      }
      setState(() {
        _balance = _money(summary.availableBalance);
        _pending = _money(summary.heldBalance);
        _total = _money(summary.balance);
      });
    } on Object {
      // Keep view-data balances.
    }
    try {
      final List<WalletTransaction> rows = await repo.fetchTransactions();
      if (!mounted || rows.isEmpty) {
        return;
      }
      setState(() {
        _transactions = rows.map(_mapTransaction).toList();
      });
    } on Object {
      // Keep view-data transactions.
    }
  }

  static String _money(num value) =>
      NumberFormat.decimalPattern().format(value);

  static CompanyWalletTransaction _mapTransaction(WalletTransaction tx) {
    return CompanyWalletTransaction(
      title: tx.title,
      dateLabel: tx.dateLabel,
      amount: _money(tx.amount.abs()),
      isCredit: tx.incoming,
      status: tx.incoming
          ? CompanyWalletTransactionStatus.paymentRelease
          : CompanyWalletTransactionStatus.paymentHold,
    );
  }

  Future<void> _submitWalletAction({
    required bool withdraw,
    required num amount,
  }) async {
    final WalletRepository repo = WalletRepository(DioClient.instance);
    try {
      final WalletActionResult result;
      if (withdraw) {
        result = await repo.withdraw(amount);
      } else {
        result = await repo.chargeCard(amount);
      }
      if (!mounted) {
        return;
      }
      await _showWalletResult(result);
      await _loadWallet();
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      await _showStatusSheet(
        success: false,
        title: 'Request failed',
        message: _cleanError(e),
      );
    }
  }

  Future<void> _showWalletResult(WalletActionResult result) async {
    if (result.redirectUrl == null || result.redirectUrl!.trim().isEmpty) {
      await _showStatusSheet(
        success: true,
        title: 'Request sent',
        message: result.message,
      );
      return;
    }

    await _showStatusSheet(
      success: true,
      title: 'Payment link ready',
      message: result.message,
      link: result.redirectUrl,
    );
  }

  Future<void> _showStatusSheet({
    required bool success,
    required String title,
    required String message,
    String? link,
  }) async {
    final Color accent = success ? const Color(0xFF16A34A) : AppColors.error;
    final Color softBg = success
        ? const Color(0xFFEAFBF0)
        : const Color(0xFFFFE8E8);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20.w,
            20.h,
            20.w,
            MediaQuery.paddingOf(sheetContext).bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 52.w,
                height: 52.w,
                decoration: BoxDecoration(
                  color: softBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  success ? Icons.check_rounded : Icons.close_rounded,
                  color: accent,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (link != null && link.trim().isNotEmpty) ...<Widget>[
                SizedBox(height: 14.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F9FF),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: const Color(0xFFE1E5EC)),
                  ),
                  child: SelectableText(
                    link,
                    style: TextStyle(
                      color: AppColors.brandBlue,
                      fontSize: 12.sp,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 18.h),
              Row(
                children: <Widget>[
                  if (link != null && link.trim().isNotEmpty) ...<Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: link));
                          Navigator.of(sheetContext).pop();
                          _showInlineNotice('Payment link copied');
                        },
                        icon: Icon(Icons.copy_rounded, size: 18.sp),
                        label: const Text('Copy'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandBlue,
                          side: const BorderSide(color: AppColors.brandBlue),
                          minimumSize: Size(0, 46.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: success ? AppColors.brandBlue : accent,
                        foregroundColor: AppColors.white,
                        minimumSize: Size(0, 46.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInlineNotice(String message) {
    showAppFeedback(context, message: message, type: AppFeedbackType.success);
  }

  String _cleanError(Object e) {
    final String raw = e.toString().replaceFirst('Exception: ', '').trim();
    return raw.isEmpty ? 'Something went wrong. Please try again.' : raw;
  }

  Future<void> _showAmountSheet({required bool withdraw}) async {
    final TextEditingController amount = TextEditingController();
    final num? value = await showModalBottomSheet<num>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              18.w,
              18.h,
              18.w,
              MediaQuery.paddingOf(sheetContext).bottom + 18.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  withdraw ? 'Withdraw amount' : 'Add balance',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 14.h),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    filled: true,
                    fillColor: const Color(0xFFF7F8FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFE1E5EC)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFE1E5EC)),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandBlue,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      final num? parsed = num.tryParse(amount.text.trim());
                      if (parsed != null && parsed > 0) {
                        Navigator.of(sheetContext).pop(parsed);
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    amount.dispose();
    if (value != null) {
      await _submitWalletAction(withdraw: withdraw, amount: value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    return CompanyAccountSubPageSheet(
      title: AppStrings.of(locale, 'company_account_wallet_title'),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _BalanceCard(
              locale: locale,
              balance: _balance,
              pending: _pending,
              total: _total,
              onAdd: () => _showAmountSheet(withdraw: false),
              onWithdraw: () => _showAmountSheet(withdraw: true),
            ),
            SizedBox(height: 20.h),
            Text(
              AppStrings.of(locale, 'company_account_transactions'),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            for (final CompanyWalletTransaction tx
                in _transactions) ...<Widget>[
              _TransactionTile(tx: tx, locale: locale),
              SizedBox(height: 10.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.locale,
    required this.balance,
    required this.pending,
    required this.total,
    required this.onAdd,
    required this.onWithdraw,
  });

  final Locale locale;
  final String balance;
  final String pending;
  final String total;
  final VoidCallback onAdd;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AppStrings.of(locale, 'company_account_available_balance'),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      balance,
                      style: TextStyle(
                        color: AppColors.brandBlue,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Image.asset(
                        ImageAssets.rsIcon,
                        width: 22.w,
                        height: 22.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: _BalanceRow(
              label: AppStrings.of(locale, 'company_account_pending_balance'),
              value: pending,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 14.h),
            child: _BalanceRow(
              label: AppStrings.of(locale, 'company_account_total_balance'),
              value: total,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandBlue,
                      minimumSize: Size(0, 42.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      AppStrings.of(locale, 'company_account_add_balance'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onWithdraw,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandBlue,
                      minimumSize: Size(0, 42.h),
                      side: const BorderSide(color: AppColors.brandBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      AppStrings.of(locale, 'company_account_withdraw'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx, required this.locale});

  final CompanyWalletTransaction tx;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final bool hold = tx.status == CompanyWalletTransactionStatus.paymentHold;
    final Color badgeBg = hold
        ? const Color(0xFFE8F4FF)
        : const Color(0xFFFFE8E8);
    final Color badgeText = hold
        ? AppColors.brandBlue
        : const Color(0xFFE85D5D);
    final String statusLabel = AppStrings.of(
      locale,
      hold ? 'company_account_payment_hold' : 'company_account_payment_release',
    );
    final Color amountColor = tx.isCredit
        ? const Color(0xFF25B861)
        : const Color(0xFFE85D5D);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 44.w,
                height: 44.w,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: AppColors.brandBlue,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      tx.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      tx.dateLabel,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.circle, size: 6.sp, color: badgeText),
                    SizedBox(width: 4.w),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: badgeText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${tx.isCredit ? '+' : '-'}${tx.amount}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
                SizedBox(width: 4.w),
                Image.asset(ImageAssets.rsIcon, width: 16.w, height: 16.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

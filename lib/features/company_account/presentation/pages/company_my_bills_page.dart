import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/company_account/data/company_account_repository.dart';
import 'package:adzmavall/features/company_account/data/company_account_view_data.dart';
import 'package:adzmavall/features/company_account/presentation/models/company_account_models.dart';
import 'package:adzmavall/features/company_account/presentation/widgets/company_account_sub_page_sheet.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyMyBillsPage extends StatefulWidget {
  const CompanyMyBillsPage({super.key});

  @override
  State<CompanyMyBillsPage> createState() => _CompanyMyBillsPageState();
}

class _CompanyMyBillsPageState extends State<CompanyMyBillsPage> {
  List<CompanyBillItem> _bills = CompanyAccountViewData.bills;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    if (!ApiUrlResolver.isConfigured) {
      return;
    }
    setState(() => _loading = true);
    try {
      final List<CompanyBillItem> bills = await CompanyAccountRepository(
        DioClient.instance,
      ).fetchBills();
      if (!mounted) {
        return;
      }
      setState(() {
        if (bills.isNotEmpty) {
          _bills = bills;
        }
        _loading = false;
      });
    } on Object {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);

    return CompanyAccountSubPageSheet(
      title: AppStrings.of(locale, 'company_account_bills_title'),
      child: RefreshIndicator(
        onRefresh: _loadBills,
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 20.h),
          itemCount: _loading ? _bills.length + 1 : _bills.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (BuildContext context, int index) {
            if (_loading && index == 0) {
              return const Center(child: CircularProgressIndicator());
            }
            final CompanyBillItem bill = _bills[_loading ? index - 1 : index];
            return _BillTile(bill: bill, locale: locale);
          },
        ),
      ),
    );
  }
}

class _BillTile extends StatelessWidget {
  const _BillTile({required this.bill, required this.locale});

  final CompanyBillItem bill;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
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
                      AppStrings.of(locale, 'company_account_campaign_id'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      bill.campaignId,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: bill.invoiceUrl.trim().isEmpty ? null : () {},
                icon: Icon(
                  Icons.download_rounded,
                  color: bill.invoiceUrl.trim().isEmpty
                      ? AppColors.textSecondary
                      : AppColors.brandBlue,
                  size: 24.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                AppStrings.of(locale, 'company_account_total_paid'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    bill.totalPaid,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandBlue,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Image.asset(ImageAssets.rsIcon, width: 18.w, height: 18.w),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

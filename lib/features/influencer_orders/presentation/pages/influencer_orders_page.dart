import 'package:adzmavall/features/influencer_orders/presentation/cubit/influencer_orders_cubit.dart';
import 'package:adzmavall/features/influencer_orders/presentation/widgets/orders_filter_bar.dart';
import 'package:adzmavall/features/influencer_orders/presentation/widgets/orders_list.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfluencerOrdersPage extends StatelessWidget {
  const InfluencerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfluencerOrdersCubit>(
      create: (_) => InfluencerOrdersCubit()..loadOrders(),
      child: Builder(
        builder: (BuildContext context) {
          final Locale locale = Localizations.localeOf(context);
          final bool isArabic = locale.languageCode == 'ar';
          return Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 18.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'Manage Orders',
                            style: TextStyle(
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 21.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  const OrdersFilterBar(),
                  SizedBox(height: 16.h),
                  const Expanded(child: OrdersList()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

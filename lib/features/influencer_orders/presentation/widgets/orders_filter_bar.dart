import 'package:adzmavall/features/influencer_orders/presentation/cubit/influencer_orders_cubit.dart';
import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrdersFilterBar extends StatelessWidget {
  const OrdersFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfluencerOrdersCubit, InfluencerOrdersState>(
      buildWhen: (InfluencerOrdersState p, InfluencerOrdersState c) =>
          p.selectedFilter != c.selectedFilter,
      builder: (BuildContext context, InfluencerOrdersState state) {
        const List<InfluencerOrdersFilter> visibleFilters =
            <InfluencerOrdersFilter>[
              InfluencerOrdersFilter.all,
              InfluencerOrdersFilter.newest,
              InfluencerOrdersFilter.pending,
              InfluencerOrdersFilter.completed,
            ];
        return SizedBox(
          height: 36.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            scrollDirection: Axis.horizontal,
            itemCount: visibleFilters.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (BuildContext context, int index) {
              final InfluencerOrdersFilter filter = visibleFilters[index];
              final bool selected = filter == state.selectedFilter;
              return InkWell(
                onTap: () =>
                    context.read<InfluencerOrdersCubit>().setFilter(filter),
                borderRadius: BorderRadius.circular(8.r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: BoxConstraints(minWidth: 52.w),
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.brandBlue : AppColors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AutoSizeText(
                    filter.label,
                    maxLines: 1,
                    minFontSize: 9,
                    maxFontSize: 12,
                    stepGranularity: 0.5,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

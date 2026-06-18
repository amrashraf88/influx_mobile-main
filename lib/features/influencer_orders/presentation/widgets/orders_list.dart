import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/influencer_orders/presentation/cubit/influencer_orders_cubit.dart';
import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';
import 'package:adzmavall/features/influencer_orders/presentation/widgets/order_card.dart';
import 'package:adzmavall/features/influencer_orders/presentation/widgets/orders_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OrdersList extends StatelessWidget {
  const OrdersList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfluencerOrdersCubit, InfluencerOrdersState>(
      builder: (BuildContext context, InfluencerOrdersState state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }

        final List<InfluencerOrder> orders = state.filteredOrders;
        if (orders.isEmpty) {
          return const OrdersEmptyState();
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 110.h),
          itemCount: orders.length,
          separatorBuilder: (_, _) => SizedBox(height: 14.h),
          itemBuilder: (BuildContext context, int index) {
            final InfluencerOrder order = orders[index];
            return OrderCard(
              order: order,
              onTap: () =>
                  context.push(RouteNames.influencerOrderDetailsPath(order.id)),
            );
          },
        );
      },
    );
  }
}

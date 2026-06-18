import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';
import 'package:adzmavall/features/influencer_orders/presentation/widgets/orders_adaptive_image.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, required this.onTap});

  final InfluencerOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.032),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _OrderLogo(name: order.clientName),
                  SizedBox(width: 12.w),
                  Expanded(child: _OrderSummary(order: order)),
                ],
              ),
              SizedBox(height: 13.h),
              Divider(color: const Color(0xFFE5E7EB), height: 1.h),
              SizedBox(height: 13.h),
              _OrderMetaRow(order: order, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    final String label = switch (order.status) {
      InfluencerOrderStatus.newRequest => 'New',
      InfluencerOrderStatus.inProgress => 'In\nProgress',
      InfluencerOrderStatus.pendingClientReview => 'Pending',
      InfluencerOrderStatus.completed => 'Completed',
      InfluencerOrderStatus.declined => 'Canceled',
    };
    return Container(
      constraints: BoxConstraints(minWidth: 62.w),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: order.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(11.r),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: order.status.color,
          height: 1.05,
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  order.clientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.05,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  order.clientSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          OrderStatusChip(order: order),
        ],
      ),
    );
  }
}

class _OrderMetaRow extends StatelessWidget {
  const _OrderMetaRow({required this.order, required this.onTap});

  final InfluencerOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Reward',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              _RsCurrencyText(
                value: order.priceLabel,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
                currencyColor: AppColors.brandBlue,
              ),
            ],
          ),
        ),
        if (order.status == InfluencerOrderStatus.newRequest)
          SizedBox(
            width: 84.w,
            height: 36.h,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Accept',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                'Due date',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                order.deliveryDateLabel,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _RsCurrencyText extends StatelessWidget {
  const _RsCurrencyText({
    required this.value,
    required this.style,
    this.currencyColor,
  });

  final String value;
  final TextStyle style;
  final Color? currencyColor;

  @override
  Widget build(BuildContext context) {
    const String currencyText = 'ر.س';
    if (!value.contains(currencyText)) {
      return Text(value, style: style);
    }

    final String amountText = value.replaceAll(currencyText, '').trim();
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          if (amountText.isNotEmpty) TextSpan(text: amountText, style: style),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsetsDirectional.only(start: 4.w),
              child: OrdersAdaptiveImage(
                source: ImageAssets.rsIcon,
                width: 15.w,
                height: 15.w,
                fit: BoxFit.contain,
                fallback: Icon(
                  Icons.currency_exchange_rounded,
                  size: 15.sp,
                  color: currencyColor ?? style.color,
                ),
              ),
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _OrderLogo extends StatelessWidget {
  const _OrderLogo({required this.name});

  final String name;

  String get _initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'AD';
    }
    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF6D3BEA), Color(0xFFE83D92)],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

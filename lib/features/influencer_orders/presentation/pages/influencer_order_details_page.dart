import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/influencer_orders/presentation/cubit/influencer_orders_cubit.dart';
import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';
import 'package:adzmavall/features/influencer_orders/presentation/widgets/orders_adaptive_image.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InfluencerOrderDetailsPage extends StatelessWidget {
  const InfluencerOrderDetailsPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InfluencerOrdersCubit>(
      create: (_) => InfluencerOrdersCubit()..loadOrder(orderId),
      child: _InfluencerOrderDetailsView(orderId: orderId),
    );
  }
}

class _InfluencerOrderDetailsView extends StatelessWidget {
  const _InfluencerOrderDetailsView({required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<InfluencerOrdersCubit, InfluencerOrdersState>(
            builder: (BuildContext context, InfluencerOrdersState state) {
              final InfluencerOrder? order = state.orderById(orderId);
              if (state.isLoading && order == null) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              if (order == null) {
                return _DetailsErrorState(
                  message: state.errorMessage ?? 'Order was not found.',
                  onBack: context.pop,
                );
              }
              return Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 22.h),
                      _DetailsHeader(onBack: context.pop),
                      SizedBox(height: 16.h),
                      _DetailTabs(selectedTab: state.selectedDetailTab),
                      if (state.errorMessage != null)
                        _InlineErrorMessage(message: state.errorMessage!),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(16.w, 21.h, 16.w, 120.h),
                          child: _DetailTabContent(
                            order: order,
                            tab: state.selectedDetailTab,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _OrderBottomActions(order: order),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailsHeader extends StatelessWidget {
  const _DetailsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        children: <Widget>[
          _SquareIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          Expanded(
            child: Center(
              child: Text(
                'Order Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          SizedBox(width: 38.w),
        ],
      ),
    );
  }
}

class _DetailsErrorState extends StatelessWidget {
  const _DetailsErrorState({required this.message, required this.onBack});

  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Column(
        children: <Widget>[
          SizedBox(height: 22.h),
          _DetailsHeader(onBack: onBack),
          const Spacer(),
          Icon(
            Icons.receipt_long_outlined,
            color: AppColors.brandBlue,
            size: 46.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _InlineErrorMessage extends StatelessWidget {
  const _InlineErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE11D48),
        ),
      ),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({required this.selectedTab});

  final InfluencerOrderDetailTab selectedTab;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: InfluencerOrderDetailTab.values.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (BuildContext context, int index) {
          final InfluencerOrderDetailTab tab =
              InfluencerOrderDetailTab.values[index];
          final bool selected = tab == selectedTab;
          return InkWell(
            onTap: () =>
                context.read<InfluencerOrdersCubit>().setDetailTab(tab),
            borderRadius: BorderRadius.circular(9.r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.brandBlue : AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.025),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                tab.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailTabContent extends StatelessWidget {
  const _DetailTabContent({required this.order, required this.tab});

  final InfluencerOrder order;
  final InfluencerOrderDetailTab tab;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      InfluencerOrderDetailTab.status => _StatusTab(order: order),
      InfluencerOrderDetailTab.client => _ClientTab(order: order),
      InfluencerOrderDetailTab.orderDetails => _OrderDetailsTab(order: order),
      InfluencerOrderDetailTab.attachment => _AttachmentTab(order: order),
      InfluencerOrderDetailTab.financialDetails => _FinancialTab(order: order),
      InfluencerOrderDetailTab.taxInvoice => _TaxInvoiceTab(order: order),
    };
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _StatusPill(order: order),
              SizedBox(height: 12.h),
              const Divider(color: Color(0xFFE5E7EB)),
              SizedBox(height: 12.h),
              Text(
                'Delivery Date : 20 December,2025, 5:22 PM',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 18.h),
              _SegmentedProgress(order: order),
            ],
          ),
        ),
        SizedBox(height: 21.h),
        Text(
          'Steps Details',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        _PanelCard(child: _StatusTimeline(order: order)),
      ],
    );
  }
}

class _ClientTab extends StatelessWidget {
  const _ClientTab({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _ClientLogo(asset: order.logoAsset),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      order.clientName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      order.clientSubtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(color: Color(0xFFE5E7EB)),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () =>
                  context.push(RouteNames.influencerChatDetailsPath(order.id)),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 20.sp),
              label: Text(
                'Chat',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsTab extends StatelessWidget {
  const _OrderDetailsTab({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    final InfluencerOrderDetails details = order.details;
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionTitle('About order'),
          _InfoRow(
            asset: ImageAssets.packageBoxIcon,
            title: 'Order Title',
            body: details.title,
          ),
          _InfoRow(
            asset: ImageAssets.userRectangleIcon,
            title: 'Order ID',
            body: details.orderId,
          ),
          _InfoRow(
            asset: ImageAssets.unlockIcon,
            title: 'Details',
            body: details.description,
          ),
          _InfoRow(
            asset: ImageAssets.userRectangleIcon,
            title: 'Client notes',
            body: details.clientNotes,
          ),
          _InfoRow(
            asset: ImageAssets.userRectangleIcon,
            title: 'Client website or social media',
            body: details.clientWebsite,
            bodyColor: AppColors.brandBlue,
          ),
          _InfoRow(
            asset: ImageAssets.calendarIcon,
            title: 'Delivery date & time',
            body: '${details.deliveryDate}      ${details.deliveryTime}',
          ),
          SizedBox(height: 10.h),
          _SectionTitle('About Campaign'),
          _InfoRow(
            asset: ImageAssets.userRectangleIcon,
            title: 'Campaign Objective',
            body: details.campaignObjective
                .map((String e) => '• $e')
                .join('\n'),
          ),
          _InfoRow(
            asset: ImageAssets.cardIcon,
            title: 'Target Followers',
            body: details.targetFollowers,
          ),
          _InfoRow(
            asset: ImageAssets.cardIcon,
            title: 'Target Followers age group',
            body: details.targetAgeGroup,
          ),
          _InfoRow(
            asset: ImageAssets.cardIcon,
            title: 'Influencer Category',
            body: details.influencerCategory,
          ),
          _InfoRow(
            asset: ImageAssets.platformsIcon,
            title: 'Platforms',
            body: details.platforms.join(', '),
          ),
        ],
      ),
    );
  }
}

class _AttachmentTab extends StatelessWidget {
  const _AttachmentTab({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        children: <Widget>[
          _AttachmentSection(
            title: 'Files (${order.attachments.files.length})',
            child: Column(
              children: order.attachments.files.map((InfluencerOrderFile file) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: <Widget>[
                      OrdersAdaptiveImage(
                        source: ImageAssets.pdfIcon,
                        width: 35.w,
                        height: 35.h,
                        fit: BoxFit.scaleDown,
                        fallback: Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.red,
                          size: 35.sp,
                        ),
                      ),
                      SizedBox(width: 11.w),
                      Expanded(
                        child: AutoSizeText(
                          file.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                          minFontSize: 10,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        file.sizeLabel,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.brandBlue,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          _AttachmentSection(
            title: 'Links',
            child: Column(
              children: order.attachments.links.map((String link) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 11.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: AutoSizeText(
                            link,
                            style: TextStyle(
                              color: AppColors.brandBlue,
                              fontSize: 14.sp,
                            ),
                            minFontSize: 10,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        OrdersAdaptiveImage(
                          source: ImageAssets.deleteIcon,
                          width: 20.w,
                          height: 20.h,
                          fit: BoxFit.scaleDown,
                          fallback: Icon(
                            Icons.delete_outline,
                            color: const Color(0xFFBE123C),
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _AttachmentSection(
            title: 'Notes',
            trailing: OrdersAdaptiveImage(
              source: ImageAssets.editIcon,
              width: 24.w,
              height: 24.h,
              fit: BoxFit.scaleDown,
              fallback: Icon(
                Icons.edit_outlined,
                color: AppColors.brandBlue,
                size: 24.sp,
              ),
            ),
            child: Text(
              order.attachments.notes,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialTab extends StatefulWidget {
  const _FinancialTab({required this.order});

  final InfluencerOrder order;

  @override
  State<_FinancialTab> createState() => _FinancialTabState();
}

class _FinancialTabState extends State<_FinancialTab> {
  bool _showDetails = true;

  @override
  Widget build(BuildContext context) {
    final InfluencerOrderFinancial financial = widget.order.financial;
    return Column(
      children: <Widget>[
        _PanelCard(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: <Widget>[
                    OrdersAdaptiveImage(
                      source: widget.order.platformIconAsset,
                      width: 50.w,
                      height: 24.w,
                      fit: BoxFit.scaleDown,
                      fallback: Icon(
                        Icons.music_note_rounded,
                        size: 24.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        widget.order.platformName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          // fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _RsCurrencyText(
                      value: financial.platformTotal,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.brandBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              if (_showDetails)
                Container(
                  padding: EdgeInsets.all(14.w),
                  color: const Color(0xFFF8FAFC),
                  child: Column(
                    children: financial.items.map((
                      InfluencerOrderFinancialItem item,
                    ) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          children: <Widget>[
                            OrdersAdaptiveImage(
                              source: item.icon,
                              width: 24.w,
                              height: 24.h,
                              fit: BoxFit.scaleDown,
                              fallback: Icon(
                                Icons.music_note_rounded,
                                size: 24.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            Text(
                              item.amount,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              SizedBox(height: 18.h),
              InkWell(
                onTap: () => setState(() => _showDetails = !_showDetails),
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        _showDetails ? 'Hide detail' : 'Show detail',
                        style: TextStyle(
                          color: AppColors.brandBlue,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        _showDetails
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.brandBlue,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _PanelCard(
          child: Column(
            children: <Widget>[
              _MoneyRow(label: 'Total order', value: financial.totalOrder),
              _MoneyRow(
                label: 'Listing fee ( 15 % )',
                value: financial.listingFee,
              ),
              _MoneyRow(
                label: 'Total before vat',
                value: financial.totalBeforeVat,
              ),
              _MoneyRow(
                label: 'Tax amount    ( 15 % )',
                value: financial.taxAmount,
                valueColor: const Color(0xFF25A85A),
              ),
              const Divider(height: 28, color: Color(0xFFE5E7EB)),
              _MoneyRow(
                label: 'Total With tax',
                value: financial.totalWithTax,
                isBold: true,
                valueColor: AppColors.brandBlue,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _PanelCard(
          child: Column(
            children: <Widget>[
              _PaymentRow(
                iconColor: const Color(0xFF25A85A),
                label: 'Deposite',
                value: financial.deposit,
              ),
              SizedBox(height: 12.h),
              _PaymentRow(
                iconColor: const Color(0xFFE5E7EB),
                label: 'Released',
                value: financial.released,
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F8FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        _CircleIcon(asset: ImageAssets.cardIcon),
                        SizedBox(width: 12.w),
                        Text(
                          'Payment Terms',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'This amount will be available for withdrawal 2 days after the ad is published',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Learn More  →',
                      style: TextStyle(
                        color: AppColors.brandBlue,
                        fontSize: 14.sp,
                        // fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TaxInvoiceTab extends StatelessWidget {
  const _TaxInvoiceTab({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tax Invoice',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'attach the tax invoice for the order to receive the amount with tax',
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Invoice amount including tax',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
              _RsCurrencyText(
                value: order.priceLabel,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.brandBlue,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          SizedBox(height: 14.h),
          InkWell(
            onTap: () =>
                context.read<InfluencerOrdersCubit>().pickTaxInvoice(order.id),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6FF),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFD8ECFF)),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textSecondary),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text:
                              order.attachments.taxInvoicePath ??
                              'Click to upload',
                          style: const TextStyle(
                            color: AppColors.brandBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const TextSpan(text: ' or drag and drop'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'SVG, PNG, JPG or GIF (max. 800×400px)',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderBottomActions extends StatelessWidget {
  const _OrderBottomActions({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    final bool actionLoading = context.select(
      (InfluencerOrdersCubit cubit) => cubit.state.isActionLoading,
    );
    final bool inProgress = order.status == InfluencerOrderStatus.inProgress;
    final bool pendingClientReview =
        order.status == InfluencerOrderStatus.pendingClientReview;
    final bool completed = order.status == InfluencerOrderStatus.completed;
    final bool enabled = !completed && !actionLoading;
    return Container(
      color: AppColors.pageBackground,
      padding: EdgeInsets.fromLTRB(
        22.w,
        12.h,
        22.w,
        MediaQuery.paddingOf(context).bottom + 18.h,
      ),
      child: pendingClientReview
          ? _OutlineActionButton(
              label: 'Attach Ad',
              icon: Icons.upload_rounded,
              enabled: enabled,
              onTap: () => _showAttachAdSheet(context, order),
            )
          : Row(
              children: <Widget>[
                Expanded(
                  child: _PrimaryActionButton(
                    label: inProgress ? 'Complete' : 'Approve',
                    enabled: enabled,
                    onTap: () {
                      if (inProgress) {
                        _showCompletionSheet(context, order);
                      } else {
                        _showApproveDialog(context, order);
                      }
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _OutlineActionButton(
                    label: inProgress ? 'Attach Ad' : 'Reject',
                    icon: inProgress ? Icons.upload_rounded : null,
                    enabled: enabled,
                    onTap: () {
                      if (inProgress) {
                        _showAttachAdSheet(context, order);
                      } else {
                        context.read<InfluencerOrdersCubit>().rejectOrder(
                          order.id,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    final List<String> titles = <String>[
      InfluencerOrderStatus.newRequest.label,
      InfluencerOrderStatus.inProgress.label,
      InfluencerOrderStatus.pendingClientReview.label,
      InfluencerOrderStatus.completed.label,
    ];
    return Column(
      children: List<Widget>.generate(titles.length, (int index) {
        final int step = index + 1;
        final bool active =
            step <= order.status.progressStep &&
            order.status != InfluencerOrderStatus.declined;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  width: 10.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: active
                          ? AppColors.brandBlue
                          : AppColors.textSecondary,
                      width: 3,
                    ),
                    color: AppColors.white,
                  ),
                ),
                if (index != titles.length - 1)
                  Container(
                    width: 1.w,
                    height: 76.h,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      titles[index],
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      'Manage multiple clients, run campaigns, and track creator performance',
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _AttachmentSection extends StatelessWidget {
  const _AttachmentSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _CircleIcon(asset: ImageAssets.packageBoxIcon),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        ?trailing,
                      ],
                    ),
                    SizedBox(height: 12.h),
                    child,
                    SizedBox(height: 18.h),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.asset,
    required this.title,
    required this.body,
    this.bodyColor,
  });

  final String asset;
  final String title;
  final String body;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _CircleIcon(asset: asset),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.35,
                        color: bodyColor ?? AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFE5E7EB)),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 13.5.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: order.status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.radio_button_checked,
            size: 10.sp,
            color: order.status.color,
          ),
          SizedBox(width: 4.w),
          Text(
            order.status.label,
            style: TextStyle(
              color: order.status.color,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentedProgress extends StatelessWidget {
  const _SegmentedProgress({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(4, (int index) {
        final bool active = index < order.status.progressStep;
        return Expanded(
          child: Container(
            height: 7.h,
            margin: EdgeInsetsDirectional.only(end: index == 3 ? 0 : 8.w),
            decoration: BoxDecoration(
              color: active ? order.status.color : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F0F9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: OrdersAdaptiveImage(
          source: asset,
          width: 24.w,
          height: 24.h,
          fit: BoxFit.scaleDown,
          fallback: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.brandBlue,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}

class _ClientLogo extends StatelessWidget {
  const _ClientLogo({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 94.w,
        height: 96.h,
        color: const Color(0xFFF5F7FB),
        child: OrdersAdaptiveImage(
          source: asset,
          width: 94.w,
          height: 96.h,
          fit: BoxFit.cover,
          fallback: Icon(
            Icons.storefront_rounded,
            color: AppColors.brandBlue,
            size: 42.sp,
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          _RsCurrencyText(
            value: value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.check_circle_rounded, color: iconColor, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _RsCurrencyText(
            value: value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.brandBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32.h,
      width: 32.w,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.tagText.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.white,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        highlightColor: AppColors.brandBlue.withValues(alpha: 0.1),
        child: SizedBox(
          width: 32.w,
          height: 32.h,
          child: Icon(icon, size: 19.sp, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onTap : null,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brandBlue,
        disabledBackgroundColor: const Color(0xFFF1F5F9),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onTap : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: icon == null
            ? const Color(0xFFBE123C)
            : AppColors.brandBlue,
        side: BorderSide(
          color: enabled
              ? (icon == null ? const Color(0xFFBE123C) : AppColors.brandBlue)
              : const Color(0xFFE5E7EB),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 19.sp),
      label: Text(
        label,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
      ),
    );
  }
}

void _showApproveDialog(BuildContext context, InfluencerOrder order) {
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return _ConfirmDialog(
        title: 'Confirm request approval',
        body:
            'Once the request is approval the status of the order will be ( Approve pending )',
        primaryLabel: 'Approve Order',
        onPrimary: () {
          context.read<InfluencerOrdersCubit>().approveOrder(order.id);
          Navigator.of(dialogContext).pop();
        },
      );
    },
  );
}

void _showAttachAdSheet(BuildContext context, InfluencerOrder order) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<InfluencerOrdersCubit>(),
      child: _AttachAdSheet(order: order),
    ),
  );
}

void _showCompletionSheet(BuildContext context, InfluencerOrder order) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<InfluencerOrdersCubit>(),
      child: _CompletionSheet(order: order),
    ),
  );
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const _MegaphoneMark(),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: _PrimaryActionButton(
                label: primaryLabel,
                onTap: onPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: _OutlineActionButton(
                label: 'Cancel',
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachAdSheet extends StatelessWidget {
  const _AttachAdSheet({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Add Ads',
      child: BlocBuilder<InfluencerOrdersCubit, InfluencerOrdersState>(
        builder: (BuildContext context, InfluencerOrdersState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('File', style: _sheetLabelStyle(context)),
              SizedBox(height: 8.h),
              _UploadBox(
                label: state.adDraft.fileName ?? 'Click to upload',
                onTap: context.read<InfluencerOrdersCubit>().pickDraftFile,
              ),
              SizedBox(height: 24.h),
              Text('Link', style: _sheetLabelStyle(context)),
              SizedBox(height: 12.h),
              ...List<Widget>.generate(state.adDraft.links.length, (int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _LinkInput(
                    initialValue: state.adDraft.links[index],
                    onChanged: (String value) => context
                        .read<InfluencerOrdersCubit>()
                        .updateDraftLink(index, value),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: context.read<InfluencerOrdersCubit>().addDraftLink,
                icon: Icon(
                  Icons.add_rounded,
                  size: 20.sp,
                  color: AppColors.brandBlue,
                ),
                label: Text(
                  'Add another link',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text('Notes', style: _sheetLabelStyle(context)),
              SizedBox(height: 12.h),
              TextField(
                minLines: 4,
                maxLines: 4,
                onChanged: context
                    .read<InfluencerOrdersCubit>()
                    .updateDraftNotes,
                decoration: InputDecoration(
                  hintText: 'Company field',
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: _PrimaryActionButton(
                  label: 'Save',
                  enabled: state.adDraft.links.any(
                    (String e) => e.trim().isNotEmpty,
                  ),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompletionSheet extends StatelessWidget {
  const _CompletionSheet({required this.order});

  final InfluencerOrder order;

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Add Ads',
      child: BlocBuilder<InfluencerOrdersCubit, InfluencerOrdersState>(
        builder: (BuildContext context, InfluencerOrdersState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(child: const _MegaphoneMark(size: 142)),
              SizedBox(height: 16.h),
              Text(
                'Confirm order completion',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Make sure to complete the order fully before confirming it. attach the order publication link here, you can also add attachment links later.',
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 10.h),
              Text('Link', style: _sheetLabelStyle(context)),
              SizedBox(height: 12.h),
              ...List<Widget>.generate(state.adDraft.links.length, (int index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _LinkInput(
                    initialValue: state.adDraft.links[index],
                    onChanged: (String value) => context
                        .read<InfluencerOrdersCubit>()
                        .updateDraftLink(index, value),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: context.read<InfluencerOrdersCubit>().addDraftLink,
                icon: Icon(
                  Icons.add_rounded,
                  size: 20.sp,
                  color: AppColors.brandBlue,
                ),
                label: Text(
                  'Add another link',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandBlue,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: _PrimaryActionButton(
                  label: 'Confirm Completion',
                  onTap: () {
                    context
                        .read<InfluencerOrdersCubit>()
                        .markPendingClientReview(order.id);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close_rounded, size: 26.sp),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 26.w),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(30.w, 20.h, 30.w, 32.h),
                  children: <Widget>[child],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF6FF),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFD8ECFF)),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              Icons.cloud_upload_outlined,
              color: AppColors.textSecondary,
              size: 36.sp,
            ),
            SizedBox(height: 12.h),
            AutoSizeText.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: label,
                    style: const TextStyle(
                      color: AppColors.brandBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(text: ' or drag and drop'),
                ],
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              minFontSize: 12,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Text(
              'SVG, PNG, JPG or GIF (max. 800×400px)',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkInput extends StatelessWidget {
  const _LinkInput({required this.initialValue, required this.onChanged});

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.link_rounded, size: 24.sp, color: Colors.black),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28.r),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
    );
  }
}

class _MegaphoneMark extends StatelessWidget {
  const _MegaphoneMark({this.size = 142});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          OrdersAdaptiveImage(
            source: ImageAssets.confirmApprovealIcon,
            width: size.w,
            height: size.h,
            fit: BoxFit.contain,
            fallback: Icon(
              Icons.campaign_rounded,
              color: AppColors.brandBlue,
              size: 70.sp,
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle _sheetLabelStyle(BuildContext context) {
  return TextStyle(
    fontSize: 17.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
}

class _RsCurrencyText extends StatelessWidget {
  const _RsCurrencyText({required this.value, required this.style});

  final String value;
  final TextStyle style;

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
                width: 16,
                height: 16,
                fit: BoxFit.contain,
                fallback: Icon(
                  Icons.currency_exchange_rounded,
                  size: 16,
                  color: style.color,
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

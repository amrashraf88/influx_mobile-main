import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/influencer_orders/data/influencer_orders_api_repository.dart';
import 'package:adzmavall/features/influencer_orders/data/influencer_orders_mock_repository.dart';
import 'package:adzmavall/features/influencer_orders/data/influencer_orders_repository.dart';
import 'package:adzmavall/features/influencer_orders/presentation/models/influencer_order_models.dart';
import 'package:adzmavall/features/influencer_profile/data/profile_edit_repository.dart';
import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InfluencerHomePage extends StatefulWidget {
  const InfluencerHomePage({super.key});

  @override
  State<InfluencerHomePage> createState() => _InfluencerHomePageState();
}

class _InfluencerHomePageState extends State<InfluencerHomePage> {
  late final Future<_InfluencerHomeData> _future = _load();

  Future<_InfluencerHomeData> _load() async {
    final InfluencerOrdersRepository ordersRepository =
        ApiUrlResolver.isConfigured
        ? InfluencerOrdersApiRepository(DioClient.instance)
        : InfluencerOrdersMockRepository();

    final List<InfluencerOrder> orders = await ordersRepository.fetchOrders();
    InfluencerProfileSummaryData profile = InfluencerProfileViewData.summary;
    if (ApiUrlResolver.isConfigured) {
      try {
        final Map<String, dynamic> json = await ProfileEditRepository(
          DioClient.instance,
        ).fetchProfile();
        profile = _profileFromJson(json, profile);
      } on Object {
        // Keep the bundled design fallback.
      }
    }

    return _InfluencerHomeData(profile: profile, orders: orders);
  }

  InfluencerProfileSummaryData _profileFromJson(
    Map<String, dynamic> json,
    InfluencerProfileSummaryData fallback,
  ) {
    String pick(List<String> keys, String fallbackValue) {
      final List<Map<String, dynamic>> maps = <Map<String, dynamic>>[json];
      for (final String objectKey in <String>[
        'user',
        'profile',
        'content_creator',
        'contentCreator',
        'creator',
      ]) {
        final Object? value = json[objectKey];
        if (value is Map) {
          maps.add(Map<String, dynamic>.from(value));
        }
      }
      for (final Map<String, dynamic> map in maps) {
        for (final String key in keys) {
          final Object? value = map[key];
          if (value != null && value.toString().trim().isNotEmpty) {
            return value.toString();
          }
        }
      }
      return fallbackValue;
    }

    return InfluencerProfileSummaryData(
      name: pick(<String>[
        'name',
        'full_name',
        'fullName',
        'display_name',
        'displayName',
        'username',
      ], fallback.name),
      title: pick(<String>[
        'headline',
        'title',
        'category',
        'niche',
        'creator_type',
      ], fallback.title),
      bio: pick(<String>['bio', 'about', 'description'], fallback.bio),
      avatarUrl: pick(<String>[
        'avatar_url',
        'avatarUrl',
        'profile_image_url',
        'profileImageUrl',
        'profile_photo_url',
        'profilePhotoUrl',
        'image_url',
        'imageUrl',
        'photo',
      ], fallback.avatarUrl),
      mawthooqLabel: pick(<String>[
        'mawthooq_label',
        'mawthooqLabel',
        'mawthooq',
        'license_number',
      ], fallback.mawthooqLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_InfluencerHomeData>(
      future: _future,
      builder: (BuildContext context, AsyncSnapshot<_InfluencerHomeData> snap) {
        final _InfluencerHomeData data =
            snap.data ??
            const _InfluencerHomeData(
              profile: InfluencerProfileViewData.summary,
              orders: <InfluencerOrder>[],
            );

        return SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: <Widget>[
              SliverToBoxAdapter(child: _HeroHeader(profile: data.profile)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 0),
                  child: _WelcomeBanner(
                    profile: data.profile,
                    newOffers: data.newOffers,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _MetricCard(
                          label: 'New offers',
                          value: data.newOffers.toString(),
                          icon: Icons.campaign_outlined,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _MetricCard(
                          label: 'In progress',
                          value: data.inProgress.toString(),
                          icon: Icons.pending_actions_outlined,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _MetricCard(
                          label: 'Completed',
                          value: data.completed.toString(),
                          icon: Icons.verified_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 24.h, 18.w, 12.h),
                  child: _SectionHeader(
                    title: 'Campaign offers',
                    action: 'View all',
                    onTap: () => context.go(RouteNames.influencerOrders),
                  ),
                ),
              ),
              if (snap.connectionState != ConnectionState.done)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (data.orders.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    onTap: () => context.go(RouteNames.influencerOrders),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: data.orders.take(3).length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (BuildContext context, int index) {
                    final InfluencerOrder order = data.orders[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: _OfferCard(
                        order: order,
                        onTap: () => context.push(
                          RouteNames.influencerOrderDetailsPath(order.id),
                        ),
                      ),
                    );
                  },
                ),
              SliverToBoxAdapter(child: SizedBox(height: 116.h)),
            ],
          ),
        );
      },
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.profile});

  final InfluencerProfileSummaryData profile;

  @override
  Widget build(BuildContext context) {
    final double topInset = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, topInset + 12.h, 20.w, 20.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF2A8DF2), Color(0xFF0066D6)],
        ),
      ),
      child: Row(
        children: <Widget>[
          _Avatar(url: profile.avatarUrl, size: 54.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Good morning, ${_firstName(profile.name)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  profile.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.82),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
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

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.profile, required this.newOffers});

  final InfluencerProfileSummaryData profile;
  final int newOffers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF1B7FEC), Color(0xFF0B5FCB)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.brandBlue.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  newOffers == 0
                      ? 'Your creator profile is ready'
                      : 'You have $newOffers new campaign offers',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'Review offers, manage orders, and keep your portfolio fresh.',
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.86),
                    fontSize: 12.sp,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 14.h),
                SizedBox(
                  height: 38.h,
                  child: FilledButton(
                    onPressed: () => context.go(RouteNames.influencerOrders),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.brandBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                    ),
                    child: const Text('View offers'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _Avatar(url: profile.avatarUrl, size: 66.w, rounded: true),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.brandBlue, size: 20.sp),
          SizedBox(height: 9.h),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textMuted, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.order, required this.onTap});

  final InfluencerOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 16,
                offset: Offset(0, 7.h),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              _Avatar(url: order.logoAsset, size: 48.w, rounded: true),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      order.clientName.isEmpty
                          ? 'Campaign offer'
                          : order.clientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      order.clientSubtitle.isEmpty
                          ? order.orderNumber
                          : order.clientSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      order.priceLabel,
                      style: TextStyle(
                        color: AppColors.brandBlue,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _StatusPill(status: order.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final InfluencerOrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        _shortStatus(status),
        style: TextStyle(
          color: status.color,
          fontSize: 9.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.inventory_2_outlined,
            color: AppColors.textMuted,
            size: 42.sp,
          ),
          SizedBox(height: 12.h),
          Text(
            'No campaign offers yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'New brand invitations will appear here as soon as they arrive.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12.sp),
          ),
          SizedBox(height: 16.h),
          OutlinedButton(onPressed: onTap, child: const Text('Open orders')),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size, this.rounded = false});

  final String url;
  final double size;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(rounded ? 18.r : 999.r);
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: size,
        height: size,
        child: url.trim().isEmpty
            ? Container(
                color: const Color(0xFFEAF2FE),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.brandBlue,
                  size: size * 0.52,
                ),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: const Color(0xFFEAF2FE)),
                errorWidget: (_, _, _) => Container(
                  color: const Color(0xFFEAF2FE),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.brandBlue,
                    size: size * 0.52,
                  ),
                ),
              ),
      ),
    );
  }
}

class _InfluencerHomeData {
  const _InfluencerHomeData({required this.profile, required this.orders});

  final InfluencerProfileSummaryData profile;
  final List<InfluencerOrder> orders;

  int get newOffers => orders
      .where(
        (InfluencerOrder order) =>
            order.status == InfluencerOrderStatus.newRequest,
      )
      .length;

  int get inProgress => orders
      .where(
        (InfluencerOrder order) =>
            order.status == InfluencerOrderStatus.inProgress,
      )
      .length;

  int get completed => orders
      .where(
        (InfluencerOrder order) =>
            order.status == InfluencerOrderStatus.completed,
      )
      .length;
}

String _firstName(String name) {
  final String trimmed = name.trim();
  if (trimmed.isEmpty) {
    return 'Creator';
  }
  return trimmed.split(RegExp(r'\s+')).first;
}

String _shortStatus(InfluencerOrderStatus status) {
  return switch (status) {
    InfluencerOrderStatus.newRequest => 'New',
    InfluencerOrderStatus.inProgress => 'In progress',
    InfluencerOrderStatus.pendingClientReview => 'Review',
    InfluencerOrderStatus.completed => 'Done',
    InfluencerOrderStatus.declined => 'Canceled',
  };
}

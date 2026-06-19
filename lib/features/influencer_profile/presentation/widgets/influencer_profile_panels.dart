import 'package:adzmavall/features/influencer_profile/presentation/models/influencer_profile_view_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_panel_card.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfluencerProfileTabContent extends StatelessWidget {
  const InfluencerProfileTabContent({
    super.key,
    required this.index,
    this.rawProfile = const <String, dynamic>{},
    this.creatorType = 'influencer',
  });

  final int index;
  final Map<String, dynamic> rawProfile;
  final String creatorType;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 1:
        return const _ClientsPanel();
      case 2:
        return const _AdPricePanel();
      case 3:
        return const _AdsPanel();
      case 4:
        return const _OverviewPanel();
      case 5:
        return _DetailsPanel(rawProfile: rawProfile, creatorType: creatorType);
      case 0:
      default:
        return const _AccountsPanel();
    }
  }
}

class _DetailsPanel extends StatelessWidget {
  const _DetailsPanel({required this.rawProfile, required this.creatorType});

  final Map<String, dynamic> rawProfile;
  final String creatorType;

  @override
  Widget build(BuildContext context) {
    final List<_ProfileDetailRow> rows = _detailsForType(
      rawProfile,
      creatorType,
    );
    if (rows.isEmpty) {
      return InfluencerPanelCard(
        child: Text(
          'No profile details yet.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return InfluencerPanelCard(
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            _ProfileDetailTile(row: rows[i]),
            if (i != rows.length - 1)
              Divider(height: 18.h, color: const Color(0xFFEDEFF4)),
          ],
        ],
      ),
    );
  }
}

class _ProfileDetailTile extends StatelessWidget {
  const _ProfileDetailTile({required this.row});

  final _ProfileDetailRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            row.label,
            style: TextStyle(
              color: const Color(0xFF7A8392),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: Text(
            row.value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileDetailRow {
  const _ProfileDetailRow(this.label, this.value);

  final String label;
  final String value;
}

List<_ProfileDetailRow> _detailsForType(
  Map<String, dynamic> json,
  String creatorType,
) {
  final List<_ProfileDetailRow> common = <_ProfileDetailRow>[
    _row(json, 'Creator type', <String>['creator_type', 'creatorType', 'type']),
    _row(json, 'City', <String>['city']),
    _row(json, 'Gender', <String>['gender']),
    _row(json, 'Age', <String>['age']),
  ];

  final String normalized = creatorType.trim().toLowerCase();
  final List<_ProfileDetailRow> typed = switch (normalized) {
    'model' => <_ProfileDetailRow>[
      _row(json, 'Nationality', <String>['nationality']),
      _row(json, 'Height', <String>['height', 'height_cm']),
      _row(json, 'Weight', <String>['weight', 'weight_kg']),
      _row(json, 'Size', <String>['size']),
      _row(json, 'Skin tone', <String>['skin_tone', 'skinTone']),
      _row(json, 'Session price', <String>[
        'session_price_per_hour',
        'sessionRatePerHour',
      ]),
      _row(json, 'Face visible', <String>['face_visibility', 'faceVisible']),
      _row(json, 'Hair visible', <String>['show_hair', 'showHair']),
      _row(json, 'Full body', <String>['body_visibility', 'bodyVisibility']),
    ],
    'ugc' => <_ProfileDetailRow>[
      _row(json, 'Video price', <String>['video_price', 'videoPrice']),
      _row(json, 'Delivery time', <String>[
        'deliverability_time',
        'delivery_time_from_arrival',
        'deliveryTimeFromArrival',
      ]),
      _row(json, 'Voice over', <String>['voice_over', 'voiceOver']),
      _row(json, 'Hook', <String>['use_hook', 'useHook']),
      _row(json, 'Face visible', <String>['face_visibility', 'faceVisible']),
      _row(json, 'Hair visible', <String>['show_hair', 'showHair']),
    ],
    'collage' => <_ProfileDetailRow>[
      _row(json, 'District', <String>['street', 'collage_district']),
      _row(json, 'Direction', <String>['city_direction', 'cityDirection']),
      _row(json, 'Accent', <String>['accent']),
      _row(json, 'Clip price', <String>[
        'clip_price_per_second',
        'clipPricePerSecond',
      ]),
    ],
    _ => <_ProfileDetailRow>[
      _row(json, 'District', <String>['street', 'district']),
      _row(json, 'Direction', <String>['city_direction', 'cityDirection']),
      _row(json, 'Mawthooq license', <String>[
        'mawthooq_license_number',
        'mawthooqLicenseNumber',
        'license_number',
      ]),
    ],
  };

  return <_ProfileDetailRow>[
    ...common,
    ...typed,
  ].where((_ProfileDetailRow row) => row.value.trim().isNotEmpty).toList();
}

_ProfileDetailRow _row(
  Map<String, dynamic> json,
  String label,
  List<String> keys,
) {
  return _ProfileDetailRow(label, _pickProfileValue(json, keys));
}

String _pickProfileValue(Map<String, dynamic> json, List<String> keys) {
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
  return '';
}

class _AccountsPanel extends StatelessWidget {
  const _AccountsPanel();

  @override
  Widget build(BuildContext context) {
    return InfluencerPanelCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: InfluencerProfileViewData.accountMetrics.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 18.h,
          crossAxisSpacing: 8.w,
          childAspectRatio: 0.70,
        ),
        itemBuilder: (BuildContext context, int index) {
          return _AccountMetricTile(
            metric: InfluencerProfileViewData.accountMetrics[index],
          );
        },
      ),
    );
  }
}

class _AccountMetricTile extends StatelessWidget {
  const _AccountMetricTile({required this.metric});

  final InfluencerAccountMetric metric;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(metric.asset, width: 24.w, height: 24.w),
          ),
        ),
        SizedBox(height: 11.h),
        Text(
          metric.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          '399.6k',
          style: TextStyle(
            color: const Color(0xFF9AA2AE),
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ClientsPanel extends StatelessWidget {
  const _ClientsPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 34.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: InfluencerProfileViewData.clientCategories.length,
            separatorBuilder: (_, _) => SizedBox(width: 24.w),
            itemBuilder: (BuildContext context, int index) {
              final bool selected = index == 0;
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    InfluencerProfileViewData.clientCategories[index],
                    style: TextStyle(
                      color: selected
                          ? AppColors.brandBlue
                          : const Color(0xFF787F8A),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    width: 86.w,
                    height: 2.h,
                    color: selected ? AppColors.brandBlue : Colors.transparent,
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        InfluencerPanelCard(
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: InfluencerProfileViewData.clients.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 18.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (BuildContext context, int index) {
              return _ClientTile(
                item: InfluencerProfileViewData.clients[index],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ClientTile extends StatelessWidget {
  const _ClientTile({required this.item});

  final InfluencerClientItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 44.w,
          height: 44.w,
          decoration: const BoxDecoration(
            color: Color(0xFFFAFAFA),
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: CachedNetworkImage(
            imageUrl: item.logoUrl,
            fit: BoxFit.cover,
            placeholder: (BuildContext context, String url) =>
                const ColoredBox(color: Color(0xFFEEF2F6)),
            errorWidget: (BuildContext context, String url, Object error) =>
                Icon(
                  Icons.storefront_outlined,
                  color: const Color(0xFF747B86),
                  size: 20.sp,
                ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          item.name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AdPricePanel extends StatelessWidget {
  const _AdPricePanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: InfluencerProfileViewData.adPriceItems
          .map(
            (InfluencerAdPriceItem item) => Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: _AdPriceCard(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _AdPriceCard extends StatelessWidget {
  const _AdPriceCard({required this.item});

  final InfluencerAdPriceItem item;

  @override
  Widget build(BuildContext context) {
    return InfluencerPanelCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(item.asset!, width: 25.w, height: 25.h),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const _FollowerPill(),
              SizedBox(width: 8.w),
              const _OpenSmallButton(),
            ],
          ),
          Divider(height: 22.h, color: const Color(0xFFE7E9ED)),
          Row(
            children: <Widget>[
              const Expanded(
                child: _PriceMetric(label: 'Coverage', value: '17,600'),
              ),
              SizedBox(width: 20.w),
              const Expanded(
                child: _PriceMetric(label: 'Video', value: '3,500'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FollowerPill extends StatelessWidget {
  const _FollowerPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D8),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        '399.6k Followers',
        style: TextStyle(
          color: const Color(0xFFE6C44E),
          fontSize: 8.5.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OpenSmallButton extends StatelessWidget {
  const _OpenSmallButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: const BoxDecoration(
        color: Color(0xFFE5F7FF),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.open_in_new_rounded,
        color: const Color(0xFF6EC7EA),
        size: 15.sp,
      ),
    );
  }
}

class _PriceMetric extends StatelessWidget {
  const _PriceMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF7D8591),
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: <Widget>[
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '﷼',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  const _OverviewPanel();

  @override
  Widget build(BuildContext context) {
    return InfluencerPanelCard(
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _OverviewSectionTitle('Key Words'),
          SizedBox(height: 14.h),
          const _ChipWrap(values: InfluencerProfileViewData.keywords),
          SizedBox(height: 20.h),
          const _OverviewSectionTitle('Age'),
          SizedBox(height: 12.h),
          const _ChipWrap(values: <String>['18-25']),
          SizedBox(height: 20.h),
          const _OverviewSectionTitle('Platforms'),
          SizedBox(height: 12.h),
          const _ChipWrap(
            values: <String>['Tiktok', 'Instagram', 'Tiktok', 'Instagram'],
          ),
        ],
      ),
    );
  }
}

class _OverviewSectionTitle extends StatelessWidget {
  const _OverviewSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ChipWrap extends StatelessWidget {
  const _ChipWrap({required this.values});

  final List<String> values;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 10.h,
      children: values
          .map(
            (String value) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: const Color(0xFF6E737B),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AdsPanel extends StatelessWidget {
  const _AdsPanel();

  @override
  Widget build(BuildContext context) {
    return InfluencerPanelCard(
      child: SizedBox(
        height: 308.h,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: InfluencerProfileViewData.adPreviews
                .map(
                  (InfluencerAdPreviewItem item) => Padding(
                    padding: EdgeInsetsDirectional.only(end: 16.w),
                    child: SizedBox(
                      width: 181.w,
                      height: 308.h,
                      child: _AdPreviewCard(item: item),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _AdPreviewCard extends StatelessWidget {
  const _AdPreviewCard({required this.item});

  final InfluencerAdPreviewItem item;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: item.imageUrl,
            fit: BoxFit.cover,
            placeholder: (BuildContext context, String url) =>
                const ColoredBox(color: Color(0xFFCBD5E1)),
            errorWidget: (BuildContext context, String url, Object error) =>
                const ColoredBox(color: Color(0xFFCBD5E1)),
          ),
          Positioned(
            top: 10.h,
            left: 10.w,
            child: const _AdOverlayCircle(icon: Icons.volume_off_rounded),
          ),
          Positioned(
            top: 10.h,
            right: 10.w,
            child: const _AdOverlayCircle(icon: Icons.play_arrow_rounded),
          ),
          Positioned(
            left: 12.w,
            bottom: 12.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.storefront_outlined,
                    color: AppColors.white,
                    size: 15.sp,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
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

class _AdOverlayCircle extends StatelessWidget {
  const _AdOverlayCircle({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.26),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.white, size: 16.sp),
    );
  }
}

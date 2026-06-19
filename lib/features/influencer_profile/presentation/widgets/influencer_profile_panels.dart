import 'package:adzmavall/features/influencer_profile/presentation/models/creator_profile_tab_data.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_panel_card.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfluencerProfileTabContent extends StatelessWidget {
  const InfluencerProfileTabContent({
    super.key,
    required this.index,
    required this.tabData,
    this.rawProfile = const <String, dynamic>{},
    this.creatorType = 'influencer',
    this.editing = false,
    this.onDelete,
  });

  final int index;
  final CreatorProfileTabData tabData;
  final Map<String, dynamic> rawProfile;
  final String creatorType;

  /// Whether the current list tab is in edit mode (shows delete affordances).
  final bool editing;

  /// Called with an item id when the user taps its delete badge.
  final void Function(String id)? onDelete;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 1:
        return _ClientsPanel(
          data: tabData,
          editing: editing,
          onDelete: onDelete,
        );
      case 2:
        return _AdPricePanel(items: tabData.adPriceItems);
      case 3:
        return _AdsPanel(ads: tabData.ads, editing: editing, onDelete: onDelete);
      case 4:
        return _OverviewPanel(data: tabData);
      case 5:
        return _DetailsPanel(rawProfile: rawProfile, creatorType: creatorType);
      case 0:
      default:
        return _AccountsPanel(
          accounts: tabData.accounts,
          editing: editing,
          onDelete: onDelete,
        );
    }
  }
}

/// Empty-state card shown when a tab has no data from the API.
class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return InfluencerPanelCard(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 18.h),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small red delete badge overlaid on list items while editing.
class _DeleteBadge extends StatelessWidget {
  const _DeleteBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22.w,
        height: 22.w,
        decoration: const BoxDecoration(
          color: Color(0xFFFF4D4F),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close_rounded, color: AppColors.white, size: 14.sp),
      ),
    );
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
  const _AccountsPanel({
    required this.accounts,
    this.editing = false,
    this.onDelete,
  });

  final List<CreatorAccountMetric> accounts;
  final bool editing;
  final void Function(String id)? onDelete;

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return const _EmptyPanel('No accounts yet.');
    }
    return InfluencerPanelCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: accounts.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 18.h,
          crossAxisSpacing: 8.w,
          childAspectRatio: 0.70,
        ),
        itemBuilder: (BuildContext context, int index) {
          final CreatorAccountMetric metric = accounts[index];
          final bool deletable =
              editing && metric.id.isNotEmpty && onDelete != null;
          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              _AccountMetricTile(metric: metric),
              if (deletable)
                Positioned(
                  top: -4.h,
                  right: -2.w,
                  child: _DeleteBadge(onTap: () => onDelete!(metric.id)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AccountMetricTile extends StatelessWidget {
  const _AccountMetricTile({required this.metric});

  final CreatorAccountMetric metric;

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
        if (metric.followers.isNotEmpty) ...<Widget>[
          SizedBox(height: 5.h),
          Text(
            metric.followers,
            style: TextStyle(
              color: const Color(0xFF9AA2AE),
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _ClientsPanel extends StatelessWidget {
  const _ClientsPanel({
    required this.data,
    this.editing = false,
    this.onDelete,
  });

  final CreatorProfileTabData data;
  final bool editing;
  final void Function(String id)? onDelete;

  @override
  Widget build(BuildContext context) {
    if (data.clients.isEmpty) {
      return const _EmptyPanel('No clients yet.');
    }
    return Column(
      children: <Widget>[
        if (data.clientCategories.isNotEmpty)
          SizedBox(
            height: 34.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.clientCategories.length,
              separatorBuilder: (_, _) => SizedBox(width: 24.w),
              itemBuilder: (BuildContext context, int index) {
                final bool selected = index == 0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      data.clientCategories[index],
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
                      color: selected
                          ? AppColors.brandBlue
                          : Colors.transparent,
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
            itemCount: data.clients.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 18.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.88,
            ),
            itemBuilder: (BuildContext context, int index) {
              final CreatorClientItem item = data.clients[index];
              final bool deletable =
                  editing && item.id.isNotEmpty && onDelete != null;
              return Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  _ClientTile(item: item),
                  if (deletable)
                    Positioned(
                      top: -4.h,
                      right: -2.w,
                      child: _DeleteBadge(onTap: () => onDelete!(item.id)),
                    ),
                ],
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

  final CreatorClientItem item;

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
  const _AdPricePanel({required this.items});

  final List<CreatorAdPriceItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyPanel('No ad prices yet.');
    }
    return Column(
      children: items
          .map(
            (CreatorAdPriceItem item) => Padding(
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

  final CreatorAdPriceItem item;

  @override
  Widget build(BuildContext context) {
    return InfluencerPanelCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(item.asset, width: 25.w, height: 25.h),
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
              if (item.followers.isNotEmpty) ...<Widget>[
                _FollowerPill(followers: item.followers),
                SizedBox(width: 8.w),
              ],
              const _OpenSmallButton(),
            ],
          ),
          Divider(height: 22.h, color: const Color(0xFFE7E9ED)),
          Row(
            children: <Widget>[
              Expanded(
                child: _PriceMetric(label: 'Coverage', value: item.coverage),
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: _PriceMetric(label: 'Video', value: item.videoPrice),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FollowerPill extends StatelessWidget {
  const _FollowerPill({required this.followers});

  final String followers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D8),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        '$followers Followers',
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
  const _OverviewPanel({required this.data});

  final CreatorProfileTabData data;

  @override
  Widget build(BuildContext context) {
    if (data.keywords.isEmpty &&
        data.ageRanges.isEmpty &&
        data.platforms.isEmpty) {
      return const _EmptyPanel('No overview details yet.');
    }
    return InfluencerPanelCard(
      padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (data.keywords.isNotEmpty) ...<Widget>[
            const _OverviewSectionTitle('Key Words'),
            SizedBox(height: 14.h),
            _ChipWrap(values: data.keywords),
            SizedBox(height: 20.h),
          ],
          if (data.ageRanges.isNotEmpty) ...<Widget>[
            const _OverviewSectionTitle('Age'),
            SizedBox(height: 12.h),
            _ChipWrap(values: data.ageRanges),
            SizedBox(height: 20.h),
          ],
          if (data.platforms.isNotEmpty) ...<Widget>[
            const _OverviewSectionTitle('Platforms'),
            SizedBox(height: 12.h),
            _ChipWrap(values: data.platforms),
          ],
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
  const _AdsPanel({required this.ads, this.editing = false, this.onDelete});

  final List<CreatorAdPreviewItem> ads;
  final bool editing;
  final void Function(String id)? onDelete;

  @override
  Widget build(BuildContext context) {
    if (ads.isEmpty) {
      return const _EmptyPanel('No ads yet.');
    }
    return InfluencerPanelCard(
      child: SizedBox(
        height: 308.h,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ads.map((CreatorAdPreviewItem item) {
              final bool deletable =
                  editing && item.id.isNotEmpty && onDelete != null;
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 16.w),
                child: SizedBox(
                  width: 181.w,
                  height: 308.h,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(child: _AdPreviewCard(item: item)),
                      if (deletable)
                        PositionedDirectional(
                          top: 10.h,
                          end: 10.w,
                          child: _DeleteBadge(onTap: () => onDelete!(item.id)),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _AdPreviewCard extends StatelessWidget {
  const _AdPreviewCard({required this.item});

  final CreatorAdPreviewItem item;

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

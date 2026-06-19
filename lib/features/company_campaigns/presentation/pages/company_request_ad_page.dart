import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/network/api_url_resolver.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/features/company_campaigns/data/company_stars_repository.dart';
import 'package:adzmavall/features/company_campaigns/data/company_stars_view_data.dart';
import 'package:adzmavall/features/company_campaigns/presentation/models/company_star_models.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_back_app_bar.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_flow_dialogs.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_date_field.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_form_field.dart';
import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_platform_chip.dart';
import 'package:adzmavall/features/influencer_profile/presentation/widgets/influencer_panel_card.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CompanyRequestAdPage extends StatefulWidget {
  const CompanyRequestAdPage({super.key, required this.starId});

  final String starId;

  @override
  State<CompanyRequestAdPage> createState() => _CompanyRequestAdPageState();
}

class _CompanyRequestAdPageState extends State<CompanyRequestAdPage> {
  late List<CompanyRequestAdPlatform> _platforms;
  final TextEditingController _delivery = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _cardNumber = TextEditingController();
  final TextEditingController _cardName = TextEditingController();
  final TextEditingController _expiry = TextEditingController();
  final TextEditingController _cvv = TextEditingController();
  bool _useCard = true;

  @override
  void initState() {
    super.initState();
    _platforms = CompanyStarsViewData.requestAdPlatforms();
    _loadPlatforms();
  }

  @override
  void dispose() {
    _delivery.dispose();
    _description.dispose();
    _cardNumber.dispose();
    _cardName.dispose();
    _expiry.dispose();
    _cvv.dispose();
    super.dispose();
  }

  static const double _platformFeeRate = 0.15;
  static const double _taxRate = 0.15;

  Future<void> _loadPlatforms() async {
    if (!ApiUrlResolver.isConfigured) {
      return;
    }
    try {
      final CompanyStarProfile profile = await CompanyStarsRepository(
        DioClient.instance,
      ).fetchStarProfile(widget.starId);
      final List<CompanyRequestAdPlatform> platforms = profile.adPrices
          .map(_platformFromAdPrice)
          .toList();
      if (!mounted || platforms.isEmpty) {
        return;
      }
      setState(() => _platforms = platforms);
    } on Object {
      // Keep the view-data fallback already in _platforms.
    }
  }

  CompanyRequestAdPlatform _platformFromAdPrice(CompanyStarAdPriceLine line) {
    final String name = line.platformName.trim().isNotEmpty
        ? line.platformName.trim()
        : _platformNameFromKey(line.labelKey);
    return CompanyRequestAdPlatform(
      id: _platformIdFromName(name),
      name: name,
      followersLabel: line.followersLabel,
      lines: <CompanyRequestAdLine>[
        CompanyRequestAdLine(
          typeKey: 'company_request_ad_story',
          priceLabel: line.coveragePrice,
          quantity: 0,
        ),
        CompanyRequestAdLine(
          typeKey: 'company_request_ad_video',
          priceLabel: line.videoPrice,
          quantity: 0,
        ),
        CompanyRequestAdLine(
          typeKey: 'company_request_ad_post',
          priceLabel: line.coveragePrice,
          quantity: 0,
        ),
        CompanyRequestAdLine(
          typeKey: 'company_request_ad_reel',
          priceLabel: line.videoPrice,
          quantity: 0,
        ),
      ],
    );
  }

  String _platformNameFromKey(String key) {
    return switch (key) {
      'company_star_platform_snapchat' => 'Snapchat',
      'company_star_platform_tiktok' => 'Tik Tok',
      'company_star_platform_whatsapp' => 'Whatsapp',
      'company_star_platform_instagram' => 'Instagram',
      'company_star_platform_facebook' => 'Facebook',
      'company_star_platform_youtube' => 'YouTube',
      'company_star_platform_telegram' => 'Telegram',
      'company_star_platform_threads' => 'Threads',
      'company_star_platform_twitter' => 'X',
      _ => key,
    };
  }

  String _platformIdFromName(String name) {
    final String lower = name.toLowerCase();
    if (lower.contains('snap')) {
      return 'snap';
    }
    if (lower.contains('tik') || lower.contains('tok')) {
      return 'tiktok';
    }
    if (lower.contains('whats')) {
      return 'wa';
    }
    if (lower.contains('insta')) {
      return 'instagram';
    }
    if (lower.contains('face') || lower == 'fb') {
      return 'facebook';
    }
    if (lower.contains('you') || lower == 'yt') {
      return 'youtube';
    }
    if (lower.contains('telegram')) {
      return 'telegram';
    }
    if (lower.contains('thread')) {
      return 'threads';
    }
    if (lower == 'x' || lower.contains('twitter')) {
      return 'twitter';
    }
    return lower.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  double _parsePrice(String priceLabel) {
    return double.tryParse(priceLabel.replaceAll(',', '')) ?? 0;
  }

  double _orderSubtotal() {
    double total = 0;
    for (final CompanyRequestAdPlatform platform in _platforms) {
      for (final CompanyRequestAdLine line in platform.lines) {
        total += line.quantity * _parsePrice(line.priceLabel);
      }
    }
    return total;
  }

  String _formatAmount(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  void _setQty(int platformIndex, int lineIndex, int delta) {
    setState(() {
      final CompanyRequestAdPlatform p = _platforms[platformIndex];
      final List<CompanyRequestAdLine> lines = List<CompanyRequestAdLine>.from(
        p.lines,
      );
      final CompanyRequestAdLine line = lines[lineIndex];
      lines[lineIndex] = line.copyWith(
        quantity: (line.quantity + delta).clamp(0, 99),
      );
      _platforms[platformIndex] = CompanyRequestAdPlatform(
        id: p.id,
        name: p.name,
        followersLabel: p.followersLabel,
        lines: lines,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final double orderTotal = _orderSubtotal();
    final double platformFee = orderTotal * _platformFeeRate;
    final double taxAmount = (orderTotal + platformFee) * _taxRate;
    final double totalWithTax = orderTotal + platformFee + taxAmount;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: CompanyCampaignBackAppBar(
        title: AppStrings.of(locale, 'company_request_ad_title'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CompanyCampaignDateField(
              label: AppStrings.of(locale, 'company_request_ad_delivery'),
              controller: _delivery,
              hint: AppStrings.of(locale, 'company_create_hint_delivery'),
            ),
            SizedBox(height: 12.h),
            CompanyCampaignFormField(
              label: AppStrings.of(locale, 'company_request_ad_description'),
              controller: _description,
              hint: AppStrings.of(locale, 'company_campaign_type_here'),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            ...List<Widget>.generate(_platforms.length, (int pi) {
              final CompanyRequestAdPlatform platform = _platforms[pi];
              return Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: _PlatformCard(
                  platform: platform,
                  locale: locale,
                  onQty: (int li, int d) => _setQty(pi, li, d),
                ),
              );
            }),
            Text(
              AppStrings.of(locale, 'company_request_ad_payment_methods'),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            _PaymentSummary(
              locale: locale,
              orderTotal: orderTotal,
              platformFee: platformFee,
              taxAmount: taxAmount,
              totalWithTax: totalWithTax,
              formatAmount: _formatAmount,
            ),
            SizedBox(height: 12.h),
            _PaymentOption(
              title: AppStrings.of(locale, 'company_request_ad_wallet'),
              subtitle: _formatAmount(totalWithTax),
              selected: !_useCard,
              onTap: () => setState(() => _useCard = false),
            ),
            SizedBox(height: 10.h),
            _PaymentOption(
              title: AppStrings.of(locale, 'company_request_ad_card'),
              subtitle: 'Mastercard / Visa',
              selected: _useCard,
              onTap: () => setState(() => _useCard = true),
              child: _useCard
                  ? Column(
                      children: <Widget>[
                        SizedBox(height: 12.h),
                        CompanyCampaignFormField(
                          label: AppStrings.of(
                            locale,
                            'company_request_ad_card_number',
                          ),
                          controller: _cardNumber,
                          hint: '0000 0000 0000 0000',
                          prefixIcon: Icons.credit_card,
                        ),
                        SizedBox(height: 10.h),
                        CompanyCampaignFormField(
                          label: AppStrings.of(
                            locale,
                            'company_request_ad_card_name',
                          ),
                          controller: _cardName,
                          hint: AppStrings.of(
                            locale,
                            'company_create_hint_brand',
                          ),
                          prefixIcon: Icons.person_outline,
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: CompanyCampaignFormField(
                                label: AppStrings.of(
                                  locale,
                                  'company_request_ad_expiry',
                                ),
                                controller: _expiry,
                                hint: 'MM/YY',
                                prefixIcon: Icons.calendar_today_outlined,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: CompanyCampaignFormField(
                                label: 'CVV',
                                controller: _cvv,
                                hint: '000',
                                prefixIcon: Icons.lock_outline,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : null,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
          child: SizedBox(
            height: 48.h,
            child: FilledButton(
              onPressed: () => showPaymentSuccessDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28.r),
                ),
              ),
              child: Text(
                AppStrings.of(locale, 'company_request_ad_pay'),
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlatformCard extends StatelessWidget {
  const _PlatformCard({
    required this.platform,
    required this.locale,
    required this.onQty,
  });

  final CompanyRequestAdPlatform platform;
  final Locale locale;
  final void Function(int lineIndex, int delta) onQty;

  String get _platformAsset {
    return CompanyCampaignPlatformAssets.assetFor(
      platform.name.trim().isNotEmpty ? platform.name : platform.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String asset = _platformAsset;
    return InfluencerPanelCard(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Image.asset(asset, width: 25.w, height: 25.h),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  platform.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              if (platform.followersLabel.trim().isNotEmpty) ...<Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8D8),
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '${platform.followersLabel} ${AppStrings.of(locale, 'company_star_followers')}',
                    style: TextStyle(
                      color: const Color(0xFFE6C44E),
                      fontSize: 8.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
              ],
              Container(
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
              ),
            ],
          ),
          Divider(height: 22.h, color: const Color(0xFFE7E9ED)),
          ...List<Widget>.generate(platform.lines.length, (int i) {
            final CompanyRequestAdLine line = platform.lines[i];
            final bool isLast = i == platform.lines.length - 1;
            final String priceLabel = line.priceLabel.trim();
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppStrings.of(locale, line.typeKey),
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
                              priceLabel.isEmpty ? '-' : priceLabel,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (priceLabel.isNotEmpty) ...<Widget>[
                              SizedBox(width: 8.w),
                              Image.asset(
                                ImageAssets.rsIcon,
                                width: 16.w,
                                height: 16.h,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  _QtyControl(
                    value: line.quantity,
                    onMinus: () => onQty(i, -1),
                    onPlus: () => onQty(i, 1),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final bool active = value > 0;
    final Color inactiveColor = const Color(0xFFD1D5DB);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _QtyButton(
          icon: Icons.remove_rounded,
          onTap: active ? onMinus : null,
          filled: false,
          active: active,
        ),
        SizedBox(
          width: 32.w,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: active ? AppColors.textPrimary : inactiveColor,
            ),
          ),
        ),
        _QtyButton(
          icon: Icons.add_rounded,
          onTap: onPlus,
          filled: true,
          active: true,
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.filled,
    required this.active,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = active
        ? AppColors.brandBlue
        : const Color(0xFFD1D5DB);
    final Color iconColor = filled
        ? AppColors.white
        : active
        ? AppColors.brandBlue
        : const Color(0xFFD1D5DB);

    return Material(
      color: filled ? AppColors.brandBlue : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
        side: filled
            ? BorderSide.none
            : BorderSide(color: borderColor, width: 1.2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: SizedBox(
          width: 36.w,
          height: 36.w,
          child: Icon(icon, size: 20.sp, color: iconColor),
        ),
      ),
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({
    required this.locale,
    required this.orderTotal,
    required this.platformFee,
    required this.taxAmount,
    required this.totalWithTax,
    required this.formatAmount,
  });

  final Locale locale;
  final double orderTotal;
  final double platformFee;
  final double taxAmount;
  final double totalWithTax;
  final String Function(double amount) formatAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
      ),
      child: Column(
        children: <Widget>[
          _Row(
            AppStrings.of(locale, 'company_campaign_order_total'),
            formatAmount(orderTotal),
            bold: true,
          ),
          _Row(
            AppStrings.of(locale, 'company_request_ad_platform_fee'),
            formatAmount(platformFee),
          ),
          _Row(
            AppStrings.of(locale, 'company_campaign_order_tax'),
            formatAmount(taxAmount),
            green: true,
          ),
          const Divider(),
          _Row(
            AppStrings.of(locale, 'company_campaign_total_with_tax'),
            formatAmount(totalWithTax),
            blue: true,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
    this.label,
    this.value, {
    this.bold = false,
    this.green = false,
    this.blue = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool green;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: green
                  ? const Color(0xFF22C55E)
                  : blue
                  ? AppColors.brandBlue
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.child,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F4FD),
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: AppColors.brandBlue,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.brandBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ?child,
            ],
          ),
        ),
      ),
    );
  }
}

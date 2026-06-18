import 'package:adzmavall/features/company_campaigns/presentation/widgets/company_campaign_form_field.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyCampaignDateField extends StatelessWidget {
  const CompanyCampaignDateField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.readOnly = false,
    this.value,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool readOnly;
  final String? value;

  static String formatDate(DateTime date, Locale locale) {
    return DateFormat('dd MMMM, yyyy', locale.languageCode).format(date);
  }

  DateTime? _parsedValue(Locale locale) {
    final String raw = controller?.text.trim() ?? value?.trim() ?? '';
    if (raw.isEmpty) {
      return null;
    }
    try {
      return DateFormat('dd MMMM, yyyy', locale.languageCode).parse(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    if (readOnly) {
      return;
    }
    final Locale locale = Localizations.localeOf(context);
    final DateTime now = DateTime.now();
    final DateTime resolvedInitial =
        _parsedValue(locale) ?? initialDate ?? now;
    final DateTime resolvedFirst = firstDate ?? now;
    final DateTime resolvedLast = lastDate ?? now.add(const Duration(days: 365 * 5));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: resolvedInitial.isBefore(resolvedFirst)
          ? resolvedFirst
          : resolvedInitial,
      firstDate: resolvedFirst,
      lastDate: resolvedLast,
      helpText: label,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.brandBlue,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && controller != null) {
      controller!.text = formatDate(picked, locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? null : () => _pickDate(context),
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: CompanyCampaignFormField(
          label: label,
          controller: controller,
          value: value ?? '',
          hint: hint,
          readOnly: true,
          prefixIconAsset: ImageAssets.calendarIcon,
        ),
      ),
    );
  }
}

import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Labeled field with optional leading asset icon (create / details campaign forms).
class CompanyCampaignFormField extends StatelessWidget {
  const CompanyCampaignFormField({
    super.key,
    required this.label,
    this.controller,
    this.value = '',
    this.hint,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
    this.keyboardType,
    this.prefixIcon,
    this.prefixIconAsset,
    this.hidePrefixIcon = false,
  });

  /// Pass [prefixIcon] for Material icons on editable forms (e.g. card, calendar).
  /// Pass [prefixIconAsset] for image assets; omit to use [ImageAssets.loginflowBuildingicon].
  /// Set [hidePrefixIcon] true for fields without a leading image.
  final String label;
  final TextEditingController? controller;
  final String value;
  final String? hint;
  final int maxLines;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final String? prefixIconAsset;
  final bool hidePrefixIcon;

  Widget? _buildPrefixIcon() {
    if (hidePrefixIcon) {
      return null;
    }
    if (prefixIcon != null) {
      return Icon(
        prefixIcon,
        size: 20.sp,
        color: const Color(0xFF94A3B8),
      );
    }
    return Image.asset(
      prefixIconAsset ?? ImageAssets.loginflowBuildingicon,
      width: 20.w,
      height: 20.w,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget? prefix = _buildPrefixIcon();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (label.isNotEmpty) ...<Widget>[
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? (value.isEmpty ? null : value) : null,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: readOnly ? null : onChanged,
          enableInteractiveSelection: !readOnly,
          mouseCursor: readOnly ? SystemMouseCursors.basic : null,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp),
          decoration: InputDecoration(
            hintText: hint ?? (value.isNotEmpty ? null : hint),
            hintStyle: TextStyle(
              color: const Color(0xFFB0B7C3),
              fontSize: 12.sp,
            ),
            prefixIcon: prefix == null
                ? null
                : Padding(
                    padding: EdgeInsets.only(left: 14.w, right: 8.w),
                    child: prefix,
                  ),
            prefixIconConstraints: BoxConstraints(minWidth: 36.w, minHeight: 24.h),
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: EdgeInsets.symmetric(
              horizontal: prefix == null ? 14.w : 4.w,
              vertical: 13.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: Color(0xFFE1E5EC)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: Color(0xFFE1E5EC)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: Color(0xFFE1E5EC)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide(
                color: readOnly ? const Color(0xFFE1E5EC) : AppColors.brandBlue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

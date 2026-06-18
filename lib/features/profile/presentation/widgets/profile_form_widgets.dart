import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.titleTrailing,
  });

  final String title;
  final String? subtitle;
  final Widget? titleTrailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFE7EAF0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ?titleTrailing,
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
            SizedBox(height: 4.h),
            Text(
              subtitle!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.sp,
                height: 1.35,
              ),
            ),
          ],
          SizedBox(height: 14.h),
          ...children,
        ],
      ),
    );
  }
}

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.errorText,
    this.keyboardType,
    this.maxLines = 1,
    this.inputFormatters,
    this.fieldFillColor,
  });

  final String label;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String? errorText;
  final TextInputType? keyboardType;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  /// When set, used as the text field background (e.g. social blocks).
  final Color? fieldFillColor;

  @override
  Widget build(BuildContext context) {
    final Color fill = fieldFillColor ?? const Color(0xFFF7F8FA);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            hintStyle: TextStyle(
              color: const Color(0xFFB0B7C3),
              fontSize: 12.sp,
            ),
            filled: true,
            fillColor: fill,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: AppColors.brandBlue),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileSelectField extends StatelessWidget {
  const ProfileSelectField({
    super.key,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.items = const <String>[],
    this.options,
    this.value,
    this.errorText,
    this.fieldFillColor,
    this.leadingIconBuilder,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final List<ProfileChipOption>? options;
  final ValueChanged<String> onChanged;
  final String? errorText;
  final Color? fieldFillColor;
  final Widget Function(String item)? leadingIconBuilder;

  List<ProfileChipOption> get _resolvedOptions {
    if (options != null && options!.isNotEmpty) {
      return options!;
    }
    return items
        .map(
          (String item) => ProfileChipOption(value: item, label: item),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<ProfileChipOption> resolvedOptions = _resolvedOptions;
    final Color fill = fieldFillColor ?? const Color(0xFFF7F8FA);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: value == null || value!.isEmpty ? null : value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: Text(hint),
          selectedItemBuilder: leadingIconBuilder == null
              ? null
              : (BuildContext context) {
                  return resolvedOptions.map((ProfileChipOption option) {
                    return _SelectItemContent(
                      label: option.label,
                      leading: leadingIconBuilder!(option.value),
                    );
                  }).toList();
                },
          items: resolvedOptions
              .map(
                (ProfileChipOption option) => DropdownMenuItem<String>(
                  value: option.value,
                  child: leadingIconBuilder == null
                      ? Text(option.label)
                      : _SelectItemContent(
                          label: option.label,
                          leading: leadingIconBuilder!(option.value),
                        ),
                ),
              )
              .toList(),
          onChanged: (String? next) {
            if (next == null) {
              return;
            }
            onChanged(next);
          },
          decoration: InputDecoration(
            errorText: errorText,
            filled: true,
            fillColor: fill,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: const BorderSide(color: AppColors.brandBlue),
            ),
          ),
          style: TextStyle(color: AppColors.textPrimary, fontSize: 13.sp),
        ),
      ],
    );
  }
}

class _SelectItemContent extends StatelessWidget {
  const _SelectItemContent({required this.label, required this.leading});

  final String label;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        leading,
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class ProfileChipOption {
  const ProfileChipOption({required this.value, required this.label});

  final String value;
  final String label;
}

class ProfileChipWrap extends StatelessWidget {
  const ProfileChipWrap({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<ProfileChipOption> options;
  final Set<String> selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: options.map((ProfileChipOption option) {
        final bool isSelected = selected.contains(option.value);
        return ChoiceChip(
          label: Text(option.label),
          selected: isSelected,
          onSelected: (_) => onSelected(option.value),
          selectedColor: AppColors.brandBlue.withValues(alpha: 0.12),
          backgroundColor: const Color(0xFFF7F8FA),
          side: BorderSide(
            color: isSelected ? AppColors.brandBlue : const Color(0xFFE1E5EC),
          ),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.brandBlue : AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.r),
          ),
        );
      }).toList(),
    );
  }
}

class ProfileUploadCard extends StatelessWidget {
  const ProfileUploadCard({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final String description;
  final String buttonText;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE1E5EC)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 46.w,
            height: 46.w,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              color: AppColors.brandBlue,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
              height: 1.35,
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: onAdd,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandBlue,
              side: const BorderSide(color: AppColors.brandBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(800.r),
              ),
            ),
            child: Text(buttonText),
          ),
          if (count > 0) ...<Widget>[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: List<Widget>.generate(
                count,
                (int index) =>
                    _UploadPlaceholder(index: index, onRemove: onRemove),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder({required this.index, required this.onRemove});

  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          width: 86.w,
          height: 112.h,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE1E5EC)),
          ),
          child: Icon(
            Icons.image_outlined,
            color: AppColors.textSecondary,
            size: 28.sp,
          ),
        ),
        Positioned(
          right: -6.w,
          top: -6.h,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              width: 22.w,
              height: 22.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.white,
                size: 14.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

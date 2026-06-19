import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Declarative description of one field inside a [showCreatorFormSheet].
class CreatorFormField {
  const CreatorFormField({
    required this.key,
    required this.label,
    this.initial = '',
    this.hint = '',
    this.multiline = false,
    this.number = false,
    this.options = const <String>[],
  });

  final String key;
  final String label;
  final String initial;
  final String hint;
  final bool multiline;
  final bool number;

  /// When non-empty the field renders as a dropdown instead of a text field.
  final List<String> options;
}

/// Shows a bottom-sheet form and returns the entered values keyed by
/// [CreatorFormField.key], or `null` if the user cancels.
Future<Map<String, String>?> showCreatorFormSheet(
  BuildContext context, {
  required String title,
  required List<CreatorFormField> fields,
  String submitLabel = 'Save',
}) {
  return showModalBottomSheet<Map<String, String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
    ),
    builder: (BuildContext ctx) => _CreatorFormSheet(
      title: title,
      fields: fields,
      submitLabel: submitLabel,
    ),
  );
}

class _CreatorFormSheet extends StatefulWidget {
  const _CreatorFormSheet({
    required this.title,
    required this.fields,
    required this.submitLabel,
  });

  final String title;
  final List<CreatorFormField> fields;
  final String submitLabel;

  @override
  State<_CreatorFormSheet> createState() => _CreatorFormSheetState();
}

class _CreatorFormSheetState extends State<_CreatorFormSheet> {
  late final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{
        for (final CreatorFormField f in widget.fields)
          if (f.options.isEmpty) f.key: TextEditingController(text: f.initial),
      };
  late final Map<String, String> _dropdownValues = <String, String>{
    for (final CreatorFormField f in widget.fields)
      if (f.options.isNotEmpty)
        f.key: f.initial.isNotEmpty ? f.initial : f.options.first,
  };

  @override
  void dispose() {
    for (final TextEditingController c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final Map<String, String> result = <String, String>{
      for (final MapEntry<String, TextEditingController> e
          in _controllers.entries)
        e.key: e.value.text.trim(),
      ..._dropdownValues,
    };
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 42.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E5EA),
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                widget.title,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 18.h),
              for (final CreatorFormField field in widget.fields) ...<Widget>[
                _FieldLabel(field.label),
                SizedBox(height: 6.h),
                if (field.options.isNotEmpty)
                  _Dropdown(
                    value: _dropdownValues[field.key]!,
                    options: field.options,
                    onChanged: (String v) =>
                        setState(() => _dropdownValues[field.key] = v),
                  )
                else
                  _TextField(
                    controller: _controllers[field.key]!,
                    hint: field.hint,
                    multiline: field.multiline,
                    number: field.number,
                  ),
                SizedBox(height: 14.h),
              ],
              SizedBox(height: 4.h),
              SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandBlue,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    widget.submitLabel,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: const Color(0xFF7A8392),
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    required this.multiline,
    required this.number,
  });

  final TextEditingController controller;
  final String hint;
  final bool multiline;
  final bool number;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: multiline ? 4 : 1,
      keyboardType: number
          ? TextInputType.number
          : (multiline ? TextInputType.multiline : TextInputType.text),
      inputFormatters: number
          ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
          : null,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: const Color(0xFFB4BAC4),
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6F8),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12.r),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          items: options
              .map(
                (String o) =>
                    DropdownMenuItem<String>(value: o, child: Text(o)),
              )
              .toList(),
          onChanged: (String? v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

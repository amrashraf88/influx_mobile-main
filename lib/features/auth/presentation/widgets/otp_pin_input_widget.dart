import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpPinInputWidget extends StatefulWidget {
  const OtpPinInputWidget({
    super.key,
    required this.length,
    required this.value,
    required this.onChanged,
  });

  final int length;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<OtpPinInputWidget> createState() => _OtpPinInputWidgetState();
}

class _OtpPinInputWidgetState extends State<OtpPinInputWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  void _onFocusOrTextChanged() {
    setState(() {});
  }

  int _activeCellIndex(int len) {
    if (!_focusNode.hasFocus) {
      return -1;
    }
    final int offset = _controller.selection.isValid
        ? _controller.selection.baseOffset
        : widget.value.length;
    final int o = offset.clamp(0, len);
    if (o >= len) {
      return len - 1;
    }
    return o;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusOrTextChanged);
    _controller.addListener(_onFocusOrTextChanged);
  }

  @override
  void didUpdateWidget(covariant OtpPinInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(
          offset: widget.value.length.clamp(0, widget.length),
        ),
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusOrTextChanged);
    _controller.removeListener(_onFocusOrTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int len = widget.length;
    final int activeIndex = _activeCellIndex(len);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).requestFocus(_focusNode),
      child: SizedBox(
        height: 76.h,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0,
                child: SizedBox(
                  width: 1.sw,
                  height: 76.h,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: len,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(counterText: ''),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: widget.onChanged,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List<Widget>.generate(len, (int i) {
                  final bool hasDigit = i < widget.value.length;
                  final String? ch = hasDigit ? widget.value[i] : null;
                  final bool selected = activeIndex == i;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: selected
                                ? AppColors.brandBlue
                                : const Color(0xFFE2E8F0),
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            ch ?? '·',
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              color: hasDigit
                                  ? AppColors.textPrimary
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

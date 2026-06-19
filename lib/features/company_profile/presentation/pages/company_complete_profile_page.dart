import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CompanyCompleteProfilePage extends StatefulWidget {
  const CompanyCompleteProfilePage({super.key, required this.phone});

  final String phone;

  @override
  State<CompanyCompleteProfilePage> createState() =>
      _CompanyCompleteProfilePageState();
}

class _CompanyCompleteProfilePageState
    extends State<CompanyCompleteProfilePage> {
  late final TextEditingController _brandName;
  late final TextEditingController _email;
  late final TextEditingController _website;
  late final TextEditingController _password;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _brandName = TextEditingController();
    _email = TextEditingController();
    _website = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _brandName.dispose();
    _email.dispose();
    _website.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _brandName.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _website.text.trim().isNotEmpty &&
      _password.text.trim().isNotEmpty;

  void _submit() {
    setState(() => _submitted = true);
    if (!_isValid) {
      return;
    }
    context.go(
      RouteNames.companyHomePath(phone: widget.phone, registered: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFFAFBFD),
          body: Column(
            children: <Widget>[
              const _Header(),
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 30.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _Badge(),
                      SizedBox(height: 18.h),
                      _BrandTextField(
                        label: 'Brand / company name',
                        hint: 'e.g. Caftan SLM',
                        controller: _brandName,
                        submitted: _submitted,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: 14.h),
                      _BrandTextField(
                        label: 'Business email',
                        hint: 'brand@company.com',
                        controller: _email,
                        submitted: _submitted,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: 14.h),
                      _BrandTextField(
                        label: 'Website',
                        hint: 'https://',
                        controller: _website,
                        submitted: _submitted,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: 14.h),
                      _BrandTextField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _password,
                        submitted: _submitted,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        onChanged: (_) => setState(() {}),
                      ),
                      SizedBox(height: 16.h),
                      Text.rich(
                        TextSpan(
                          text: 'By creating an account you agree to the ',
                          children: <InlineSpan>[
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: AppColors.brandBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.brandBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                        style: TextStyle(
                          color: const Color(0xFFA4ABB8),
                          fontSize: 11.5.sp,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 26.h),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFEFF1F5))),
                  ),
                  child: Material(
                    color: AppColors.brandBlue,
                    shadowColor: AppColors.brandBlue.withValues(alpha: 0.32),
                    elevation: 8,
                    borderRadius: BorderRadius.circular(13.r),
                    child: InkWell(
                      onTap: _submit,
                      borderRadius: BorderRadius.circular(13.r),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50.h,
                        child: Center(
                          child: Text(
                            'Create account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEFF1F5))),
      ),
      child: Column(
        children: <Widget>[
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 12.h),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 38.w,
                    height: 38.w,
                    child: FilledButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(RouteNames.authAccountType);
                        }
                      },
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFFF1F4F9),
                        foregroundColor: const Color(0xFF0E1426),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11.r),
                        ),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_left_rounded,
                        size: 25.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Brand sign up',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF0E1426),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(width: 38.w),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FE),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.business_center_outlined,
            color: AppColors.brandBlue,
            size: 16.sp,
          ),
          SizedBox(width: 7.w),
          Text(
            'Brand account',
            style: TextStyle(
              color: AppColors.brandBlue,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTextField extends StatelessWidget {
  const _BrandTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.submitted,
    required this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool submitted;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final bool showError = submitted && controller.text.trim().isEmpty;
    final BorderRadius radius = BorderRadius.circular(12.r);
    final Color borderColor = showError
        ? const Color(0xFFE05252)
        : const Color(0xFFE6EAF1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF5A6680),
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 7.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          cursorColor: AppColors.brandBlue,
          style: TextStyle(
            color: const Color(0xFF0E1426),
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 13.h,
            ),
            hintStyle: TextStyle(
              color: const Color(0xFFB6BDCA),
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: radius,
              borderSide: BorderSide(
                color: showError
                    ? const Color(0xFFE05252)
                    : AppColors.brandBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

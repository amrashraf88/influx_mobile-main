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
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: const Color(0xFFFAFBFD),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                _Header(isArabic: isArabic),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _Badge(isArabic: isArabic),
                        SizedBox(height: 18.h),
                        _BrandTextField(
                          label: isArabic
                              ? 'اسم البراند / الشركة'
                              : 'Brand / company name',
                          hint: 'e.g. Caftan SLM',
                          controller: _brandName,
                          submitted: _submitted,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 14.h),
                        _BrandTextField(
                          label: isArabic
                              ? 'البريد الإلكتروني للعمل'
                              : 'Business email',
                          hint: 'brand@company.com',
                          controller: _email,
                          submitted: _submitted,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 14.h),
                        _BrandTextField(
                          label: isArabic ? 'الموقع الإلكتروني' : 'Website',
                          hint: 'https://',
                          controller: _website,
                          submitted: _submitted,
                          keyboardType: TextInputType.url,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 14.h),
                        _BrandTextField(
                          label: isArabic ? 'كلمة المرور' : 'Password',
                          hint: '••••••••',
                          controller: _password,
                          submitted: _submitted,
                          obscureText: true,
                          onChanged: (_) => setState(() {}),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          isArabic
                              ? 'بإنشاء الحساب أنت توافق على الشروط وسياسة الخصوصية.'
                              : 'By creating an account you agree to the Terms and Privacy Policy.',
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
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 18.h),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFEFF1F5))),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(isArabic ? 'إنشاء حساب' : 'Create account'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.isArabic});

  final bool isArabic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEFF1F5))),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 12.h),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 38.w,
                  height: 38.w,
                  child: FilledButton(
                    onPressed: () => context.pop(),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: const Color(0xFFF1F4F9),
                      foregroundColor: const Color(0xFF0E1426),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                    ),
                    child: Icon(
                      isArabic
                          ? Icons.keyboard_arrow_right_rounded
                          : Icons.keyboard_arrow_left_rounded,
                      size: 25.sp,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    isArabic ? 'تسجيل البراند' : 'Brand sign up',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF0E1426),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                SizedBox(width: 38.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.isArabic});

  final bool isArabic;

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
          Icon(Icons.business_center_outlined, size: 16.sp),
          SizedBox(width: 7.w),
          Text(
            isArabic ? 'حساب براند' : 'Brand account',
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
    this.keyboardType,
    this.obscureText = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool submitted;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final bool showError = submitted && controller.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF5A6680),
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 7.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: TextStyle(
            color: const Color(0xFF0E1426),
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            errorText: showError ? 'Required' : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 13.h,
            ),
            hintStyle: TextStyle(
              color: const Color(0xFFB6BDCA),
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: Color(0xFFE6EAF1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: Color(0xFFE6EAF1),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.brandBlue,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

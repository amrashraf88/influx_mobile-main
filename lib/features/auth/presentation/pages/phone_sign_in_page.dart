import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/auth/data/models/otp_models.dart';
import 'package:adzmavall/features/auth/presentation/cubit/auth_phone_cubit.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_flow_header_widget.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_header_grid_painter.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneSignInPage extends StatefulWidget {
  const PhoneSignInPage({super.key, required this.accountType});

  final String accountType;

  @override
  State<PhoneSignInPage> createState() => _PhoneSignInPageState();
}

class _PhoneSignInPageState extends State<PhoneSignInPage> {
  late final TextEditingController _phoneController;
  String _dialCode = '+966';

  void _onPhoneTextChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneController.addListener(_onPhoneTextChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneTextChanged);
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final TextStyle phoneFieldStyle = TextStyle(
      color: const Color(0xFF111827),
      fontSize: 14.sp,
      fontWeight: FontWeight.w600,
      height: 1.0,
    );
    final TextStyle phoneHintStyle = TextStyle(
      color: const Color(0xFF9CA3AF),
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      height: 1.0,
    );
    final bool dialCodeLikeHint = _phoneController.text.isEmpty;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: SafeArea(
          bottom: false,
          top: false,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double headerHeight = 394.h;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            height: headerHeight,
                            width: double.infinity,
                            child: CustomPaint(
                              foregroundPainter: AuthHeaderGridPainter(),
                              child: Container(
                                color: AppColors.brandBlue,
                                padding: EdgeInsets.only(top: 75.h),
                                child: AuthFlowHeaderWidget(
                                  showStar: false,
                                  centerText: true,
                                  title: 'Login to your\naccount',
                                  subtitle: '',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 210.h),
                        ],
                      ),
                      Positioned(
                        left: 16.w,
                        right: 16.w,
                        top: headerHeight - 137.h,
                        child: Material(
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20.r),
                          color: const Color(0xFFF4F5F7),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F5F7),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: const Color(0xFFD9DCE3),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                16.w,
                                24.h,
                                16.w,
                                23.h,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Phone Number',
                                    style: TextStyle(
                                      color: const Color(0xFF1F2937),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(
                                          AuthPhoneState.maxDigits,
                                        ),
                                      ],
                                      style: phoneFieldStyle,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: AppStrings.of(
                                          locale,
                                          'auth_phone_hint',
                                        ),
                                        hintStyle: phoneHintStyle,
                                        filled: true,
                                        fillColor: const Color(0xFFF1F1F4),
                                        contentPadding: EdgeInsets.fromLTRB(
                                          0,
                                          14.h,
                                          16.w,
                                          14.h,
                                        ),
                                        prefixIconConstraints: BoxConstraints(
                                          minHeight: 48.h,
                                          maxHeight: 48.h,
                                          minWidth: 0,
                                          maxWidth: 220.w,
                                        ),
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.only(left: 12.w),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              CountryCodePicker(
                                                initialSelection: 'SA',
                                                favorite: const <String>[
                                                  'SA',
                                                  'AE',
                                                  'EG',
                                                ],
                                                padding: EdgeInsets.zero,
                                                margin: EdgeInsets.zero,
                                                alignLeft: true,
                                                hideMainText: true,
                                                showFlag: true,
                                                showFlagMain: true,
                                                showOnlyCountryWhenClosed: true,
                                                onInit: (CountryCode? code) {
                                                  final String? d =
                                                      code?.dialCode;
                                                  if (d != null &&
                                                      d.isNotEmpty &&
                                                      d != _dialCode) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((
                                                          _,
                                                        ) {
                                                          if (!mounted) {
                                                            return;
                                                          }
                                                          setState(
                                                            () => _dialCode = d,
                                                          );
                                                        });
                                                  }
                                                },
                                                onChanged: (CountryCode code) {
                                                  setState(() {
                                                    _dialCode =
                                                        code.dialCode ?? '+966';
                                                  });
                                                },
                                                builder: (CountryCode? country) {
                                                  final String? uri =
                                                      country?.flagUri;
                                                  final double flagSize = 28.w;
                                                  return Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: flagSize,
                                                        height: flagSize,
                                                        child: uri == null
                                                            ? const DecoratedBox(
                                                                decoration: BoxDecoration(
                                                                  color: Color(
                                                                    0xFF006C35,
                                                                  ),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              )
                                                            : ClipOval(
                                                                child: Image.asset(
                                                                  uri,
                                                                  package:
                                                                      'country_code_picker',
                                                                  width:
                                                                      flagSize,
                                                                  height:
                                                                      flagSize,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  gaplessPlayback:
                                                                      true,
                                                                ),
                                                              ),
                                                      ),
                                                      Icon(
                                                        Icons
                                                            .keyboard_arrow_down_rounded,
                                                        color: const Color(
                                                          0xFF111827,
                                                        ),
                                                        size: 20.sp,
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                _dialCode,
                                                style: dialCodeLikeHint
                                                    ? phoneHintStyle
                                                    : phoneFieldStyle,
                                              ),
                                              // SizedBox(width: 1.w),
                                            ],
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            30.r,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFD8D8DD),
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            30.r,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFD8D8DD),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            30.r,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFBFC5CE),
                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                      onChanged: (String value) {
                                        context
                                            .read<AuthPhoneCubit>()
                                            .setDigits(value);
                                      },
                                    ),
                                  ),
                                  SizedBox(height: 24.h),
                                  BlocConsumer<AuthPhoneCubit, AuthPhoneState>(
                                    listenWhen:
                                        (
                                          AuthPhoneState previous,
                                          AuthPhoneState current,
                                        ) =>
                                            previous.status != current.status,
                                    listener: (
                                      BuildContext context,
                                      AuthPhoneState state,
                                    ) {
                                      if (state.status != AuthPhoneStatus.success) {
                                        return;
                                      }
                                      final OtpInitiateResult? result =
                                          state.lastInitiateResult;
                                      if (result == null || result.id.isEmpty) {
                                        return;
                                      }
                                      final String phone = '$_dialCode${state.digits}';
                                      final String identifier =
                                          AuthPhoneCubit.apiIdentifier(
                                            _dialCode,
                                            state.digits,
                                          );
                                      if (!context.mounted) {
                                        return;
                                      }
                                      context.push(
                                        Uri(
                                          path: RouteNames.authVerification,
                                          queryParameters: <String, String>{
                                            'account': widget.accountType,
                                            'phone': phone,
                                            'identifier': identifier,
                                            'otpId': result.id,
                                            'hasExistingAccount':
                                                result.hasExistingAccount
                                                    .toString(),
                                          },
                                        ).toString(),
                                      );
                                    },
                                    builder: (context, state) {
                                      final bool canSubmit =
                                          state.isValid && !state.isLoading;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: <Widget>[
                                          if (state.errorMessage != null) ...<Widget>[
                                            Text(
                                              state.errorMessage!,
                                              style: TextStyle(
                                                color: const Color(0xFFB91C1C),
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 12.h),
                                          ],
                                          SizedBox(
                                            width: double.infinity,
                                            height: 40.h,
                                            child: FilledButton(
                                              style: FilledButton.styleFrom(
                                                backgroundColor: canSubmit
                                                    ? AppColors.brandBlue
                                                    : const Color(0xFFECEFF1),
                                                foregroundColor: canSubmit
                                                    ? AppColors.white
                                                    : const Color(0xFFA1A1AA),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        800.r,
                                                      ),
                                                ),
                                                textStyle: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              onPressed: canSubmit
                                                  ? () {
                                                      context
                                                          .read<AuthPhoneCubit>()
                                                          .initiateOtp(
                                                            accountType: widget
                                                                .accountType,
                                                            dialCode: _dialCode,
                                                          );
                                                    }
                                                  : null,
                                              child: state.isLoading
                                                  ? SizedBox(
                                                      width: 22.w,
                                                      height: 22.w,
                                                      child:
                                                          const CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            color:
                                                                AppColors.white,
                                                          ),
                                                    )
                                                  : Text(
                                                      AppStrings.of(
                                                        locale,
                                                        'auth_next',
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          SizedBox(height: 18.h),
                                          Text(
                                            'By Clicking Continue, you agree to\nAdz Mavall Agreement',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.brandBlue,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w500,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

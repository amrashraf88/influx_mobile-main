import 'dart:io' show File;

import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_header_grid_painter.dart';
import 'package:adzmavall/features/company_profile/presentation/cubit/company_profile_cubit.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:adzmavall/utils/imageassets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _companyName;
  late final TextEditingController _brandName;
  late final TextEditingController _companyLink;
  late final TextEditingController _commercialRegistration;
  late final TextEditingController _vatNumber;
  late final TextEditingController _businessRegisterNumber;
  late final TextEditingController _taxNumber;
  late final TextEditingController _addressName;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _postalCode;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController();
    _lastName = TextEditingController();
    _companyName = TextEditingController();
    _brandName = TextEditingController();
    _companyLink = TextEditingController();
    _commercialRegistration = TextEditingController();
    _vatNumber = TextEditingController();
    _businessRegisterNumber = TextEditingController();
    _taxNumber = TextEditingController();
    _addressName = TextEditingController();
    _city = TextEditingController();
    _address = TextEditingController();
    _postalCode = TextEditingController();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _companyName.dispose();
    _brandName.dispose();
    _companyLink.dispose();
    _commercialRegistration.dispose();
    _vatNumber.dispose();
    _businessRegisterNumber.dispose();
    _taxNumber.dispose();
    _addressName.dispose();
    _city.dispose();
    _address.dispose();
    _postalCode.dispose();
    super.dispose();
  }

  Future<void> _pickBusinessRegisterDocument(
    BuildContext context,
    CompanyProfileCubit cubit,
  ) async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      allowMultiple: false,
    );
    if (!context.mounted || result == null || result.files.isEmpty) {
      return;
    }
    cubit.setBusinessRegisterDocument(result.files.first.name);
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: BlocProvider<CompanyProfileCubit>(
        create: (_) => CompanyProfileCubit(phone: widget.phone),
        child: Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: AppColors.pageBackground,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Stack(
                clipBehavior: Clip.none,
                fit: StackFit.expand,
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 300.h,
                    child: CustomPaint(
                      foregroundPainter: AuthHeaderGridPainter(),
                      child: Container(
                        color: AppColors.brandBlue,
                        alignment: Alignment.topCenter,
                        padding: EdgeInsets.only(top: 72.h),
                        child: Text(
                          'Create Your\nAccount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 185.h,
                    bottom: 0,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        17.w,
                        0,
                        17.w,
                        32.h + MediaQuery.paddingOf(context).bottom,
                      ),
                      child: const _CompanyProfileCard(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyProfileCard extends StatelessWidget {
  const _CompanyProfileCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE7EAF0)),
        ),
        padding: EdgeInsets.fromLTRB(26.w, 24.h, 22.w, 24.h),
        child: BlocBuilder<CompanyProfileCubit, CompanyProfileState>(
          builder: (BuildContext context, CompanyProfileState state) {
            final CompanyProfileCubit cubit = context
                .read<CompanyProfileCubit>();
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _StepContent(
                    key: ValueKey<int>(state.step),
                    state: state,
                    cubit: cubit,
                  ),
                ),
                SizedBox(height: 20.h),
                _PrimaryActionButton(state: state),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({super.key, required this.state, required this.cubit});

  final CompanyProfileState state;
  final CompanyProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final _CompanyCompleteProfilePageState page = context
        .findAncestorStateOfType<_CompanyCompleteProfilePageState>()!;
    return switch (state.step) {
      0 => _CompanyInfoStep(page: page, state: state, cubit: cubit),
      1 => _PersonalInfoStep(page: page, state: state, cubit: cubit),
      2 => _BusinessDocumentStep(page: page, state: state, cubit: cubit),
      3 => _AddressStep(page: page, state: state, cubit: cubit),
      _ => _PlatformStep(state: state, cubit: cubit),
    };
  }
}

class _PersonalInfoStep extends StatelessWidget {
  const _PersonalInfoStep({
    required this.page,
    required this.state,
    required this.cubit,
  });

  final _CompanyCompleteProfilePageState page;
  final CompanyProfileState state;
  final CompanyProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final bool showErrors = state.isSubmitted;
    return Column(
      children: <Widget>[
        _CompanyTextField(
          label: 'First Name',
          required: true,
          hint: 'First name',
          image: ImageAssets.personIcon,
          controller: page._firstName,
          errorText: _requiredError(showErrors, state.firstName),
          onChanged: cubit.setFirstName,
        ),
        SizedBox(height: 20.h),
        _CompanyTextField(
          label: 'Last Name',
          required: true,
          hint: 'Last name',
          image: ImageAssets.personIcon,
          controller: page._lastName,
          errorText: _requiredError(showErrors, state.lastName),
          onChanged: cubit.setLastName,
        ),
        SizedBox(height: 20.h),
        _ReadOnlyCompanyField(
          label: 'Phone Number',
          hint: state.phone,
          image: ImageAssets.settingsContactIcon,
          value: state.phone,
          leading: const Text('🇸🇦'),
        ),
      ],
    );
  }
}

class _CompanyInfoStep extends StatelessWidget {
  const _CompanyInfoStep({
    required this.page,
    required this.state,
    required this.cubit,
  });

  final _CompanyCompleteProfilePageState page;
  final CompanyProfileState state;
  final CompanyProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final bool showErrors = state.isSubmitted;
    return Column(
      children: <Widget>[
        _ProfilePicturePicker(cubit: cubit),
        SizedBox(height: 18.h),
        _CompanyTextField(
          label: 'Compay Name',
          hint: 'Company Name',
          image: ImageAssets.companyNameIcon,
          controller: page._companyName,
          errorText: _requiredError(showErrors, state.companyName),
          onChanged: cubit.setCompanyName,
        ),
        SizedBox(height: 20.h),
        _CompanyTextField(
          label: 'Brand Name',
          hint: 'Brand Name',
          image: ImageAssets.brandNameIcon,
          controller: page._brandName,
          errorText: _requiredError(showErrors, state.brandName),
          onChanged: cubit.setBrandName,
        ),
        SizedBox(height: 20.h),
        _CompanyTextField(
          label: 'Link that Represent your Company',
          hint: 'Company Link',
          image: ImageAssets.linkIcon,
          controller: page._companyLink,
          errorText: _requiredError(showErrors, state.companyLink),
          keyboardType: TextInputType.url,
          onChanged: cubit.setCompanyLink,
        ),
        SizedBox(height: 20.h),
        _CompanyTextField(
          label: 'Commercial Registration',
          hint: 'Enter Motooq License',
          image: ImageAssets.settingsMawthoqIcon,
          controller: page._commercialRegistration,
          errorText: _requiredError(showErrors, state.commercialRegistration),
          onChanged: cubit.setCommercialRegistration,
        ),
        SizedBox(height: 20.h),
        _CompanyTextField(
          label: 'Value Added Tax',
          hint: 'Enter Fal License',
          image: ImageAssets.settingsMawthoqIcon,
          controller: page._vatNumber,
          errorText: _requiredError(showErrors, state.vatNumber),
          onChanged: cubit.setVatNumber,
        ),
      ],
    );
  }
}

class _BusinessDocumentStep extends StatelessWidget {
  const _BusinessDocumentStep({
    required this.page,
    required this.state,
    required this.cubit,
  });

  final _CompanyCompleteProfilePageState page;
  final CompanyProfileState state;
  final CompanyProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final bool showErrors = state.isSubmitted;
    return Column(
      children: <Widget>[
        _CompanyTextField(
          label: 'Business register number',
          required: true,
          hint: 'Register number',
          image: ImageAssets.registerNumberIcon,
          controller: page._businessRegisterNumber,
          errorText: _requiredError(showErrors, state.businessRegisterNumber),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: cubit.setBusinessRegisterNumber,
        ),
        SizedBox(height: 20.h),
        _CompanyTextField(
          label: 'Tax number',
          required: true,
          hint: 'Tax number',
          image: ImageAssets.taxNumberIcon,
          controller: page._taxNumber,
          errorText: _requiredError(showErrors, state.taxNumber),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: cubit.setTaxNumber,
        ),
        SizedBox(height: 20.h),
        _ReadOnlyCompanyField(
          label: 'Business register document',
          required: true,
          hint: 'Upload file',
          value: state.businessRegisterDocument,
          image: ImageAssets.uploadFileIcon,
          errorText: _requiredError(showErrors, state.businessRegisterDocument),
          trailing: _UploadButton(
            onPressed: () => page._pickBusinessRegisterDocument(context, cubit),
          ),
        ),
      ],
    );
  }
}

class _AddressStep extends StatelessWidget {
  const _AddressStep({
    required this.page,
    required this.state,
    required this.cubit,
  });

  final _CompanyCompleteProfilePageState page;
  final CompanyProfileState state;
  final CompanyProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final bool showErrors = state.isSubmitted;
    return Column(
      children: <Widget>[
        _CompanyTextField(
          label: 'Address name',
          required: true,
          hint: 'Address name',
          image: ImageAssets.addressNameIcon,
          controller: page._addressName,
          errorText: _requiredError(showErrors, state.addressName),
          onChanged: cubit.setAddressName,
        ),
        SizedBox(height: 20.h),
        _CountryField(
          value: state.country,
          errorText: _requiredError(showErrors, state.country),
          onChanged: cubit.setCountry,
        ),
        SizedBox(height: 20.h),
        _CompanyTextField(
          label: 'City',
          required: true,
          hint: 'city',
          image: ImageAssets.cityIcon,
          controller: page._city,
          errorText: _requiredError(showErrors, state.city),
          onChanged: cubit.setCity,
        ),
        SizedBox(height: 20.h),
        _CompanyTextField(
          label: 'Address',
          required: true,
          hint: 'Address',
          image: ImageAssets.pinLocationIcon,
          controller: page._address,
          errorText: _requiredError(showErrors, state.address),
          onChanged: cubit.setAddress,
        ),
        SizedBox(height: 20.h),
        _CompanyTextField(
          label: 'Postal code',
          required: true,
          hint: 'Tax number',
          image: ImageAssets.mailboxIcon,
          controller: page._postalCode,
          errorText: _requiredError(showErrors, state.postalCode),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: cubit.setPostalCode,
        ),
      ],
    );
  }
}

class _PlatformStep extends StatelessWidget {
  const _PlatformStep({required this.state, required this.cubit});

  final CompanyProfileState state;
  final CompanyProfileCubit cubit;

  @override
  Widget build(BuildContext context) {
    final bool showErrors =
        state.isSubmitted && state.selectedPlatforms.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Choose Platform',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 7.w,
          runSpacing: 10.h,
          children: <Widget>[
            for (final _PlatformOption option in _platformOptions)
              _PlatformChip(
                option: option,
                selected: state.selectedPlatforms.contains(option.label),
                onTap: () => cubit.togglePlatform(option.label),
              ),
            _MoreChip(onTap: () {}),
          ],
        ),
        if (showErrors)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'Select at least one platform',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.state});

  final CompanyProfileState state;

  @override
  Widget build(BuildContext context) {
    final CompanyProfileCubit cubit = context.read<CompanyProfileCubit>();
    final bool isLast = state.step == CompanyProfileState.lastStep;
    final bool enabled = isLast ? state.canSubmit : state.canGoNext;
    return SizedBox(
      height: 40.h,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: enabled
              ? AppColors.brandBlue
              : const Color(0xFFECEFF1),
          foregroundColor: enabled ? AppColors.white : const Color(0xFFA1A1AA),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(800.r),
          ),
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        onPressed: () {
          if (isLast) {
            if (cubit.submit()) {
              debugPrint(
                '[TEMP] Company registration draft (no API): '
                '${cubit.state.toRegistrationDraft()}',
              );
              final String phone = cubit.state.phone;
              context.go(
                Uri(
                  path: RouteNames.profileCompanyRegistrationSuccess,
                  queryParameters: <String, String>{
                    if (phone.trim().isNotEmpty) 'phone': phone,
                  },
                ).toString(),
              );
            }
            return;
          }
          cubit.nextStep();
        },
        child: Text(isLast ? 'Save' : 'Next'),
      ),
    );
  }
}

class _ProfilePicturePicker extends StatelessWidget {
  const _ProfilePicturePicker({required this.cubit});

  final CompanyProfileCubit cubit;

  Future<void> _pick(BuildContext context) async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (!context.mounted || result == null || result.files.isEmpty) {
      return;
    }
    final PlatformFile file = result.files.first;
    final String? path = file.path;
    if (path != null && path.trim().isNotEmpty) {
      cubit.setProfilePicturePath(path.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyProfileCubit, CompanyProfileState>(
      buildWhen: (CompanyProfileState p, CompanyProfileState c) =>
          p.profilePicturePath != c.profilePicturePath,
      builder: (BuildContext context, CompanyProfileState state) {
        final bool hasLocalFile =
            state.profilePicturePath.isNotEmpty && !kIsWeb;

        return Column(
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _pick(context),
                    child: Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                        color: AppColors.white,
                      ),
                      padding: EdgeInsets.all(3.w),
                      child: ClipOval(
                        child: hasLocalFile
                            ? Image.file(
                                File(state.profilePicturePath),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (
                                      BuildContext context,
                                      Object error,
                                      StackTrace? stackTrace,
                                    ) {
                                      return ColoredBox(
                                        color: const Color(0xFFF7F7F8),
                                        child: Center(
                                          child: Image.asset(
                                            ImageAssets.companyPersonIcon,
                                            width: 60.w,
                                            height: 60.h,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      );
                                    },
                              )
                            : ColoredBox(
                                color: const Color(0xFFF7F7F8),
                                child: Center(
                                  child: Image.asset(
                                    ImageAssets.companyPersonIcon,
                                    width: 60.w,
                                    height: 60.h,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  end: 0.w,
                  bottom: 18.h,
                  child: Material(
                    color: AppColors.brandBlue,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _pick(context),
                      child: SizedBox(
                        width: 28.w,
                        height: 28.w,
                        child: Icon(
                          Icons.add_rounded,
                          color: AppColors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              'Set profile picture',
              style: TextStyle(color: const Color(0xFF6B7280), fontSize: 12.sp),
            ),
          ],
        );
      },
    );
  }
}

class _CompanyTextField extends StatelessWidget {
  const _CompanyTextField({
    required this.label,
    required this.hint,
    required this.image,
    required this.controller,
    required this.onChanged,
    this.required = false,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final String hint;
  final String image;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool required;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return _CompanyFieldShell(
      label: label,
      required: required,
      errorText: errorText,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        decoration: _companyInputDecoration(hint: hint, image: image),
      ),
    );
  }
}

class _ReadOnlyCompanyField extends StatelessWidget {
  const _ReadOnlyCompanyField({
    required this.label,
    required this.hint,
    required this.value,
    required this.image,
    this.required = false,
    this.errorText,
    this.leading,
    this.trailing,
  });

  final String label;
  final String hint;
  final String value;
  final String image;
  final bool required;
  final String? errorText;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return _CompanyFieldShell(
      label: label,
      required: required,
      errorText: errorText,
      child: InputDecorator(
        decoration: _companyInputDecoration(hint: hint, image: image).copyWith(
          errorText: null,
          suffixIcon: trailing,
          prefixIcon: leading == null
              ? Padding(
                  padding: EdgeInsetsDirectional.only(start: 14.w, end: 10.w),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: Image.asset(image, fit: BoxFit.contain),
                  ),
                )
              : Padding(
                  padding: EdgeInsetsDirectional.only(start: 14.w, end: 8.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      leading!,
                      SizedBox(width: 6.w),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18.sp,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
        ),
        child: Text(
          value.isEmpty ? hint : value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: value.isEmpty
                ? const Color(0xFFB1B5BD)
                : AppColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CountryField extends StatelessWidget {
  const _CountryField({
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    const List<String> countries = <String>[
      'Saudi Arabia',
      'United Arab Emirates',
      'Egypt',
      'Qatar',
    ];
    return _CompanyFieldShell(
      label: 'Country of region',
      required: true,
      errorText: errorText,
      child: DropdownButtonFormField<String>(
        initialValue: value.isEmpty ? null : value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: countries
            .map(
              (String country) => DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              ),
            )
            .toList(),
        onChanged: (String? next) {
          if (next != null) {
            onChanged(next);
          }
        },
        decoration: _companyInputDecoration(
          hint: 'Select Country',
          image: ImageAssets.selectCountryIcon,
        ).copyWith(errorText: null),
      ),
    );
  }
}

class _CompanyFieldShell extends StatelessWidget {
  const _CompanyFieldShell({
    required this.label,
    required this.child,
    this.required = false,
    this.errorText,
  });

  final String label;
  final Widget child;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              // fontWeight: FontWeight.w500,
            ),
            children: <InlineSpan>[
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: const Color(0xFFE11D48),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        child,
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 12.w),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }
}

InputDecoration _companyInputDecoration({
  required String hint,
  required String image,
}) {
  return InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: TextStyle(
      color: const Color(0xFFB1B5BD),
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: const Color(0xFFF7F7F8),
    contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 13.h),
    prefixIcon: Padding(
      padding: EdgeInsetsDirectional.only(start: 14.w, end: 10.w),
      child: SizedBox(
        width: 20.w,
        height: 20.h,
        child: Image.asset(image, fit: BoxFit.contain),
      ),
    ),
    prefixIconConstraints: BoxConstraints(minWidth: 46.w, minHeight: 48.h),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28.r),
      borderSide: const BorderSide(color: Color(0xFFE1E1E6)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28.r),
      borderSide: const BorderSide(color: Color(0xFFE1E1E6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28.r),
      borderSide: const BorderSide(color: AppColors.brandBlue, width: 1.2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28.r),
      borderSide: const BorderSide(color: Color(0xFFE11D48)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28.r),
      borderSide: const BorderSide(color: Color(0xFFE11D48)),
    ),
  );
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 0),
      child: SizedBox(
        width: 56.w,
        child: FilledButton(
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.brandBlue,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadiusDirectional.horizontal(
                end: Radius.circular(28.r),
              ),
            ),
          ),
          onPressed: onPressed,
          child: Icon(Icons.file_upload_outlined, size: 22.sp),
        ),
      ),
    );
  }
}

class _PlatformChip extends StatelessWidget {
  const _PlatformChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _PlatformOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE3F2FF) : AppColors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE1E5EC)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              option.icon,
              size: 15.sp,
              color: selected ? AppColors.brandBlue : AppColors.textPrimary,
            ),
            SizedBox(width: 4.w),
            Text(
              option.label,
              style: TextStyle(
                color: selected ? AppColors.brandBlue : AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FF),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: const Color(0xFFE1E5EC)),
        ),
        child: Text(
          '+ More',
          style: TextStyle(
            color: AppColors.brandBlue,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PlatformOption {
  const _PlatformOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

const List<_PlatformOption> _platformOptions = <_PlatformOption>[
  _PlatformOption('Cars', Icons.directions_car_outlined),
  _PlatformOption('Beauty', Icons.spa_outlined),
  _PlatformOption('Fashion', Icons.checkroom_outlined),
  _PlatformOption('Food', Icons.restaurant_outlined),
  _PlatformOption('Sports', Icons.sports_basketball_outlined),
  _PlatformOption('Drinks', Icons.local_drink_outlined),
  _PlatformOption('Medical', Icons.vaccines_outlined),
  _PlatformOption('Fashion', Icons.checkroom_outlined),
  _PlatformOption('Medical', Icons.vaccines_outlined),
  _PlatformOption('Finance', Icons.trending_up_rounded),
  _PlatformOption('Cars', Icons.directions_car_outlined),
  _PlatformOption('Beauty', Icons.spa_outlined),
  _PlatformOption('Medical', Icons.vaccines_outlined),
  _PlatformOption('Food', Icons.restaurant_outlined),
  _PlatformOption('Sports', Icons.sports_basketball_outlined),
  _PlatformOption('Drinks', Icons.local_drink_outlined),
  _PlatformOption('Medical', Icons.vaccines_outlined),
  _PlatformOption('Fashion', Icons.checkroom_outlined),
  _PlatformOption('Medical', Icons.vaccines_outlined),
  _PlatformOption('Finance', Icons.trending_up_rounded),
];

String? _requiredError(bool showErrors, String value) {
  if (!showErrors || value.trim().isNotEmpty) {
    return null;
  }
  return 'This field is required';
}

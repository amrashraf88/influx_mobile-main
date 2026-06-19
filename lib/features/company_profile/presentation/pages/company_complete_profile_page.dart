import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/core/widgets/app_feedback.dart';
import 'package:adzmavall/features/auth/presentation/widgets/auth_header_grid_painter.dart';
import 'package:adzmavall/features/company_profile/data/brand_registration_repository.dart';
import 'package:adzmavall/features/company_profile/presentation/cubit/company_profile_cubit.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CompanyCompleteProfilePage extends StatelessWidget {
  const CompanyCompleteProfilePage({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CompanyProfileCubit>(
      create: (_) => CompanyProfileCubit(
        phone: phone,
        repository: BrandRegistrationRepository(DioClient.instance),
      ),
      child: const _CompanyRegisterView(),
    );
  }
}

class _CompanyRegisterView extends StatelessWidget {
  const _CompanyRegisterView();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: AppColors.brandBlue,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: BlocConsumer<CompanyProfileCubit, CompanyProfileState>(
          listenWhen:
              (CompanyProfileState previous, CompanyProfileState next) =>
                  previous.errorMessage != next.errorMessage,
          listener: (BuildContext context, CompanyProfileState state) {
            final String? message = state.errorMessage;
            if (message == null || message.trim().isEmpty) {
              return;
            }
            showAppFeedback(
              context,
              message: message,
              type: AppFeedbackType.error,
            );
          },
          builder: (BuildContext context, CompanyProfileState state) {
            final CompanyProfileCubit cubit = context
                .read<CompanyProfileCubit>();
            return Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: Colors.white,
              body: SafeArea(
                top: false,
                bottom: false,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final double headerHeight = 390.h;
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                SizedBox(
                                  height: headerHeight,
                                  child: CustomPaint(
                                    foregroundPainter: AuthHeaderGridPainter(),
                                    child: Container(
                                      color: AppColors.brandBlue,
                                      child: SafeArea(
                                        bottom: false,
                                        child: Padding(
                                          padding: EdgeInsets.fromLTRB(
                                            18.w,
                                            26.h,
                                            18.w,
                                            0,
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: _BackButton(
                                                  onPressed: () {
                                                    if (context.canPop()) {
                                                      context.pop();
                                                    } else {
                                                      context.go(
                                                        RouteNames
                                                            .authAccountType,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              SizedBox(height: 26.h),
                                              Text(
                                                'Create Your\nAccount',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 32.sp,
                                                  height: 1.18,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 520),
                              ],
                            ),
                            Positioned(
                              left: 16.w,
                              right: 16.w,
                              top: headerHeight - 155.h,
                              child: _RegisterCard(
                                state: state,
                                onNext: () async {
                                  if (state.step <
                                      CompanyProfileState.lastStep) {
                                    cubit.nextStep();
                                    return;
                                  }
                                  final bool success = await cubit.register();
                                  if (success && context.mounted) {
                                    context.go(
                                      RouteNames.companyHomePath(
                                        phone: state.phone,
                                        registered: true,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          foregroundColor: const Color(0xFF6B7280),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Icon(Icons.keyboard_arrow_left_rounded, size: 30.sp),
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  const _RegisterCard({required this.state, required this.onNext});

  final CompanyProfileState state;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.white,
      borderRadius: BorderRadius.circular(22.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(26.w, 28.h, 26.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: const Color(0xFFE3E5EA), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (state.step == 0) const _OwnerStep(),
            if (state.step == 1) const _CompanyStep(),
            if (state.step == 2) const _DocumentsStep(),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: FilledButton(
                onPressed: state.isSubmitting ? null : onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandBlue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.brandBlue.withValues(
                    alpha: 0.65,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: state.isSubmitting
                    ? SizedBox(
                        width: 22.w,
                        height: 22.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        state.step == CompanyProfileState.lastStep
                            ? 'Create account'
                            : 'Next',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerStep extends StatelessWidget {
  const _OwnerStep();

  @override
  Widget build(BuildContext context) {
    final CompanyProfileCubit cubit = context.read<CompanyProfileCubit>();
    final CompanyProfileState state = context
        .watch<CompanyProfileCubit>()
        .state;
    return Column(
      children: <Widget>[
        _BrandInput(
          label: 'First Name',
          hint: 'First name',
          icon: Icons.person_outline_rounded,
          required: true,
          error: state.isSubmitted && state.firstName.trim().isEmpty,
          onChanged: cubit.setFirstName,
        ),
        SizedBox(height: 22.h),
        _BrandInput(
          label: 'Last Name',
          hint: 'Last name',
          icon: Icons.person_outline_rounded,
          required: true,
          error: state.isSubmitted && state.lastName.trim().isEmpty,
          onChanged: cubit.setLastName,
        ),
        SizedBox(height: 22.h),
        _ReadonlyPhoneField(phone: state.phone),
      ],
    );
  }
}

class _CompanyStep extends StatelessWidget {
  const _CompanyStep();

  @override
  Widget build(BuildContext context) {
    final CompanyProfileCubit cubit = context.read<CompanyProfileCubit>();
    final CompanyProfileState state = context
        .watch<CompanyProfileCubit>()
        .state;
    return Column(
      children: <Widget>[
        const _ProfilePicturePicker(),
        SizedBox(height: 22.h),
        _BrandInput(
          label: 'Company Name',
          hint: 'Company Name',
          icon: Icons.business_outlined,
          error: state.isSubmitted && state.companyName.trim().isEmpty,
          onChanged: cubit.setCompanyName,
        ),
        SizedBox(height: 22.h),
        _BrandInput(
          label: 'Brand Name',
          hint: 'Brand Name',
          icon: Icons.account_tree_outlined,
          error: state.isSubmitted && state.brandName.trim().isEmpty,
          onChanged: cubit.setBrandName,
        ),
        SizedBox(height: 22.h),
        _BrandInput(
          label: 'Link that Represent your Company',
          hint: 'Company URL',
          icon: Icons.link_rounded,
          keyboardType: TextInputType.url,
          error: state.isSubmitted && state.companyLink.trim().isEmpty,
          onChanged: cubit.setCompanyLink,
        ),
        SizedBox(height: 22.h),
        _BrandInput(
          label: 'Commercial Registration',
          hint: 'Enter Commercial Registration',
          icon: Icons.description_outlined,
          error:
              state.isSubmitted && state.commercialRegistration.trim().isEmpty,
          onChanged: cubit.setCommercialRegistration,
        ),
        SizedBox(height: 22.h),
        _BrandInput(
          label: 'Value Added Tax',
          hint: 'Enter VAT number',
          icon: Icons.description_outlined,
          error: state.isSubmitted && state.vatNumber.trim().isEmpty,
          onChanged: cubit.setVatNumber,
        ),
      ],
    );
  }
}

class _DocumentsStep extends StatelessWidget {
  const _DocumentsStep();

  @override
  Widget build(BuildContext context) {
    final CompanyProfileCubit cubit = context.read<CompanyProfileCubit>();
    final CompanyProfileState state = context
        .watch<CompanyProfileCubit>()
        .state;
    return Column(
      children: <Widget>[
        _BrandInput(
          label: 'Business register number',
          hint: 'Register number',
          icon: Icons.business_center_outlined,
          required: true,
          keyboardType: TextInputType.number,
          error:
              state.isSubmitted && state.businessRegisterNumber.trim().isEmpty,
          onChanged: cubit.setBusinessRegisterNumber,
        ),
        SizedBox(height: 22.h),
        _BrandInput(
          label: 'Tax number',
          hint: 'Tax number',
          icon: Icons.account_balance_outlined,
          required: true,
          keyboardType: TextInputType.number,
          error: state.isSubmitted && state.taxNumber.trim().isEmpty,
          onChanged: cubit.setTaxNumber,
        ),
        SizedBox(height: 22.h),
        _UploadField(
          error:
              state.isSubmitted &&
              state.businessRegisterDocument.trim().isEmpty,
        ),
      ],
    );
  }
}

class _ProfilePicturePicker extends StatelessWidget {
  const _ProfilePicturePicker();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyProfileCubit, CompanyProfileState>(
      buildWhen: (CompanyProfileState previous, CompanyProfileState current) =>
          previous.profilePicturePath != current.profilePicturePath,
      builder: (BuildContext context, CompanyProfileState state) {
        return Column(
          children: <Widget>[
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Container(
                    width: 132.w,
                    height: 132.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF0F2F5),
                      border: Border.all(color: const Color(0xFFE5E8EF)),
                    ),
                    child: Icon(
                      state.profilePicturePath.isEmpty
                          ? Icons.person_outline_rounded
                          : Icons.check_rounded,
                      size: 72.sp,
                      color: const Color(0xFFA3AAB6),
                    ),
                  ),
                  Positioned(
                    right: 4.w,
                    bottom: 18.h,
                    child: GestureDetector(
                      onTap: () async {
                        final FilePickerResult? result =
                            await FilePicker.pickFiles(type: FileType.image);
                        final String? path = result?.files.single.path;
                        if (path != null && context.mounted) {
                          context
                              .read<CompanyProfileCubit>()
                              .setProfilePicturePath(path);
                        }
                      },
                      child: Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: const BoxDecoration(
                          color: AppColors.brandBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Set profile picture',
              style: TextStyle(
                color: const Color(0xFF697386),
                fontSize: 14.5.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ReadonlyPhoneField extends StatelessWidget {
  const _ReadonlyPhoneField({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: 'Phone Number',
      child: Row(
        children: <Widget>[
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2F7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('🇸🇦', style: TextStyle(fontSize: 16.sp)),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            phone.isEmpty ? '+966 55 555 5566' : phone,
            style: TextStyle(
              color: const Color(0xFFB2B4BA),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadField extends StatelessWidget {
  const _UploadField({required this.error});

  final bool error;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompanyProfileCubit, CompanyProfileState>(
      buildWhen: (CompanyProfileState previous, CompanyProfileState current) =>
          previous.businessRegisterDocument != current.businessRegisterDocument,
      builder: (BuildContext context, CompanyProfileState state) {
        return _FieldShell(
          label: 'Business register document',
          required: true,
          error: error,
          trailing: GestureDetector(
            onTap: () async {
              final FilePickerResult? result = await FilePicker.pickFiles(
                type: FileType.any,
              );
              final String? path = result?.files.single.path;
              if (path != null && context.mounted) {
                context.read<CompanyProfileCubit>().setBusinessRegisterDocument(
                  path,
                );
              }
            },
            child: Container(
              width: 58.w,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.brandBlue,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(999.r),
                ),
              ),
              child: Icon(
                Icons.file_upload_outlined,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
          ),
          child: Expanded(
            child: Text(
              state.businessRegisterDocument.isEmpty
                  ? 'Upload file'
                  : state.businessRegisterDocument.split('/').last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: state.businessRegisterDocument.isEmpty
                    ? const Color(0xFFB2B4BA)
                    : const Color(0xFF111827),
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrandInput extends StatelessWidget {
  const _BrandInput({
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.required = false,
    this.error = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final bool required;
  final bool error;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return _FieldShell(
      label: label,
      required: required,
      error: error,
      leadingIcon: icon,
      child: Expanded(
        child: TextField(
          keyboardType: keyboardType,
          onChanged: onChanged,
          cursorColor: AppColors.brandBlue,
          style: TextStyle(
            color: const Color(0xFF111827),
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration.collapsed(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFFB2B4BA),
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  const _FieldShell({
    required this.label,
    required this.child,
    this.leadingIcon,
    this.trailing,
    this.required = false,
    this.error = false,
  });

  final String label;
  final Widget child;
  final IconData? leadingIcon;
  final Widget? trailing;
  final bool required;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text.rich(
          TextSpan(
            text: label,
            children: <InlineSpan>[
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: const Color(0xFFE7355D)),
                ),
            ],
          ),
          style: TextStyle(
            color: const Color(0xFF242424),
            fontSize: 16.sp,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 54.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFCFCFD),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: error ? const Color(0xFFE7355D) : const Color(0xFFE5E5E8),
              width: 1.2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: <Widget>[
              SizedBox(width: 20.w),
              if (leadingIcon != null) ...<Widget>[
                Icon(leadingIcon, size: 25.sp, color: const Color(0xFF101322)),
                SizedBox(width: 18.w),
              ],
              child,
              ?trailing,
            ],
          ),
        ),
      ],
    );
  }
}

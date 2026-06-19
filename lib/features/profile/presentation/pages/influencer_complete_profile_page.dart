import 'dart:math' as math;

import 'package:adzmavall/core/localization/app_strings.dart';
import 'package:adzmavall/core/lookup/lookup_repository.dart';
import 'package:adzmavall/core/network/dio_client.dart';
import 'package:adzmavall/core/routes/route_names.dart';
import 'package:adzmavall/features/profile/data/content_creator_registration_repository.dart';
import 'package:adzmavall/features/profile/presentation/cubit/influencer_profile_cubit.dart';
import 'package:adzmavall/core/lookup/lookup_item.dart';
import 'package:adzmavall/features/profile/presentation/cubit/profile_lookups_cubit.dart';
import 'package:adzmavall/features/profile/presentation/widgets/profile_form_widgets.dart';
import 'package:adzmavall/utils/appcolors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class InfluencerCompleteProfilePage extends StatefulWidget {
  const InfluencerCompleteProfilePage({
    super.key,
    required this.phone,
    this.creatorType,
  });

  final String phone;
  final String? creatorType;

  @override
  State<InfluencerCompleteProfilePage> createState() =>
      _InfluencerCompleteProfilePageState();
}

class _InfluencerCompleteProfilePageState
    extends State<InfluencerCompleteProfilePage> {
  late final TextEditingController _name;
  late final TextEditingController _fullNameArabic;
  late final TextEditingController _age;
  late final TextEditingController _mawthoq;
  late final TextEditingController _district;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _fullNameArabic = TextEditingController();
    _age = TextEditingController();
    _mawthoq = TextEditingController();
    _district = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _fullNameArabic.dispose();
    _age.dispose();
    _mawthoq.dispose();
    _district.dispose();
    super.dispose();
  }

  void _syncTextFieldsToCubit(InfluencerProfileCubit cubit) {
    cubit
      ..setName(_name.text)
      ..setFullNameArabic(_fullNameArabic.text)
      ..setAge(_age.text)
      ..setMawthoqCertificateNumber(_mawthoq.text)
      ..setDistrict(_district.text);
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final bool isArabic = locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<InfluencerProfileCubit>(
            create: (_) => InfluencerProfileCubit(
              phone: widget.phone,
              initialCreatorKind: widget.creatorType,
              registrationRepository: ContentCreatorRegistrationRepository(
                DioClient.instance,
              ),
            ),
          ),
          BlocProvider<ProfileLookupsCubit>(
            create: (_) =>
                ProfileLookupsCubit(LookupRepository(DioClient.instance)),
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.pageBackground,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Builder(
              builder: (BuildContext context) {
                final MediaQueryData mq = MediaQuery.of(context);
                final double topInset = mq.padding.top;
                final double headerHeight = topInset + 258.h;
                final double headerOverlap = 100.h;
                return AnnotatedRegion<SystemUiOverlayStyle>(
                  value: const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                    systemNavigationBarColor: AppColors.pageBackground,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: headerHeight,
                        child: _ProfileHeader(
                          height: headerHeight,
                          topInset: topInset,
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: headerHeight - headerOverlap,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                SizedBox(height: 8.h),
                                const _CreatorTypeSection(),
                                SizedBox(height: 14.h),
                                Expanded(
                                  child: SingleChildScrollView(
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    padding: EdgeInsets.only(bottom: 20.h),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        BlocBuilder<
                                          InfluencerProfileCubit,
                                          InfluencerProfileState
                                        >(
                                          buildWhen:
                                              (
                                                InfluencerProfileState p,
                                                InfluencerProfileState c,
                                              ) =>
                                                  p.creatorKind !=
                                                  c.creatorKind,
                                          builder:
                                              (
                                                BuildContext context,
                                                InfluencerProfileState state,
                                              ) {
                                                final bool isInfluencer =
                                                    state.creatorKind ==
                                                    'influencer';
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: <Widget>[
                                                    _BasicInformationSection(
                                                      nameController: _name,
                                                      fullNameArabicController:
                                                          _fullNameArabic,
                                                      ageController: _age,
                                                      mawthoqController:
                                                          _mawthoq,
                                                    ),
                                                    SizedBox(height: 14.h),
                                                    const _CategoriesSection(),
                                                    SizedBox(height: 14.h),
                                                    _CreatorDetailsByTypeSection(
                                                      districtController:
                                                          _district,
                                                    ),
                                                    if (isInfluencer) ...<
                                                      Widget
                                                    >[
                                                      SizedBox(height: 14.h),
                                                      const _SocialMediaSection(),
                                                    ],
                                                  ],
                                                );
                                              },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar:
              BlocBuilder<InfluencerProfileCubit, InfluencerProfileState>(
                builder: (BuildContext context, InfluencerProfileState state) {
                  final bool canSubmit = state.isValid && !state.isSubmitting;
                  return SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          if (state.submitError != null) ...<Widget>[
                            Text(
                              state.submitError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                          ],
                          SizedBox(
                            height: 48.h,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: canSubmit
                                    ? AppColors.brandBlue
                                    : const Color(0xFFE4E8EF),
                                foregroundColor: canSubmit
                                    ? AppColors.white
                                    : const Color(0xFF94A3B8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(800.r),
                                ),
                              ),
                              onPressed: canSubmit
                                  ? () async {
                                      final InfluencerProfileCubit cubit =
                                          context
                                              .read<InfluencerProfileCubit>();
                                      _syncTextFieldsToCubit(cubit);
                                      final bool success = await cubit
                                          .register();
                                      if (success && context.mounted) {
                                        context.go(
                                          RouteNames.influencerProfile,
                                        );
                                      }
                                    }
                                  : null,
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.white,
                                      ),
                                    )
                                  : Text(
                                      AppStrings.of(locale, 'profile_submit'),
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
                  );
                },
              ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.height, required this.topInset});

  final double height;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: const _ProfileHeaderBackgroundPainter(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, topInset + 10.h, 20.w, 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppStrings.of(locale, 'profile_create_account'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 8.h),
              // Text(
              //   AppStrings.of(locale, 'profile_create_account_subtitle'),
              //   textAlign: TextAlign.center,
              //   maxLines: 3,
              //   overflow: TextOverflow.ellipsis,
              //   style: TextStyle(
              //     color: AppColors.white.withValues(alpha: 0.88),
              //     fontSize: 13.sp,
              //     height: 1.35,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreatorTypeSection extends StatelessWidget {
  const _CreatorTypeSection();

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
      builder: (BuildContext context, ProfileLookupsState lookupsState) {
        return BlocBuilder<InfluencerProfileCubit, InfluencerProfileState>(
          buildWhen: (InfluencerProfileState p, InfluencerProfileState c) =>
              p.creatorKind != c.creatorKind,
          builder: (BuildContext context, InfluencerProfileState state) {
            final InfluencerProfileCubit cubit = context
                .read<InfluencerProfileCubit>();
            return ProfileSectionCard(
              title: AppStrings.of(locale, 'profile_creator_type_title'),
              subtitle: AppStrings.of(locale, 'profile_creator_type_subtitle'),
              children: <Widget>[
                _ProfileLookupSelectField(
                  label: AppStrings.of(locale, 'profile_select_category_label'),
                  hint: AppStrings.of(locale, 'profile_select_hint'),
                  status: lookupsState.creatorTypesStatus,
                  errorMessage: lookupsState.creatorTypesError,
                  items: lookupsState.creatorTypes,
                  value: _lookupValueInOptions(
                    state.creatorKind,
                    lookupsState.creatorTypes,
                  ),
                  onChanged: cubit.setCreatorKind,
                  onRetry: context.read<ProfileLookupsCubit>().loadCreatorTypes,
                  leadingIconBuilder: (String value) {
                    return Icon(
                      _creatorIconForKind(value),
                      size: 18.sp,
                      color: const Color(0xFF6B7280),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _BasicInformationSection extends StatelessWidget {
  const _BasicInformationSection({
    required this.nameController,
    required this.fullNameArabicController,
    required this.ageController,
    required this.mawthoqController,
  });

  final TextEditingController nameController;
  final TextEditingController fullNameArabicController;
  final TextEditingController ageController;
  final TextEditingController mawthoqController;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return BlocBuilder<InfluencerProfileCubit, InfluencerProfileState>(
      builder: (BuildContext context, InfluencerProfileState state) {
        final InfluencerProfileCubit cubit = context
            .read<InfluencerProfileCubit>();
        final bool showErrors = state.isSubmitted;
        return ProfileSectionCard(
          title: AppStrings.of(locale, 'profile_basic_title'),
          subtitle: AppStrings.of(locale, 'profile_basic_subtitle'),
          children: <Widget>[
            ProfileTextField(
              label: AppStrings.of(locale, 'profile_name'),
              hint: AppStrings.of(locale, 'profile_name_hint'),
              controller: nameController,
              errorText: showErrors && nameController.text.trim().isEmpty
                  ? AppStrings.of(locale, 'profile_required_error')
                  : null,
              onChanged: cubit.setName,
            ),
            SizedBox(height: 12.h),
            ProfileTextField(
              label: AppStrings.of(locale, 'profile_full_name_arabic'),
              hint: AppStrings.of(locale, 'profile_full_name_arabic_hint'),
              controller: fullNameArabicController,
              errorText:
                  showErrors && fullNameArabicController.text.trim().isEmpty
                  ? AppStrings.of(locale, 'profile_required_error')
                  : null,
              onChanged: cubit.setFullNameArabic,
            ),
            SizedBox(height: 12.h),
            ProfileTextField(
              label: AppStrings.of(locale, 'profile_age'),
              hint: AppStrings.of(locale, 'profile_age_hint'),
              controller: ageController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              errorText: showErrors && ageController.text.trim().isEmpty
                  ? AppStrings.of(locale, 'profile_required_error')
                  : null,
              onChanged: cubit.setAge,
            ),
            SizedBox(height: 12.h),
            ProfileSelectField(
              label: AppStrings.of(locale, 'profile_gender_label'),
              hint: AppStrings.of(locale, 'profile_select_hint'),
              value: state.gender == InfluencerGender.male
                  ? AppStrings.of(locale, 'profile_gender_male')
                  : AppStrings.of(locale, 'profile_gender_female'),
              items: <String>[
                AppStrings.of(locale, 'profile_gender_male'),
                AppStrings.of(locale, 'profile_gender_female'),
              ],
              errorText: null,
              onChanged: (String value) {
                cubit.setGender(
                  value == AppStrings.of(locale, 'profile_gender_female')
                      ? InfluencerGender.female
                      : InfluencerGender.male,
                );
              },
            ),
            SizedBox(height: 12.h),
            BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
              builder:
                  (BuildContext context, ProfileLookupsState lookupsState) {
                    return _ProfileLookupSelectField(
                      label: AppStrings.of(locale, 'profile_city'),
                      hint: AppStrings.of(locale, 'profile_city_hint'),
                      status: lookupsState.citiesStatus,
                      errorMessage: lookupsState.citiesError,
                      items: lookupsState.cities,
                      value: _lookupValueInOptions(
                        state.city,
                        lookupsState.cities,
                      ),
                      fieldErrorText: showErrors && state.city.trim().isEmpty
                          ? AppStrings.of(locale, 'profile_required_error')
                          : null,
                      onChanged: cubit.setCity,
                      onRetry: context.read<ProfileLookupsCubit>().loadCities,
                    );
                  },
            ),
            if (state.creatorKind == 'influencer') ...<Widget>[
              SizedBox(height: 12.h),
              ProfileTextField(
                label: AppStrings.of(locale, 'profile_mawthoq_certificate'),
                hint: AppStrings.of(locale, 'profile_mawthoq_certificate_hint'),
                controller: mawthoqController,
                onChanged: cubit.setMawthoqCertificateNumber,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection();

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
      builder: (BuildContext context, ProfileLookupsState lookupsState) {
        return BlocBuilder<InfluencerProfileCubit, InfluencerProfileState>(
          buildWhen: (InfluencerProfileState p, InfluencerProfileState c) =>
              p.selectedCategories != c.selectedCategories ||
              p.isSubmitted != c.isSubmitted,
          builder: (BuildContext context, InfluencerProfileState state) {
            final InfluencerProfileCubit cubit = context
                .read<InfluencerProfileCubit>();
            final ProfileLookupsCubit lookupsCubit = context
                .read<ProfileLookupsCubit>();

            Widget body;
            if (lookupsState.categoriesLoading) {
              body = Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.brandBlue),
                ),
              );
            } else if (lookupsState.categoriesStatus ==
                LookupLoadStatus.failure) {
              body = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    lookupsState.categoriesError ??
                        'Could not load categories.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  OutlinedButton(
                    onPressed: lookupsCubit.loadCategories,
                    child: const Text('Retry'),
                  ),
                ],
              );
            } else if (lookupsState.categories.isEmpty) {
              body = Text(
                'No categories available.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13.sp,
                ),
              );
            } else {
              body = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ProfileChipWrap(
                    options: _toChipOptions(lookupsState.categories),
                    selected: state.selectedCategories,
                    onSelected: cubit.toggleCategory,
                  ),
                  if (lookupsState.categoriesHasMore ||
                      lookupsState.categoriesLoadingMore) ...<Widget>[
                    SizedBox(height: 12.h),
                    Align(
                      alignment: Alignment.center,
                      child: lookupsState.categoriesLoadingMore
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.brandBlue,
                              ),
                            )
                          : TextButton(
                              onPressed: lookupsCubit.loadMoreCategories,
                              child: Text(
                                AppStrings.of(locale, 'home_show_more'),
                                style: TextStyle(
                                  color: AppColors.brandBlue,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.brandBlue,
                                ),
                              ),
                            ),
                    ),
                  ],
                  if (lookupsState.categoriesError != null &&
                      lookupsState.categories.isNotEmpty) ...<Widget>[
                    SizedBox(height: 8.h),
                    Text(
                      lookupsState.categoriesError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              );
            }

            return ProfileSectionCard(
              title: AppStrings.of(locale, 'profile_categories_title'),
              subtitle: AppStrings.of(locale, 'profile_categories_subtitle'),
              children: <Widget>[
                body,
                if (state.isSubmitted && state.selectedCategories.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      AppStrings.of(locale, 'profile_required_error'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CreatorDetailsByTypeSection extends StatelessWidget {
  const _CreatorDetailsByTypeSection({required this.districtController});

  final TextEditingController districtController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InfluencerProfileCubit, InfluencerProfileState>(
      buildWhen: (InfluencerProfileState p, InfluencerProfileState c) =>
          p.creatorKind != c.creatorKind ||
          p.creatorFields != c.creatorFields ||
          p.creatorToggles != c.creatorToggles ||
          p.district != c.district ||
          p.direction != c.direction ||
          p.city != c.city ||
          p.isSubmitted != c.isSubmitted,
      builder: (BuildContext context, InfluencerProfileState state) {
        switch (state.creatorKind) {
          case 'model':
            return const _ModelDetailsSection();
          case 'collage':
            return const _CollageDetailsSection();
          case 'ugc':
            return const _UgcDetailsSection();
          case 'influencer':
          default:
            return _InfluencerDetailsSection(
              districtController: districtController,
            );
        }
      },
    );
  }
}

class _InfluencerDetailsSection extends StatelessWidget {
  const _InfluencerDetailsSection({required this.districtController});

  final TextEditingController districtController;

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
      builder: (BuildContext context, ProfileLookupsState lookupsState) {
        return BlocBuilder<InfluencerProfileCubit, InfluencerProfileState>(
          builder: (BuildContext context, InfluencerProfileState state) {
            final InfluencerProfileCubit cubit = context
                .read<InfluencerProfileCubit>();
            final ProfileLookupsCubit lookupsCubit = context
                .read<ProfileLookupsCubit>();
            final bool showErrors = state.isSubmitted;
            return ProfileSectionCard(
              title: AppStrings.of(locale, 'profile_details_title'),
              subtitle: AppStrings.of(locale, 'profile_details_subtitle'),
              children: <Widget>[
                ProfileTextField(
                  label: AppStrings.of(locale, 'profile_district'),
                  hint: AppStrings.of(locale, 'profile_district_hint'),
                  controller: districtController,
                  errorText:
                      showErrors && districtController.text.trim().isEmpty
                      ? AppStrings.of(locale, 'profile_required_error')
                      : null,
                  onChanged: cubit.setDistrict,
                ),
                SizedBox(height: 12.h),
                _ProfileLookupSelectField(
                  label: AppStrings.of(locale, 'profile_direction'),
                  hint: AppStrings.of(locale, 'profile_direction_hint'),
                  status: lookupsState.directionsStatus,
                  errorMessage: lookupsState.directionsError,
                  items: lookupsState.directions,
                  value: _lookupValueInOptions(
                    state.direction,
                    lookupsState.directions,
                  ),
                  fieldErrorText: showErrors && state.direction.trim().isEmpty
                      ? AppStrings.of(locale, 'profile_required_error')
                      : null,
                  onChanged: cubit.setDirection,
                  onRetry: lookupsCubit.loadDirections,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ModelDetailsSection extends StatelessWidget {
  const _ModelDetailsSection();

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final InfluencerProfileCubit cubit = context.read<InfluencerProfileCubit>();
    final InfluencerProfileState state = context
        .watch<InfluencerProfileCubit>()
        .state;
    return ProfileSectionCard(
      title: AppStrings.of(locale, 'profile_basic_title'),
      subtitle: AppStrings.of(locale, 'profile_clients_subtitle'),
      children: <Widget>[
        ProfileSelectField(
          label: AppStrings.of(locale, 'profile_nationality'),
          hint: AppStrings.of(locale, 'profile_nationality_hint'),
          value: _fieldValueInOptions(
            state,
            'nationality',
            _nationalityOptions(locale),
          ),
          items: _nationalityOptions(locale),
          onChanged: (String value) =>
              cubit.setCreatorField('nationality', value),
        ),
        SizedBox(height: 12.h),
        ProfileTextField(
          label: AppStrings.of(locale, 'profile_height_cm'),
          hint: AppStrings.of(locale, 'profile_height_cm_hint'),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (String value) =>
              cubit.setCreatorField('height_cm', value),
        ),
        SizedBox(height: 12.h),
        ProfileTextField(
          label: AppStrings.of(locale, 'profile_weight_kg'),
          hint: AppStrings.of(locale, 'profile_weight_kg_hint'),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (String value) =>
              cubit.setCreatorField('weight_kg', value),
        ),
        SizedBox(height: 12.h),
        BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
          builder: (BuildContext context, ProfileLookupsState lookupsState) {
            return _ProfileLookupSelectField(
              label: AppStrings.of(locale, 'profile_size'),
              hint: AppStrings.of(locale, 'profile_size_hint'),
              status: lookupsState.modelSizesStatus,
              errorMessage: lookupsState.modelSizesError,
              items: lookupsState.modelSizes,
              value: _lookupValueInOptions(
                state.creatorFields['size'],
                lookupsState.modelSizes,
              ),
              fieldErrorText:
                  state.isSubmitted &&
                      (state.creatorFields['size']?.trim().isEmpty ?? true)
                  ? AppStrings.of(locale, 'profile_required_error')
                  : null,
              onChanged: (String value) => cubit.setCreatorField('size', value),
              onRetry: context.read<ProfileLookupsCubit>().loadModelSizes,
            );
          },
        ),
        SizedBox(height: 12.h),
        BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
          builder: (BuildContext context, ProfileLookupsState lookupsState) {
            return _ProfileLookupSelectField(
              label: AppStrings.of(locale, 'profile_skin_tone'),
              hint: AppStrings.of(locale, 'profile_skin_tone_hint'),
              status: lookupsState.modelSkinTonesStatus,
              errorMessage: lookupsState.modelSkinTonesError,
              items: lookupsState.modelSkinTones,
              value: _lookupValueInOptions(
                state.creatorFields['skin_tone'],
                lookupsState.modelSkinTones,
              ),
              fieldErrorText:
                  state.isSubmitted &&
                      (state.creatorFields['skin_tone']?.trim().isEmpty ?? true)
                  ? AppStrings.of(locale, 'profile_required_error')
                  : null,
              onChanged: (String value) =>
                  cubit.setCreatorField('skin_tone', value),
              onRetry: context.read<ProfileLookupsCubit>().loadModelSkinTones,
            );
          },
        ),
        SizedBox(height: 12.h),
        ProfileTextField(
          label: AppStrings.of(locale, 'profile_district'),
          hint: AppStrings.of(locale, 'profile_district_hint'),
          onChanged: (String value) => cubit.setCreatorField('district', value),
        ),
        SizedBox(height: 12.h),
        BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
          builder: (BuildContext context, ProfileLookupsState lookupsState) {
            return _ProfileLookupSelectField(
              label: AppStrings.of(locale, 'profile_direction'),
              hint: AppStrings.of(locale, 'profile_direction_hint'),
              status: lookupsState.directionsStatus,
              errorMessage: lookupsState.directionsError,
              items: lookupsState.directions,
              value: _lookupValueInOptions(
                state.creatorFields['direction'],
                lookupsState.directions,
              ),
              onChanged: (String value) =>
                  cubit.setCreatorField('direction', value),
              onRetry: context.read<ProfileLookupsCubit>().loadDirections,
            );
          },
        ),
        SizedBox(height: 12.h),
        ProfileTextField(
          label: AppStrings.of(locale, 'profile_session_rate_per_hour_sar'),
          hint: AppStrings.of(locale, 'profile_select_hint'),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (String value) =>
              cubit.setCreatorField('session_rate_per_hour', value),
        ),
        SizedBox(height: 10.h),
        _CreatorToggleRow(
          label: AppStrings.of(locale, 'profile_face_visible'),
          value: state.creatorToggles['face_visible'] ?? true,
          onChanged: (bool value) =>
              cubit.setCreatorToggle('face_visible', value),
        ),
        _CreatorToggleRow(
          label: AppStrings.of(locale, 'profile_hair_visible'),
          value: state.creatorToggles['hair_visible'] ?? true,
          onChanged: (bool value) =>
              cubit.setCreatorToggle('hair_visible', value),
        ),
        _CreatorToggleRow(
          label: AppStrings.of(locale, 'profile_show_full_body'),
          value: state.creatorToggles['show_full_body'] ?? true,
          onChanged: (bool value) =>
              cubit.setCreatorToggle('show_full_body', value),
        ),
      ],
    );
  }
}

class _CollageDetailsSection extends StatelessWidget {
  const _CollageDetailsSection();

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final InfluencerProfileCubit cubit = context.read<InfluencerProfileCubit>();
    final InfluencerProfileState state = context
        .watch<InfluencerProfileCubit>()
        .state;
    return ProfileSectionCard(
      title: AppStrings.of(locale, 'profile_collage_details_title'),
      subtitle: AppStrings.of(locale, 'profile_clients_subtitle'),
      children: <Widget>[
        ProfileTextField(
          label: AppStrings.of(locale, 'profile_district'),
          hint: AppStrings.of(locale, 'profile_district_hint'),
          onChanged: (String value) =>
              cubit.setCreatorField('collage_district', value),
        ),
        SizedBox(height: 12.h),
        ProfileTextField(
          label: AppStrings.of(locale, 'profile_price_per_second_sar'),
          hint: AppStrings.of(locale, 'profile_select_hint'),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (String value) =>
              cubit.setCreatorField('price_per_second', value),
        ),
        SizedBox(height: 12.h),
        BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
          builder: (BuildContext context, ProfileLookupsState lookupsState) {
            return _ProfileLookupSelectField(
              label: 'Accent',
              hint: AppStrings.of(locale, 'profile_select_hint'),
              status: lookupsState.modelAccentsStatus,
              errorMessage: lookupsState.modelAccentsError,
              items: lookupsState.modelAccents,
              value: _lookupValueInOptions(
                state.creatorFields['accent'],
                lookupsState.modelAccents,
              ),
              fieldErrorText:
                  state.isSubmitted &&
                      (state.creatorFields['accent']?.trim().isEmpty ?? true)
                  ? AppStrings.of(locale, 'profile_required_error')
                  : null,
              onChanged: (String value) =>
                  cubit.setCreatorField('accent', value),
              onRetry: context.read<ProfileLookupsCubit>().loadModelAccents,
            );
          },
        ),
        SizedBox(height: 12.h),
        BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
          builder: (BuildContext context, ProfileLookupsState lookupsState) {
            return _ProfileLookupSelectField(
              label: AppStrings.of(locale, 'profile_direction'),
              hint: AppStrings.of(locale, 'profile_select_hint'),
              status: lookupsState.directionsStatus,
              errorMessage: lookupsState.directionsError,
              items: lookupsState.directions,
              value: _lookupValueInOptions(
                state.creatorFields['directions'],
                lookupsState.directions,
              ),
              onChanged: (String value) =>
                  cubit.setCreatorField('directions', value),
              onRetry: context.read<ProfileLookupsCubit>().loadDirections,
            );
          },
        ),
      ],
    );
  }
}

class _UgcDetailsSection extends StatelessWidget {
  const _UgcDetailsSection();

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final InfluencerProfileCubit cubit = context.read<InfluencerProfileCubit>();
    final InfluencerProfileState state = context
        .watch<InfluencerProfileCubit>()
        .state;
    return ProfileSectionCard(
      title: AppStrings.of(locale, 'profile_ugc_details_title'),
      subtitle: AppStrings.of(locale, 'profile_clients_subtitle'),
      children: <Widget>[
        ProfileTextField(
          label: AppStrings.of(locale, 'profile_video_price_sar_short'),
          hint: AppStrings.of(locale, 'profile_select_hint'),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (String value) =>
              cubit.setCreatorField('video_price', value),
        ),
        SizedBox(height: 12.h),
        ProfileTextField(
          label: AppStrings.of(locale, 'profile_delivery_time_from_arrival'),
          hint: AppStrings.of(locale, 'profile_select_hint'),
          onChanged: (String value) =>
              cubit.setCreatorField('delivery_time_from_arrival', value),
        ),
        SizedBox(height: 12.h),
        BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
          builder: (BuildContext context, ProfileLookupsState lookupsState) {
            return _ProfileLookupSelectField(
              label: 'Accent',
              hint: AppStrings.of(locale, 'profile_select_hint'),
              status: lookupsState.modelAccentsStatus,
              errorMessage: lookupsState.modelAccentsError,
              items: lookupsState.modelAccents,
              value: _lookupValueInOptions(
                state.creatorFields['accent'],
                lookupsState.modelAccents,
              ),
              onChanged: (String value) =>
                  cubit.setCreatorField('accent', value),
              onRetry: context.read<ProfileLookupsCubit>().loadModelAccents,
            );
          },
        ),
        SizedBox(height: 12.h),
        ProfileTextField(
          label: AppStrings.of(locale, 'profile_offer_your_works'),
          hint: AppStrings.of(locale, 'profile_select_hint'),
          onChanged: (String value) =>
              cubit.setCreatorField('offer_your_works', value),
        ),
        SizedBox(height: 10.h),
        _CreatorToggleRow(
          label: AppStrings.of(locale, 'profile_voice_over'),
          value: state.creatorToggles['voice_over'] ?? true,
          onChanged: (bool value) =>
              cubit.setCreatorToggle('voice_over', value),
        ),
        _CreatorToggleRow(
          label: AppStrings.of(locale, 'profile_use_hook'),
          value: state.creatorToggles['use_hook'] ?? true,
          onChanged: (bool value) => cubit.setCreatorToggle('use_hook', value),
        ),
        _CreatorToggleRow(
          label: AppStrings.of(locale, 'profile_hair_visible'),
          value: state.creatorToggles['hair_visible'] ?? true,
          onChanged: (bool value) =>
              cubit.setCreatorToggle('hair_visible', value),
        ),
        _CreatorToggleRow(
          label: AppStrings.of(locale, 'profile_face_visible'),
          value: state.creatorToggles['face_visible'] ?? true,
          onChanged: (bool value) =>
              cubit.setCreatorToggle('face_visible', value),
        ),
      ],
    );
  }
}

class _CreatorToggleRow extends StatelessWidget {
  const _CreatorToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.white,
              activeTrackColor: AppColors.brandBlue,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialMediaSection extends StatelessWidget {
  const _SocialMediaSection();

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    return BlocBuilder<InfluencerProfileCubit, InfluencerProfileState>(
      buildWhen: (InfluencerProfileState p, InfluencerProfileState c) =>
          p.socialAccounts != c.socialAccounts,
      builder: (BuildContext context, InfluencerProfileState state) {
        final InfluencerProfileCubit cubit = context
            .read<InfluencerProfileCubit>();
        return ProfileSectionCard(
          title: AppStrings.of(locale, 'profile_social_title'),
          subtitle: AppStrings.of(locale, 'profile_social_subtitle'),
          titleTrailing: IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
            onPressed: cubit.addSocialAccount,
            icon: Icon(
              Icons.add_box_rounded,
              color: AppColors.brandBlue,
              size: 30.sp,
            ),
          ),
          children: <Widget>[
            for (int i = 0; i < state.socialAccounts.length; i++) ...<Widget>[
              if (i > 0) SizedBox(height: 12.h),
              _SocialAccountEditor(
                key: ValueKey<String>(state.socialAccounts[i].id),
                entry: state.socialAccounts[i],
                cubit: cubit,
                locale: locale,
                canRemove: state.socialAccounts.length > 1,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SocialAccountEditor extends StatefulWidget {
  const _SocialAccountEditor({
    super.key,
    required this.entry,
    required this.cubit,
    required this.locale,
    required this.canRemove,
  });

  final InfluencerSocialAccountEntry entry;
  final InfluencerProfileCubit cubit;
  final Locale locale;
  final bool canRemove;

  @override
  State<_SocialAccountEditor> createState() => _SocialAccountEditorState();
}

class _SocialAccountEditorState extends State<_SocialAccountEditor> {
  late TextEditingController _handle;
  final Map<String, TextEditingController> _priceControllers =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _handle = TextEditingController(text: widget.entry.handle);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContentTypes());
  }

  @override
  void didUpdateWidget(covariant _SocialAccountEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.id != widget.entry.id) {
      _handle.dispose();
      _disposePriceControllers();
      _handle = TextEditingController(text: widget.entry.handle);
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadContentTypes());
    } else {
      if (_handle.text != widget.entry.handle) {
        _handle.text = widget.entry.handle;
      }
      if (oldWidget.entry.platform != widget.entry.platform) {
        _disposePriceControllers();
      }
      _syncPriceControllersFromEntry();
    }
  }

  @override
  void dispose() {
    _handle.dispose();
    _disposePriceControllers();
    super.dispose();
  }

  void _loadContentTypes() {
    final String platform = widget.entry.platform.trim();
    if (platform.isEmpty || !mounted) {
      return;
    }
    final ProfileLookupsCubit lookupsCubit = context
        .read<ProfileLookupsCubit>();
    final List<LookupItem> cached = lookupsCubit.state.adContentTypesFor(
      platform,
    );
    if (cached.isNotEmpty) {
      _ensurePriceControllers(cached);
    }
    lookupsCubit.loadAdContentTypes(platform);
  }

  void _disposePriceControllers() {
    for (final TextEditingController controller in _priceControllers.values) {
      controller.dispose();
    }
    _priceControllers.clear();
  }

  void _ensurePriceControllers(List<LookupItem> contentTypes) {
    final Set<String> needed = contentTypes
        .map((LookupItem e) => e.value)
        .toSet();
    for (final String key in _priceControllers.keys.toList()) {
      if (!needed.contains(key)) {
        _priceControllers.remove(key)?.dispose();
      }
    }
    for (final LookupItem item in contentTypes) {
      _priceControllers.putIfAbsent(
        item.value,
        () =>
            TextEditingController(text: widget.entry.prices[item.value] ?? ''),
      );
    }
  }

  void _syncPriceControllersFromEntry() {
    for (final MapEntry<String, TextEditingController> entry
        in _priceControllers.entries) {
      final String price = widget.entry.prices[entry.key] ?? '';
      if (entry.value.text != price) {
        entry.value.text = price;
      }
    }
  }

  Widget _buildContentTypePrices(
    ProfileLookupsState lookupsState,
    Locale locale,
  ) {
    final String platform = widget.entry.platform.trim();
    if (platform.isEmpty) {
      return const SizedBox.shrink();
    }

    final LookupLoadStatus status = lookupsState.adContentTypesStatusFor(
      platform,
    );
    final ProfileLookupsCubit lookupsCubit = context
        .read<ProfileLookupsCubit>();

    if (status == LookupLoadStatus.loading ||
        status == LookupLoadStatus.initial) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.brandBlue),
        ),
      );
    }

    if (status == LookupLoadStatus.failure) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            lookupsState.adContentTypesErrorFor(platform) ??
                'Could not load ad content types.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: () =>
                lookupsCubit.loadAdContentTypes(platform, force: true),
            child: const Text('Retry'),
          ),
        ],
      );
    }

    final List<LookupItem> contentTypes = lookupsState.adContentTypesFor(
      platform,
    );

    if (contentTypes.isEmpty) {
      return Text(
        'No ad content types available for this platform.',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
      );
    }

    return Column(
      children: <Widget>[
        for (int i = 0; i < contentTypes.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: 12.h),
          ProfileTextField(
            label: '${contentTypes[i].label} (SAR)',
            hint: AppStrings.of(locale, 'profile_price_enter_hint'),
            controller: _priceControllers[contentTypes[i].value],
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (String value) => widget.cubit.updateSocialAccountPrice(
              widget.entry.id,
              contentTypes[i].value,
              value,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = widget.locale;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.pageBackground,
        borderRadius: BorderRadius.circular(16.r),
        // border: Border.all(color: const Color(0xFFD5DAE3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (widget.canRemove)
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 36.w, minHeight: 36.h),
                onPressed: () =>
                    widget.cubit.removeSocialAccount(widget.entry.id),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: const Color(0xFFEF4444),
                  size: 22.sp,
                ),
              ),
            ),
          BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
            builder: (BuildContext context, ProfileLookupsState lookupsState) {
              return _ProfileLookupSelectField(
                label: AppStrings.of(locale, 'profile_platform'),
                hint: AppStrings.of(locale, 'profile_select_hint'),
                status: lookupsState.socialPlatformsStatus,
                errorMessage: lookupsState.socialPlatformsError,
                items: lookupsState.socialPlatforms,
                value: _lookupValueInOptions(
                  widget.entry.platform,
                  lookupsState.socialPlatforms,
                ),
                onChanged: (String value) {
                  widget.cubit.updateSocialAccount(
                    widget.entry.id,
                    platform: value,
                    clearPrices: true,
                  );
                  _disposePriceControllers();
                  context.read<ProfileLookupsCubit>().loadAdContentTypes(value);
                },
                onRetry: context
                    .read<ProfileLookupsCubit>()
                    .loadSocialPlatforms,
              );
            },
          ),
          SizedBox(height: 12.h),
          ProfileTextField(
            label: AppStrings.of(locale, 'profile_username_handle'),
            hint: AppStrings.of(locale, 'profile_username_handle_hint'),
            controller: _handle,
            onChanged: (String value) => widget.cubit.updateSocialAccount(
              widget.entry.id,
              handle: value,
            ),
          ),
          SizedBox(height: 12.h),
          BlocListener<ProfileLookupsCubit, ProfileLookupsState>(
            listenWhen: (ProfileLookupsState p, ProfileLookupsState c) {
              final String platform = widget.entry.platform
                  .trim()
                  .toLowerCase();
              if (platform.isEmpty) {
                return false;
              }
              return p.adContentTypesFor(platform) !=
                  c.adContentTypesFor(platform);
            },
            listener: (BuildContext context, ProfileLookupsState state) {
              _ensurePriceControllers(
                state.adContentTypesFor(widget.entry.platform),
              );
            },
            child: BlocBuilder<ProfileLookupsCubit, ProfileLookupsState>(
              builder:
                  (BuildContext context, ProfileLookupsState lookupsState) {
                    return _buildContentTypePrices(lookupsState, locale);
                  },
            ),
          ),
        ],
      ),
    );
  }
}

/// Blue fill, faint grid, and light “star” specks behind the header title.
class _ProfileHeaderBackgroundPainter extends CustomPainter {
  const _ProfileHeaderBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = AppColors.brandBlue);

    final Paint grid = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.09)
      ..strokeWidth = 1;
    const double step = 22;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final math.Random random = math.Random(41);
    final Paint speck = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.24);
    for (int i = 0; i < 56; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.45 + random.nextDouble() * 1.15,
        speck,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

IconData _creatorIconForKind(String creatorKind) {
  return switch (creatorKind) {
    'model' => Icons.face_retouching_natural_rounded,
    'collage' => Icons.school_rounded,
    'ugc' => Icons.video_camera_front_rounded,
    _ => Icons.person_rounded,
  };
}

String? _fieldValueInOptions(
  InfluencerProfileState state,
  String key,
  List<String> options,
) {
  final String? value = state.creatorFields[key];
  if (value == null || value.isEmpty || !options.contains(value)) {
    return null;
  }
  return value;
}

List<ProfileChipOption> _toChipOptions(List<LookupItem> items) {
  return items
      .map(
        (LookupItem item) =>
            ProfileChipOption(value: item.value, label: item.label),
      )
      .toList();
}

String? _lookupValueInOptions(String? stored, List<LookupItem> options) {
  if (stored == null || stored.trim().isEmpty) {
    return null;
  }
  return options.any((LookupItem item) => item.value == stored) ? stored : null;
}

class _ProfileLookupSelectField extends StatelessWidget {
  const _ProfileLookupSelectField({
    required this.label,
    required this.hint,
    required this.status,
    required this.items,
    required this.onChanged,
    required this.onRetry,
    this.value,
    this.errorMessage,
    this.fieldErrorText,
    this.leadingIconBuilder,
  });

  final String label;
  final String hint;
  final LookupLoadStatus status;
  final List<LookupItem> items;
  final String? value;
  final String? errorMessage;
  final String? fieldErrorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onRetry;
  final Widget Function(String value)? leadingIconBuilder;

  @override
  Widget build(BuildContext context) {
    if (status == LookupLoadStatus.loading) {
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
          const LinearProgressIndicator(color: AppColors.brandBlue),
        ],
      );
    }

    if (status == LookupLoadStatus.failure) {
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
          Text(
            errorMessage ?? 'Could not load options.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 8.h),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      );
    }

    if (items.isEmpty) {
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
          Text(
            'No options available.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
          ),
        ],
      );
    }

    return ProfileSelectField(
      label: label,
      hint: hint,
      value: value,
      options: _toChipOptions(items),
      errorText: fieldErrorText,
      leadingIconBuilder: leadingIconBuilder,
      onChanged: onChanged,
    );
  }
}

List<String> _nationalityOptions(Locale locale) {
  return <String>[
    AppStrings.of(locale, 'profile_country_saudi'),
    AppStrings.of(locale, 'profile_country_uae'),
    AppStrings.of(locale, 'profile_country_egypt'),
  ];
}

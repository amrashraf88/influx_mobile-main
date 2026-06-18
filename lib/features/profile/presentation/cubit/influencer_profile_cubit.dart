import 'package:adzmavall/features/auth/data/auth_repository.dart';
import 'package:adzmavall/features/profile/data/content_creator_registration_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum InfluencerGender { male, female }

enum ProfileSubmitStatus { idle, loading, success, failure }

class InfluencerSocialAccountEntry extends Equatable {
  const InfluencerSocialAccountEntry({
    required this.id,
    this.platform = '',
    this.handle = '',
    this.prices = const <String, String>{},
  });

  final String id;
  final String platform;
  final String handle;
  final Map<String, String> prices;

  InfluencerSocialAccountEntry copyWith({
    String? platform,
    String? handle,
    Map<String, String>? prices,
    bool clearPrices = false,
  }) {
    return InfluencerSocialAccountEntry(
      id: id,
      platform: platform ?? this.platform,
      handle: handle ?? this.handle,
      prices: clearPrices
          ? const <String, String>{}
          : (prices ?? this.prices),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    platform,
    handle,
    prices,
  ];
}

class InfluencerProfileState extends Equatable {
  InfluencerProfileState({
    required this.phone,
    this.gender = InfluencerGender.male,
    this.creatorKind = 'influencer',
    this.name = '',
    this.fullNameArabic = '',
    this.age = '',
    this.mawthoqCertificateNumber = '',
    this.district = '',
    this.direction = '',
    this.city = '',
    this.creatorImageId,
    this.selectedCategories = const <String>{},
    this.creatorFields = const <String, String>{},
    this.creatorToggles = const <String, bool>{},
    List<InfluencerSocialAccountEntry>? socialAccounts,
    this.isSubmitted = false,
    this.submitStatus = ProfileSubmitStatus.idle,
    this.submitError,
  }) : socialAccounts =
           socialAccounts ??
           <InfluencerSocialAccountEntry>[
             InfluencerSocialAccountEntry(
               id: InfluencerProfileState._newSocialId(),
             ),
           ];

  final String phone;
  final InfluencerGender gender;
  final String creatorKind;
  final String name;
  final String fullNameArabic;
  final String age;
  final String mawthoqCertificateNumber;
  final String district;
  final String direction;
  final String city;
  final int? creatorImageId;
  final Set<String> selectedCategories;
  final Map<String, String> creatorFields;
  final Map<String, bool> creatorToggles;
  final List<InfluencerSocialAccountEntry> socialAccounts;
  final bool isSubmitted;
  final ProfileSubmitStatus submitStatus;
  final String? submitError;

  bool get isSubmitting => submitStatus == ProfileSubmitStatus.loading;

  static int _socialIdCounter = 0;
  static String _newSocialId() {
    _socialIdCounter += 1;
    return 'social_$_socialIdCounter';
  }

  bool get isValid {
    final bool basicValid =
        name.trim().isNotEmpty &&
        fullNameArabic.trim().isNotEmpty &&
        age.trim().isNotEmpty &&
        city.trim().isNotEmpty &&
        selectedCategories.isNotEmpty;
    if (!basicValid) {
      return false;
    }
    switch (creatorKind) {
      case 'influencer':
        return district.trim().isNotEmpty && direction.trim().isNotEmpty;
      case 'collage':
        return creatorFields['collage_district']?.trim().isNotEmpty == true &&
            creatorFields['price_per_second']?.trim().isNotEmpty == true &&
            creatorFields['accent']?.trim().isNotEmpty == true &&
            creatorFields['directions']?.trim().isNotEmpty == true;
      case 'ugc':
        return creatorFields['video_price']?.trim().isNotEmpty == true &&
            creatorFields['delivery_time_from_arrival']?.trim().isNotEmpty ==
                true;
      case 'model':
        return creatorFields['nationality']?.trim().isNotEmpty == true &&
            creatorFields['height_cm']?.trim().isNotEmpty == true &&
            creatorFields['weight_kg']?.trim().isNotEmpty == true &&
            creatorFields['size']?.trim().isNotEmpty == true &&
            creatorFields['skin_tone']?.trim().isNotEmpty == true &&
            creatorFields['district']?.trim().isNotEmpty == true &&
            creatorFields['direction']?.trim().isNotEmpty == true &&
            creatorFields['session_rate_per_hour']?.trim().isNotEmpty == true;
      default:
        return true;
    }
  }

  InfluencerProfileState copyWith({
    InfluencerGender? gender,
    String? creatorKind,
    String? name,
    String? fullNameArabic,
    String? age,
    String? mawthoqCertificateNumber,
    String? district,
    String? direction,
    String? city,
    int? creatorImageId,
    Set<String>? selectedCategories,
    Map<String, String>? creatorFields,
    Map<String, bool>? creatorToggles,
    List<InfluencerSocialAccountEntry>? socialAccounts,
    bool? isSubmitted,
    ProfileSubmitStatus? submitStatus,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return InfluencerProfileState(
      phone: phone,
      gender: gender ?? this.gender,
      creatorKind: creatorKind ?? this.creatorKind,
      name: name ?? this.name,
      fullNameArabic: fullNameArabic ?? this.fullNameArabic,
      age: age ?? this.age,
      mawthoqCertificateNumber:
          mawthoqCertificateNumber ?? this.mawthoqCertificateNumber,
      district: district ?? this.district,
      direction: direction ?? this.direction,
      city: city ?? this.city,
      creatorImageId: creatorImageId ?? this.creatorImageId,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      creatorFields: creatorFields ?? this.creatorFields,
      creatorToggles: creatorToggles ?? this.creatorToggles,
      socialAccounts: socialAccounts ?? this.socialAccounts,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      submitStatus: submitStatus ?? this.submitStatus,
      submitError: clearSubmitError ? null : submitError ?? this.submitError,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    phone,
    gender,
    creatorKind,
    name,
    fullNameArabic,
    age,
    mawthoqCertificateNumber,
    district,
    direction,
    city,
    creatorImageId,
    selectedCategories,
    creatorFields,
    creatorToggles,
    socialAccounts,
    isSubmitted,
    submitStatus,
    submitError,
  ];
}

class InfluencerProfileCubit extends Cubit<InfluencerProfileState> {
  InfluencerProfileCubit({
    required String phone,
    required ContentCreatorRegistrationRepository registrationRepository,
  }) : _registrationRepository = registrationRepository,
       super(InfluencerProfileState(phone: phone));

  final ContentCreatorRegistrationRepository _registrationRepository;

  void setGender(InfluencerGender gender) {
    emit(state.copyWith(gender: gender));
  }

  void setName(String value) {
    emit(state.copyWith(name: value));
  }

  void setFullNameArabic(String value) {
    emit(state.copyWith(fullNameArabic: value));
  }

  void setCreatorKind(String value) {
    emit(state.copyWith(creatorKind: value));
  }

  void setCreatorField(String key, String value) {
    emit(
      state.copyWith(
        creatorFields: <String, String>{...state.creatorFields, key: value},
      ),
    );
  }

  void setCreatorToggle(String key, bool value) {
    emit(
      state.copyWith(
        creatorToggles: <String, bool>{...state.creatorToggles, key: value},
      ),
    );
  }

  void setAge(String value) {
    emit(state.copyWith(age: value));
  }

  void setMawthoqCertificateNumber(String value) {
    emit(state.copyWith(mawthoqCertificateNumber: value));
  }

  void setDistrict(String value) {
    emit(state.copyWith(district: value));
  }

  void setDirection(String value) {
    emit(state.copyWith(direction: value));
  }

  void setCity(String value) {
    emit(state.copyWith(city: value));
  }

  void setCreatorImageId(int? value) {
    emit(state.copyWith(creatorImageId: value));
  }

  void toggleCategory(String value) {
    final Set<String> next = Set<String>.from(state.selectedCategories);
    if (!next.add(value)) {
      next.remove(value);
    }
    emit(state.copyWith(selectedCategories: next));
  }

  void addSocialAccount() {
    final List<InfluencerSocialAccountEntry> next =
        List<InfluencerSocialAccountEntry>.from(state.socialAccounts)..add(
          InfluencerSocialAccountEntry(
            id: InfluencerProfileState._newSocialId(),
          ),
        );
    emit(state.copyWith(socialAccounts: next));
  }

  void removeSocialAccount(String id) {
    if (state.socialAccounts.length <= 1) {
      return;
    }
    final List<InfluencerSocialAccountEntry> next = state.socialAccounts
        .where((InfluencerSocialAccountEntry e) => e.id != id)
        .toList();
    emit(state.copyWith(socialAccounts: next));
  }

  void updateSocialAccount(
    String id, {
    String? platform,
    String? handle,
    Map<String, String>? prices,
    bool clearPrices = false,
  }) {
    final List<InfluencerSocialAccountEntry> next = state.socialAccounts.map((
      InfluencerSocialAccountEntry e,
    ) {
      if (e.id != id) {
        return e;
      }
      return e.copyWith(
        platform: platform,
        handle: handle,
        prices: prices,
        clearPrices: clearPrices,
      );
    }).toList();
    emit(state.copyWith(socialAccounts: next));
  }

  void updateSocialAccountPrice(
    String id,
    String contentType,
    String price,
  ) {
    final List<InfluencerSocialAccountEntry> next = state.socialAccounts.map((
      InfluencerSocialAccountEntry e,
    ) {
      if (e.id != id) {
        return e;
      }
      return e.copyWith(
        prices: <String, String>{
          ...e.prices,
          contentType: price,
        },
      );
    }).toList();
    emit(state.copyWith(socialAccounts: next));
  }

  bool submit() {
    final bool valid = state.isValid;
    emit(state.copyWith(isSubmitted: true, clearSubmitError: true));
    return valid;
  }

  Future<bool> register() async {
    final bool valid = submit();
    if (!valid) {
      return false;
    }

    emit(
      state.copyWith(
        submitStatus: ProfileSubmitStatus.loading,
        clearSubmitError: true,
      ),
    );

    try {
      await _registrationRepository.registerContentCreator(state);
      emit(state.copyWith(submitStatus: ProfileSubmitStatus.success));
      return true;
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          submitStatus: ProfileSubmitStatus.failure,
          submitError: e.message,
        ),
      );
      return false;
    } catch (_) {
      emit(
        state.copyWith(
          submitStatus: ProfileSubmitStatus.failure,
          submitError: 'Registration failed. Please try again.',
        ),
      );
      return false;
    }
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompanyProfileState extends Equatable {
  const CompanyProfileState({
    required this.phone,
    this.step = 0,
    this.firstName = '',
    this.lastName = '',
    this.companyName = '',
    this.brandName = '',
    this.companyLink = '',
    this.commercialRegistration = '',
    this.vatNumber = '',
    this.businessRegisterNumber = '',
    this.taxNumber = '',
    this.businessRegisterDocument = '',
    this.addressName = '',
    this.country = '',
    this.city = '',
    this.address = '',
    this.postalCode = '',
    this.selectedPlatforms = const <String>{},
    this.profilePicturePath = '',
    this.isSubmitted = false,
  });

  static const int lastStep = 4;

  final String phone;
  final int step;
  final String firstName;
  final String lastName;
  final String companyName;
  final String brandName;
  final String companyLink;
  final String commercialRegistration;
  final String vatNumber;
  final String businessRegisterNumber;
  final String taxNumber;
  final String businessRegisterDocument;
  final String addressName;
  final String country;
  final String city;
  final String address;
  final String postalCode;
  final Set<String> selectedPlatforms;

  /// Local file path from image picker; empty until the user picks a photo.
  final String profilePicturePath;
  final bool isSubmitted;

  bool get isCurrentStepValid {
    return switch (step) {
      0 =>
        companyName.trim().isNotEmpty &&
            brandName.trim().isNotEmpty &&
            companyLink.trim().isNotEmpty &&
            commercialRegistration.trim().isNotEmpty &&
            vatNumber.trim().isNotEmpty,
      1 => firstName.trim().isNotEmpty && lastName.trim().isNotEmpty,
      2 =>
        businessRegisterNumber.trim().isNotEmpty &&
            taxNumber.trim().isNotEmpty &&
            businessRegisterDocument.trim().isNotEmpty,
      3 =>
        addressName.trim().isNotEmpty &&
            country.trim().isNotEmpty &&
            city.trim().isNotEmpty &&
            address.trim().isNotEmpty &&
            postalCode.trim().isNotEmpty,
      4 => selectedPlatforms.isNotEmpty,
      _ => false,
    };
  }

  bool get canGoNext => step < lastStep && isCurrentStepValid;
  bool get canSubmit => step == lastStep && isCurrentStepValid;

  /// Shape intended for a future company registration API; not sent anywhere yet.
  Map<String, dynamic> toRegistrationDraft() => <String, dynamic>{
    'phone': phone,
    'first_name': firstName,
    'last_name': lastName,
    'company_name': companyName,
    'brand_name': brandName,
    'company_link': companyLink,
    'commercial_registration': commercialRegistration,
    'vat_number': vatNumber,
    'business_register_number': businessRegisterNumber,
    'tax_number': taxNumber,
    'business_register_document': businessRegisterDocument,
    'address_name': addressName,
    'country': country,
    'city': city,
    'address': address,
    'postal_code': postalCode,
    'platforms': selectedPlatforms.toList(),
    'profile_picture_local_path': profilePicturePath,
  };

  CompanyProfileState copyWith({
    int? step,
    String? firstName,
    String? lastName,
    String? companyName,
    String? brandName,
    String? companyLink,
    String? commercialRegistration,
    String? vatNumber,
    String? businessRegisterNumber,
    String? taxNumber,
    String? businessRegisterDocument,
    String? addressName,
    String? country,
    String? city,
    String? address,
    String? postalCode,
    Set<String>? selectedPlatforms,
    String? profilePicturePath,
    bool? isSubmitted,
  }) {
    return CompanyProfileState(
      phone: phone,
      step: step ?? this.step,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      brandName: brandName ?? this.brandName,
      companyLink: companyLink ?? this.companyLink,
      commercialRegistration:
          commercialRegistration ?? this.commercialRegistration,
      vatNumber: vatNumber ?? this.vatNumber,
      businessRegisterNumber:
          businessRegisterNumber ?? this.businessRegisterNumber,
      taxNumber: taxNumber ?? this.taxNumber,
      businessRegisterDocument:
          businessRegisterDocument ?? this.businessRegisterDocument,
      addressName: addressName ?? this.addressName,
      country: country ?? this.country,
      city: city ?? this.city,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      selectedPlatforms: selectedPlatforms ?? this.selectedPlatforms,
      profilePicturePath: profilePicturePath ?? this.profilePicturePath,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    phone,
    step,
    firstName,
    lastName,
    companyName,
    brandName,
    companyLink,
    commercialRegistration,
    vatNumber,
    businessRegisterNumber,
    taxNumber,
    businessRegisterDocument,
    addressName,
    country,
    city,
    address,
    postalCode,
    selectedPlatforms,
    profilePicturePath,
    isSubmitted,
  ];
}

class CompanyProfileCubit extends Cubit<CompanyProfileState> {
  CompanyProfileCubit({required String phone})
    : super(CompanyProfileState(phone: phone));

  void setFirstName(String value) => emit(state.copyWith(firstName: value));
  void setLastName(String value) => emit(state.copyWith(lastName: value));
  void setCompanyName(String value) => emit(state.copyWith(companyName: value));
  void setBrandName(String value) => emit(state.copyWith(brandName: value));
  void setCompanyLink(String value) => emit(state.copyWith(companyLink: value));
  void setCommercialRegistration(String value) {
    emit(state.copyWith(commercialRegistration: value));
  }

  void setVatNumber(String value) => emit(state.copyWith(vatNumber: value));
  void setBusinessRegisterNumber(String value) {
    emit(state.copyWith(businessRegisterNumber: value));
  }

  void setTaxNumber(String value) => emit(state.copyWith(taxNumber: value));
  void setBusinessRegisterDocument(String value) {
    emit(state.copyWith(businessRegisterDocument: value));
  }

  void setAddressName(String value) => emit(state.copyWith(addressName: value));
  void setCountry(String value) => emit(state.copyWith(country: value));
  void setCity(String value) => emit(state.copyWith(city: value));
  void setAddress(String value) => emit(state.copyWith(address: value));
  void setPostalCode(String value) => emit(state.copyWith(postalCode: value));

  void setProfilePicturePath(String path) {
    emit(state.copyWith(profilePicturePath: path));
  }

  void togglePlatform(String value) {
    final Set<String> next = Set<String>.from(state.selectedPlatforms);
    if (!next.add(value)) {
      next.remove(value);
    }
    emit(state.copyWith(selectedPlatforms: next));
  }

  bool nextStep() {
    if (!state.isCurrentStepValid) {
      emit(state.copyWith(isSubmitted: true));
      return false;
    }
    if (state.step >= CompanyProfileState.lastStep) {
      return true;
    }
    emit(state.copyWith(step: state.step + 1, isSubmitted: false));
    return true;
  }

  bool submit() {
    final bool valid = state.canSubmit;
    emit(state.copyWith(isSubmitted: true));
    return valid;
  }
}

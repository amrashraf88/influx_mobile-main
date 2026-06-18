/// OTP login type sent to `POST /auth/otp-verifications/initiate`.
enum OtpAuthType {
  creatorLogin('creator_login'),
  brandLogin('brand_login');

  const OtpAuthType(this.apiValue);

  final String apiValue;

  static OtpAuthType fromAccountType(String accountType) {
    return accountType == 'company' ? brandLogin : creatorLogin;
  }
}

/// Response from OTP initiate (`data` object).
class OtpInitiateResult {
  const OtpInitiateResult({
    required this.id,
    required this.isVerified,
    this.relatedTo,
  });

  final String id;
  final bool isVerified;
  final OtpRelatedTo? relatedTo;

  bool get hasExistingAccount {
    if (relatedTo == null) {
      return false;
    }
    return relatedTo!.brand != null || relatedTo!.creator != null;
  }

  factory OtpInitiateResult.fromJson(Map<String, dynamic> json) {
    final Object? relatedRaw = json['relatedTo'] ?? json['related_to'];
    return OtpInitiateResult(
      id: json['id']?.toString() ?? '',
      isVerified: json['isVerified'] == true || json['is_verified'] == true,
      relatedTo: relatedRaw is Map
          ? OtpRelatedTo.fromJson(Map<String, dynamic>.from(relatedRaw))
          : null,
    );
  }
}

class OtpRelatedTo {
  const OtpRelatedTo({
    required this.id,
    this.status,
    this.brand,
    this.creator,
  });

  final int id;
  final OtpLabeledValue? status;
  final OtpBrand? brand;
  final Map<String, dynamic>? creator;

  factory OtpRelatedTo.fromJson(Map<String, dynamic> json) {
    final Object? statusRaw = json['status'];
    final Object? brandRaw = json['brand'] ?? json['company'];
    // The API returns an existing creator under `content_creator`; keep
    // `creator` as a fallback. Without this the app never detects an existing
    // account and wrongly routes returning users to registration (→ invalid_otp).
    final Object? creatorRaw = json['content_creator'] ?? json['creator'];
    return OtpRelatedTo(
      id: _asInt(json['id']),
      status: statusRaw is Map
          ? OtpLabeledValue.fromJson(Map<String, dynamic>.from(statusRaw))
          : null,
      brand: brandRaw is Map
          ? OtpBrand.fromJson(Map<String, dynamic>.from(brandRaw))
          : null,
      creator: creatorRaw is Map
          ? Map<String, dynamic>.from(creatorRaw)
          : null,
    );
  }
}

class OtpLabeledValue {
  const OtpLabeledValue({required this.value, required this.label});

  final String value;
  final String label;

  factory OtpLabeledValue.fromJson(Map<String, dynamic> json) {
    return OtpLabeledValue(
      value: json['value']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
    );
  }
}

class OtpBrand {
  const OtpBrand({
    required this.id,
    this.companyName,
    this.phoneNumber,
  });

  final int id;
  final String? companyName;
  final String? phoneNumber;

  factory OtpBrand.fromJson(Map<String, dynamic> json) {
    return OtpBrand(
      id: _asInt(json['id']),
      companyName: json['company_name']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
    );
  }
}

/// Response from OTP complete (`data` object).
class OtpCompleteResult {
  const OtpCompleteResult({
    required this.otpVerificationId,
    required this.isVerified,
    required this.token,
  });

  final String otpVerificationId;
  final bool isVerified;
  final String token;

  factory OtpCompleteResult.fromJson(Map<String, dynamic> json) {
    return OtpCompleteResult(
      otpVerificationId:
          json['otp_verification_id']?.toString() ??
          json['otpVerificationId']?.toString() ??
          '',
      isVerified: json['is_verified'] == true || json['isVerified'] == true,
      token: json['token']?.toString() ?? '',
    );
  }
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

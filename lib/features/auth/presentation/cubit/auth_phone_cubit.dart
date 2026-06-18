import 'package:adzmavall/features/auth/data/auth_repository.dart';
import 'package:adzmavall/features/auth/data/models/otp_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthPhoneStatus { initial, loading, success, failure }

class AuthPhoneState extends Equatable {
  const AuthPhoneState({
    required this.digits,
    this.status = AuthPhoneStatus.initial,
    this.errorMessage,
    this.lastInitiateResult,
  });

  /// National digits entered in the phone field (country code added at API call).
  final String digits;
  final AuthPhoneStatus status;
  final String? errorMessage;
  final OtpInitiateResult? lastInitiateResult;

  static const int minDigits = 9;
  static const int maxDigits = 15;

  bool get isValid =>
      digits.length >= minDigits && digits.length <= maxDigits;

  bool get isLoading => status == AuthPhoneStatus.loading;

  @override
  List<Object?> get props => <Object?>[
    digits,
    status,
    errorMessage,
    lastInitiateResult,
  ];

  AuthPhoneState copyWith({
    String? digits,
    AuthPhoneStatus? status,
    String? errorMessage,
    OtpInitiateResult? lastInitiateResult,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return AuthPhoneState(
      digits: digits ?? this.digits,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      lastInitiateResult: clearResult
          ? null
          : lastInitiateResult ?? this.lastInitiateResult,
    );
  }
}

class AuthPhoneCubit extends Cubit<AuthPhoneState> {
  AuthPhoneCubit(this._repository) : super(const AuthPhoneState(digits: ''));

  final AuthRepository _repository;

  /// Country code + national digits, no `+` (e.g. `966501234567`).
  static String apiIdentifier(String dialCode, String nationalDigits) {
    final String countryCode = dialCode.replaceAll(RegExp(r'\D'), '');
    return '$countryCode$nationalDigits';
  }

  void setDigits(String raw) {
    final String only = raw.replaceAll(RegExp(r'\D'), '');
    final String clipped = only.length > AuthPhoneState.maxDigits
        ? only.substring(0, AuthPhoneState.maxDigits)
        : only;
    if (clipped == state.digits) return;
    emit(
      state.copyWith(
        digits: clipped,
        status: AuthPhoneStatus.initial,
        clearError: true,
        clearResult: true,
      ),
    );
  }

  Future<OtpInitiateResult?> initiateOtp({
    required String accountType,
    required String dialCode,
  }) async {
    if (!state.isValid || state.isLoading) {
      return null;
    }

    emit(
      state.copyWith(
        status: AuthPhoneStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final OtpInitiateResult result = await _repository.initiateOtp(
        type: OtpAuthType.fromAccountType(accountType),
        identifier: apiIdentifier(dialCode, state.digits),
      );
      if (result.id.isEmpty) {
        emit(
          state.copyWith(
            status: AuthPhoneStatus.failure,
            errorMessage: 'Invalid OTP session. Please try again.',
          ),
        );
        return null;
      }
      emit(
        state.copyWith(
          status: AuthPhoneStatus.success,
          lastInitiateResult: result,
        ),
      );
      return result;
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: AuthPhoneStatus.failure,
          errorMessage: e.message,
        ),
      );
      return null;
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthPhoneStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
      return null;
    }
  }
}

import 'package:adzmavall/core/auth/auth_token_storage.dart';
import 'package:adzmavall/features/auth/data/auth_repository.dart';
import 'package:adzmavall/features/auth/data/models/otp_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum OtpVerificationStatus { initial, loading, success, failure }

class OtpVerificationState extends Equatable {
  const OtpVerificationState({
    required this.code,
    this.status = OtpVerificationStatus.initial,
    this.errorMessage,
    this.completeResult,
  });

  static const int codeLength = 6;

  final String code;
  final OtpVerificationStatus status;
  final String? errorMessage;
  final OtpCompleteResult? completeResult;

  bool get isComplete => code.length == codeLength;

  bool get isLoading => status == OtpVerificationStatus.loading;

  @override
  List<Object?> get props => <Object?>[
    code,
    status,
    errorMessage,
    completeResult,
  ];

  OtpVerificationState copyWith({
    String? code,
    OtpVerificationStatus? status,
    String? errorMessage,
    OtpCompleteResult? completeResult,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return OtpVerificationState(
      code: code ?? this.code,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      completeResult: clearResult
          ? null
          : completeResult ?? this.completeResult,
    );
  }
}

class OtpVerificationCubit extends Cubit<OtpVerificationState> {
  OtpVerificationCubit({
    required AuthRepository repository,
    required AuthTokenStorage tokenStorage,
    required String verificationId,
    required this.accountType,
    required this.identifier,
    required this.hasExistingAccount,
  }) : _repository = repository,
       _tokenStorage = tokenStorage,
       _verificationId = verificationId,
       super(const OtpVerificationState(code: ''));

  final AuthRepository _repository;
  final AuthTokenStorage _tokenStorage;

  String _verificationId;

  String get verificationId => _verificationId;
  final String accountType;
  /// Country code + national digits, no `+` (e.g. `966501234567`).
  final String identifier;
  final bool hasExistingAccount;

  void setCode(String raw) {
    final String digits = raw.replaceAll(RegExp(r'\D'), '');
    final String next = digits.length > OtpVerificationState.codeLength
        ? digits.substring(0, OtpVerificationState.codeLength)
        : digits;
    if (next == state.code) return;
    emit(
      state.copyWith(
        code: next,
        status: OtpVerificationStatus.initial,
        clearError: true,
      ),
    );
  }

  void clear() => emit(const OtpVerificationState(code: ''));

  Future<OtpCompleteResult?> completeOtp() async {
    if (!state.isComplete || state.isLoading) {
      return null;
    }

    emit(
      state.copyWith(
        status: OtpVerificationStatus.loading,
        clearError: true,
        clearResult: true,
      ),
    );

    try {
      final OtpCompleteResult result = await _repository.completeOtp(
        verificationId: verificationId,
        code: state.code,
      );
      if (result.token.isEmpty) {
        emit(
          state.copyWith(
            status: OtpVerificationStatus.failure,
            errorMessage: 'Verification succeeded but no token was returned.',
          ),
        );
        return null;
      }
      await _tokenStorage.saveToken(result.token);
      // Remember whether this session is a brand or a content creator so the
      // shared screens (chat, profile) call the matching API endpoints.
      await _tokenStorage.saveRole(
        accountType == 'company' ? 'brand' : 'creator',
      );
      // Persist the verification id so the register endpoints can reference the
      // verified OTP (the backend rejects registration with `invalid_otp`
      // otherwise). Fall back to the id used in the complete request.
      final String otpId = result.otpVerificationId.isNotEmpty
          ? result.otpVerificationId
          : verificationId;
      if (otpId.isNotEmpty) {
        await _tokenStorage.saveOtpVerificationId(otpId);
      }
      emit(
        state.copyWith(
          status: OtpVerificationStatus.success,
          completeResult: result,
        ),
      );
      return result;
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: OtpVerificationStatus.failure,
          errorMessage: e.message,
        ),
      );
      return null;
    } catch (_) {
      emit(
        state.copyWith(
          status: OtpVerificationStatus.failure,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
      return null;
    }
  }

  Future<OtpInitiateResult?> resendOtp() async {
    emit(
      state.copyWith(
        status: OtpVerificationStatus.loading,
        clearError: true,
      ),
    );
    try {
      final OtpInitiateResult result = await _repository.initiateOtp(
        type: OtpAuthType.fromAccountType(accountType),
        identifier: identifier,
      );
      if (result.id.isNotEmpty) {
        _verificationId = result.id;
      }
      emit(
        state.copyWith(
          status: OtpVerificationStatus.initial,
          code: '',
        ),
      );
      return result;
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: OtpVerificationStatus.failure,
          errorMessage: e.message,
        ),
      );
      return null;
    } catch (_) {
      emit(
        state.copyWith(
          status: OtpVerificationStatus.failure,
          errorMessage: 'Could not resend code. Please try again.',
        ),
      );
      return null;
    }
  }
}

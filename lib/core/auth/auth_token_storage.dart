import 'package:adzmavall/core/network/api_debug_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the bearer token returned from OTP complete.
class AuthTokenStorage {
  AuthTokenStorage._();

  static final AuthTokenStorage instance = AuthTokenStorage._();

  static const String _tokenKey = 'auth_bearer_token';
  static const String _otpVerificationIdKey = 'auth_otp_verification_id';
  static const String _roleKey = 'auth_account_role';

  String? _token;
  String? _otpVerificationId;
  String? _role;
  SharedPreferences? _prefs;

  String? get token => _token;

  bool get hasToken => _token != null && _token!.trim().isNotEmpty;

  /// The verification id returned by `otp-verifications/{id}/complete`.
  /// Must be sent to the register endpoints so the backend can link the
  /// registration to the verified OTP (otherwise it returns `invalid_otp`).
  String? get otpVerificationId => _otpVerificationId;

  /// `'brand'` or `'creator'` — set at login so repositories can pick the
  /// correct (brand vs influencer) API endpoints.
  String? get role => _role;

  bool get isBrand => _role == 'brand';

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _token = _prefs!.getString(_tokenKey);
    _otpVerificationId = _prefs!.getString(_otpVerificationIdKey);
    _role = _prefs!.getString(_roleKey);
    if (kDebugMode && hasToken) {
      ApiDebugLogger.log('TOKEN LOADED: $_token');
    }
  }

  Future<void> saveRole(String role) async {
    _prefs ??= await SharedPreferences.getInstance();
    _role = role;
    await _prefs!.setString(_roleKey, role);
  }

  Future<void> saveToken(String token) async {
    _prefs ??= await SharedPreferences.getInstance();
    _token = token;
    await _prefs!.setString(_tokenKey, token);
    if (kDebugMode) {
      ApiDebugLogger.log('TOKEN SAVED: $token');
    }
  }

  Future<void> saveOtpVerificationId(String id) async {
    _prefs ??= await SharedPreferences.getInstance();
    _otpVerificationId = id;
    await _prefs!.setString(_otpVerificationIdKey, id);
    if (kDebugMode) {
      ApiDebugLogger.log('OTP VERIFICATION ID SAVED: $id');
    }
  }

  Future<void> clearToken() async {
    _prefs ??= await SharedPreferences.getInstance();
    _token = null;
    _otpVerificationId = null;
    _role = null;
    await _prefs!.remove(_tokenKey);
    await _prefs!.remove(_otpVerificationIdKey);
    await _prefs!.remove(_roleKey);
  }
}

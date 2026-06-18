import 'package:adzmavall/core/auth/auth_token_storage.dart';
import 'package:adzmavall/core/network/auth_interceptor.dart';
import 'package:adzmavall/core/network/debug_log_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

abstract final class DioClient {
  static final Dio instance = Dio(
    BaseOptions(
      // OTP initiate / SMS-sending endpoints can be slow on production,
      // so allow up to 60s before aborting.
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  static bool _configured = false;

  static void configure() {
    if (_configured) {
      return;
    }
    instance.interceptors.add(
      AuthInterceptor(AuthTokenStorage.instance),
    );
    if (kDebugMode) {
      instance.interceptors.add(DebugLogInterceptor());
    }
    _configured = true;
  }
}

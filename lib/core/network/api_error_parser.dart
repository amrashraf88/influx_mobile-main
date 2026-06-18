import 'package:dio/dio.dart';

abstract final class ApiErrorParser {
  static String messageFromDio(DioException error) {
    final Response<dynamic>? response = error.response;
    final dynamic data = response?.data;
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? message = map['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      final Object? errorField = map['error'];
      if (errorField is String && errorField.trim().isNotEmpty) {
        return errorField;
      }
      final Object? errors = map['errors'];
      if (errors is Map) {
        final Map<String, dynamic> errorMap = Map<String, dynamic>.from(errors);
        for (final Object? value in errorMap.values) {
          if (value is List && value.isNotEmpty) {
            return value.first.toString();
          }
          if (value is String && value.trim().isNotEmpty) {
            return value;
          }
        }
      }
    }
    if (response?.statusMessage != null &&
        response!.statusMessage!.trim().isNotEmpty) {
      return response.statusMessage!;
    }
    return error.message ?? 'Something went wrong. Please try again.';
  }
}

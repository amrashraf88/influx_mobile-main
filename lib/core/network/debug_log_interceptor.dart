import 'dart:convert';

import 'package:adzmavall/core/network/api_debug_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs every API request and response to the debug console (debug builds only).
///
/// Nothing is redacted — tokens and full response bodies are printed as-is.
class DebugLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      ApiDebugLogger.log(
        '→ REQUEST\n'
        '${options.method} ${options.uri}\n'
        'Headers:\n${_formatMap(options.headers)}\n'
        'Body:\n${_formatData(options.data)}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final String body = _formatData(response.data);
      ApiDebugLogger.log(
        '← RESPONSE\n'
        '${response.statusCode} ${response.requestOptions.method} '
        '${response.requestOptions.uri}\n'
        'Headers:\n${_formatHeaderMap(response.headers.map)}\n'
        'Body:\n$body',
      );
      _logTokenIfPresent(body);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final int? status = err.response?.statusCode;
      final String body = _formatData(err.response?.data);
      ApiDebugLogger.log(
        '✕ ERROR\n'
        '${status ?? '—'} ${err.requestOptions.method} '
        '${err.requestOptions.uri}\n'
        'Message: ${err.message}\n'
        'Headers:\n${_formatHeaderMap(err.response?.headers.map)}\n'
        'Body:\n$body',
      );
      _logTokenIfPresent(body);
    }
    handler.next(err);
  }

  static void _logTokenIfPresent(String formattedBody) {
    try {
      final dynamic decoded = jsonDecode(formattedBody);
      final String? token = _extractToken(decoded);
      if (token != null && token.isNotEmpty) {
        ApiDebugLogger.log('TOKEN RECEIVED: $token');
      }
    } catch (_) {
      // Body is not JSON — skip token extraction.
    }
  }

  static String? _extractToken(dynamic data) {
    if (data is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(data);
      final Object? direct = map['token'];
      if (direct is String && direct.isNotEmpty) {
        return direct;
      }
      final Object? inner = map['data'];
      if (inner is Map) {
        final Object? nested = Map<String, dynamic>.from(inner)['token'];
        if (nested is String && nested.isNotEmpty) {
          return nested;
        }
      }
    }
    return null;
  }

  static String _formatData(dynamic data) {
    if (data == null) {
      return 'null';
    }
    if (data is String) {
      final String trimmed = data.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
        try {
          final dynamic decoded = jsonDecode(trimmed);
          return const JsonEncoder.withIndent('  ').convert(decoded);
        } catch (_) {
          return data;
        }
      }
      return data;
    }
    if (data is Map || data is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(data);
      } catch (_) {
        return data.toString();
      }
    }
    return data.toString();
  }

  static String _formatMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return '  (empty)';
    }
    try {
      return const JsonEncoder.withIndent('  ').convert(map);
    } catch (_) {
      return map.toString();
    }
  }

  static String _formatHeaderMap(Map<String, List<String>>? map) {
    if (map == null || map.isEmpty) {
      return '  (empty)';
    }
    final Map<String, dynamic> normalized = <String, dynamic>{};
    map.forEach((String key, List<String> value) {
      normalized[key] = value.length == 1 ? value.first : value;
    });
    return _formatMap(normalized);
  }
}

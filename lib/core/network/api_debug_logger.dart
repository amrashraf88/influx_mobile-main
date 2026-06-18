import 'package:flutter/foundation.dart';

/// Prints API logs to the Flutter debug console without truncation.
abstract final class ApiDebugLogger {
  static const String _prefix = '[API]';
  static const int _chunkSize = 900;

  static void log(String message) {
    if (!kDebugMode) {
      return;
    }
    if (message.length <= _chunkSize) {
      debugPrint('$_prefix $message');
      return;
    }
    debugPrint('$_prefix --- start (${message.length} chars) ---');
    for (int i = 0; i < message.length; i += _chunkSize) {
      final int end = i + _chunkSize > message.length
          ? message.length
          : i + _chunkSize;
      debugPrint('$_prefix ${message.substring(i, end)}');
    }
    debugPrint('$_prefix --- end ---');
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

class OnlineStatusResult {
  final bool success;
  final String message;
  final bool? isOnline;

  const OnlineStatusResult({
    required this.success,
    required this.message,
    this.isOnline,
  });
}

class OnlineStatusService {
  static const String _tag = 'OnlineStatusService';

  static const String _url =
      'https://helpr.digital/api/toggle-online-status';

  static const Duration _timeout = Duration(seconds: 15);

  /// ------------------------------------------------------------
  /// TOGGLE ONLINE / OFFLINE STATUS
  /// ------------------------------------------------------------
  static Future<OnlineStatusResult> toggleStatus({
    required int userId,
    required bool isOnline,
  }) async {
    try {
      final body = <String, dynamic>{
        'worker_id': userId,
        'is_online': isOnline ? 1 : 0,
      };

      developer.log(
        '📤 REQUEST => $_url | BODY => ${jsonEncode(body)}',
        name: _tag,
      );

      final response = await http
          .post(
        Uri.parse(_url),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      developer.log(
        '📥 RESPONSE => ${response.statusCode} | ${response.body}',
        name: _tag,
      );

      Map<String, dynamic> data = {};

      try {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (e) {
        developer.log(
          '⚠️ Invalid JSON response: $e',
          name: _tag,
        );
      }

      /// ----------------------------------------------------------
      /// SUCCESS
      /// ----------------------------------------------------------
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data['success'] == true) {
        return OnlineStatusResult(
          success: true,
          message:
          data['message']?.toString() ??
              'Status updated successfully.',
          isOnline: _parseOnlineStatus(data['is_online']),
        );
      }

      /// ----------------------------------------------------------
      /// API ERROR
      /// ----------------------------------------------------------
      return OnlineStatusResult(
        success: false,
        message:
        data['message']?.toString() ??
            'Unable to update online status.',
      );
    } on TimeoutException {
      developer.log(
        '⏱️ Request timeout while updating status',
        name: _tag,
      );

      return const OnlineStatusResult(
        success: false,
        message: 'Request timed out. Please try again.',
      );
    } catch (e, stackTrace) {
      developer.log(
        '❌ Toggle status exception: $e',
        name: _tag,
        error: e,
        stackTrace: stackTrace,
      );

      return const OnlineStatusResult(
        success: false,
        message: 'Something went wrong. Please try again.',
      );
    }
  }

  /// ------------------------------------------------------------
  /// PARSE BACKEND STATUS
  ///
  /// Supports:
  /// 1 / 0
  /// "1" / "0"
  /// true / false
  /// "online" / "offline"
  /// ------------------------------------------------------------
  static bool? _parseOnlineStatus(dynamic value) {
    if (value == null) return null;

    if (value is bool) return value;

    if (value is int) {
      if (value == 1) return true;
      if (value == 0) return false;
    }

    final normalized = value.toString().trim().toLowerCase();

    if (normalized == '1' ||
        normalized == 'true' ||
        normalized == 'online') {
      return true;
    }

    if (normalized == '0' ||
        normalized == 'false' ||
        normalized == 'offline') {
      return false;
    }

    return null;
  }
}
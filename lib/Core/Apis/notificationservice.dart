import 'dart:convert';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Apis/sessionmanager.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../Features/SharedScreen/Notificationsection/notificationmodel.dart';

class NotificationResult {
  final bool success;
  final String? errorMessage;
  final List<NotificationModel> notifications;

  NotificationResult({
    required this.success,
    this.errorMessage,
    required this.notifications,
  });
}

class NotificationService {
  static const String _url = "https://helpr.digital/api/user/notifications";
  static const String _fcmTokenUrl = "https://helpr.digital/api/user/update-fcm-token";
  static const String _markAsReadUrl = "https://helpr.digital/api/notifications/mark-as-read";

  /// Fetch notifications list from the backend API
  static Future<NotificationResult> fetchNotifications() async {
    try {
      final userId = SessionManager.getUserId();

      if (userId == null) {
        print("🔴 [NotificationService] No user_id found in session");
        return NotificationResult(
          success: false,
          errorMessage: 'notif_error_not_logged_in'.tr,
          notifications: [],
        );
      }

      print("📡 [NotificationService] Fetching notifications for user_id=$userId");

      final response = await http
          .post(
        Uri.parse(_url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"user_id": userId}),
      )
          .timeout(const Duration(seconds: 15));

      print("📥 [NotificationService] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final bool success = decoded['success'] == true;

        final List rawList = decoded['notifications'] is List
            ? decoded['notifications'] as List
            : [];

        final notifications = rawList
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Newest first
        notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return NotificationResult(
          success: success,
          notifications: notifications,
        );
      }

      return NotificationResult(
        success: false,
        errorMessage: "${'notif_error_server'.tr} (${response.statusCode})",
        notifications: [],
      );
    } catch (e) {
      print("🔴 [NotificationService] fetchNotifications ERROR: $e");
      return NotificationResult(
        success: false,
        errorMessage: 'notif_error_something_went_wrong'.tr,
        notifications: [],
      );
    }
  }

  /// Mark single notification as read on backend API
  static Future<bool> markAsRead(int notificationId) async {
    try {
      final userId = SessionManager.getUserId();
      if (userId == null) return false;

      print("📡 [NotificationService] Marking notification_id=$notificationId as read for user_id=$userId");

      final response = await http
          .post(
        Uri.parse(_markAsReadUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "notification_id": notificationId,
        }),
      )
          .timeout(const Duration(seconds: 10));

      print("📥 [NotificationService] MarkRead Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['success'] == true;
      }
      return false;
    } catch (e) {
      print("🔴 [NotificationService] markAsRead ERROR: $e");
      return false;
    }
  }

  /// Sync Firebase Cloud Messaging (FCM) token to backend
  static Future<void> syncFcmToken() async {
    try {
      final userId = SessionManager.getUserId();
      if (userId == null) return;

      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      print("📲 [NotificationService] Syncing FCM token for user_id=$userId");

      final response = await http
          .post(
        Uri.parse(_fcmTokenUrl),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "user_id": userId,
          "fcm_token": fcmToken,
        }),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print("🟢 [NotificationService] FCM token successfully synced.");
      } else {
        print("🟡 [NotificationService] Failed to sync FCM token: ${response.statusCode}");
      }
    } catch (e) {
      print("🔴 [NotificationService] syncFcmToken ERROR: $e");
    }
  }
}
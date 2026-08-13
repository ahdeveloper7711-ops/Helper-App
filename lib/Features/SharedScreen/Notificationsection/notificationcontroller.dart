import 'package:get/get.dart';
import '../../../Core/Apis/notificationservice.dart';
import 'notificationmodel.dart';

class NotificationController extends GetxController {
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  var errorMessage = ''.obs;
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  /// Fetch notifications from backend service
  Future<void> fetchNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final result = await NotificationService.fetchNotifications();

      if (result.success) {
        notifications.value = result.notifications;
      } else {
        errorMessage.value = result.errorMessage ?? 'notification_screen_load_error_fallback'.tr;
      }
    } catch (e) {
      errorMessage.value = 'notification_screen_load_error_fallback'.tr;
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// Get unread notifications count dynamically
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Mark single notification as read (local update + API call)
  Future<void> markSingleAsRead(int notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || notifications[index].isRead) return;

    // Optimistically update local state for fast UI response
    final old = notifications[index];
    notifications[index] = NotificationModel(
      id: old.id,
      userId: old.userId,
      title: old.title,
      message: old.message,
      type: old.type,
      isRead: true,
      createdAt: old.createdAt,
      updatedAt: DateTime.now(),
    );
    notifications.refresh();

    // Send API call to backend
    await NotificationService.markAsRead(notificationId);
  }

  /// Mark all local notifications as read and sync with backend API
  Future<void> markAllAsRead() async {
    final unreadList = notifications.where((n) => !n.isRead).toList();
    if (unreadList.isEmpty) return;

    // Optimistically mark local items as read for instant UI feedback
    notifications.value = notifications.map((n) {
      return NotificationModel(
        id: n.id,
        userId: n.userId,
        title: n.title,
        message: n.message,
        type: n.type,
        isRead: true,
        createdAt: n.createdAt,
        updatedAt: DateTime.now(),
      );
    }).toList();

    // Call API in parallel for all unread items
    await Future.wait(
      unreadList.map((n) => NotificationService.markAsRead(n.id)),
    );

    // Refresh from server to ensure perfect sync
    await fetchNotifications(isRefresh: true);
  }
}
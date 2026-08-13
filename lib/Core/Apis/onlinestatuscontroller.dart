import 'package:get/get.dart';

import 'onlinestatusservice.dart';
import 'sessionmanager.dart';
import '../Widgets/AppLoader.dart';

class OnlineStatusController extends GetxController {
  final RxBool isOnline = false.obs;
  final RxBool isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalStatus();
  }

  /// ------------------------------------------------------------
  /// LOCAL STATUS
  /// ------------------------------------------------------------
  void _loadLocalStatus() {
    isOnline.value = SessionManager.getOnlineStatus();
  }

  void refreshFromSession() {
    isOnline.value = SessionManager.getOnlineStatus();
  }

  /// ------------------------------------------------------------
  /// BACKEND -> LOCAL/GETX SYNC
  ///
  /// Client/Worker ki kisi API se "is_online" mile,
  /// to isi function ko call karna hai.
  ///
  /// Handles:
  /// 1, 0, "1", "0", true, false, "online", "offline"
  /// ------------------------------------------------------------
  Future<void> syncFromBackend(dynamic backendStatus) async {
    final parsedStatus = _parseOnlineStatus(backendStatus);

    if (parsedStatus == null) return;

    isOnline.value = parsedStatus;

    if (SessionManager.getOnlineStatus() != parsedStatus ||
        !SessionManager.hasSavedOnlineStatus()) {
      await SessionManager.saveOnlineStatus(parsedStatus);
    }
  }

  /// ------------------------------------------------------------
  /// ONLINE / OFFLINE TOGGLE
  /// ------------------------------------------------------------
  Future<void> toggleOnlineStatus() async {
    if (isUpdating.value) return;

    final userId = SessionManager.getUserId();

    if (userId == null) {
      Get.snackbar(
        'Error',
        'User session not found.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final newStatus = !isOnline.value;

    try {
      isUpdating.value = true;

      AppLoader.show(
        text: newStatus
            ? 'Updating online status...'
            : 'Updating offline status...',
      );

      final result = await OnlineStatusService.toggleStatus(
        userId: userId,
        isOnline: newStatus,
      );

      if (!result.success) {
        Get.snackbar(
          'Error',
          result.message,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      /// Backend ne status return kiya ho to wahi final source hai.
      /// Agar backend status missing ho to requested status use hoga.
      final confirmedStatus = result.isOnline ?? newStatus;

      isOnline.value = confirmedStatus;

      await SessionManager.saveOnlineStatus(confirmedStatus);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to update online status.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpdating.value = false;
      AppLoader.hide();
    }
  }

  /// ------------------------------------------------------------
  /// STATUS PARSER
  /// ------------------------------------------------------------
  bool? _parseOnlineStatus(dynamic value) {
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
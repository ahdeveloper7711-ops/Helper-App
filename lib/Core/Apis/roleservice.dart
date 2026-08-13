import 'package:get/get.dart';

import '../../Core/Apis/auth_api.dart';
import '../../Core/Apis/sessionmanager.dart';
import '../../Core/Widgets/AppLoader.dart';
import '../../Features/ClientsSide/ClientBottomNavigation/ClientBottomnavigationScreen.dart';
import '../../Features/WorkerSide/WorkerBottomNavigation/WorkerBottomnavigationScreen.dart';

class RoleService {
  static Future<Map<String, dynamic>> switchUserRole(int userId) async {
    return await ApiService.postRequest(
      endpoint: "/user/switch-role",
      body: {"user_id": userId},
      requiresAuth: true,
    );
  }

  /// FULL switch-role flow: API call + session update + correct
  /// BottomNavigation par navigate. Profile screen ke "Switch Role"
  /// button ke onTap mein seedha `RoleService.performRoleSwitch()` call karein.
  static Future<void> performRoleSwitch() async {
    final userId = SessionManager.getUserId();
    if (userId == null) {
      Get.snackbar("Error", "User not found, please login again.");
      return;
    }

    AppLoader.show(text: "Switching role...");
    final result = await switchUserRole(userId);
    AppLoader.hide();

    final data = result["data"];
    final success = data is Map ? (data["success"] ?? false) : false;

    if (!success) {
      final msg = (data is Map ? data["message"] : null) ??
          result["error"] ??
          "Role switch failed";
      Get.snackbar("Error", msg.toString());
      return;
    }

    // Backend se updated user + naya role expected hai
    final Map<String, dynamic> updatedUser = data["user"] != null
        ? Map<String, dynamic>.from(data["user"])
        : (SessionManager.getUser() ?? {});

    final newBackendRole = (data["role"] ?? updatedUser["role"] ?? "").toString();
    final newLocalRole = SessionManager.normalizeRole(newBackendRole);

    updatedUser["role"] = newBackendRole;

    // Session ko permanently update karein (role + user dono)
    await SessionManager.updateRolePermanently(newLocalRole, updatedUser);

    // ✅ Naye role ke hisaab se sahi BottomNavigation par le jayein
    if (newLocalRole == "job") {
      Get.offAll(() => Clientbottomnavigationscreen());
    } else {
      Get.offAll(() => Workerbottomnavigationscreen());
    }
  }
}
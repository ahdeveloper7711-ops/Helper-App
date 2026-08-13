import 'package:get/get.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientProfilescreensection/clientProfilecontroller.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientsettingsection/settingcontroller.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clienthomesection/clientjobcontroller.dart';

class ControllerCleanup {
  static void resetUserScopedControllers() {
    if (Get.isRegistered<ProfileController>()) {
      Get.delete<ProfileController>(force: true);
      print("🧹 ProfileController force-deleted for account switch");
    }

    if (Get.isRegistered<SettingsController>()) {
      Get.delete<SettingsController>(force: true);
      print("🧹 SettingsController force-deleted for account switch");
    }
    if (Get.isRegistered<ClientJobsController>()) {
      Get.delete<ClientJobsController>(force: true);
      print("🧹 ClientJobsController force-deleted for account switch");
    }
  }
}
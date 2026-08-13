import 'package:get/get.dart';

class RoleController extends GetxController {
  RxString selectedRole = ''.obs;

  void selectRole(String role) {
    selectedRole.value = role;
  }

  bool get isSelected => selectedRole.value.isNotEmpty;

  /// Optional: Helper method to validate role selection before proceeding
  bool validateSelection() {
    if (!isSelected) {
      Get.snackbar(
        'role_ctrl_err_title'.tr,
        'role_ctrl_err_msg'.tr,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }
}
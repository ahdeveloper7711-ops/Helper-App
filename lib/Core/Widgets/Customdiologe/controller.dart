import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'CustomDiologe.dart';

class DialogController extends GetxController {

  void showLogoutDialog(BuildContext context) {
    CustomAlertDialog.show(
      context: context,
      title: 'dialog_logout_title'.tr,
      subtitle: 'dialog_logout_subtitle'.tr,
      icon: Icons.logout,
      navigateToLoginOnConfirm: true,

      onConfirm: () {
        print("User logged out");
      },
    );
  }

  void showDeleteDialog(BuildContext context) {
    CustomAlertDialog.show(
      context: context,
      title: 'dialog_delete_title'.tr,
      subtitle: 'dialog_delete_subtitle'.tr,
      icon: Icons.delete,
      confirmColor: const Color(0xffFF4D4D),

      onConfirm: () {
        print("Item deleted");
      },
    );
  }
}
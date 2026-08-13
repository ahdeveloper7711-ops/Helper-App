import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ErrorController extends GetxController {
  static ErrorController get to => Get.find();

  void showError(
      String message, {
        String? title,
        Duration duration = const Duration(seconds: 3),
      }) {
    Get.snackbar(
      title ?? 'error_default_title'.tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xffFDE8E8),
      colorText: const Color(0xffB00020),
      icon: const Icon(Icons.error_outline, color: Color(0xffFF4D4D)),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: duration,
    );
  }

  void showSuccess(
      String message, {
        String? title,
        Duration duration = const Duration(seconds: 3),
      }) {
    Get.snackbar(
      title ?? 'success_default_title'.tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xffE8F5E9),
      colorText: const Color(0xff1B5E20),
      icon: const Icon(Icons.check_circle, color: Colors.green),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: duration,
    );
  }

  void showInfo(
      String message, {
        String? title,
        Duration duration = const Duration(seconds: 3),
      }) {
    Get.snackbar(
      title ?? 'info_default_title'.tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xffE3F2FD),
      colorText: const Color(0xff0D47A1),
      icon: const Icon(Icons.info_outline, color: Colors.blue),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: duration,
    );
  }
}
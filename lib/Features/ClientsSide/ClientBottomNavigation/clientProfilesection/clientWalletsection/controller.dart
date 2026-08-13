import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletController extends GetxController {
  RxString selectedMethod = "Card".obs; // Card / Bank
  RxString selectedCard = "Uzcard".obs;

  RxDouble balance = 2450.00.obs;

  void toggleMethod(String method) {
    selectedMethod.value = method;
  }

  void changeCard(String card) {
    selectedCard.value = card;
  }

  void deposit(double amount) {
    if (amount <= 0) return;
    balance.value += amount;

    Get.snackbar(
      'wallet_ctrl_success_title'.tr,
      'wallet_ctrl_deposit_msg'.trArgs([amount.toStringAsFixed(2)]),
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
    );
  }

  /// 🔥 UPDATED WITHDRAW (THEME-AWARE SNACKBARS)
  void withdraw(double amount) {
    if (amount <= 0) return;

    if (amount > balance.value) {
      Get.snackbar(
        'wallet_ctrl_err_balance_title'.tr,
        'wallet_ctrl_err_balance_msg'.tr,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    balance.value -= amount;

    Get.snackbar(
      'wallet_ctrl_success_title'.tr,
      'wallet_ctrl_withdraw_msg'.tr,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(10),
    );
  }
}
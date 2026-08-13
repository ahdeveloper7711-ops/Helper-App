import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';

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
      'wallet_success_title'.tr,
      'wallet_deposit_success_message'.trParams({'amount': '\$${amount.toStringAsFixed(2)}'}),
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),      margin: const EdgeInsets.all(10),
    );
  }

  /// 🔥 UPDATED WITHDRAW (THEME-AWARE SNACKBARS)
  void withdraw(double amount) {
    if (amount <= 0) return;

    if (amount > balance.value) {
      Get.snackbar(
        'wallet_insufficient_balance_title'.tr,
        'wallet_insufficient_balance_message'.tr,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        margin: const EdgeInsets.all(10),
      );
      return;
    }

    balance.value -= amount;

    Get.snackbar(
      'wallet_success_title'.tr,
      'wallet_withdraw_success_message'.tr,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),      margin: const EdgeInsets.all(10),
    );
  }
}
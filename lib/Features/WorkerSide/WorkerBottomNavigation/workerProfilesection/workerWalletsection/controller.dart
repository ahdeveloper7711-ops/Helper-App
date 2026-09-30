import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Apis/paymentservice.dart';
import 'package:helper_app2/Core/Apis/sessionmanager.dart';
import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';

class WalletController extends GetxController {
  RxString selectedMethod = "Card".obs; // Card / Bank
  RxString selectedCard = "Uzcard".obs;

  RxDouble balance = 0.00.obs;
  RxBool isLoading = false.obs;
  RxBool isTopUpLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBalanceFromSession();
  }

  void _loadBalanceFromSession() {
    try {
      final user = SessionManager.getUser();
      if (user != null) {
        final raw = user['wallet_balance'] ??
            user['walletBalance'] ??
            user['balance'] ??
            0;
        final parsed = double.tryParse(raw.toString()) ?? 0.0;
        balance.value = parsed;
      }
    } catch (_) {
      balance.value = 0.0;
    }
  }

  void toggleMethod(String method) {
    selectedMethod.value = method;
  }

  void changeCard(String card) {
    selectedCard.value = card;
  }

  /// Real Top-Up via API
  Future<void> deposit(double amount) async {
    if (amount <= 0) {
      Get.snackbar(
        'wallet_error_title'.tr,
        'wallet_error_invalid_amount'.tr,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(
          vertical: AppSize.height * 0.01,
          horizontal: AppSize.height * 0.01,
        ),
        margin: const EdgeInsets.all(10),
      );
      return;
    }

    if (isTopUpLoading.value) return;

    isTopUpLoading.value = true;

    try {
      final result = await PaymentService.workerTopUp(
        amount: amount,
        paymentMethod: "card",
      );

      if (result.success) {
        if (result.newBalance != null) {
          balance.value = result.newBalance!;
        } else {
          balance.value += amount;
        }

        // Session mein bhi update kar do (agar baad mein use ho)
        try {
          final user = SessionManager.getUser() ?? {};
          user['wallet_balance'] = balance.value.toStringAsFixed(2);
          await SessionManager.saveUser(user);
        } catch (_) {}

        Get.back(); // dialog band

        Get.snackbar(
          'wallet_success_title'.tr,
          result.message.isNotEmpty
              ? result.message
              : 'wallet_deposit_success_message'
              .trParams({'amount': '\$${amount.toStringAsFixed(2)}'}),
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          padding: EdgeInsets.symmetric(
            vertical: AppSize.height * 0.01,
            horizontal: AppSize.height * 0.01,
          ),
          margin: const EdgeInsets.all(10),
        );
      } else {
        Get.snackbar(
          'wallet_error_title'.tr,
          result.message,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          padding: EdgeInsets.symmetric(
            vertical: AppSize.height * 0.01,
            horizontal: AppSize.height * 0.01,
          ),
          margin: const EdgeInsets.all(10),
        );
      }
    } finally {
      isTopUpLoading.value = false;
    }
  }

  /// Local withdraw (API nahi hai abhi)
  void withdraw(double amount) {
    if (amount <= 0) return;

    if (amount > balance.value) {
      Get.snackbar(
        'wallet_insufficient_balance_title'.tr,
        'wallet_insufficient_balance_message'.tr,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(
          vertical: AppSize.height * 0.01,
          horizontal: AppSize.height * 0.01,
        ),
        margin: const EdgeInsets.all(10),
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
      padding: EdgeInsets.symmetric(
        vertical: AppSize.height * 0.01,
        horizontal: AppSize.height * 0.01,
      ),
      margin: const EdgeInsets.all(10),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Button.dart';
import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';
import '../../../../../Core/Widgets/iconcircle.dart';
import 'controller.dart';

class WithdrawPopup extends StatelessWidget {
  WithdrawPopup({super.key});

  final c = Get.find<WalletController>();
  final amount = TextEditingController();
  final iban = TextEditingController();
  final methods = ["Card", "Bank Account"];

  String _methodLabel(String method) {
    switch (method) {
      case "Card":
        return 'withdraw_popup_method_card'.tr;
      case "Bank Account":
        return 'withdraw_popup_method_bank_account'.tr;
      default:
        return method;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppSize.height * 0.018),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor, // Dynamic Background
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'withdraw_popup_title'.tr,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.canvasColor),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: IconCircle(
                      icon: Icons.close,
                      height: AppSize.height * 0.045,
                      width: AppSize.height * 0.045,
                      backgroundColor: theme.cardColor,
                      iconColor: theme.canvasColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// METHOD SWITCH
              Obx(() => Row(
                children: methods.map((e) {
                  final isSelected = c.selectedMethod.value == e;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => c.toggleMethod(e),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? theme.primaryColor : theme.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              e == "Card" ? Icons.credit_card : Icons.account_balance,
                              size: 14,
                              color: isSelected ? Colors.white : theme.canvasColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _methodLabel(e),
                              style: TextStyle(
                                color: isSelected ? Colors.white : theme.canvasColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

              const SizedBox(height: 15),

              /// AMOUNT + AVAILABLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('withdraw_popup_label_amount'.tr, style: TextStyle(fontSize: 11, color: theme.canvasColor.withOpacity(0.6))),
                  Obx(() => Text(
                    'withdraw_popup_available_balance'.trParams({'amount': '\$${c.balance.value.toStringAsFixed(2)}'}),
                    style: TextStyle(fontSize: 11, color: theme.primaryColor, fontWeight: FontWeight.bold),
                  )),
                ],
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: AppSize.height * 0.058,
                child: TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: theme.canvasColor),
                  decoration: InputDecoration(
                    hintText: 'withdraw_popup_hint_amount'.tr,
                    hintStyle: TextStyle(fontSize: AppSize.height * 0.016, color: theme.canvasColor.withOpacity(0.4)),
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSize.height * 0.06), borderSide: BorderSide.none),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              /// IBAN ONLY FOR BANK
              Obx(() => c.selectedMethod.value == "Bank Account"
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('withdraw_popup_label_iban'.tr, style: TextStyle(fontSize: 11, color: theme.canvasColor.withOpacity(0.6))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: iban,
                    style: TextStyle(color: theme.canvasColor),
                    decoration: InputDecoration(
                      hintText: 'withdraw_popup_hint_iban'.tr,
                      hintStyle: TextStyle(color: theme.canvasColor.withOpacity(0.4)),
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              )
                  : const SizedBox()),

              CustomButton(title: 'withdraw_popup_confirm_button'.tr, onTap: () {})
            ],
          ),
        ),
      ),
    );
  }
}
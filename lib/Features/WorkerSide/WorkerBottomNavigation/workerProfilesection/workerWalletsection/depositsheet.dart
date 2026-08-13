import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Button.dart';
import 'package:helper_app2/Core/Widgets/MediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Widgets/iconcircle.dart';
import 'controller.dart';

class DepositPopup extends StatelessWidget {
  DepositPopup({super.key});

  final c = Get.find<WalletController>();
  final amount = TextEditingController();
  final cardNumber = TextEditingController();
  final expiry = TextEditingController();
  final cvv = TextEditingController();
  final name = TextEditingController();
  final cards = ["Uzcard", "Humo", "Visa", "MC"];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppSize.height * 0.018),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor, // Dynamic Background
          borderRadius: BorderRadius.circular(22),
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
                    'deposit_popup_title'.tr,
                    style: TextStyle(
                      fontSize: AppSize.height * 0.022,
                      fontWeight: FontWeight.bold,
                      color: theme.canvasColor,
                    ),
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

              SizedBox(height: AppSize.height * 0.015),

              /// CARD TYPE
              Text(
                'deposit_popup_select_card_type'.tr,
                style: TextStyle(
                  fontSize: AppSize.height * 0.013,
                  color: theme.canvasColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: AppSize.height * 0.01),

              Obx(() => Wrap(
                spacing: 8,
                children: cards.map((e) {
                  final isSel = c.selectedCard.value == e;
                  return GestureDetector(
                    onTap: () => c.changeCard(e),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.height * 0.018,
                        vertical: AppSize.height * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: isSel ? theme.primaryColor : theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        e,
                        style: TextStyle(
                          color: isSel ? Colors.white : theme.canvasColor,
                          fontSize: AppSize.height * 0.013,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

              SizedBox(height: AppSize.height * 0.015),

              _field(context, 'deposit_popup_label_amount'.tr, amount, TextInputType.number, hint: 'deposit_popup_hint_amount'.tr),
              _field(context, 'deposit_popup_label_card_number'.tr, cardNumber, TextInputType.number, hint: 'deposit_popup_hint_card_number'.tr, topText: 'deposit_popup_top_text_card_number'.tr),
              Row(
                children: [
                  Expanded(child: _field(context, 'deposit_popup_label_expiry'.tr, expiry, TextInputType.datetime, hint: 'deposit_popup_hint_expiry'.tr)),
                  SizedBox(width: AppSize.width * 0.03),
                  Expanded(child: _field(context, 'deposit_popup_label_cvv'.tr, cvv, TextInputType.number, hint: 'deposit_popup_hint_cvv'.tr)),
                ],
              ),
              _field(context, 'deposit_popup_label_cardholder_name'.tr, name, TextInputType.name, hint: 'deposit_popup_hint_cardholder_name'.tr),

              SizedBox(height: AppSize.height * 0.02),
              CustomButton(title: 'deposit_popup_confirm_button'.tr, onTap: () {})
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(BuildContext context, String label, TextEditingController ctrl, TextInputType type, {String? hint, String? topText}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: AppSize.height * 0.012),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSize.height * 0.012,
                  color: theme.canvasColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (topText != null)
                Text(
                  topText,
                  style: TextStyle(fontSize: AppSize.height * 0.012, color: theme.primaryColor, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          SizedBox(height: AppSize.height * 0.008),
          Container(
            height: AppSize.height * 0.058,
            padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.03),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            ),
            child: TextField(
              controller: ctrl,
              keyboardType: type,
              style: TextStyle(color: theme.canvasColor),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: AppSize.height * 0.015, color: theme.canvasColor.withOpacity(0.4)),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
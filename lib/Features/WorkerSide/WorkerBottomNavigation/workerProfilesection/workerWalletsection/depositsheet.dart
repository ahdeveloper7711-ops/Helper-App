import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // ---------- Card-specific config ----------
  Map<String, dynamic> _cardConfig(String card) {
    switch (card) {
      case "Uzcard":
        return {
          "hint": "8600 **** **** ****",
          "topText": "UZCARD (8600)",
          "maxLength": 16,
          "prefix": "8600",
        };
      case "Humo":
        return {
          "hint": "9860 **** **** ****",
          "topText": "HUMO (9860)",
          "maxLength": 16,
          "prefix": "9860",
        };
      case "Visa":
        return {
          "hint": "4*** **** **** ****",
          "topText": "VISA",
          "maxLength": 16,
          "prefix": "4",
        };
      case "MC":
        return {
          "hint": "5*** **** **** ****",
          "topText": "MASTERCARD",
          "maxLength": 16,
          "prefix": "5",
        };
      default:
        return {
          "hint": "**** **** **** ****",
          "topText": "",
          "maxLength": 16,
          "prefix": "",
        };
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
          color: theme.scaffoldBackgroundColor,
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

              /// CARD TYPE LABEL
              Text(
                'deposit_popup_select_card_type'.tr,
                style: TextStyle(
                  fontSize: AppSize.height * 0.013,
                  color: theme.canvasColor.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: AppSize.height * 0.01),

              /// CARD TYPE CHIPS
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cards.map((e) {
                  final isSel = c.selectedCard.value == e;
                  return GestureDetector(
                    onTap: () {
                      c.changeCard(e);
                      // Card change pe number field clear (professional feel)
                      cardNumber.clear();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.height * 0.018,
                        vertical: AppSize.height * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: isSel ? theme.primaryColor : theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSel
                              ? theme.primaryColor
                              : theme.dividerColor.withOpacity(0.25),
                          width: isSel ? 1.5 : 1,
                        ),
                        boxShadow: isSel
                            ? [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                            : null,
                      ),
                      child: Text(
                        e,
                        style: TextStyle(
                          color: isSel ? Colors.white : theme.canvasColor,
                          fontSize: AppSize.height * 0.013,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),

              SizedBox(height: AppSize.height * 0.015),

              /// AMOUNT (common for all)
              _field(
                context,
                'deposit_popup_label_amount'.tr,
                amount,
                TextInputType.number,
                hint: 'deposit_popup_hint_amount'.tr,
              ),

              /// CARD NUMBER — changes with selected card
              Obx(() {
                final config = _cardConfig(c.selectedCard.value);
                return _field(
                  context,
                  'deposit_popup_label_card_number'.tr,
                  cardNumber,
                  TextInputType.number,
                  hint: config["hint"],
                  topText: config["topText"],
                  maxLength: config["maxLength"],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(config["maxLength"]),
                  ],
                );
              }),

              /// EXPIRY + CVV
              Row(
                children: [
                  Expanded(
                    child: _field(
                      context,
                      'deposit_popup_label_expiry'.tr,
                      expiry,
                      TextInputType.number,
                      hint: 'deposit_popup_hint_expiry'.tr,
                      maxLength: 5,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                        LengthLimitingTextInputFormatter(5),
                        _ExpiryDateFormatter(),
                      ],
                    ),
                  ),
                  SizedBox(width: AppSize.width * 0.03),
                  Expanded(
                    child: _field(
                      context,
                      'deposit_popup_label_cvv'.tr,
                      cvv,
                      TextInputType.number,
                      hint: 'deposit_popup_hint_cvv'.tr,
                      maxLength: 4,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                ],
              ),

              /// CARDHOLDER NAME
              _field(
                context,
                'deposit_popup_label_cardholder_name'.tr,
                name,
                TextInputType.name,
                hint: 'deposit_popup_hint_cardholder_name'.tr,
              ),

              SizedBox(height: AppSize.height * 0.02),

              /// CONFIRM BUTTON
              Obx(() => CustomButton(
                title: c.isTopUpLoading.value
                    ? 'deposit_popup_processing'.tr
                    : 'deposit_popup_confirm_button'.tr,
                onTap: c.isTopUpLoading.value
                    ? () {}
                    : () {
                  final raw = amount.text
                      .trim()
                      .replaceAll(',', '')
                      .replaceAll('\$', '');
                  final parsed = double.tryParse(raw) ?? 0.0;
                  c.deposit(parsed);
                },
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
      BuildContext context,
      String label,
      TextEditingController ctrl,
      TextInputType type, {
        String? hint,
        String? topText,
        int? maxLength,
        List<TextInputFormatter>? inputFormatters,
      }) {
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
              if (topText != null && topText.isNotEmpty)
                Text(
                  topText,
                  style: TextStyle(
                    fontSize: AppSize.height * 0.012,
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
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
              maxLength: maxLength,
              inputFormatters: inputFormatters,
              style: TextStyle(color: theme.canvasColor),
              decoration: InputDecoration(
                counterText: "",
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: AppSize.height * 0.015,
                  color: theme.canvasColor.withOpacity(0.4),
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Auto-formats expiry as MM/YY while typing
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text.replaceAll('/', '');

    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    if (text.length >= 3) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
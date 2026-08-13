import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Features/AuthScreens/loginsignupcontroller/Login&SignUpScreen.dart';

class CustomAlertDialog {
  static void show({
    required BuildContext context,
    String? title,
    String? subtitle,
    IconData icon = Icons.logout,

    String? confirmText,
    String? cancelText,
    Color iconColor = const Color(0xff94C973),
    Color confirmColor = const Color(0xff94C973),
    Color? cancelColor,

    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool navigateToLoginOnConfirm = false,
  }) {
    final theme = Theme.of(context);

    /// Agar cancelColor pass nahi hui to theme ke hisaab se auto set hogi
    final effectiveCancelColor = cancelColor ?? theme.canvasColor.withOpacity(0.6);

    // Fallback localization support
    final resolvedTitle = title ?? 'dialog_default_logout_title'.tr;
    final resolvedSubtitle = subtitle ?? 'dialog_default_logout_subtitle'.tr;
    final resolvedConfirmText = confirmText ?? 'dialog_default_confirm_text'.tr;
    final resolvedCancelText = cancelText ?? 'dialog_default_cancel_text'.tr;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        backgroundColor: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// ICON
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.15),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),

              const SizedBox(height: 12),

              /// TITLE
              Text(
                resolvedTitle,
                style: TextStyle(
                  color: theme.canvasColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              /// SUBTITLE
              Text(
                resolvedSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.canvasColor.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 18),

              /// BUTTONS
              Row(
                children: [

                  /// CANCEL
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        if (onCancel != null) onCancel!();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: effectiveCancelColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            resolvedCancelText,
                            style: TextStyle(
                              color: effectiveCancelColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// CONFIRM
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();

                        if (onConfirm != null) onConfirm!();

                        if (navigateToLoginOnConfirm) {
                          Get.offAll(
                            LoginSignupScreen(),
                            transition: Transition.fade,
                            duration: const Duration(milliseconds: 500),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: confirmColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            resolvedConfirmText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
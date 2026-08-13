import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../Core/Widgets/Background.dart';
import '../../../Core/Widgets/Button.dart';
import '../../../Core/Widgets/CustomHeader.dart';
import '../../../Core/Widgets/MediaqueryHelperfile.dart';
import 'otpcontroller.dart';

/// OTP VERIFICATION SCREEN
class OtpVerificationScreen extends StatelessWidget {
  OtpVerificationScreen({
    super.key,
    required int userId,
    required String contact,
    required bool isPhone,
    required String backendRole,
    String? firebaseVerificationId,
  }) : controller = Get.put(
    OtpController(
      userId: userId,
      contact: contact,
      isPhone: isPhone,
      backendRole: backendRole,
      firebaseVerificationId: firebaseVerificationId,
    ),
    tag: contact,
  );

  final OtpController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSize.height * 0.02),

                    CustomHeader(
                      title: "",
                      showBackButton: true,
                      onBack: () => Get.back(),
                    ),

                    SizedBox(height: AppSize.height * 0.03),

                    Center(
                      child: Image(
                        image: const AssetImage("assets/images/logo.png"),
                        height: AppSize.height * 0.15,
                      ),
                    ),

                    SizedBox(height: AppSize.height * 0.05),

                    Text(
                      'otp_screen_title'.tr,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: AppSize.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),

                    SizedBox(height: AppSize.height * 0.01),

                    Text(
                      'otp_screen_subtitle'.trParams({'contact': controller.contact}),
                      style: TextStyle(
                        fontFamily: "pr",
                        color: theme.canvasColor.withOpacity(0.55),
                        fontSize: AppSize.height * 0.02,
                      ),
                    ),

                    SizedBox(height: AppSize.height * 0.04),

                    /// OTP INPUT BOXES
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      obscureText: false,
                      animationType: AnimationType.fade,
                      keyboardType: TextInputType.number,
                      textStyle: TextStyle(
                        fontFamily: "pb",
                        color: theme.canvasColor,
                        fontWeight: FontWeight.bold,
                      ),
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(16),
                        fieldHeight: AppSize.height * 0.065,
                        fieldWidth: AppSize.width * 0.125,
                        activeColor: theme.primaryColor,
                        inactiveColor: theme.dividerColor.withOpacity(0.2),
                        selectedColor: theme.primaryColor,
                        activeFillColor: theme.cardColor,
                        inactiveFillColor: theme.cardColor,
                        selectedFillColor: theme.cardColor,
                      ),
                      animationDuration: const Duration(milliseconds: 200),
                      enableActiveFill: true,
                      onChanged: controller.onOtpChanged,
                      onCompleted: (_) => controller.verifyOtp(),
                    ),

                    /// ERROR TEXT
                    Obx(() {
                      final error = controller.otpError.value;
                      if (error.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: EdgeInsets.only(top: AppSize.height * 0.008, left: 8),
                        child: Text(
                          error,
                          style: TextStyle(
                            fontFamily: "pr",
                            color: const Color(0xffEF4444),
                            fontSize: AppSize.height * 0.016,
                          ),
                        ),
                      );
                    }),

                    SizedBox(height: AppSize.height * 0.03),

                    /// RESEND OTP
                    Center(
                      child: Obx(
                            () => GestureDetector(
                          onTap: controller.isResending.value
                              ? null
                              : controller.resendOtp,
                          child: Text(
                            controller.isResending.value
                                ? 'otp_screen_resending'.tr
                                : 'otp_screen_resend_prompt'.tr,
                            style: TextStyle(
                              fontFamily: "pb",
                              color: theme.primaryColor,
                              fontSize: AppSize.height * 0.02,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: AppSize.height * 0.04),

                    /// VERIFY BUTTON
                    Obx(
                          () => CustomButton(
                        title: controller.isLoading.value
                            ? 'otp_screen_button_verifying'.tr
                            : 'otp_screen_button_verify'.tr,
                        onTap: controller.isLoading.value
                            ? () {}
                            : controller.verifyOtp,
                      ),
                    ),

                    SizedBox(height: AppSize.height * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../../Core/Apis/auth_api.dart';
import '../../../Core/Apis/sessionmanager.dart';
import '../../../Core/Widgets/AppLoader.dart';
import '../otpsession/otpverificationscreen.dart';

class AuthController extends GetxController {
  RxBool isPhone = true.obs;
  RxBool isLogin = true.obs;
  RxBool isLoading = false.obs;
  RxString phoneError = "".obs;
  RxString emailError = "".obs;

  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  final RegExp phoneRegex = RegExp(r'^[0-9+\-\s\(\)]{7,20}$');
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  void toggleMethod(bool value) {
    isPhone.value = value;
    phoneError.value = "";
    emailError.value = "";
  }

  void toggleAuth() {
    isLogin.value = !isLogin.value;
  }

  bool _validatePhone(String phone) {
    final cleaned = phone.trim();
    if (cleaned.isEmpty) {
      phoneError.value = "auth_error_enter_phone".tr;
      return false;
    }
    if (!phoneRegex.hasMatch(cleaned)) {
      phoneError.value = "auth_error_valid_phone".tr;
      return false;
    }
    phoneError.value = "";
    return true;
  }

  bool _validateEmail(String email) {
    final value = email.trim();
    if (value.isEmpty) {
      emailError.value = "auth_error_enter_email".tr;
      return false;
    }
    if (!emailRegex.hasMatch(value)) {
      emailError.value = "auth_error_valid_email".tr;
      return false;
    }
    emailError.value = "";
    return true;
  }

  Future<void> continueAuth({
    required String phone,
    required String email,
  }) async {
    if (isLoading.value) return;

    final tempRole = SessionManager.getTempRole() ?? "work";
    final backendRole = SessionManager.mapLocalRoleToBackend(tempRole);

    // ============================
    // PHONE FIREBASE OTP
    // ============================
    if (isPhone.value) {
      if (!_validatePhone(phone)) {
        Get.snackbar("auth_error_general".tr, phoneError.value);
        return;
      }

      String formattedPhone =
      phone.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');

      if (!formattedPhone.startsWith("+")) {
        phoneError.value = "Please select country code";
        Get.snackbar("Phone Error", phoneError.value);
        return;
      }

      isLoading.value = true;
      AppLoader.show(text: "Sending OTP...");

      try {
        await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          verificationCompleted:
              (fb_auth.PhoneAuthCredential credential) async {
            print("🟢 AUTO VERIFIED");
          },
          verificationFailed: (fb_auth.FirebaseAuthException e) {
            AppLoader.hide();
            isLoading.value = false;
            print("🔴 FIREBASE OTP ERROR ${e.message}");
            Get.snackbar("OTP Error", e.message ?? "OTP failed");
          },
          codeSent: (String verificationId, int? resendToken) {
            AppLoader.hide();
            isLoading.value = false;
            print("🟢 OTP SENT");

            Get.to(
                  () => OtpVerificationScreen(
                userId: 0,
                contact: formattedPhone,
                isPhone: true,
                backendRole: backendRole,
                firebaseVerificationId: verificationId,
              ),
              transition: Transition.fade,
              duration: const Duration(milliseconds: 500),
            );
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            print("⏱ OTP TIMEOUT");
          },
        );
      } catch (e) {
        AppLoader.hide();
        isLoading.value = false;
        Get.snackbar("Error", e.toString());
      }
    }
    // ============================
    // EMAIL OTP BACKEND FLOW
    // ============================
    else {
      if (!_validateEmail(email)) {
        Get.snackbar("auth_error_general".tr, emailError.value);
        return;
      }

      isLoading.value = true;
      AppLoader.show(text: "Please wait...");

      try {
        final result = await ApiService.postRequest(
          endpoint: "/signup",
          body: {"email": email.trim(), "role": backendRole},
        );

        AppLoader.hide();
        isLoading.value = false;

        final data = result["data"];
        final success = data is Map ? data["success"] ?? false : false;

        if (!success) {
          Get.snackbar("Error", data["message"] ?? "Signup failed");
          return;
        }

        final userId = data["user_id"] ?? data["id"];

        Get.to(
              () => OtpVerificationScreen(
            userId: userId,
            contact: email.trim(),
            isPhone: false,
            backendRole: backendRole,
          ),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 500),
        );
      } catch (e) {
        AppLoader.hide();
        isLoading.value = false;
        Get.snackbar("Error", e.toString());
      }
    }
  }
}
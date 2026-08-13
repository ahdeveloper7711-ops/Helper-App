import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/ClientBottomnavigationScreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/WorkerBottomnavigationScreen.dart';

import '../../../Core/Apis/auth_api.dart';
import '../../../Core/Apis/sessionmanager.dart';
import '../../../Core/Apis/notificationservice.dart';
import '../../../Core/Widgets/AppLoader.dart';
import '../loginsignupcontroller/controllercleanup.dart';

class OtpController extends GetxController {
  final int userId;
  final String contact;
  final bool isPhone;
  final String backendRole;

  String? _verificationId;
  int? _resendToken;

  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  RxString enteredOtp = "".obs;
  RxBool isLoading = false.obs;
  RxBool isResending = false.obs;
  RxString otpError = "".obs;

  OtpController({
    required this.userId,
    required this.contact,
    required this.isPhone,
    required this.backendRole,
    String? firebaseVerificationId,
    int? firebaseResendToken,
  }) {
    _verificationId = firebaseVerificationId;
    _resendToken = firebaseResendToken;
  }

  void onOtpChanged(String value) {
    enteredOtp.value = value;
    otpError.value = "";
  }

  Future<void> verifyOtp() async {
    if (isLoading.value) return;

    if (enteredOtp.value.length != 6) {
      otpError.value = "otp_error_complete_code".tr;
      return;
    }

    isLoading.value = true;
    AppLoader.show(text: "Verifying OTP...");

    try {
      if (isPhone) {
        await verifyFirebaseOtp();
      } else {
        await verifyEmailOtp();
      }
    } catch (e) {
      AppLoader.hide();
      isLoading.value = false;
      otpError.value = e.toString().replaceAll("Exception: ", "");
      Get.snackbar("Error", otpError.value);
    }
  }

  // ============================================================
  // PHONE FLOW (Firebase verifies OTP — backend verify-otp NEVER called)
  // ============================================================
  Future<void> verifyFirebaseOtp() async {
    if (_verificationId == null) {
      throw Exception("Verification ID missing");
    }

    // Step 1: Confirm SMS code with Firebase
    final credential = fb_auth.PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: enteredOtp.value.trim(),
    );

    final result = await _firebaseAuth.signInWithCredential(credential);

    if (result.user == null) {
      throw Exception("Firebase user not found");
    }

    // Step 2: Register/fetch backend user_id tied to this phone number.
    // NOTE: we deliberately ignore the "otp" field in this response —
    // Firebase already verified the phone, backend OTP is not used.
    final signupResult = await ApiService.postRequest(
      endpoint: "/signup",
      body: {"phone": contact, "role": backendRole},
    );

    final signupData = signupResult["data"];

    if (signupData is! Map || signupData["success"] != true) {
      throw Exception(signupData["message"] ?? "Signup failed");
    }

    final backendUserId = signupData["user_id"] ?? signupData["id"];

    if (backendUserId == null) {
      throw Exception("User ID missing from server response");
    }

    // Step 3: Fetch the full user profile object (since /signup does not
    // return a full "user" object — only /user/profile/view does).
    final profileResult = await ApiService.postRequest(
      endpoint: "/user/profile/view",
      body: {"user_id": backendUserId},
    );

    final profileData = profileResult["data"];

    if (profileData is! Map || profileData["success"] != true) {
      throw Exception(profileData["message"] ?? "Could not load profile");
    }

    final Map<String, dynamic> user = Map<String, dynamic>.from(
      profileData["user"],
    );

    // Ensure phone is always present even if backend omits it
    user["phone"] ??= contact;

    await completeLogin(user);
  }

  // ============================================================
  // EMAIL FLOW (Backend verifies OTP)
  // ============================================================
  Future<void> verifyEmailOtp() async {
    final result = await ApiService.postRequest(
      endpoint: "/auth/verify-otp",
      body: {"user_id": userId, "otp": enteredOtp.value},
    );

    final data = result["data"];

    if (data is! Map || data["success"] != true) {
      throw Exception(data["message"] ?? "Invalid OTP");
    }

    final user = Map<String, dynamic>.from(data["user"]);

    await completeLogin(user);
  }

  // ============================================================
  // COMMON: Save session + sync FCM + navigate Home
  // ============================================================
  Future<void> completeLogin(Map<String, dynamic> user) async {
    AppLoader.hide();
    isLoading.value = false;

    ControllerCleanup.resetUserScopedControllers();

    // ✅ RoleSelectionScreen pe jo role explicitly select kiya gaya tha,
    // wahi is waqt source of truth hai — backend ke purane/stale role ko
    // navigation decide karne nahi dena.
    final role = SessionManager.normalizeRole(backendRole);

    // Cached user object ko bhi selected role ke sath sync rakhein taa ke
    // baad mein getUser() se koi mismatch na aaye.
    user["role"] = SessionManager.mapLocalRoleToBackend(role);

    await SessionManager.saveUser(user);
    await SessionManager.saveRole(role);

    // Sync FCM token once
    await NotificationService.syncFcmToken();

    if (role == "job") {
      Get.offAll(() => Clientbottomnavigationscreen());
    } else {
      Get.offAll(() => Workerbottomnavigationscreen());
    }
  }
  Future<void> resendOtp() async {
    if (isResending.value) return;
    isResending.value = true;

    try {
      if (isPhone) {
        await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: contact,
          forceResendingToken: _resendToken,
          verificationCompleted: (credential) {},
          verificationFailed: (e) {
            Get.snackbar("OTP Error", e.message ?? "Failed");
          },
          codeSent: (id, token) {
            _verificationId = id;
            _resendToken = token;
            Get.snackbar("Success", "OTP sent again");
          },
          codeAutoRetrievalTimeout: (id) {
            _verificationId = id;
          },
        );
      } else {
        await ApiService.postRequest(
          endpoint: "/signup",
          body: {"email": contact, "role": backendRole},
        );
      }
    } finally {
      isResending.value = false;
    }
  }
}

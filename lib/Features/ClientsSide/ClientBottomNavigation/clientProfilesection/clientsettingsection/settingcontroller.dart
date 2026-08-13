import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:helper_app2/Core/Apis/sessionmanager.dart';
import 'package:helper_app2/Core/Apis/clientprofileservice.dart';
import 'package:helper_app2/Core/Apis/roleservice.dart';
import 'package:helper_app2/Core/Widgets/AppLoader.dart';

import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/ClientBottomnavigationScreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/WorkerBottomnavigationScreen.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientProfilescreensection/clientProfilecontroller.dart';

import 'package:helper_app2/Features/AuthScreens/loginsignupcontroller/Login&SignUpScreen.dart';

import '../../../../../Core/Apis/onlinestatuscontroller.dart';
import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';

/// SHARED SETTINGS CONTROLLER (Client + Worker dono)
class SettingsController extends GetxController {
  RxString selectedLanguage = "English".obs;
  RxInt notificationCount = 2.obs;

  RxBool isClient = (SessionManager.getRole() == "job").obs;
  RxBool isLoading = false.obs;

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
  }
  Future<void> switchUserRole() async {
    // Prevent double tap
    if (isLoading.value) {
      print("🟡 IGNORED: role switch already running");
      return;
    }

    final int? userId = SessionManager.getUserId();

    if (userId == null) {
      Get.snackbar('settings_ctrl_err_session_title'.tr, 'settings_ctrl_err_session_msg'.tr,    snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),);
      return;
    }

    isLoading.value = true;

    AppLoader.show(text: 'settings_ctrl_loader_switching'.tr);

    try {
      final response = await RoleService.switchUserRole(userId);

      if (response["statusCode"] >= 200 && response["statusCode"] < 300) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(
          response["data"],
        );

        final Map<String, dynamic> switchedUser = Map<String, dynamic>.from(
          data["user"],
        );

        final Map<String, dynamic> oldUser = Map<String, dynamic>.from(
          SessionManager.getUser() ?? {},
        );

        Map<String, dynamic> user = {...oldUser, ...switchedUser};

        final String rawNewRole = user["role"].toString();

        final String normalizedRole = SessionManager.normalizeRole(rawNewRole);

        // When switching to Client remove worker skills
        if (normalizedRole == "job") {
          final clearResult = await ProfileService.updateProfile(
            username: (user["username"] ?? "").toString(),
            phone: (user["phone"] ?? "").toString(),
            skills: const [],
          );

          if (clearResult["data"] != null &&
              clearResult["data"]["success"] == true &&
              clearResult["data"]["user"] != null) {
            final Map<String, dynamic> clearedUser = Map<String, dynamic>.from(
              clearResult["data"]["user"],
            );

            user = {...user, ...clearedUser};

            print("🟢 SKILLS CLEARED FOR CLIENT ROLE");
          } else {
            print("🟡 COULD NOT CLEAR SKILLS: ${clearResult['error']}");
          }
        }

        await SessionManager.updateRolePermanently(rawNewRole, user);

        isClient.value = normalizedRole == "job";

        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().refreshFromUser(user);
        }
        if (Get.isRegistered<OnlineStatusController>()) {
          Get.find<OnlineStatusController>().refreshFromSession();
        }

        print("🟢 SUCCESS: Switched to $normalizedRole");

        // CLOSE LOADER BEFORE NAVIGATION
        AppLoader.hide();

        // Give dialog time to disappear
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate
        if (normalizedRole == "job") {
          Get.offAll(() => Clientbottomnavigationscreen());
        } else {
          Get.offAll(() => Workerbottomnavigationscreen());
        }

        Future.delayed(const Duration(milliseconds: 300), () {
          Get.snackbar(
            'settings_ctrl_success_title'.tr,
            data["message"]?.toString() ?? 'settings_ctrl_success_msg'.tr,
            snackPosition: SnackPosition.BOTTOM,
            padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),
          );
        });
      } else {
        AppLoader.hide();

        Get.snackbar('settings_ctrl_err_session_title'.tr, response["error"] ?? 'settings_ctrl_err_switch'.tr,    snackPosition: SnackPosition.BOTTOM,
          padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),);
      }
    } catch (e) {
      AppLoader.hide();

      print("❌ ERROR SWITCHING ROLE: $e");

      Get.snackbar('settings_ctrl_err_session_title'.tr, 'settings_ctrl_err_general'.tr,    snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),);
    } finally {
      isLoading.value = false;
    }
  }
  /// ==========================================================
  /// LOGOUT FUNCTION
  /// ==========================================================
  Future<void> logout() async {
    AppLoader.show(text: 'settings_ctrl_loader_logout'.tr);

    try {
      await SessionManager.clearSession();

      print("🚪 SUCCESS: User logged out");

      AppLoader.hide();

      await Future.delayed(const Duration(milliseconds: 300));

      Get.offAll(() => LoginSignupScreen());
    } catch (e) {
      AppLoader.hide();

      print("❌ LOGOUT ERROR: $e");

      Get.snackbar('settings_ctrl_err_session_title'.tr, 'settings_ctrl_err_logout'.tr,    snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),);
    }
  }
}
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:helper_app2/Core/Widgets/AppLoader.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/WorkerBottomnavigationScreen.dart';

import '../../../../../Core/Apis/clientprofileservice.dart'; // ProfileService reuse (generic hai)
import '../../../../../Core/Apis/sessionmanager.dart';
import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';

class Workerprofilecontroller extends GetxController {
  RxString username = "".obs;
  RxString email = "".obs;
  RxString phone = "".obs;
  RxString profilePicUrl = "".obs;
  RxString role = "worker".obs;

  RxBool isLoading = false.obs;
  RxBool isUpdating = false.obs;

  Rx<File?> pickedImage = Rx<File?>(null);

  RxString selectedLanguage = "English".obs;
  RxBool locationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();

    _loadFromSession();

    // delay profile API
    Future.delayed(
      const Duration(microseconds: 500),
          () {
        fetchProfile();
      },
    );
  }

  void _loadFromSession() {
    final savedUser = SessionManager.getUser();
    if (savedUser != null) {
      _applyUserData(savedUser);
    }
    selectedLanguage.value = SessionManager.getLanguage();
  }

  Future<void> fetchProfile() async {
    if (isLoading.value) return;

    isLoading.value = true;

    try {
      final result = await ProfileService.viewProfile();

      if (result["error"] != null) {
        print(
          "🔴 WORKER PROFILE FETCH FAILED: ${result['error']}",
        );

        return;
      }


      final data = result["data"];

      if (data != null &&
          data["success"] == true &&
          data["user"] != null) {

        final user =
        Map<String, dynamic>.from(data["user"]);

        _applyUserData(user);

        await SessionManager.saveUser(user);

        print(
          "🟢 WORKER PROFILE FETCHED: $user",
        );
      }


    } catch (e) {

      print(
        "❌ WORKER PROFILE EXCEPTION: $e",
      );

    } finally {

      isLoading.value = false;

    }
  }
  Future<void> updateProfile({
    required String newUsername,
    required String newPhone,
  }) async {
    if (isUpdating.value) {
      print("🟡 IGNORED: worker profile update already in progress");
      return;
    }

    if (newUsername.trim().isEmpty) {
      Get.snackbar(
        'worker_profile_oops_title'.tr,
        'worker_profile_name_empty_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    isUpdating.value = true;
    AppLoader.show(text: 'worker_profile_saving_loader'.tr);

    String? base64Image;
    if (pickedImage.value != null) {
      final bytes = await pickedImage.value!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final result = await ProfileService.updateProfile(
      username: newUsername.trim(),
      phone: newPhone.trim(),
      profilePicBase64: base64Image,
    );

    isUpdating.value = false;
    AppLoader.hide();

    if (result["error"] != null) {
      print("🔴 WORKER PROFILE UPDATE FAILED: ${result['error']}");
      Get.snackbar(
        'worker_profile_update_failed_title'.tr,
        result["error"].toString(),
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    final data = result["data"];
    if (data != null && data["success"] == true && data["user"] != null) {
      final user = Map<String, dynamic>.from(data["user"]);
      _applyUserData(user);
      await SessionManager.saveUser(user);
      pickedImage.value = null;

      Get.snackbar(
        'worker_profile_success_title'.tr,
        (data["message"] ?? 'worker_profile_updated_success_message'.tr).toString(),
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      Get.offAll(() => Workerbottomnavigationscreen());
    } else {
      Get.snackbar(
        'worker_profile_update_failed_title'.tr,
        'worker_profile_generic_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  void _applyUserData(Map<String, dynamic> user) {
    username.value = (user["username"] ?? "").toString();
    email.value = (user["email"] ?? "").toString();
    phone.value = (user["phone"] ?? "").toString();
    profilePicUrl.value = (user["profile_pic"] ?? "").toString();
    role.value = (user["role"] ?? "worker").toString();
  }

  bool get _isUsernameActuallySet {
    final u = username.value.trim();
    if (u.isEmpty) return false;

    final e = email.value.trim();
    final p = phone.value.trim();

    if (e.isNotEmpty && u.toLowerCase() == e.toLowerCase()) return false;
    if (p.isNotEmpty && u == p) return false;
    if (u.contains('@')) return false;

    return true;
  }

  String get displayUsername => _isUsernameActuallySet ? username.value : 'worker_profile_add_name_placeholder'.tr;
  String get editableUsername => _isUsernameActuallySet ? username.value : "";

  String get displayEmail => email.value.trim().isNotEmpty ? email.value : 'worker_profile_not_provided'.tr;
  String get displayPhone => phone.value.trim().isNotEmpty ? phone.value : 'worker_profile_not_provided'.tr;

  /// Role ke hisaab se khud "I'm a Client" ya "I'm a Worker" show hoga
  String get displayRole => 'worker_profile_im_a_role'.trParams({'role': _capitalize(role.value)});

  bool get hasProfilePic => profilePicUrl.value.trim().isNotEmpty;

  ImageProvider get avatarImage {
    if (pickedImage.value != null) {
      return FileImage(pickedImage.value!);
    }
    if (hasProfilePic) {
      return NetworkImage(profilePicUrl.value);
    }
    return const AssetImage("assets/images/profile.png");
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> pickImageFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) pickedImage.value = File(picked.path);
  }

  Future<void> pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) pickedImage.value = File(picked.path);
  }

  void discardPickedImage() {
    pickedImage.value = null;
  }

  void setLanguage(String lang) {
    selectedLanguage.value = lang;
  }

  void toggleLocation(bool value) {
    locationEnabled.value = value;
  }
}
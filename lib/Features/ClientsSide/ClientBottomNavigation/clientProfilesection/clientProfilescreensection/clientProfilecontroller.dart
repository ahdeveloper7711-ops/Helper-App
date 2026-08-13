import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:helper_app2/Core/Widgets/AppLoader.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/ClientBottomnavigationScreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/WorkerBottomnavigationScreen.dart';

import '../../../../../Core/Apis/clientprofileservice.dart';
import '../../../../../Core/Apis/sessionmanager.dart';
import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';

class ProfileController extends GetxController {
  RxString username = "".obs;
  RxString email = "".obs;
  RxString phone = "".obs;
  RxString profilePicUrl = "".obs;

  /// Normalized role: "job" (client) ya "work" (worker)
  RxString role = "".obs;

  /// Sirf worker role ke liye relevant hoti hain. Client role mein
  /// backend khud khali/absent bhejta hai (ya humne clear kardi hoti hain),
  /// is liye ye list khud-ba-khud khali ho jati hai.
  RxList<String> skills = <String>[].obs;
  final TextEditingController skillTextController = TextEditingController();

  RxBool isLoading = false.obs; // profile fetch (view API) loading
  RxBool isUpdating = false.obs; // profile update (update API) loading

  /// Locally pick ki gayi image (upload / save honay se pehle preview ke liye)
  Rx<File?> pickedImage = Rx<File?>(null);

  RxString selectedLanguage = "English".obs;
  RxBool locationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromSession(); // pehle cached data foran dikha do (blank screen na aye)
    fetchProfile(); // phir server se fresh/latest data le aao
  }

  @override
  void onClose() {
    skillTextController.dispose();
    super.onClose();
  }

  void _loadFromSession() {
    final savedUser = SessionManager.getUser();
    if (savedUser != null) {
      _applyUserData(savedUser);
    }
    selectedLanguage.value = SessionManager.getLanguage();
  }

  /// -------------------- FETCH PROFILE (view API) --------------------
  Future<void> fetchProfile() async {
    isLoading.value = true;
    final result = await ProfileService.viewProfile();
    isLoading.value = false;

    if (result["error"] != null) {
      print("🔴 PROFILE FETCH FAILED: ${result['error']}");
      Get.snackbar(
        'profile_fetch_error_title'.tr,
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
      await SessionManager.saveUser(user); // session bhi refresh rakho
      print("🟢 PROFILE FETCHED: $user");
    }
  }

  /// -------------------- UPDATE PROFILE (update API) --------------------
  /// [skills] null bhejo tu skills touch nahi hongi. Empty list [] bhejo
  /// tu skills clear ho jayengi. Poori list bhejo tu wahi save ho jayegi.
  Future<bool> updateProfile({
    required String newUsername,
    required String newPhone,
    List<String>? skills,
  }) async {
    // Double-tap guard
    if (isUpdating.value) {
      print("🟡 IGNORED: profile update already in progress");
      return false;
    }

    if (newUsername.trim().isEmpty) {
      Get.snackbar(
        'profile_update_missing_name_title'.tr,
        'profile_update_missing_name'.tr,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return false;
    }

    isUpdating.value = true;
    AppLoader.show(text: 'profile_update_loader'.tr);

    String? base64Image;
    if (pickedImage.value != null) {
      final bytes = await pickedImage.value!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final result = await ProfileService.updateProfile(
      username: newUsername.trim(),
      phone: newPhone.trim(),
      profilePicBase64: base64Image,
      skills: skills,
    );

    isUpdating.value = false;
    AppLoader.hide();

    if (result["error"] != null) {
      print("🔴 PROFILE UPDATE FAILED: ${result['error']}");
      Get.snackbar(
        'profile_update_failed_title'.tr,
        result["error"].toString(),
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return false;
    }

    final data = result["data"];
    if (data != null && data["success"] == true && data["user"] != null) {
      final user = Map<String, dynamic>.from(data["user"]);
      _applyUserData(user);

      await SessionManager.saveUser(user);

      // IMPORTANT:
      // local preview ko immediately remove na karo
      // pehle network image confirm hone do

      if (user["profile_pic"] != null &&
          user["profile_pic"].toString().isNotEmpty) {
        profilePicUrl.value = user["profile_pic"].toString();
      }

      pickedImage.value = null;
      Get.snackbar(
        'profile_update_success_title'.tr,
        (data["message"] ?? 'profile_update_success_msg'.tr).toString(),
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      // Role ke hisab se sahi bottom navigation screen par le jao
      if (role.value == "job") {
        Get.offAll(() => Clientbottomnavigationscreen());
      } else {
        Get.offAll(() => Workerbottomnavigationscreen());
      }
      return true;
    } else {
      Get.snackbar(
        'profile_update_failed_title'.tr,
        'profile_update_fallback_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Role switch hone ke turant baad (SettingsController se) call hota
  /// hai taa ka is controller ka data - bina dobara API call kiye - foran
  /// naye role ke mutabiq update ho jaye (profile pic/name/skills sab).
  void refreshFromUser(Map<String, dynamic> user) {
    _applyUserData(user);
  }

  /// User map se sari Rx values set karo
  void _applyUserData(Map<String, dynamic> user) {
    username.value = (user["username"] ?? user["fullname"] ?? "").toString();
    email.value = (user["email"] ?? "").toString();
    phone.value = (user["phone"] ?? "").toString();
    profilePicUrl.value = (user["profile_pic"] ?? user["profile_image"] ?? "")
        .toString();
    role.value = SessionManager.normalizeRole(
      (user["role"] ?? "work").toString(),
    );

    // Skills sirf worker role mein relevant hain. Backend jo bhejay wahi
    // sach maano - client role mein ye field null/missing hogi tu list
    // khud khali ho jayegi (UI mein skills show hi nahi hongi).
    final rawSkills = user["skills"];
    if (rawSkills is List) {
      skills.value = rawSkills.map((e) => e.toString()).toList();
    } else {
      skills.value = [];
    }
  }

  /// ---------------- SKILLS (worker only) ----------------
  void addSkill() {
    final text = skillTextController.text.trim();

    if (text.isEmpty) {
      Get.snackbar(
        'profile_skill_empty_title'.tr,
        'profile_skill_empty_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    if (skills.contains(text)) {
      Get.snackbar(
        'profile_skill_exists_title'.tr,
        'profile_skill_exists_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
      );
      return;
    }

    skills.add(text);
    skillTextController.clear();
  }

  void removeSkill(String skill) {
    skills.remove(skill);
  }

  /// ---------------- DISPLAY HELPERS ----------------
  /// Naye register hue user ka username abhi set nahi hota, is liye backend
  /// (jab sirf email/phone se signup hota hai) khud email ya phone ko hi
  /// username field mein bhar देता hai. Is liye agar username, email ya
  /// phone ke barabar/similar nikle, to usay "set nahi kiya" hi treat karo.
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

  String get displayUsername =>
      _isUsernameActuallySet ? username.value : 'profile_fallback_name'.tr;

  String get editableUsername => _isUsernameActuallySet ? username.value : "";

  String get displayEmail =>
      email.value.trim().isNotEmpty ? email.value : 'profile_fallback_email'.tr;

  String get displayPhone =>
      phone.value.trim().isNotEmpty ? phone.value : 'profile_fallback_phone'.tr;

  String get displayRole => 'profile_role_prefix'.trParams({
    'role': role.value == "job" ? 'profile_role_client'.tr : 'profile_role_worker'.tr,
  });

  bool get hasProfilePic => profilePicUrl.value.trim().isNotEmpty;

  /// Agar user ne profile pic upload/pick ki hui hai tu wahi ImageProvider
  /// return karta hai, warna null - taa ka UI (ProfileAvatar widget) khud
  /// decide kar sake ke grey placeholder dikhana hai ya asal photo.
  ImageProvider? get avatarImageOrNull {
    if (pickedImage.value != null) {
      return FileImage(pickedImage.value!);
    }
    if (hasProfilePic) {
      return NetworkImage(profilePicUrl.value);
    }
    return null;
  }

  /// ---------------- IMAGE PICKER ----------------
  Future<void> pickImageFromCamera() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (picked != null) pickedImage.value = File(picked.path);
  }

  Future<void> pickImageFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) pickedImage.value = File(picked.path);
  }

  /// Edit screen se bina save kiye bahar jayein tu locally picked image
  /// discard kar do (warna galat reh jayega).
  void discardPickedImage() {
    pickedImage.value = null;
  }

  /// ---------------- LANGUAGE / LOCATION ----------------
  void setLanguage(String lang) {
    selectedLanguage.value = lang;
  }

  void toggleLocation(bool value) {
    locationEnabled.value = value;
  }
}
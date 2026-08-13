import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Apis/sessionmanager.dart';

class ThemeController extends GetxController {
  var isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    // App start hote hi last-saved theme load karo
    isDarkMode.value = SessionManager.getThemeMode();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Naya theme session mein save karo taake restart par yaad rahe
    SessionManager.saveThemeMode(isDarkMode.value);

    // GetBuilder<ThemeController> ko manually notify karo (Rx alone kaafi nahi)
    update();
  }
}

class ThemeService {
  // Primary Color aap ki di gayi value
  static const Color primaryGreen = Color(0xff94C973);

  // 1. Light Theme
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xffF9F9F9),
    cardColor: Colors.white,
    canvasColor: Colors.black,
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      surface: Colors.white,
    ),
    iconTheme: const IconThemeData(color: Colors.black54),
  );

  // 2. Dark Theme
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryGreen,
    scaffoldBackgroundColor: const Color(0xff121212),
    cardColor: const Color(0xff1E1E1E),
    canvasColor: Colors.white,
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      surface: Color(0xff1E1E1E),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
  );
}
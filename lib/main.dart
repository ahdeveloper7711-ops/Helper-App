import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:helper_app2/Features/OtherScreens/splashscreen.dart';

import 'Core/Apis/firebacenotificationservice.dart';
import 'Core/Apis/sessionmanager.dart';
import 'Core/AppTheme/themecontroller.dart';
import 'Core/Localization/apptranslation.dart';
import 'Core/Localization/languagehelper.dart';
import 'Core/Widgets/ErrorWidget.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📲 Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialize
  await Firebase.initializeApp();
  await FirebaseNotificationService.initialize();

  // Firebase Background Messaging Handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await GetStorage.init();

  // Controllers Register karein
  Get.put(ThemeController());
  Get.put(ErrorController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: 'Helper App',
          debugShowCheckedModeBanner: false,
          theme: ThemeService.lightTheme,
          darkTheme: ThemeService.darkTheme,
          themeMode: themeController.isDarkMode.value
              ? ThemeMode.dark
              : ThemeMode.light,
          color: themeController.isDarkMode.value
              ? ThemeService.darkTheme.scaffoldBackgroundColor
              : ThemeService.lightTheme.scaffoldBackgroundColor,
          home: const SplashScreen(),
          translations: AppTranslations(),
          locale: LanguageHelper.localeFor(
              SessionManager.getLanguage()
          ),
          fallbackLocale: LanguageHelper.defaultLocale,
        );
      },
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Navigation ke liye GetX ka use
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/ClientBottomnavigationScreen.dart';
import 'package:helper_app2/Features/OtherScreens/LanguageSelection/languagescreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/WorkerBottomnavigationScreen.dart';
import 'package:helper_app2/Features/OtherScreens/RoleSelection/roleselectionscreen.dart';

import '../../Core/Apis/sessionmanager.dart';
import '../../Core/Widgets/Background.dart';
import '../../Core/Widgets/MediaqueryHelperfile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // NEW: taake didChangeDependencies har rebuild par dobara precache na kare
  bool _assetsPrecached = false;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      // 1. Check if user is logged in
      final bool isLoggedIn = SessionManager.isLoggedIn();

      if (isLoggedIn) {
        // 2. Get the FINAL permanent role
        final String? role = SessionManager.getRole();
        print("🔵 SPLASH: User logged in, Role found: $role");

        if (role == "job") {
          // Client mode
          Get.offAll(() => Clientbottomnavigationscreen());
        } else if (role == "work") {
          // Worker mode
          Get.offAll(() => Workerbottomnavigationscreen());
        } else {
          // Role null hai toh safety ke liye Role Selection par bhejo
          Get.offAll(() => LanguageScreen());
        }
      } else {
        // 3. User logged out hai
        print("🔴 SPLASH: No session, navigating to Role Selection");
        Get.offAll(() => LanguageScreen());
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // NEW: Splash ke 2-second window mein hi RoleSelectionScreen ki
    // dono images ko decode + cache kar dete hain. Isse jab user
    // Role -> Language navigate karega, transition ke dauran koi
    // image decode nahi hogi -> black glitch/frame-jank fix ho jata hai.
    if (!_assetsPrecached) {
      _assetsPrecached = true;
      _precacheRoleSelectionAssets();
    }
  }

  Future<void> _precacheRoleSelectionAssets() async {
    try {
      await Future.wait([
        precacheImage(
          const AssetImage("assets/images/roleselectionimage.png"),
          context,
        ),
        precacheImage(
          const AssetImage("assets/images/roleselectionimage2.png"),
          context,
        ),
      ]);
    } catch (e) {
      // Precaching fail bhi ho jaye (e.g. asset missing), splash flow
      // ko block nahi karna — normal navigation apni jagah chalti rahegi.
      print("⚠️ SPLASH: Precache failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AppBackground(
        backgroundColor: theme.scaffoldBackgroundColor,
        child: Center(
          child: Image.asset(
            "assets/images/logo.png",
            height: AppSize.height * 0.25,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
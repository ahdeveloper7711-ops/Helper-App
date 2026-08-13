import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/MediaqueryHelperfile.dart';

class AppLoader {
  static bool _isOpen = false;

  /// SHOW LOADER (GETX VERSION)
  static void show({
    String? text,
    Color color = const Color(0xff94C973),
    bool barrierDismissible = false,
    Duration? autoCloseAfter,
  }) {
    if (_isOpen) return;

    _isOpen = true;

    Get.dialog(
      barrierDismissible: barrierDismissible,
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: AppSize.width * 0.4,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpinKitCircle(
                  color: color,
                  size: 45,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.black12,
    );

    /// AUTO CLOSE
    if (autoCloseAfter != null) {
      Future.delayed(autoCloseAfter, () async {
        await hide();
      });
    }
  }


  /// HIDE LOADER
  static Future<void> hide() async {
    if (!_isOpen) return;
    _isOpen = false;
    try {
      if (Get.key.currentState?.canPop() ?? false) {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 250));
      }
    } catch (e) {
      debugPrint("⚠️ AppLoader hide error: $e");
    }
  }


  /// FORCE CLOSE (safety)
  /// Agar kisi bhi case mein loader state stuck ho jaye
  static Future<void> forceClose() async {
    _isOpen = false;

    try {
      while (Get.isDialogOpen ?? false) {
        Get.back();
        await Future.delayed(
          const Duration(milliseconds: 100),
        );
      }
    } catch (e) {
      debugPrint("⚠️ AppLoader forceClose error: $e");
    }
  }


  /// CHECK LOADER STATUS
  static bool get isShowing => _isOpen;
}
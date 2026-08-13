import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppNavigator {
  AppNavigator._();

  /// FADE ANIMATION (DEFAULT)
  static void pushFade(Widget page) {
    Get.to(
          () => page,
      transition: Transition.fade,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// SLIDE FROM RIGHT
  static void pushRight(Widget page) {
    Get.to(
          () => page,
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// SLIDE FROM LEFT
  static void pushLeft(Widget page) {
    Get.to(
          () => page,
      transition: Transition.leftToRight,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// BOTTOM TO TOP
  static void pushUp(Widget page) {
    Get.to(
          () => page,
      transition: Transition.upToDown,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// REPLACE (NO BACK)
  static void pushReplace(Widget page) {
    Get.off(
          () => page,
      transition: Transition.fade,
      duration: const Duration(milliseconds: 250),
    );
  }

  /// CLEAR STACK (LOGIN FLOW)
  static void pushAndClear(Widget page) {
    Get.offAll(
          () => page,
      transition: Transition.fade,
      duration: const Duration(milliseconds: 250),
    );
  }
}
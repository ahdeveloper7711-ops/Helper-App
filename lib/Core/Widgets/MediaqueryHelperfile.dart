import 'package:get/get.dart';

class AppSize {
  AppSize._();

  /// SCREEN SIZE
  static double get width => Get.size.width;
  static double get height => Get.size.height;
  /// RESPONSIVE TEXT BASE
  static double get text => Get.size.width;

  /// SAFE AREA (OPTIONAL USE)
  static double get topPadding => Get.mediaQuery.padding.top;
  static double get bottomPadding => Get.mediaQuery.padding.bottom;

  /// STATUS BAR HEIGHT
  static double get statusBar => Get.mediaQuery.viewPadding.top;

  /// NAVIGATION BAR HEIGHT
  static double get navBar => Get.mediaQuery.viewPadding.bottom;

  /// SHORTCUTS (COMMON USE CASES)

  static double widthPercent(double percent) {
    return width * percent;
  }

  static double heightPercent(double percent) {
    return height * percent;
  }

  static double textPercent(double percent) {
    return text * percent;
  }
}
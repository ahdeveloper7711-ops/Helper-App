import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData? icon;
  final double? size;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Gradient? gradient;

  const CustomBackButton({
    super.key,
    this.onTap,
    this.icon,
    this.size,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final double btnSize = size ?? mq.width * 0.11;

    // Theme ke mutabiq default colors decide karna
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default background: Light mein light-grey, Dark mein thora darker
    final defaultBg = isDark ? const Color(0xff2A2A2A) : const Color(0xffF2F4F7);

    // Default icon color: Light mein black, Dark mein white
    final defaultIconColor = Theme.of(context).canvasColor;

    return GestureDetector(
      onTap: onTap ?? () => Get.back(),
      child: Container(
        height: btnSize,
        width: btnSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          color: gradient == null
              ? (backgroundColor ?? defaultBg)
              : null,
          border: borderColor != null
              ? Border.all(color: borderColor!)
              : null,
        ),
        child: Icon(
          icon ?? Icons.arrow_back_rounded,
          color: iconColor ?? defaultIconColor,
          size: mq.width * 0.06,
        ),
      ),
    );
  }
}
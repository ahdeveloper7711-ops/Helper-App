import 'package:flutter/material.dart';

class IconCircle extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  final double height;
  final double width;
  final double iconSize;

  /// opacity control
  final double opacity;

  const IconCircle({
    super.key,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.height = 45,
    this.width = 45,
    this.iconSize = 20,
    this.opacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    // Theme-Aware Colors
    // Agar iconColor na diya jaye toh theme ka icon theme ya canvasColor use karein
    final iColor = iconColor ?? Theme.of(context).primaryColor;

    // Agar background color na diya jaye toh primary color ka halka shade use karein
    final bColor = backgroundColor ?? Theme.of(context).primaryColor;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bColor.withOpacity(opacity),
      ),
      child: Center(
        child: Icon(
          icon,
          color: iColor,
          size: iconSize,
        ),
      ),
    );
  }
}
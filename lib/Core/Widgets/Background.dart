import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String? image;
  final BoxFit imageFit;
  final Color? backgroundColor;

  const AppBackground({
    super.key,
    required this.child,
    this.image,
    this.imageFit = BoxFit.cover,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Theme ke mutabiq background color pick karega
    final themeBgColor = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: themeBgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: image != null
                ? Image.asset(image!, fit: imageFit)
                : Container(color: themeBgColor),
          ),
          SafeArea(child: child),
        ],
      ),
    );
  }
}
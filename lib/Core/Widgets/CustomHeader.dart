import 'package:flutter/material.dart';
import 'package:helper_app2/Core/Widgets/Backbutton.dart';
import 'package:helper_app2/Core/Widgets/MediaqueryHelperfile.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final String? profileImage;
  final Widget? rightWidget;
  final Color? backgroundColor;
  final double? titleSize;
  final double? subtitleSize;
  final EdgeInsets? padding;

  const CustomHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBack,
    this.profileImage,
    this.rightWidget,
    this.backgroundColor,
    this.titleSize,
    this.subtitleSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Theme-Aware Colors
    final textColor = Theme.of(context).canvasColor;
    final subTitleColor = Theme.of(context).canvasColor.withOpacity(0.6);

    return Container(
      width: double.infinity,
      padding: padding ??
          EdgeInsets.only(
            top: AppSize.height * 0.015,
            left: 0,
            right: 0,
            bottom: AppSize.height * 0.02,
          ),
      color: backgroundColor ?? Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// LEFT ELEMENT
          if (showBackButton)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CustomBackButton(onTap: onBack),
            )
          else if (profileImage != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(profileImage!),
              ),
            ),

          /// TITLE AREA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: "pb",
                    color: textColor, // Dynamic text color
                    fontSize: titleSize ?? AppSize.width * 0.056,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: subTitleColor, // Dynamic subtitle color
                      fontFamily: "pr",
                      fontSize: subtitleSize ?? AppSize.width * 0.03,
                    ),
                  ),
                ],
              ],
            ),
          ),

          /// RIGHT SIDE
          if (rightWidget != null) rightWidget!,
        ],
      ),
    );
  }
}
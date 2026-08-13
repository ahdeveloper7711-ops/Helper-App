import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  final Widget? leading;
  final Widget? trailing;

  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final double? height;
  final EdgeInsets? padding;

  final Color? titleColor;
  final double? titleSize;
  final FontWeight? titleWeight;

  final Color? subtitleColor;
  final double? subtitleSize;
  final FontWeight? subtitleWeight;

  final int titleMaxLines;
  final int subtitleMaxLines;
  final double spacing;

  const CustomTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.trailing,
    this.switchValue,
    this.onSwitchChanged,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 16,
    this.height,
    this.padding,
    this.titleColor,
    this.titleSize,
    this.titleWeight,
    this.subtitleColor,
    this.subtitleSize,
    this.subtitleWeight,
    this.titleMaxLines = 1,
    this.subtitleMaxLines = 2,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final size = Get.size;

    // Theme-Aware Colors
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.cardColor;
    final tColor = titleColor ?? theme.canvasColor;
    final subColor = subtitleColor ?? theme.canvasColor.withOpacity(0.6);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: double.infinity,
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.018,
            ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// LEADING
            if (leading != null) ...[
              leading!,
              SizedBox(width: size.width * 0.03),
            ],

            /// TEXT AREA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tColor,
                      fontSize: titleSize ?? size.width * 0.035,
                      fontWeight: titleWeight ?? FontWeight.w600,
                      fontFamily: "pm",
                    ),
                  ),

                  if (subtitle != null) ...[
                    SizedBox(height: spacing),
                    Text(
                      subtitle!,
                      maxLines: subtitleMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: subColor,
                        fontSize: subtitleSize ?? size.width * 0.028,
                        fontWeight: subtitleWeight ?? FontWeight.normal,
                        fontFamily: "pr",
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            /// SWITCH
            if (switchValue != null && onSwitchChanged != null)
              Switch(
                value: switchValue!,
                onChanged: onSwitchChanged,
                activeColor: theme.primaryColor, // Use Primary Green
              )

            /// TRAILING
            else if (trailing != null)
              trailing!,
          ],
        ),
      ),
    );
  }
}
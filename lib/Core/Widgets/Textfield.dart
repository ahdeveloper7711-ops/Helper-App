import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final double? height;
  final double? textSize;
  final double? hintTextSize;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final double? prefixIconSize;
  final double? suffixIconSize;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final double borderRadius;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool isSearch;
  final Widget? errorWidget;
  final EdgeInsets? padding;

  const CustomTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines,
    this.minLines,
    this.height,
    this.textSize,
    this.hintTextSize,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconSize,
    this.suffixIconSize,
    this.prefixIconColor,
    this.suffixIconColor,
    this.borderRadius = 12,
    this.onChanged,
    this.onTap,
    this.isSearch = false,
    this.errorWidget,
    this.padding,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final size = Get.size;
    final theme = Theme.of(context);

    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: widget.height,
            child: TextField(
              controller: widget.controller,
              keyboardType: widget.isSearch ? TextInputType.text : widget.keyboardType,
              obscureText: _isObscured,
              readOnly: widget.readOnly,
              onChanged: widget.onChanged,
              onTap: widget.onTap,
              maxLines: widget.maxLines ?? 1,
              minLines: widget.minLines,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: widget.textSize ?? size.width * 0.04,
                color: theme.canvasColor, // Dynamic Text Color
                fontFamily: "pr",
              ),
              decoration: InputDecoration(
                hintText: widget.isSearch ? 'custom_text_field_search_hint'.tr : widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: "pr",
                  color: theme.canvasColor.withOpacity(0.5), // Dynamic Hint Color
                  fontSize: widget.hintTextSize ?? size.width * 0.035,
                ),
                filled: true,
                fillColor: widget.fillColor ?? theme.cardColor, // Dynamic Fill Color
                prefixIcon: widget.prefixIcon == null
                    ? null
                    : IconTheme(
                  data: IconThemeData(
                    size: widget.prefixIconSize ?? 20,
                    color: widget.prefixIconColor ?? theme.canvasColor.withOpacity(0.6),
                  ),
                  child: widget.prefixIcon!,
                ),
                suffixIcon: widget.obscureText
                    ? GestureDetector(
                  onTap: () => setState(() => _isObscured = !_isObscured),
                  child: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    size: widget.suffixIconSize ?? 20,
                    color: widget.suffixIconColor ?? theme.canvasColor.withOpacity(0.6),
                  ),
                )
                    : (widget.suffixIcon == null
                    ? null
                    : IconTheme(
                  data: IconThemeData(
                    size: widget.suffixIconSize ?? 20,
                    color: widget.suffixIconColor ?? theme.canvasColor.withOpacity(0.6),
                  ),
                  child: widget.suffixIcon!,
                )),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(color: widget.borderColor ?? Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  borderSide: BorderSide(
                    color: widget.focusedBorderColor ?? theme.primaryColor, // Use Primary Green
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          if (widget.errorWidget != null) ...[
            const SizedBox(height: 6),
            widget.errorWidget!,
          ],
        ],
      ),
    );
  }
}
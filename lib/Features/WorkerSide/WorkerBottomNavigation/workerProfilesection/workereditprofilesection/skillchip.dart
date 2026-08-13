import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';

class Workerskillchip extends StatelessWidget {
  final String text;
  final VoidCallback onRemove;

  const Workerskillchip({
    super.key,
    required this.text,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = Color(0xff8B5CF6);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.width * 0.032,
        vertical: AppSize.height * 0.009,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text.tr, // .tr add kiya hai taake translation support mil jaye
            style: TextStyle(
              color: accent,
              fontWeight: FontWeight.w600,
              fontSize: AppSize.width * 0.033,
            ),
          ),
          SizedBox(width: AppSize.width * 0.016),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 12,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
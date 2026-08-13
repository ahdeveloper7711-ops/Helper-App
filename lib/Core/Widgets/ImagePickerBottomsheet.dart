import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePickerBottomSheet {
  static void show({
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
  }) {
    final size = Get.size;
    final context = Get.context!;
    final theme = Theme.of(context);

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.025,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor, // Theme ke mutabiq dynamic background
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HANDLE BAR
            Container(
              width: size.width * 0.14,
              height: 4,
              decoration: BoxDecoration(
                color: theme.canvasColor.withOpacity(0.2), // Theme-aware handle
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            SizedBox(height: size.height * 0.02),

            /// TITLE
            Text(
              'image_picker_title'.tr,
              style: TextStyle(
                fontFamily: "ps",
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.bold,
                color: theme.canvasColor,
              ),
            ),

            SizedBox(height: size.height * 0.03),

            Row(
              children: [
                /// CAMERA & GALLERY
                _buildOption(
                  size: size,
                  icon: Icons.camera_alt_rounded,
                  label: 'image_picker_camera'.tr,
                  onTap: () {
                    Get.back();
                    onCameraTap();
                  },
                  theme: theme,
                ),
                SizedBox(width: size.width * 0.04),
                _buildOption(
                  size: size,
                  icon: Icons.photo_library_rounded,
                  label: 'image_picker_gallery'.tr,
                  onTap: () {
                    Get.back();
                    onGalleryTap();
                  },
                  theme: theme,
                ),
              ],
            ),
            SizedBox(height: size.height * 0.02),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
    );
  }

  // Helper widget for clean code
  static Widget _buildOption({
    required Size size,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.022),
          decoration: BoxDecoration(
            color: theme.cardColor, // Dynamic card color
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: size.width * 0.07,
                backgroundColor: theme.primaryColor.withOpacity(0.15),
                child: Icon(icon, color: theme.primaryColor, size: size.width * 0.075),
              ),
              SizedBox(height: size.height * 0.012),
              Text(
                label,
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: size.width * 0.04,
                  color: theme.canvasColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
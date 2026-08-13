import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Widgets/Button.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clienteditprofilesection/clienteditprofilescreen.dart';

import '../../../../Core/Widgets/profileavator.dart';
import 'clientProfilescreensection/clientProfilecontroller.dart';

class Clientpersonalinformationscreen extends StatefulWidget {
  const Clientpersonalinformationscreen({super.key});

  @override
  State<Clientpersonalinformationscreen> createState() => _ClientpersonalinformationscreenState();
}

class _ClientpersonalinformationscreenState extends State<Clientpersonalinformationscreen> {
  // Yahan bhi wahi shared (permanent) instance mile ga jo main profile
  // screen ne banaya tha - is liye edit ke baad ye screen bhi khud update ho jayegi.
  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBackground(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSize.height * 0.009),

              /// HEADER
              CustomHeader(
                title: 'personal_info_title'.tr,
                showBackButton: true,
                onBack: () => Get.back(),
              ),

              SizedBox(height: AppSize.height * 0.025),

              /// ---------------- PROFILE HERO CARD ----------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.032),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.primaryColor,
                              theme.primaryColor.withOpacity(0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: ProfileAvatar(radius: AppSize.width * 0.14),
                      ),
                      SizedBox(height: AppSize.height * 0.016),
                      Obx(() => Text(
                        controller.displayUsername,
                        style: TextStyle(
                          color: theme.canvasColor,
                          fontSize: AppSize.width * 0.048,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppSize.height * 0.025),

              /// ---------------- CONTACT INFO CARD ----------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSize.width * 0.045),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSize.width * 0.02),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.person_outline_rounded,
                              color: theme.primaryColor, size: AppSize.width * 0.045),
                        ),
                        SizedBox(width: AppSize.width * 0.03),
                        Text(
                          'personal_info_section_contact'.tr,
                          style: TextStyle(
                            fontSize: AppSize.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: theme.canvasColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSize.height * 0.016),
                    Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
                    SizedBox(height: AppSize.height * 0.014),

                    Obx(() => _infoTile(
                      theme,
                      icon: Icons.badge_outlined,
                      title: 'personal_info_label_name'.tr,
                      value: controller.displayUsername,
                    )),
                    Divider(color: theme.dividerColor.withOpacity(0.1), height: AppSize.height * 0.03),

                    Obx(() => _infoTile(
                      theme,
                      icon: Icons.email_outlined,
                      title: 'personal_info_label_email'.tr,
                      value: controller.displayEmail,
                    )),
                    Divider(color: theme.dividerColor.withOpacity(0.1), height: AppSize.height * 0.03),

                    Obx(() => _infoTile(
                      theme,
                      icon: Icons.phone_outlined,
                      title: 'personal_info_label_phone'.tr,
                      value: controller.displayPhone,
                    )),
                  ],
                ),
              ),

              SizedBox(height: AppSize.height * 0.035),

              /// EDIT BUTTON
              CustomButton(
                title: 'personal_info_btn_edit'.tr,
                leftWidget: const Icon(Icons.mode_edit_outline_rounded, color: Colors.white),
                onTap: () {
                  Get.to(
                        () => Clienteditprofilescreen(),
                    transition: Transition.fade,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
              SizedBox(height: AppSize.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  /// INFO TILE — icon chip + title + value, ek row mein
  Widget _infoTile(ThemeData theme, {required IconData icon, required String title, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSize.width * 0.05, color: theme.canvasColor.withOpacity(0.4)),
        SizedBox(width: AppSize.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppSize.width * 0.028,
                  color: theme.canvasColor.withOpacity(0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSize.height * 0.004),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppSize.width * 0.038,
                  fontWeight: FontWeight.w600,
                  color: theme.canvasColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
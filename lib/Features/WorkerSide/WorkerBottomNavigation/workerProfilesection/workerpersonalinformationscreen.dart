import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Widgets/Button.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/workerProfilesection/workereditprofilesection/workereditprofilescreen.dart';

import '../../../../Core/Widgets/profileavator.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientProfilescreensection/clientProfilecontroller.dart';

class Workerpersonalinformationscreen extends StatelessWidget {
  // SHARED controller - Worker/Client profile screen se already
  // permanent register ho chuki hoti hai jab tak user login hai.
  final ProfileController controller = Get.find<ProfileController>();

  Workerpersonalinformationscreen({super.key});

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
                title: 'worker_personal_info_title'.tr,
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
                          'worker_personal_info_section_contact'.tr,
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
                      title: 'worker_personal_info_full_name_label'.tr,
                      value: controller.displayUsername,
                    )),
                    Divider(color: theme.dividerColor.withOpacity(0.1), height: AppSize.height * 0.03),

                    Obx(() => _infoTile(
                      theme,
                      icon: Icons.email_outlined,
                      title: 'worker_personal_info_email_label'.tr,
                      value: controller.displayEmail,
                    )),
                    Divider(color: theme.dividerColor.withOpacity(0.1), height: AppSize.height * 0.03),

                    Obx(() => _infoTile(
                      theme,
                      icon: Icons.phone_outlined,
                      title: 'worker_personal_info_phone_label'.tr,
                      value: controller.displayPhone,
                    )),
                  ],
                ),
              ),

              SizedBox(height: AppSize.height * 0.025),

              /// ---------------- SKILLS CARD ----------------
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
                            color: const Color(0xff8B5CF6).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.build_outlined,
                              color: const Color(0xff8B5CF6), size: AppSize.width * 0.045),
                        ),
                        SizedBox(width: AppSize.width * 0.03),
                        Text(
                          'worker_personal_info_skills_label'.tr,
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
                    SizedBox(height: AppSize.height * 0.016),

                    Obx(() {
                      if (controller.skills.isEmpty) {
                        return Text(
                          'worker_personal_info_no_skills'.tr,
                          style: TextStyle(
                            color: theme.canvasColor.withOpacity(0.45),
                            fontSize: AppSize.width * 0.033,
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.skills.map((s) => _SkillChip(label: s)).toList(),
                      );
                    }),
                  ],
                ),
              ),

              SizedBox(height: AppSize.height * 0.035),

              /// EDIT BUTTON
              CustomButton(
                title: 'worker_personal_info_edit_button'.tr,
                leftWidget: const Icon(Icons.mode_edit_outline_rounded, color: Colors.white),
                onTap: () {
                  Get.to(
                        () => Workereditprofilescreen(),
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

/// SKILL CHIP (READ ONLY)
class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

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
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontWeight: FontWeight.w600,
          fontSize: AppSize.width * 0.033,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/Button.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';
import 'package:helper_app2/Core/Widgets/Textfield.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/workerProfilesection/workereditprofilesection/skillchip.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientProfilescreensection/clientProfilecontroller.dart';

class Workereditprofilescreen extends StatefulWidget {
  Workereditprofilescreen({super.key});

  @override
  State<Workereditprofilescreen> createState() =>
      _WorkereditprofilescreenState();
}

class _WorkereditprofilescreenState extends State<Workereditprofilescreen> {
  // Worker profile screen se already permanent register ho chuki hoti hai
  final ProfileController controller = Get.find<ProfileController>();

  String formatPhoneNumber(String phone) {
    phone = phone.trim();
    phone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (phone.startsWith('+')) {
      return phone;
    }
    if (phone.startsWith('00')) {
      return '+${phone.substring(2)}';
    }
    return phone;
  }

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    // Current profile data se fields prefill karo
    nameController.text = controller.editableUsername;
    phoneController.text = controller.phone.value;
    emailController = TextEditingController(
      text: controller.email.value.isNotEmpty
          ? controller.email.value
          : 'worker_edit_profile_no_email'.tr,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _showImageSourceSheet() {
    final theme = Theme.of(context);
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.dividerColor.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            _sheetTile(
              theme: theme,
              icon: Icons.camera_alt_rounded,
              label: 'worker_edit_profile_take_photo'.tr,
              onTap: () async {
                Get.back();
                await controller.pickImageFromCamera();
              },
            ),
            _sheetTile(
              theme: theme,
              icon: Icons.photo_library_rounded,
              label: 'worker_edit_profile_choose_gallery'.tr,
              onTap: () async {
                Get.back();
                await controller.pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetTile({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.primaryColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.primaryColor, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(color: theme.canvasColor, fontWeight: FontWeight.w600),
      ),
    );
  }

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

              CustomHeader(
                title: 'worker_edit_profile_title'.tr,
                showBackButton: true,
                onBack: () => Get.back(),
              ),

              SizedBox(height: AppSize.height * 0.025),

              /// ---------------- PROFILE PHOTO CARD ----------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.03),
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
                      Stack(
                        clipBehavior: Clip.none,
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
                            child: Obx(() {
                              final img = controller.avatarImageOrNull;
                              return CircleAvatar(
                                radius: AppSize.width * 0.14,
                                backgroundColor: theme.dividerColor.withOpacity(0.2),
                                backgroundImage: img,
                                child: img == null
                                    ? Icon(
                                  Icons.person_rounded,
                                  size: AppSize.width * 0.14,
                                  color: theme.canvasColor.withOpacity(0.4),
                                )
                                    : null,
                              );
                            }),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showImageSourceSheet,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: theme.cardColor, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primaryColor.withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSize.height * 0.014),
                      GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Text(
                          'worker_edit_profile_change_photo'.tr,
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: AppSize.width * 0.035,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: AppSize.height * 0.025),

              /// ---------------- PERSONAL INFO CARD ----------------
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
                          child: Icon(Icons.person_outline_rounded, color: theme.primaryColor, size: AppSize.width * 0.045),
                        ),
                        SizedBox(width: AppSize.width * 0.03),
                        Text(
                          'worker_edit_profile_section_personal'.tr,
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
                    SizedBox(height: AppSize.height * 0.02),

                    CustomTextField(
                      borderRadius: AppSize.height*0.06,
                      borderColor: Colors.grey,
                      controller: nameController,
                      hintText: 'worker_edit_profile_hint_full_name'.tr,
                    ),
                    SizedBox(height: AppSize.height * 0.016),

                    Opacity(
                      opacity: 0.55,
                      child: IgnorePointer(
                        child: CustomTextField(
                          borderRadius: AppSize.height * 0.06,
                          borderColor: Colors.grey,
                          controller: emailController,
                          hintText: 'worker_edit_profile_hint_email'.tr,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSize.height * 0.008),
                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, size: AppSize.width * 0.032, color: theme.canvasColor.withOpacity(0.45)),
                        SizedBox(width: AppSize.width * 0.015),
                        Expanded(
                          child: Text(
                            'worker_edit_profile_email_locked_note'.tr,
                            style: TextStyle(
                              fontSize: AppSize.width * 0.028,
                              color: theme.canvasColor.withOpacity(0.45),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSize.height * 0.016),

                    CustomTextField(
                      borderRadius: AppSize.height*0.06,
                      borderColor: Colors.grey,
                      controller: phoneController,
                      hintText: 'worker_edit_profile_hint_phone'.tr,
                      keyboardType: TextInputType.phone,
                    ),
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
                          child: Icon(Icons.build_outlined, color: const Color(0xff8B5CF6), size: AppSize.width * 0.045),
                        ),
                        SizedBox(width: AppSize.width * 0.03),
                        Text(
                          'worker_edit_profile_skills_label'.tr,
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
                    SizedBox(height: AppSize.height * 0.018),

                    /// Existing skills as removable chips
                    Obx(() {
                      if (controller.skills.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.008),
                          child: Text(
                            'worker_edit_profile_no_skills_yet'.tr,
                            style: TextStyle(
                              fontSize: AppSize.width * 0.033,
                              color: theme.canvasColor.withOpacity(0.45),
                            ),
                          ),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.skills
                            .map(
                              (skill) => Workerskillchip(
                            text: skill,
                            onRemove: () => controller.removeSkill(skill),
                          ),
                        )
                            .toList(),
                      );
                    }),

                    SizedBox(height: AppSize.height * 0.02),

                    /// Add new skill row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            borderRadius: AppSize.height*0.06,
                            borderColor: Colors.grey,
                            controller: controller.skillTextController,
                            hintText: 'worker_edit_profile_hint_add_skill'.tr,
                          ),
                        ),
                        SizedBox(width: AppSize.width * 0.025),
                        GestureDetector(
                          onTap: controller.addSkill,
                          child: Container(
                            height: AppSize.height * 0.058,
                            width: AppSize.height * 0.058,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add_rounded, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSize.height * 0.035),

              /// ---------------- BUTTONS ----------------
              Obx(
                    () => Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        title: 'worker_edit_profile_cancel_button'.tr,
                        onTap: controller.isUpdating.value
                            ? () {}
                            : () {
                          controller.discardPickedImage();
                          Get.back();
                        },
                        backgroundColor: theme.scaffoldBackgroundColor,
                        textColor: theme.canvasColor,
                        borderColor: theme.dividerColor,
                      ),
                    ),
                    SizedBox(width: AppSize.width * 0.04),
                    Expanded(
                      child: CustomButton(
                        title: controller.isUpdating.value
                            ? 'worker_edit_profile_saving_button'.tr
                            : 'worker_edit_profile_save_button'.tr,
                        onTap: controller.isUpdating.value
                            ? () {}
                            : () {
                          controller.updateProfile(
                            newUsername: nameController.text,
                            newPhone: formatPhoneNumber(
                              phoneController.text,
                            ),
                            skills: controller.skills.toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSize.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}
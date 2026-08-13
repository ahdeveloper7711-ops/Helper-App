import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/Button.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';
import 'package:helper_app2/Core/Widgets/Textfield.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';

import '../../../../../Core/Widgets/ImagePickerBottomsheet.dart';
import '../../../../../Core/Widgets/profileavator.dart';
import '../clientProfilescreensection/clientProfilecontroller.dart';

class Clienteditprofilescreen extends StatefulWidget {
  Clienteditprofilescreen({super.key});

  @override
  State<Clienteditprofilescreen> createState() =>
      _ClienteditprofilescreenState();
}

class _ClienteditprofilescreenState extends State<Clienteditprofilescreen> {
  // Shared/permanent instance - Main Profile screen se hi banaya gaya tha
  final controller = Get.find<ProfileController>();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  // Email edit nahi hota (backend update API email accept hi nahi karti),
  // is liye ye field sirf read-only display ke liye hai.
  late final TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    // Current profile data se fields ko prefill karo (professional apps jaisa UX)
    nameController = TextEditingController(text: controller.editableUsername);
    phoneController = TextEditingController(text: controller.phone.value);
    emailController = TextEditingController(
      text: controller.email.value.isNotEmpty
          ? controller.email.value
          : 'edit_profile_email_fallback'.tr,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _onCancel() {
    controller
        .discardPickedImage(); // agar image select ki thi bina save kiye, discard karo
    Get.back();
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
                title: 'edit_profile_title'.tr,
                showBackButton: true,
                onBack: _onCancel,
              ),

              SizedBox(height: AppSize.height * 0.025),

              /// ---------------- PROFILE PHOTO CARD ----------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.03),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.15),
                  ),
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
                            child: ProfileAvatar(radius: AppSize.width * 0.14),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                ImagePickerBottomSheet.show(
                                  onCameraTap: controller.pickImageFromCamera,
                                  onGalleryTap: controller.pickImageFromGallery,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.primaryColor,
                                      theme.primaryColor.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.cardColor,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primaryColor.withOpacity(
                                        0.35,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSize.height * 0.014),
                      GestureDetector(
                        onTap: () {
                          ImagePickerBottomSheet.show(
                            onCameraTap: controller.pickImageFromCamera,
                            onGalleryTap: controller.pickImageFromGallery,
                          );
                        },
                        child: Text(
                          'edit_profile_change_photo'.tr,
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
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.15),
                  ),
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
                          child: Icon(
                            Icons.person_outline_rounded,
                            color: theme.primaryColor,
                            size: AppSize.width * 0.045,
                          ),
                        ),
                        SizedBox(width: AppSize.width * 0.03),
                        Text(
                          'edit_profile_section_personal'.tr,
                          style: TextStyle(
                            fontSize: AppSize.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: theme.canvasColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSize.height * 0.016),
                    Divider(
                      color: theme.dividerColor.withOpacity(0.15),
                      height: 1,
                    ),
                    SizedBox(height: AppSize.height * 0.02),

                    CustomTextField(
                      borderColor: Colors.grey,
                      borderRadius: AppSize.height * 0.06,
                      controller: nameController,
                      hintText: 'edit_profile_hint_name'.tr,
                    ),
                    SizedBox(height: AppSize.height * 0.016),

                    Opacity(
                      opacity: 0.55,
                      child: IgnorePointer(
                        child: CustomTextField(
                          borderRadius: AppSize.height * 0.06,
                          borderColor: Colors.grey,
                          controller: emailController,
                          hintText: 'edit_profile_hint_email'.tr,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSize.height * 0.008),
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: AppSize.width * 0.032,
                          color: theme.canvasColor.withOpacity(0.45),
                        ),
                        SizedBox(width: AppSize.width * 0.015),
                        Expanded(
                          child: Text(
                            'edit_profile_email_locked_note'.tr,
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
                      borderColor: Colors.grey,
                      borderRadius: AppSize.height * 0.06,
                      controller: phoneController,
                      hintText: 'edit_profile_hint_phone'.tr,
                      keyboardType: TextInputType.phone,
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
                        title: 'edit_profile_btn_cancel'.tr,
                        onTap: controller.isUpdating.value ? () {} : _onCancel,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        textColor: theme.canvasColor,
                        borderColor: theme.dividerColor,
                      ),
                    ),
                    SizedBox(width: AppSize.width * 0.04),
                    Expanded(
                      child: CustomButton(
                        title: controller.isUpdating.value
                            ? 'edit_profile_btn_saving'.tr
                            : 'edit_profile_btn_save'.tr,
                        onTap: controller.isUpdating.value
                            ? () {}
                            : () => controller.updateProfile(
                                newUsername: nameController.text,
                                newPhone: phoneController.text,
                              ),
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

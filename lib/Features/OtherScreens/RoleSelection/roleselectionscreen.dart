import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Backbutton.dart';
import 'package:helper_app2/Features/AuthScreens/loginsignupcontroller/Login&SignUpScreen.dart';
import 'package:helper_app2/Features/OtherScreens/RoleSelection/rolecontroller.dart';
import '../../../Core/Apis/sessionmanager.dart';
import '../../../Core/Widgets/Background.dart';
import '../../../Core/Widgets/Button.dart';
import '../../../Core/Widgets/MediaqueryHelperfile.dart';

class RoleSelectionScreen extends StatelessWidget {
  RoleSelectionScreen({super.key});

  final RoleController controller = Get.put(RoleController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBackground(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.06),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: AppSize.height * 0.02),
              Align(
                  alignment: Alignment.centerLeft,
                  child: CustomBackButton()),
              SizedBox(height: AppSize.height * 0.04),

              /// TITLE
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${'role_selection_title_line1'.tr}\n',
                              style: TextStyle(
                                fontSize: AppSize.width * 0.07,
                                fontWeight: FontWeight.bold,
                                color: theme.canvasColor,
                                height: 1.25,
                              ),
                            ),
                            TextSpan(
                              text: 'role_selection_title_line2'.tr,
                              style: TextStyle(
                                fontSize: AppSize.width * 0.07,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: AppSize.height * 0.02),
                    Image.asset(
                      "assets/images/roleselectionimage2.png",
                      height: AppSize.height * 0.09,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSize.height * 0.015),

              /// IMAGE
              Container(
                padding: EdgeInsets.all(AppSize.width * 0.02),
                child: Image.asset(
                  "assets/images/roleselectionimage.png",
                  height: AppSize.height * 0.42,
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: AppSize.height * 0.015),

              /// ROLE BUTTONS
              Obx(
                    () => Row(
                  children: [
                    _buildRoleButton(
                      theme: theme,
                      label: 'role_selection_post_job'.tr,
                      icon: Icons.add_circle_outline,
                      isSelected: controller.selectedRole.value == "job",
                      onTap: () => controller.selectRole("job"),
                    ),
                    SizedBox(width: AppSize.width * 0.035),
                    _buildRoleButton(
                      theme: theme,
                      label: 'role_selection_find_work'.tr,
                      icon: Icons.search_rounded,
                      isSelected: controller.selectedRole.value == "work",
                      onTap: () => controller.selectRole("work"),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppSize.height * 0.035),

              /// CONTINUE BUTTON
              CustomButton(
                title: 'role_selection_continue'.tr,
                onTap: () {
                  if (!controller.isSelected) {
                    Get.snackbar(
                      'role_selection_error_title'.tr,
                      'role_selection_error_message'.tr,
                      backgroundColor: theme.cardColor,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: EdgeInsets.symmetric(
                        horizontal: AppSize.width * 0.05,
                        vertical: AppSize.height * 0.02,
                      ),
                      borderRadius: 14,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSize.height * 0.018,
                        horizontal: AppSize.height * 0.02,
                      ),
                      colorText: theme.canvasColor,
                      icon: Icon(Icons.error_outline, color: theme.primaryColor),
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }
                  SessionManager.saveTempRole(controller.selectedRole.value);
                  Get.to(() => LoginSignupScreen(),
                    transition: Transition.fadeIn,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
              SizedBox(height: AppSize.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  /// REUSABLE ROLE BUTTON — clean, minimal, professional, no tap-flicker/blink
  Widget _buildRoleButton({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.08) : theme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor.withOpacity(0.25),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            splashColor: theme.primaryColor.withOpacity(0.06),
            highlightColor: theme.primaryColor.withOpacity(0.04),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.02),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: Icon(
                      icon,
                      key: ValueKey(isSelected),
                      color: isSelected ? theme.primaryColor : theme.canvasColor.withOpacity(0.5),
                      size: AppSize.height * 0.026,
                    ),
                  ),
                  SizedBox(height: AppSize.height * 0.008),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      color: isSelected ? theme.primaryColor : theme.canvasColor.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      fontSize: AppSize.height * 0.0145,
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/WorkerProfilesection/Workersettingsection/Workersettingscreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/workerProfilesection/workerFavouratesection/workerfavouritesscreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/workerProfilesection/workerHelpsupportsection/workerhelpandsupportscreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/workerProfilesection/workerWalletsection/workerwalletscreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/workerProfilesection/workerpersonalinformationscreen.dart';
import '../../../../../Core/Apis/onlinestatuscontroller.dart';
import '../../../../../Core/AppTheme/themecontroller.dart';
import '../../../../../Core/Widgets/Background.dart';
import '../../../../../Core/Widgets/Button.dart';
import '../../../../../Core/Widgets/Customdiologe/CustomDiologe.dart';
import '../../../../../Core/Widgets/Customtile.dart';
import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';
import '../../../../../Core/Widgets/iconcircle.dart';
import '../../../../../Core/Widgets/profileavator.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientProfilescreensection/clientProfilecontroller.dart';

import '../../../../ClientsSide/ClientBottomNavigation/clientProfilesection/clientsettingsection/settingcontroller.dart';

class Workerprofilescreen extends StatefulWidget {
  Workerprofilescreen({super.key});

  @override
  State<Workerprofilescreen> createState() => _WorkerprofilescreenState();
}

class _WorkerprofilescreenState extends State<Workerprofilescreen> {
  final ProfileController controller = Get.isRegistered<ProfileController>()
      ? Get.find<ProfileController>()
      : Get.put(ProfileController(), permanent: true);

  final SettingsController settingsController =
      Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController(), permanent: true);

  final ThemeController themeController = Get.find();

  final OnlineStatusController onlineStatusController =
      Get.isRegistered<OnlineStatusController>()
      ? Get.find<OnlineStatusController>()
      : Get.put(OnlineStatusController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBackground(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.05),
          child: Column(
            children: [
              CustomHeader(
                title: 'worker_profile_title'.tr,
                rightWidget: Row(
                  children: [
                    // ONLINE / OFFLINE BADGE
                    Obx(() {
                      final isOnline = onlineStatusController.isOnline.value;
                      final isUpdating =
                          onlineStatusController.isUpdating.value;
                      return GestureDetector(
                        onTap: onlineStatusController.toggleOnlineStatus,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (isOnline
                                        ? const Color(0xff1DBF73)
                                        : theme.canvasColor)
                                    .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              if (isUpdating)
                                SizedBox(
                                  height: 10,
                                  width: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: isOnline
                                        ? const Color(0xff1DBF73)
                                        : theme.canvasColor.withOpacity(0.5),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: isOnline
                                      ? const Color(0xff1DBF73)
                                      : theme.canvasColor.withOpacity(0.5),
                                ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline
                                    ? 'worker_profile_online'.tr
                                    : 'worker_profile_offline'.tr,
                                style: TextStyle(
                                  color: isOnline
                                      ? const Color(0xff1DBF73)
                                      : theme.canvasColor.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(width: AppSize.width * 0.01),
                    // DARK MODE TOGGLE
                    GestureDetector(
                      onTap: () => themeController.toggleTheme(),
                      child: IconCircle(
                        icon: Get.isDarkMode
                            ? Icons.light_mode_outlined
                            : Icons.dark_mode_outlined,
                        height: AppSize.height * 0.05,
                        width: AppSize.height * 0.05,
                        iconSize: AppSize.height * 0.025,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSize.height * 0.03),

              /// PROFILE IMAGE + NAME + ROLE
              Obx(() {
                return Column(
                  children: [
                    Stack(
                      children: [
                        ProfileAvatar(radius: AppSize.height * 0.072),
                        if (controller.isLoading.value)
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                radius: AppSize.height * 0.072,
                                backgroundColor: Colors.black.withOpacity(0.25),
                                child: const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      controller.displayUsername,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),
                    Text(
                      controller.displayRole,
                      style: TextStyle(
                        color: theme.canvasColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: AppSize.height * 0.03),

              /// TILES
              _tile(
                context,
                title: 'worker_profile_personal_info'.tr,
                icon: Icons.person,
                onTap: () => Get.to(() => Workerpersonalinformationscreen(),transition: Transition.fade),
              ),
              _tile(
                context,
                title: 'worker_profile_wallet'.tr,
                icon: Icons.wallet,
                onTap: () => Get.to(() => Workerwalletscreen(),transition: Transition.fade),
              ),
              _tile(
                context,
                title: 'worker_profile_favourites'.tr,
                icon: Icons.favorite,
                iconColor: Colors.red,
                onTap: () => Get.to(() => Workerfavouritesscreen(),transition: Transition.fade),
              ),

              Obx(
                () => _tile(
                  context,
                  title: 'worker_profile_location'.tr,
                  subtitle: 'worker_profile_location_sub'.tr,
                  icon: Icons.location_on,
                  iconColor: theme.primaryColor,
                  isSwitch: true,
                  switchValue: controller.locationEnabled.value,
                  onSwitch: controller.toggleLocation,
                ),
              ),

              _tile(
                context,
                title: 'worker_profile_settings'.tr,
                icon: Icons.settings,
                onTap: () => Get.to(() => Workersettingscreen(),transition: Transition.fade),
              ),
              _tile(
                context,
                title: 'worker_profile_help_support'.tr,
                icon: Icons.help,
                onTap: () => Get.to(() => Workerhelpandsupportscreen(),transition: Transition.fade),
              ),

              SizedBox(height: AppSize.height * 0.02),

              /// LOGOUT
              CustomButton(
                title: 'worker_profile_logout'.tr,
                onTap: () => CustomAlertDialog.show(
                  context: context,
                  title: 'worker_profile_logout_title'.tr,
                  subtitle: 'worker_profile_logout_subtitle'.tr,
                  onConfirm: () {
                    settingsController.logout();
                  },
                ),
                borderColor: Colors.redAccent,
                textColor: Colors.redAccent,
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: AppSize.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? subtitle,
    Color? iconColor,
    bool isSwitch = false,
    bool? switchValue,
    ValueChanged<bool>? onSwitch,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomTile(
        title: title,
        subtitle: subtitle,
        backgroundColor: Colors.transparent,
        borderColor: theme.dividerColor.withOpacity(0.5),
        titleColor: theme.canvasColor,
        titleWeight: FontWeight.bold,
        titleSize: AppSize.height * 0.022,
        leading: IconCircle(
          icon: icon,
          iconColor: iconColor ?? theme.canvasColor,
        ),
        trailing: isSwitch
            ? null
            : Icon(Icons.arrow_forward_ios, size: 16, color: theme.canvasColor),
        switchValue: isSwitch ? switchValue : null,
        onSwitchChanged: isSwitch ? onSwitch : null,
        onTap: onTap,
      ),
    );
  }
}

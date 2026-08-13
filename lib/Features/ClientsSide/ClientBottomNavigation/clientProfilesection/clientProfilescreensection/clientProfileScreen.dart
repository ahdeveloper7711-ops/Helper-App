import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientFavouratesection/clientfavouritesscreen.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientWalletsection/clientwalletscreen.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientpersonalinformationscreen.dart';
import '../../../../../Core/Apis/onlinestatuscontroller.dart';
import '../../../../../Core/AppTheme/themecontroller.dart';
import '../../../../../Core/Widgets/Background.dart';
import '../../../../../Core/Widgets/Button.dart';
import '../../../../../Core/Widgets/Customdiologe/CustomDiologe.dart';
import '../../../../../Core/Widgets/Customtile.dart';
import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';
import '../../../../../Core/Widgets/iconcircle.dart';
import '../../../../../Core/Widgets/profileavator.dart';
import '../clientHelpsupportsection/clienthelpandsupportscreen.dart';
import '../clientsettingsection/clientsettingscreen.dart';
import '../clientsettingsection/settingcontroller.dart';
import 'clientProfilecontroller.dart';

class Clientprofilescreen extends StatefulWidget {
  Clientprofilescreen({super.key});

  @override
  State<Clientprofilescreen> createState() => _ClientprofilescreenState();
}

class _ClientprofilescreenState extends State<Clientprofilescreen> {
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
                title: 'client_profile_title'.tr,
                rightWidget: Row(
                  children: [
                    // ONLINE / OFFLINE BADGE — ab shared controller (Obx)
                    // se reactive hai, Home screen ke sath sync mein.
                    Obx(() {
                      final isOnline = onlineStatusController.isOnline.value;
                      final isUpdating = onlineStatusController.isUpdating.value;
                      return GestureDetector(
                        onTap: onlineStatusController.toggleOnlineStatus,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (isOnline ? const Color(0xff1DBF73) : theme.canvasColor)
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
                                    color: isOnline ? const Color(0xff1DBF73) : theme.canvasColor.withOpacity(0.5),
                                  ),
                                )
                              else
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: isOnline ? const Color(0xff1DBF73) : theme.canvasColor.withOpacity(0.5),
                                ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline ? 'client_profile_online'.tr : 'client_profile_offline'.tr,
                                style: TextStyle(
                                  color: isOnline ? const Color(0xff1DBF73) : theme.canvasColor.withOpacity(0.6),
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

              /// PROFILE IMAGE + NAME + ROLE (backend se, reactive)
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
                title: 'client_profile_personal_info'.tr,
                icon: Icons.person,
                onTap: () => Get.to(() => Clientpersonalinformationscreen(),transition: Transition.fade),
              ),
              _tile(
                context,
                title: 'client_profile_wallet'.tr,
                icon: Icons.wallet,
                onTap: () => Get.to(() => Clientwalletscreen(),transition: Transition.fade),
              ),
              _tile(
                context,
                title: 'client_profile_favourites'.tr,
                icon: Icons.favorite,
                iconColor: Colors.red,
                onTap: () => Get.to(() => Clientfavouritesscreen(),transition: Transition.fade),
              ),

              Obx(
                    () => _tile(
                  context,
                  title: 'client_profile_location'.tr,
                  subtitle: 'client_profile_location_subtitle'.tr,
                  icon: Icons.location_on,
                  iconColor: theme.primaryColor,
                  isSwitch: true,
                  switchValue: controller.locationEnabled.value,
                  onSwitch: controller.toggleLocation,
                ),
              ),

              _tile(
                context,
                title: 'client_profile_settings'.tr,
                icon: Icons.settings,
                onTap: () => Get.to(() => Clientsettingscreen(),transition: Transition.fade),
              ),
              _tile(
                context,
                title: 'client_profile_help_support'.tr,
                icon: Icons.help,
                onTap: () => Get.to(() => ClientHelpAndSupportScreen(),transition: Transition.fade),
              ),

              SizedBox(height: AppSize.height * 0.02),

              CustomButton(
                title: 'client_profile_logout'.tr,
                onTap: () => CustomAlertDialog.show(
                  context: context,
                  title: 'client_profile_logout'.tr,
                  subtitle: 'client_profile_logout_confirm'.tr,
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
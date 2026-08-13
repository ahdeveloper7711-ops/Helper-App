import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/Customtile.dart';
import 'package:helper_app2/Core/Widgets/MediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Widgets/iconcircle.dart';
import 'package:helper_app2/Features/SharedScreen/Notificationsection/NotificationScreen.dart';
import '../../../../../Core/Apis/roleservice.dart';
import '../../../../../Core/Apis/sessionmanager.dart';
import '../../../../../Core/AppTheme/themecontroller.dart';
import '../../../../../Core/Widgets/AppLoader.dart';
import '../../../../../Core/Widgets/Backbutton.dart';
import '../../../../AuthScreens/loginsignupcontroller/Login&SignUpScreen.dart';
import '../../../../AuthScreens/loginsignupcontroller/controllercleanup.dart';
import '../../../../SharedScreen/Notificationsection/notificationcontroller.dart';
import '../clientProfilescreensection/Languagebottomsheet.dart';
import '../clientProfilescreensection/clientProfilecontroller.dart';
import 'settingcontroller.dart';

class Clientsettingscreen extends StatefulWidget {
  Clientsettingscreen({super.key});

  @override
  State<Clientsettingscreen> createState() => _ClientsettingscreenState();
}

class _ClientsettingscreenState extends State<Clientsettingscreen> {
  final c = Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController(), permanent: true);

  final ThemeController themeController = Get.find();

  // Theme control ke liye
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.05),
          child: Column(
            children: [
              SizedBox(height: AppSize.height * 0.02),
              Row(
                children: [
                  const CustomBackButton(),
                  SizedBox(width: AppSize.width * 0.03),
                  Text(
                    'settings_title'.tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).canvasColor, // Dynamic color
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.height * 0.03),

              Obx(
                () => _tile(
                  context,
                  title: 'settings_lang_title'.tr,
                  subtitle: Get.isRegistered<ProfileController>()
                      ? Get.find<ProfileController>().selectedLanguage.value
                      : c.selectedLanguage.value,
                  icon: Icons.language,
                  onTap: () => Get.to(
                    () => const LanguageScreen2(),
                    transition: Transition.fade,
                    duration: const Duration(milliseconds: 500),
                  ),
                ),
              ),

              // NOTIFICATIONS (reactive: badge count badalta hai)
              // NOTIFICATIONS (reactive: badge count badalta hai)
              // NOTIFICATIONS (reactive: shared NotificationController se live unread count)
              Obx(() {
                final notifController = Get.isRegistered<NotificationController>()
                    ? Get.find<NotificationController>()
                    : Get.put(NotificationController(), permanent: true);

                final unreadCount = notifController.unreadCount;

                return _tile(
                  context,
                  onTap: () async {
                    await Get.to(
                          () => const NotificationScreen(),
                      transition: Transition.fade,
                      duration: const Duration(milliseconds: 500),
                    );
                    // Wapas aane par list refresh, taake mark-as-read ka asar turant nazar aaye
                    notifController.fetchNotifications(isRefresh: true);
                  },
                  title: 'settings_notifications_title'.tr,
                  icon: Icons.notifications,
                  trailingWidget: _badge(context, unreadCount),
                );
              }),

              // DARK MODE (Theme Switcher)
              _tile(
                context,
                title: 'settings_dark_mode_title'.tr,
                subtitle: 'settings_dark_mode_subtitle'.tr,
                icon: Icons.dark_mode,
                isSwitch: true,
                switchValue: Get.isDarkMode,
                // Current theme check
                onSwitch: (_) => themeController.toggleTheme(),
              ),

              // BECOME WORKER (reactive: switch hone ke baad turant update)
              Obx(
                () => _tile(
                  context,
                  onTap: () => RoleService.performRoleSwitch(),                  // Direct tap par bhi call kar sakte hain
                  title: 'settings_become_worker_title'.tr,
                  icon: Icons.person,
                  trailingWidget: _smallSwitch(context, c.isClient.value),
                ),
              ),

              const SizedBox(height: 20),
              _infoBox(context),
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
    VoidCallback? onTap,
    bool isSwitch = false,
    bool? switchValue,
    ValueChanged<bool>? onSwitch,
    Widget? trailingWidget,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSize.height * 0.01),
      child: CustomTile(
        title: title,
        subtitle: subtitle,
        backgroundColor: Colors.transparent,
        borderColor: Theme.of(context).dividerColor.withOpacity(0.2),
        // Dynamic Border
        titleColor: Theme.of(context).canvasColor,
        // Dynamic Text Color
        titleWeight: FontWeight.bold,
        titleSize: AppSize.height * 0.018,
        leading: IconCircle(icon: icon),
        trailing:
            trailingWidget ??
            (isSwitch
                ? null
                : Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).canvasColor,
                    size: 16,
                  )),
        switchValue: isSwitch ? switchValue : null,
        onSwitchChanged: isSwitch ? onSwitch : null,
        onTap: onTap,
      ),
    );
  }

  Widget _smallSwitch(BuildContext context, bool value) {
    return GestureDetector(
      onTap: () async {
        // Jab user switch button dabaye, toh controller ka function chale
        await c.switchUserRole();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'settings_switch_btn'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (count > 0)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              "$count",
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        const SizedBox(width: 10),
        Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: Theme.of(context).canvasColor,
        ),
      ],
    );
  }

  Widget _infoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          _infoRow(
            'settings_info_version_key'.tr,
            'settings_info_version_val'.tr,
          ),
          const Divider(),
          _infoRow(
            'settings_info_status_key'.tr,
            'settings_info_status_val'.tr,
          ),
          const Divider(),
          _infoRow(
            'settings_info_security_key'.tr,
            'settings_info_security_val'.tr,
          ),
        ],
      ),
    );
  }
}

class _infoRow extends StatelessWidget {
  final String a, b;

  const _infoRow(this.a, this.b);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(a, style: TextStyle(color: Theme.of(context).canvasColor)),
        Text(
          b,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).canvasColor,
          ),
        ),
      ],
    );
  }

  Future<void> logout() async {
    AppLoader.show(text: 'settings_logout_loader'.tr);
    try {
      await SessionManager.clearSession();
      print("🚪 SUCCESS: User logged out");

      // FIX: agli login ke liye controllers bhi clear kar do
      ControllerCleanup.resetUserScopedControllers();

      AppLoader.hide();
      await Future.delayed(const Duration(milliseconds: 150));
      Get.offAll(() => LoginSignupScreen());
    } catch (e) {
      AppLoader.hide();
      print("❌ LOGOUT ERROR: $e");
      Get.snackbar(
        'settings_logout_error_title'.tr,
        'settings_logout_error_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(
          vertical: AppSize.height * 0.01,
          horizontal: AppSize.height * 0.01,
        ),
      );
    }
  }
}

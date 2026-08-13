import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/Customtile.dart';
import 'package:helper_app2/Core/Widgets/MediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Widgets/iconcircle.dart';
import 'package:helper_app2/Features/SharedScreen/Notificationsection/NotificationScreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/workerProfilesection/workerProfilescreensection/workerLanguagebottomsheet.dart';
import '../../../../../Core/Apis/roleservice.dart';
import '../../../../../Core/AppTheme/themecontroller.dart';
import '../../../../../Core/Widgets/Backbutton.dart';
import '../../../../ClientsSide/ClientBottomNavigation/clientProfilesection/clientsettingsection/settingcontroller.dart';
import '../../../../SharedScreen/Notificationsection/notificationcontroller.dart';

class Workersettingscreen extends StatefulWidget {
  Workersettingscreen({super.key});

  @override
  State<Workersettingscreen> createState() => _WorkersettingscreenState();
}

class _WorkersettingscreenState extends State<Workersettingscreen> {
  final c = Get.isRegistered<SettingsController>()
      ? Get.find<SettingsController>()
      : Get.put(SettingsController(), permanent: true);

  final ThemeController themeController = Get.find();

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
                    'worker_settings_title'.tr,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).canvasColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSize.height * 0.03),

              // LANGUAGE (reactive) — ab Workerlanguagebottomsheet.currentLanguage
              // se aata hai, koi direct controller import nahi karna pada.
              Obx(
                () => _tile(
                  context,
                  title: 'worker_settings_language'.tr,
                  subtitle: Workerlanguagescreen2.currentLanguage,
                  icon: Icons.language,
                  onTap: Workerlanguagescreen2.show,
                ),
              ),
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

              _tile(
                context,
                title: 'worker_settings_dark_mode'.tr,
                subtitle: 'worker_settings_dark_mode_sub'.tr,
                icon: Icons.dark_mode,
                isSwitch: true,
                switchValue: Get.isDarkMode,
                onSwitch: (_) => themeController.toggleTheme(),
              ),

              Obx(
                () => _tile(
                  context,
                  onTap: () => RoleService.performRoleSwitch(),                  title: 'worker_settings_become_client'.tr,
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
        titleColor: Theme.of(context).canvasColor,
        titleWeight: FontWeight.bold,
        titleSize: AppSize.height * 0.0179,
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
        await c.switchUserRole();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'worker_settings_switch'.tr,
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
            'worker_settings_app_version'.tr,
            'worker_settings_version_val'.tr,
          ),
          const Divider(),
          _infoRow(
            'worker_settings_acc_status'.tr,
            'worker_settings_verified'.tr,
          ),
          const Divider(),
          _infoRow(
            'worker_settings_security'.tr,
            'worker_settings_security_val'.tr,
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
}

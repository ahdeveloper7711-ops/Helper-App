import 'package:flutter/material.dart';
import 'package:helper_app2/Core/Widgets/Backbutton.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/MediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Widgets/iconcircle.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notificationcontroller.dart';
import 'notificationmodel.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController _notifController = Get.put(
    NotificationController(),
  );

  bool push = true, email = true, sms = false, sound = true;
  int tab = 0;

  @override
  void initState() {
    super.initState();
    _notifController.fetchNotifications();
    _checkPushSettings();
  }

  Future<void> _checkPushSettings() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .getNotificationSettings();
    setState(() {
      push =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
    });
  }

  Future<void> _togglePushNotifications(bool value) async {
    setState(() {
      push = value;
    });

    if (value) {
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(alert: true, badge: true, sound: true);
      setState(() {
        push = settings.authorizationStatus == AuthorizationStatus.authorized;
      });
    } else {
      print("🔕 Push notifications disabled locally.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.05),
              child: Column(
                children: [
                  SizedBox(height: AppSize.height * 0.02),
                  Obx(() => _header(theme)),
                  SizedBox(height: AppSize.height * 0.028),
                  Obx(() => _tabBar(theme)),
                  SizedBox(height: AppSize.height * 0.025),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.03),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: ValueKey(tab),
                        child: tab == 0
                            ? Obx(() => _inbox(theme))
                            : _settings(theme),
                      ),
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

  // ==========================================================
  // HEADER
  // ==========================================================
  Widget _header(ThemeData theme) {
    return Row(
      children: [
        const CustomBackButton(),
        SizedBox(width: AppSize.width * 0.03),
        Expanded(
          child: Text(
            'notification_screen_title'.tr,
            style: TextStyle(
              fontFamily: "pb",
              fontSize: AppSize.textPercent(0.052),
              fontWeight: FontWeight.bold,
              color: theme.canvasColor,
            ),
          ),
        ),
        if (tab == 0 && _notifController.unreadCount > 0)
          GestureDetector(
            onTap: () => _notifController.markAllAsRead(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.width * 0.03,
                vertical: AppSize.height * 0.009,
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.done_all_rounded,
                    size: AppSize.textPercent(0.038),
                    color: theme.primaryColor,
                  ),
                  SizedBox(width: AppSize.width * 0.012),
                  Text(
                    'notification_screen_mark_all_read'.tr,
                    style: TextStyle(
                      fontFamily: "pb",
                      fontSize: AppSize.textPercent(0.026),
                      fontWeight: FontWeight.w600,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================
  // TAB BAR
  // ==========================================================
  Widget _tabBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          _tab(
            'notification_screen_tab_inbox'.tr,
            Icons.inbox_rounded,
            0,
            theme,
          ),
          _tab(
            'notification_screen_tab_settings'.tr,
            Icons.tune_rounded,
            1,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _tab(String title, IconData icon, int index, ThemeData theme) {
    final active = tab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.014),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.78),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            borderRadius: BorderRadius.circular(25),
            boxShadow: active
                ? [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppSize.textPercent(0.038),
                color: active
                    ? Colors.white
                    : theme.canvasColor.withOpacity(0.55),
              ),
              SizedBox(width: AppSize.width * 0.018),
              Text(
                title,
                style: TextStyle(
                  fontFamily: "pb",
                  fontWeight: FontWeight.w600,
                  fontSize: AppSize.textPercent(0.032),
                  color: active
                      ? Colors.white
                      : theme.canvasColor.withOpacity(0.6),
                ),
              ),
              if (index == 0 && _notifController.unreadCount > 0) ...[
                SizedBox(width: AppSize.width * 0.015),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withOpacity(0.25)
                        : theme.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_notifController.unreadCount}',
                    style: TextStyle(
                      fontFamily: "pb",
                      fontSize: AppSize.textPercent(0.024),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // INBOX TAB
  // ==========================================================
  Widget _inbox(ThemeData theme) {
    if (_notifController.isLoading.value) {
      return Center(
        child: CircularProgressIndicator(color: theme.primaryColor),
      );
    }

    if (_notifController.errorMessage.value.isNotEmpty) {
      return _messageState(
        theme: theme,
        icon: Icons.error_outline_rounded,
        iconColor: const Color(0xffEF4444),
        title: 'notification_screen_error_title'.tr,
        subtitle: _notifController.errorMessage.value,
        showRetry: true,
      );
    }

    if (_notifController.notifications.isEmpty) {
      return _messageState(
        theme: theme,
        icon: Icons.notifications_none_rounded,
        iconColor: theme.primaryColor,
        title: 'notification_screen_empty_title'.tr,
        subtitle: 'notification_screen_empty_subtitle'.tr,
        showRetry: false,
      );
    }

    return RefreshIndicator(
      color: theme.primaryColor,
      onRefresh: () => _notifController.fetchNotifications(isRefresh: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: AppSize.height * 0.02),
        itemCount: _notifController.notifications.length,
        itemBuilder: (context, index) {
          final n = _notifController.notifications[index];
          return _notifCard(n, theme, index);
        },
      ),
    );
  }

  Widget _messageState({
    required ThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showRetry,
  }) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: AppSize.height * 0.13),
        Center(
          child: Container(
            padding: EdgeInsets.all(AppSize.width * 0.06),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: AppSize.width * 0.11, color: iconColor),
          ),
        ),
        SizedBox(height: AppSize.height * 0.024),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: "pb",
            fontWeight: FontWeight.bold,
            fontSize: AppSize.textPercent(0.042),
            color: theme.canvasColor,
          ),
        ),
        SizedBox(height: AppSize.height * 0.01),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.1),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "pr",
              fontSize: AppSize.textPercent(0.032),
              color: theme.canvasColor.withOpacity(0.5),
              height: 1.4,
            ),
          ),
        ),
        if (showRetry) ...[
          SizedBox(height: AppSize.height * 0.026),
          Center(
            child: GestureDetector(
              onTap: () => _notifController.fetchNotifications(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.width * 0.07,
                  vertical: AppSize.height * 0.015,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: AppSize.width * 0.02),
                    Text(
                      'notification_screen_retry_button'.tr,
                      style: TextStyle(
                        fontFamily: "pb",
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: AppSize.textPercent(0.033),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _notifCard(NotificationModel n, ThemeData theme, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 40).clamp(0, 400)),
      curve: Curves.easeOut,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 12),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => _notifController.markSingleAsRead(n.id),
        child: Container(
          margin: EdgeInsets.only(bottom: AppSize.height * 0.012),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: n.isRead
                ? theme.cardColor
                : theme.primaryColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: n.isRead
                  ? theme.dividerColor.withOpacity(0.15)
                  : theme.primaryColor.withOpacity(0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconCircle(
                icon: n.icon,
                iconColor: theme.primaryColor,
                backgroundColor: theme.primaryColor.withOpacity(0.12),
              ),
              SizedBox(width: AppSize.width * 0.032),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.title,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontWeight: FontWeight.w600,
                        fontSize: AppSize.textPercent(0.035),
                        color: theme.canvasColor,
                      ),
                    ),
                    SizedBox(height: AppSize.height * 0.004),
                    Text(
                      n.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "pr",
                        color: theme.canvasColor.withOpacity(0.5),
                        fontSize: AppSize.textPercent(0.03),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSize.width * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    n.timeAgo,
                    style: TextStyle(
                      fontFamily: "pr",
                      fontSize: AppSize.textPercent(0.024),
                      color: theme.canvasColor.withOpacity(0.4),
                    ),
                  ),
                  if (!n.isRead) ...[
                    SizedBox(height: AppSize.height * 0.008),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor,
                            theme.primaryColor.withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SETTINGS TAB
  // ==========================================================
  Widget _settings(ThemeData theme) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _toggleRow(
                Icons.notifications_active_outlined,
                const Color(0xff3B82F6),
                'notification_screen_push_title'.tr,
                'notification_screen_push_subtitle'.tr,
                push,
                _togglePushNotifications,
                theme,
              ),
              _divider(theme),
              _toggleRow(
                Icons.email_outlined,
                const Color(0xff8B5CF6),
                'notification_screen_email_title'.tr,
                'notification_screen_email_subtitle'.tr,
                email,
                    (v) => setState(() => email = v),
                theme,
              ),
              _divider(theme),
              _toggleRow(
                Icons.sms_outlined,
                const Color(0xff10B981),
                'notification_screen_sms_title'.tr,
                'notification_screen_sms_subtitle'.tr,
                sms,
                    (v) => setState(() => sms = v),
                theme,
              ),
              _divider(theme),
              _toggleRow(
                Icons.volume_up_outlined,
                const Color(0xffF59E0B),
                'notification_screen_sound_title'.tr,
                'notification_screen_sound_subtitle'.tr,
                sound,
                    (v) => setState(() => sound = v),
                theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(ThemeData theme) => Padding(
    padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.004),
    child: Divider(color: theme.dividerColor.withOpacity(0.12), height: 1),
  );

  Widget _toggleRow(
      IconData icon,
      Color accent,
      String title,
      String subtitle,
      bool value,
      Function(bool) onChanged,
      ThemeData theme,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.012),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.width * 0.022),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: AppSize.textPercent(0.045)),
          ),
          SizedBox(width: AppSize.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "pb",
                    fontWeight: FontWeight.w600,
                    fontSize: AppSize.textPercent(0.035),
                    color: theme.canvasColor,
                  ),
                ),
                SizedBox(height: AppSize.height * 0.002),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: "pr",
                    fontSize: AppSize.textPercent(0.028),
                    color: theme.canvasColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.primaryColor,
          ),
        ],
      ),
    );
  }
}
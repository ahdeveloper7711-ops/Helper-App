import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/AppTheme/themecontroller.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Widgets/iconcircle.dart';
import 'package:helper_app2/Core/Widgets/profileavator.dart';
import 'package:helper_app2/Features/SharedScreen/Notificationsection/NotificationScreen.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clientProfilesection/clientProfilescreensection/clientProfilecontroller.dart';
import '../../../../Core/Apis/onlinestatuscontroller.dart';
import '../../../SharedScreen/Notificationsection/notificationcontroller.dart';
import 'clientjobcard.dart';
import 'clientjobcontroller.dart';

class Clienthomescreen extends StatelessWidget {
  final VoidCallback? onNavigateToPostJob;

  const Clienthomescreen({super.key, this.onNavigateToPostJob});

  @override
  Widget build(BuildContext context) {
    final ClientJobsController controller = Get.isRegistered<ClientJobsController>()
        ? Get.find<ClientJobsController>()
        : Get.put(ClientJobsController(), permanent: true);

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: AppSize.height*0.12),
        child: FloatingActionButton(
          backgroundColor: theme.primaryColor,
          shape: const CircleBorder(),
          onPressed: onNavigateToPostJob,
          child: Icon(Icons.add, color: theme.cardColor),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => controller.refresh(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSize.height * 0.01),
                    const _HomeHeader(),
                    SizedBox(height: AppSize.height * 0.02),
                    const _HomeStatsRow(),
                    SizedBox(height: AppSize.height * 0.03),
                    Text(
                      'client_home_discover_jobs'.tr,
                      style: TextStyle(
                        fontSize: AppSize.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),
                    Text(
                      'client_home_subtitle'.tr,
                      style: TextStyle(
                        fontSize: AppSize.width * 0.03,
                        color: theme.canvasColor.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(height: AppSize.height * 0.02),

                    Obx(() {
                      if (controller.tabs.length > 1) {
                        return const _FilterChips();
                      }
                      return const SizedBox.shrink();
                    }),
                    SizedBox(height: AppSize.height * 0.02),

                    /// 🔽 Jobs section — loading / error / empty / data states
                    Obx(() {
                      if (controller.isLoading.value && controller.allJobs.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: AppSize.height * 0.08),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (controller.errorMessage.value.isNotEmpty && controller.allJobs.isEmpty) {
                        return _ErrorState(
                          message: controller.errorMessage.value,
                          onRetry: () => controller.fetchHomeData(),
                          theme: theme,
                        );
                      }

                      final featured = controller.featuredJob;
                      final recommended = controller.recommendedJobs;

                      if (controller.filteredJobs.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.only(top: AppSize.height * 0.05),
                          child: Center(
                            child: Text(
                              'client_home_no_jobs'.tr,
                              style: TextStyle(color: theme.canvasColor.withOpacity(0.6)),
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (featured != null) ClientJobCard(job: featured),
                          if (featured != null) SizedBox(height: AppSize.height * 0.01),
                          if (recommended.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'client_home_your_posted_jobs'.tr,
                                  style: TextStyle(
                                    fontSize: AppSize.width * 0.04,
                                    fontWeight: FontWeight.bold,
                                    color: theme.canvasColor,
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: AppSize.height * 0.02),
                          Column(
                            children: recommended.map((job) => ClientJobCard(job: job)).toList(),
                          ),
                        ],
                      );
                    }),

                    SizedBox(height: AppSize.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThemeController themeController = Get.find();
    final ProfileController profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    final OnlineStatusController onlineStatusController =
    Get.isRegistered<OnlineStatusController>()
        ? Get.find<OnlineStatusController>()
        : Get.put(OnlineStatusController(), permanent: true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ProfileAvatar(radius: AppSize.width * 0.05),
            SizedBox(width: AppSize.width * 0.028),
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'client_home_welcome'.tr,
                  style: TextStyle(
                    fontSize: AppSize.width * 0.032,
                    color: theme.canvasColor.withOpacity(0.5),
                  ),
                ),
                Text(
                  profileController.displayUsername,
                  style: TextStyle(
                    fontSize: AppSize.width * 0.038,
                    fontWeight: FontWeight.bold,
                    color: theme.canvasColor,
                  ),
                ),
              ],
            )),
          ],
        ),
        Row(
          children: [
            Obx(() {
              final isOnline = onlineStatusController.isOnline.value;
              final isUpdating = onlineStatusController.isUpdating.value;
              return GestureDetector(
                onTap: onlineStatusController.toggleOnlineStatus,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isOnline ? theme.primaryColor : theme.canvasColor)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (isUpdating)
                        SizedBox(
                          height: 9,
                          width: 9,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: isOnline ? theme.primaryColor : theme.canvasColor.withOpacity(0.5),
                          ),
                        )
                      else
                        Icon(
                          Icons.circle,
                          size: 9,
                          color: isOnline ? theme.primaryColor : theme.canvasColor.withOpacity(0.5),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'client_home_online'.tr : 'client_home_offline'.tr,
                        style: TextStyle(
                          color: isOnline ? theme.primaryColor : theme.canvasColor.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(width: AppSize.width * 0.01),
            GestureDetector(
              onTap: () => themeController.toggleTheme(),
              child: IconCircle(
                icon: Get.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                height: AppSize.height * 0.045,
                width: AppSize.height * 0.045,
                iconSize: AppSize.height * 0.025,
              ),
            ),
            SizedBox(width: AppSize.width * 0.01),
            Obx(() {
              // Safe Global NotificationController instance
              final notifController = Get.isRegistered<NotificationController>()
                  ? Get.find<NotificationController>()
                  : Get.put(NotificationController(), permanent: true);

              final unreadCount = notifController.unreadCount;

              return GestureDetector(
                onTap: () async {
                  // Notification screen se wapas aane par notifications refresh honge
                  await Get.to(() => const NotificationScreen());
                  notifController.fetchNotifications(isRefresh: true);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconCircle(
                      icon: Icons.notifications,
                      height: AppSize.height * 0.05,
                      width: AppSize.height * 0.05,
                      iconColor: theme.canvasColor,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            })        ],
        ),
      ],
    );
  }
}

class _HomeStatsRow extends StatelessWidget {
  const _HomeStatsRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ClientJobsController>();

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(AppSize.width * 0.04),
            decoration: BoxDecoration(color: theme.primaryColor, borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                Text(
                  'client_home_wallet'.tr,
                  style: TextStyle(
                    color: theme.cardColor.withOpacity(0.75),
                    fontSize: AppSize.width * 0.03,
                  ),
                ),
                SizedBox(height: AppSize.height * 0.005),
                Obx(() {
                  final balance = controller.userDetails.value?.walletBalance;
                  return Text(
                    balance != null ? "$balance ${'post_job_currency_uzs'.tr}" : "--",
                    style: TextStyle(
                      color: theme.cardColor,
                      fontSize: AppSize.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
              ],
            ),          ),
        ),
        SizedBox(width: AppSize.width * 0.03),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(AppSize.width * 0.04),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text('client_home_active_jobs'.tr,
                    style: TextStyle(color: theme.canvasColor.withOpacity(0.5), fontSize: AppSize.width * 0.03)),
                SizedBox(height: AppSize.height * 0.005),
                Obx(() => Text(
                  "${controller.allJobs.length}",
                  style: TextStyle(
                      color: theme.canvasColor, fontSize: AppSize.width * 0.05, fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  ClientJobsController get controller => Get.find<ClientJobsController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(controller.tabs.length, (index) {
            final isSelected = controller.selectedIndex.value == index;
            final label = controller.tabs[index];

            return GestureDetector(
              onTap: () => controller.selectTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: AppSize.width * 0.02),
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.width * 0.04,
                  vertical: AppSize.height * 0.01,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : theme.dividerColor.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? theme.cardColor : theme.canvasColor,
                    fontWeight: FontWeight.w600,
                    fontSize: AppSize.width * 0.032,
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final ThemeData theme;

  const _ErrorState({required this.message, required this.onRetry, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppSize.height * 0.06),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.wifi_off_rounded, size: AppSize.width * 0.12, color: theme.canvasColor.withOpacity(0.3)),
            SizedBox(height: AppSize.height * 0.015),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.canvasColor.withOpacity(0.6)),
            ),
            SizedBox(height: AppSize.height * 0.015),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('client_home_retry'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
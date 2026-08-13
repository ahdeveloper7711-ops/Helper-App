import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';

import '../Workerhomesection/workerhomecontroller.dart';
import 'controller.dart';
import 'workerjobhistorycard.dart';

class Workermyjobscreen extends StatefulWidget {
  const Workermyjobscreen({super.key});

  @override
  State<Workermyjobscreen> createState() => _WorkermyjobscreenState();
}

class _WorkermyjobscreenState extends State<Workermyjobscreen> {
  late final WorkerJobHistoryController controller;
  late final WorkerHomeController homeController;

  bool _showLoader = false;

  void _setLoader(bool value) {
    if (!mounted) return;
    setState(() => _showLoader = value);
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(WorkerJobHistoryController());

    // NEW: myWorkerId ke liye WorkerHomeController — WorkerJobHistoryCard ko
    // "mySelected vs takenByOther" decide karne ke liye is id ki zaroorat hai.
    homeController = Get.isRegistered<WorkerHomeController>()
        ? Get.find<WorkerHomeController>()
        : Get.put(WorkerHomeController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _setLoader(true);
      try {
        await controller.loadMyJobs();
      } catch (e) {
        debugPrint("⚠️ [Workermyjobscreen] loadMyJobs error: $e");
      } finally {
        _setLoader(false);
      }
    });
  }

  Future<void> _handleRefresh() async {
    _setLoader(true);
    try {
      await controller.loadMyJobs();
    } catch (e) {
      debugPrint("⚠️ [Workermyjobscreen] refresh error: $e");
    } finally {
      _setLoader(false);
    }
  }

  IconData _iconForTab(int index) {
    switch (index) {
      case 0:
        return Icons.bolt_rounded; // Active
      case 1:
        return Icons.check_circle_rounded; // Completed
      case 2:
        return Icons.cancel_rounded; // Cancelled
      default:
        return Icons.work_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBackground(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.05),
            child: Column(
              children: [
                SizedBox(height: AppSize.height * 0.009),
                Row(
                  children: [
                    Expanded(
                      child: CustomHeader(
                        title: 'worker_my_jobs_title'.tr,
                      ),
                    ),
                    GestureDetector(
                      onTap: _handleRefresh,
                      child: Container(
                        padding: EdgeInsets.all(AppSize.width * 0.02),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.refresh_rounded,
                            color: theme.primaryColor, size: AppSize.width * 0.05),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSize.height * 0.022),

                /// ---------------- CUSTOM TABS (gradient pill style) ----------------
                Obx(() {
                  return Container(
                    padding: EdgeInsets.all(AppSize.width * 0.012),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppSize.width * 0.09),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: List.generate(
                        controller.tabs.length,
                            (index) {
                          final isSelected = controller.selectedTab.value == index;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => controller.selectTab(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeOut,
                                margin: EdgeInsets.symmetric(horizontal: AppSize.width * 0.008),
                                padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.01),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                    colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.75)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                      : null,
                                  borderRadius: BorderRadius.circular(AppSize.width * 0.06),
                                  boxShadow: isSelected
                                      ? [
                                    BoxShadow(
                                      color: theme.primaryColor.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _iconForTab(index),
                                      size: AppSize.width * 0.06,
                                      color: isSelected ? Colors.white : theme.canvasColor.withOpacity(0.45),
                                    ),
                                    SizedBox(height: AppSize.height * 0.007),
                                    Text(
                                      controller.tabs[index],
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : theme.canvasColor.withOpacity(0.55),
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSize.width * 0.036,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),

                SizedBox(height: AppSize.height * 0.022),

                /// ---------------- LIST ----------------
                Expanded(
                  child: Obx(() {
                    final jobs = controller.filteredJobs;

                    if (jobs.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: AppSize.height * 0.12),
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(AppSize.width * 0.06),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.assignment_late_outlined,
                                    size: AppSize.width * 0.14,
                                    color: theme.primaryColor.withOpacity(0.6),
                                  ),
                                ),
                                SizedBox(height: AppSize.height * 0.02),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.12),
                                  child: Text(
                                    'worker_my_jobs_empty'.tr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: theme.canvasColor.withOpacity(0.55),
                                      fontSize: AppSize.width * 0.038,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "pb",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      itemCount: jobs.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return WorkerJobHistoryCard(
                          job: job,
                          myWorkerId: homeController.workerId.value,
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          /// Local loader overlay
          if (_showLoader)
            Positioned.fill(
              child: Container(
                color: Colors.black12,
                child: Center(
                  child: CircularProgressIndicator(color: theme.primaryColor),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';

import '../Workerhomesection/workerhomecontroller.dart';
import '../Workerhomesection/workerjobcard.dart';

class Workeractivejobscreen extends StatefulWidget {
  final VoidCallback? onBack; // NEW
  const Workeractivejobscreen({super.key , this.onBack});

  @override
  State<Workeractivejobscreen> createState() => _WorkeractivejobscreenState();
}

class _WorkeractivejobscreenState extends State<Workeractivejobscreen> {
  late final WorkerHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<WorkerHomeController>()
        ? Get.find<WorkerHomeController>()
        : Get.put(WorkerHomeController());

    // Screen open hote hi latest state fetch kar lein taake completed/
    // cancelled ho chuki job foran list se hat jaye.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshJobsSilently();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
      return AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.05),
            child: Column(
              children: [
                SizedBox(height: AppSize.height * 0.02),
                CustomHeader(
                  title: 'worker_active_jobs_title'.tr,
                  showBackButton: true,
                  onBack: widget.onBack ?? () {},
                ),
                SizedBox(height: AppSize.height * 0.02),
                Expanded(
                  child: Obx(() {
                    final activeJobs = controller.myActiveJobs;
                    final myWorkerId = controller.workerId.value;

                    if (activeJobs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.work_off_outlined,
                              size: AppSize.width * 0.14,
                              color: theme.canvasColor.withOpacity(0.3),
                            ),
                            SizedBox(height: AppSize.height * 0.015),
                            Text(
                              'worker_active_jobs_empty'.tr,
                              style: TextStyle(
                                color: theme.canvasColor.withOpacity(0.5),
                                fontSize: AppSize.width * 0.036,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: controller.refreshJobsSilently,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: activeJobs.length,
                        itemBuilder: (context, index) => WorkerJobCard(
                          job: activeJobs[index],
                          myWorkerId: myWorkerId,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
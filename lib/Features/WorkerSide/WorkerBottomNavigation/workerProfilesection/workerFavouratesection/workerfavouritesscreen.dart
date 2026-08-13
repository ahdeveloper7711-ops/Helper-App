import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/CustomHeader.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';

import '../../Workerhomesection/workerhomecontroller.dart';
import '../../Workerhomesection/workerjobcard.dart';


class Workerfavouritesscreen extends StatefulWidget {
  const Workerfavouritesscreen({super.key});

  @override
  State<Workerfavouritesscreen> createState() => _WorkerfavouritesscreenState();
}

class _WorkerfavouritesscreenState extends State<Workerfavouritesscreen> {
  late final WorkerHomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<WorkerHomeController>()
        ? Get.find<WorkerHomeController>()
        : Get.put(WorkerHomeController());
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
                  title: 'worker_favourites_title'.tr,
                  showBackButton: true,
                  onBack: () => Get.back(),
                ),
                SizedBox(height: AppSize.height * 0.02),
                Expanded(
                  child: Obx(() {
                    final favJobs = controller.myFavouriteJobs;
                    final myWorkerId = controller.workerId.value;

                    if (favJobs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border_rounded,
                              size: AppSize.width * 0.14,
                              color: theme.canvasColor.withOpacity(0.3),
                            ),
                            SizedBox(height: AppSize.height * 0.015),
                            Text(
                              'worker_favourites_empty_title'.tr,
                              style: TextStyle(
                                color: theme.canvasColor.withOpacity(0.5),
                                fontSize: AppSize.width * 0.036,
                              ),
                            ),
                            SizedBox(height: AppSize.height * 0.006),
                            Text(
                              'worker_favourites_empty_subtitle'.tr,
                              style: TextStyle(
                                color: theme.canvasColor.withOpacity(0.35),
                                fontSize: AppSize.width * 0.03,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: favJobs.length,
                      itemBuilder: (context, index) => WorkerJobCard(
                        job: favJobs[index],
                        myWorkerId: myWorkerId,
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
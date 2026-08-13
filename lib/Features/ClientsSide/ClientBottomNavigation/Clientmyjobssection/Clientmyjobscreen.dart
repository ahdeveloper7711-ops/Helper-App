import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Core/Widgets/MediaqueryHelperfile.dart'; // Aapka AppSize path

import 'Clientjobhistorycard.dart';
import 'clientmyjobcontroller.dart';

class ClientMyJobScreen extends StatelessWidget {
  const ClientMyJobScreen({super.key});

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
    final controller = Get.put(ClientMyJobController());

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'client_my_jobs_title'.tr,
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.bold,
            fontSize: AppSize.width * 0.048,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchClientJobs(),
        color: theme.primaryColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.04),
          child: Column(
            children: [
              SizedBox(height: AppSize.height * 0.008),

              /// ---------------- CUSTOM TABS ROW (upgraded) ----------------
              Obx(() {
                final tabs = controller.tabs;
                return Container(
                  padding: EdgeInsets.symmetric(vertical:AppSize.width * 0.014,horizontal: AppSize.width * 0.01),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(AppSize.height*0.6),
                    border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(tabs.length, (index) {
                      final tab = tabs[index];
                      final isSelected = controller.selectedTab.value == tab;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => controller.updateFilter(tab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            margin: EdgeInsets.symmetric(horizontal: AppSize.width * 0.006),
                            padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.012),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.75)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : null,
                              color: isSelected ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppSize.height*0.6),
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
                                  size: AppSize.width * 0.05,
                                  color: isSelected ? Colors.white : theme.canvasColor.withOpacity(0.45),
                                ),
                                SizedBox(width: AppSize.height * 0.0025),
                                Text(
                                  tab,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : theme.canvasColor.withOpacity(0.55),
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSize.width * 0.033,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),

              SizedBox(height: AppSize.height * 0.022),

              /// ---------------- JOBS LIST VIEW ----------------
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: theme.primaryColor,
                      ),
                    );
                  }

                  if (controller.filteredJobs.isEmpty) {
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
                                  '${'client_my_jobs_empty_prefix'.tr}${controller.selectedTab.value}${'client_my_jobs_empty_suffix'.tr}',
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

                  // NEW: ClientJobHistoryCard seedha JobPostModel accept karta hai —
                  // ClientJobCard jaisi hi poori UI (expandable sections, pills, etc.)
                  // saath, koi manual field mapping/parsing ki zaroorat nahi rahi.
                  return ListView.builder(
                    itemCount: controller.filteredJobs.length,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final job = controller.filteredJobs[index];
                      return ClientJobHistoryCard(job: job);
                    },
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
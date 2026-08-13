import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../../../../Core/Apis/jobservice.dart';
import '../clienthomesection/clientjobmodel.dart';

class ClientMyJobController extends GetxController {
  static const String _tag = "ClientMyJobController";

  // Loading and Data states
  var isLoading = false.obs;
  var activeJobs = <JobPostModel>[].obs;
  var inactiveJobs = <JobPostModel>[].obs;
  var filteredJobs = <JobPostModel>[].obs;

  // Tabs management
  List<String> get tabs => [
    'client_my_job_tab_active'.tr,
    'client_my_job_tab_completed'.tr,
    'client_my_job_tab_cancelled'.tr,
  ];

  var selectedTab = 'client_my_job_tab_active'.tr.obs;

  @override
  void onInit() {
    super.onInit();
    selectedTab.value = 'client_my_job_tab_active'.tr;
    fetchClientJobs();
  }

  /// API se real data fetch karne ka function
  Future<void> fetchClientJobs() async {
    try {
      isLoading(true);
      developer.log("🔄 [$_tag] Fetching client jobs from API...", name: _tag);

      final response = await JobService.getClientHomeData();

      if (response != null) {
        activeJobs.value = response.activeJobs;
        inactiveJobs.value = response.inactiveJobs;
        developer.log("✅ [$_tag] Loaded ${activeJobs.length} active and ${inactiveJobs.length} inactive jobs.", name: _tag);
      } else {
        developer.log("⚠️ [$_tag] Response was null, clear lists.", name: _tag);
        activeJobs.clear();
        inactiveJobs.clear();
      }

      // Data fetch hone ke baad current tab ke mutabiq filter karein
      updateFilter(selectedTab.value);
    } catch (e) {
      developer.log("❌ [$_tag] Error fetching jobs: $e", name: _tag);
    } finally {
      isLoading(false);
    }
  }

  /// Tab selection badalne par list filter karne ka logic
  void updateFilter(String tabLabel) {
    selectedTab.value = tabLabel;
    filteredJobs.clear();

    final normalizedTab = tabLabel.toUpperCase();
    final activeTabKey = 'client_my_job_tab_active'.tr.toUpperCase();
    final completedTabKey = 'client_my_job_tab_completed'.tr.toUpperCase();
    final cancelledTabKey = 'client_my_job_tab_cancelled'.tr.toUpperCase();

    // 1. ACTIVE Tab: Yeh 'active_jobs' array se data uthayega
    if (normalizedTab == activeTabKey || normalizedTab == "ACTIVE") {
      filteredJobs.addAll(activeJobs);
    }
    // 2. COMPLETED Tab: Yeh 'inactive_jobs' mein se COMPLETED status wali jobs nikalega
    else if (normalizedTab == completedTabKey || normalizedTab == "COMPLETED") {
      filteredJobs.addAll(
          inactiveJobs.where((job) => job.status.toUpperCase() == "COMPLETED" || job.state.toUpperCase() == "COMPLETED").toList()
      );
    }
    // 3. CANCELLED Tab: Yeh 'inactive_jobs' mein se CANCELLED status wali jobs nikalega
    else if (normalizedTab == cancelledTabKey || normalizedTab == "CANCELLED") {
      filteredJobs.addAll(
          inactiveJobs.where((job) => job.status.toUpperCase() == "CANCELLED" || job.state.toUpperCase() == "CANCELLED").toList()
      );
    }

    developer.log("🎯 [$_tag] Filter updated for Tab: $tabLabel. Displaying ${filteredJobs.length} jobs.", name: _tag);
  }
}
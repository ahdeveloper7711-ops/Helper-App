import 'package:get/get.dart';
import '../Workerhomesection/workerexplorejobmodel.dart';
import '../../../../Core/Apis/workerjobservice.dart' as service_model;

class WorkerJobHistoryController extends GetxController {
  var selectedTab = 0.obs;

  // Tabs list can reference localization keys or handle labels through getters/mapping
  List<String> get tabs => [
    'worker_job_history_tab_all'.tr,
    'worker_job_history_tab_active'.tr,
    'worker_job_history_tab_past'.tr,
  ];

  final RxList<WorkerMyJobModel> _activeJobs = <WorkerMyJobModel>[].obs;
  final RxList<WorkerMyJobModel> _pastJobs = <WorkerMyJobModel>[].obs;

  List<WorkerMyJobModel> get activeJobs => _activeJobs;
  List<WorkerMyJobModel> get pastJobs => _pastJobs;

  @override
  void onInit() {
    super.onInit();
    loadMyJobs();
  }

  /// Main function to load data from API
  Future<void> loadMyJobs() async {
    try {
      final result = await service_model.WorkerJobService.getMyJobs();

      // NOTE: WorkerJobService already returns List<WorkerMyJobModel> —
      // koi extra mapping/conversion ki zaroorat nahi.
      _activeJobs.assignAll(result.activeJobs);
      _pastJobs.assignAll(result.pastJobs);

      update();
    } catch (e) {
      print("❌ Error in Mapping or API: $e");
    }
  }

  Future<void> refreshJobsSilently() async {
    print("🔄 [WorkerJobHistoryController] Background sync triggered from Apply Action");
    await loadMyJobs();
  }

  /// Apply karne ke foran baad job ko Active list mein daal deta hai,
  /// taake bottom-navigation "My Jobs" tab mein turant dikhe — server
  /// refresh ka intezaar kiye baghair.
  void addAppliedJobOptimistically(WorkerExploreJobModel job) {
    final alreadyThere = _activeJobs.any((j) => j.id == job.id);
    if (alreadyThere) return;

    _activeJobs.insert(0, WorkerMyJobModel.fromExploreModel(job));
    update();
  }

  List<WorkerMyJobModel> get filteredJobs {
    // Check based on index instead of hardcoded strings to support language changes smoothly
    if (selectedTab.value == 1) return _activeJobs;
    if (selectedTab.value == 2) return _pastJobs;
    return [..._activeJobs, ..._pastJobs]; // Index 0 -> All
  }

  void selectTab(int index) {
    selectedTab.value = index;
    update();
  }
}
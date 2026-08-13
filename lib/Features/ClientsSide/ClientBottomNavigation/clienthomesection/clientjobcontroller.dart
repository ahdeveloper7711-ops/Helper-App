import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../../../Core/Apis/jobservice.dart';
import '../../../../Core/Apis/onlinestatuscontroller.dart';
import '../../../../Core/Apis/workerjobservice.dart';
import '../../../../Core/Apis/jobactionresult.dart';
import '../../../../Core/Apis/sessionmanager.dart';
import 'clientjobmodel.dart';

class ClientJobsController extends GetxController {
  static const String _tag = "ClientJobsController";

  final RxList<JobPostModel> allJobs = <JobPostModel>[].obs;
  final RxList<JobPostModel> inactiveJobs = <JobPostModel>[].obs;

  final Rx<UserDetailsModel?> userDetails = Rx<UserDetailsModel?>(null);

  final RxSet<int> favouriteJobIds = <int>{}.obs;
  final RxMap<int, String> acceptedWorkerIds = <int, String>{}.obs;

  final RxInt selectedIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxMap<int, List<WorkerApplicant>> interestedWorkersByJob = <int, List<WorkerApplicant>>{}.obs;
  final RxMap<int, bool> interestedWorkersLoading = <int, bool>{}.obs;
  final RxMap<int, String> interestedWorkersError = <int, String>{}.obs;

  /// ------------------------------------------------------------
  /// hasAcceptedWorker / isWorkerAccepted — local map ke sath sath
  /// job.hasSelectedWorker ko bhi fallback ke tor par check karte
  /// hain. Ab selectWorker() asal backend API call karti hai, is
  /// liye job.selectedWorkerId hamesha backend se sahi (persisted)
  /// aayega — refresh/logout-login ke baad bhi consistent rahega.
  /// ------------------------------------------------------------
  bool hasAcceptedWorker(int jobId) {
    if (acceptedWorkerIds.containsKey(jobId)) return true;
    final job = getJobById(jobId);
    return job?.hasSelectedWorker ?? false;
  }

  bool isWorkerAccepted(int jobId, String workerId) {
    final local = acceptedWorkerIds[jobId];
    if (local != null) return local == workerId;
    final job = getJobById(jobId);
    return job?.selectedWorkerId?.toString() == workerId;
  }

  /// ------------------------------------------------------------
  /// UPDATED: SELECT WORKER — ab asal backend API (client/jobs/
  /// select-worker) ko call karta hai. Success par job ko locally
  /// bhi turant update karte hain (selected_worker_id + state =
  /// CHAT_ENABLED) taake UI turant reflect ho, lekin asal source
  /// of truth ab backend hai — is liye state permanent rahegi.
  /// ------------------------------------------------------------
  Future<JobActionResult> selectWorker(int jobId, String workerId) async {
    final clientId = await _getClientId();
    final wId = int.tryParse(workerId) ?? 0;

    final result = await JobService.selectWorker(jobId: jobId, workerId: wId, userId: clientId);

    if (result.success) {
      acceptedWorkerIds[jobId] = workerId;
      _updateJobLocally(jobId, selectedWorkerId: wId, state: 'CHAT_ENABLED');
      debugPrint("✅ [$_tag] Worker $workerId selected (backend confirmed) for job $jobId (state -> CHAT_ENABLED)");
    } else {
      debugPrint("❌ [$_tag] selectWorker failed for job $jobId, worker $workerId: ${result.message}");
    }

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  List<String> get tabs {
    final categories = allJobs.map((j) => j.category).toSet().toList()..sort();
    return ['client_jobs_tab_all'.tr, ...categories];
  }

  Future<void> fetchHomeData() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await JobService.getClientHomeData();

    if (result != null) {
      userDetails.value = result.userDetails;
      if (result.userDetails?.isOnline != null) {
        final onlineStatusController =
        Get.isRegistered<OnlineStatusController>()
            ? Get.find<OnlineStatusController>()
            : Get.put(
          OnlineStatusController(),
          permanent: true,
        );

        await onlineStatusController.syncFromBackend(
          result.userDetails!.isOnline,
        );
      }
      allJobs.assignAll(result.activeJobs);
      inactiveJobs.assignAll(result.inactiveJobs);

      // Backend se aaye hue selected_worker_id ko local map ke sath sync kar
      // dete hain, taake hasAcceptedWorker/isWorkerAccepted turant consistent rahein.
      for (final job in [...result.activeJobs, ...result.inactiveJobs]) {
        if (job.hasSelectedWorker) {
          acceptedWorkerIds[job.id] = job.selectedWorkerId.toString();
        }
      }

      if (selectedIndex.value >= tabs.length) {
        selectedIndex.value = 0;
      }
    } else {
      errorMessage.value = 'client_jobs_error_loading'.tr;
    }

    isLoading.value = false;
  }

  Future<void> refresh() async => fetchHomeData();

  void selectTab(int index) {
    if (index < 0 || index >= tabs.length) return;
    selectedIndex.value = index;
  }

  List<JobPostModel> get filteredJobs {
    if (tabs.isEmpty) return [];
    final safeIndex = selectedIndex.value.clamp(0, tabs.length - 1);
    final category = tabs[safeIndex];
    if (category == 'client_jobs_tab_all'.tr || category == "All") return allJobs;
    return allJobs.where((job) => job.category == category).toList();
  }

  JobPostModel? get featuredJob {
    if (selectedIndex.value != 0) return null;
    return filteredJobs.isNotEmpty ? filteredJobs.first : null;
  }

  List<JobPostModel> get recommendedJobs {
    if (selectedIndex.value == 0) {
      return filteredJobs.skip(1).toList();
    }
    return filteredJobs;
  }

  List<JobPostModel> get favouriteJobs =>
      allJobs.where((job) => favouriteJobIds.contains(job.id)).toList();

  bool isFavourite(int jobId) => favouriteJobIds.contains(jobId);

  void toggleFavourite(int jobId) {
    if (favouriteJobIds.contains(jobId)) {
      favouriteJobIds.remove(jobId);
    } else {
      favouriteJobIds.add(jobId);
    }
  }

  JobPostModel? getJobById(int jobId) {
    try {
      return allJobs.firstWhere((job) => job.id == jobId);
    } catch (_) {
      try {
        return inactiveJobs.firstWhere((job) => job.id == jobId);
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> fetchInterestedWorkers(int jobId, {bool forceRefresh = false}) async {
    if (!forceRefresh && interestedWorkersByJob.containsKey(jobId)) {
      return;
    }

    interestedWorkersLoading[jobId] = true;
    interestedWorkersError[jobId] = '';

    final workers = await JobService.getInterestedWorkers(jobId);

    interestedWorkersByJob[jobId] = workers;
    interestedWorkersLoading[jobId] = false;
  }

  List<WorkerApplicant> interestedWorkersFor(int jobId) => interestedWorkersByJob[jobId] ?? [];

  bool isLoadingInterestedWorkers(int jobId) => interestedWorkersLoading[jobId] ?? false;

  bool hasFetchedInterestedWorkers(int jobId) => interestedWorkersByJob.containsKey(jobId);

  /// ------------------------------------------------------------
  /// current client ki id resolve karta hai
  /// ------------------------------------------------------------
  Future<int> _getClientId() async {
    final id = await SessionManager.getUserId();
    return int.tryParse('${id ?? ''}') ?? 0;
  }

  /// ------------------------------------------------------------
  /// job ko locally update karta hai (allJobs ya inactiveJobs jahan
  /// bhi ho), taake UI turant refresh ho
  /// ------------------------------------------------------------
  void _updateJobLocally(int jobId, {int? selectedWorkerId, String? state}) {
    final idx = allJobs.indexWhere((j) => j.id == jobId);
    if (idx != -1) {
      allJobs[idx] = allJobs[idx].copyWith(selectedWorkerId: selectedWorkerId, state: state);
      return;
    }
    final inactiveIdx = inactiveJobs.indexWhere((j) => j.id == jobId);
    if (inactiveIdx != -1) {
      inactiveJobs[inactiveIdx] = inactiveJobs[inactiveIdx].copyWith(selectedWorkerId: selectedWorkerId, state: state);
    }
  }

  /// ------------------------------------------------------------
  /// CANCEL JOB — client/jobs/cancel API
  /// ------------------------------------------------------------
  Future<JobActionResult> cancelJob(int jobId) async {
    final clientId = await _getClientId();
    final result = await JobService.cancelJob(jobId: jobId, userId: clientId);
    if (result.success) {
      _updateJobLocally(jobId, state: 'CANCELLED');
      acceptedWorkerIds.remove(jobId);
    }
    return result;
  }

  /// ------------------------------------------------------------
  /// COMPLETE JOB — worker/jobs/complete API (client screen se
  /// call hoti hai, accepted worker ki id ke sath)
  /// ------------------------------------------------------------
  Future<JobActionResult> completeJob(int jobId, int workerId) async {
    final result = await WorkerJobService.completeJob(jobId: jobId, workerId: workerId);
    if (result.success) {
      _updateJobLocally(jobId, state: 'COMPLETED');
    }
    return result;
  }
}
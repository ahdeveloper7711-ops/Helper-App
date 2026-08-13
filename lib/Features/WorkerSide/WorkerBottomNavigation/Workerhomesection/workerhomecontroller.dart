import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:helper_app2/Core/Apis/sessionmanager.dart';
import '../../../../Core/Apis/workerjobservice.dart';
import '../../../../Core/Apis/jobservice.dart';
import '../../../../Core/Apis/jobactionresult.dart';
import 'workerexplorejobmodel.dart';

class WorkerHomeController extends GetxController {
  static const String _tag = "WorkerHomeController";

  final RxnString selectedCity = RxnString(null);
  final RxList<WorkerExploreJobModel> jobs = <WorkerExploreJobModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxSet<int> appliedJobIds = <int>{}.obs;

  // NEW: favourite jobs (worker-scoped, persisted)
  final RxSet<int> favouriteJobIds = <int>{}.obs;

  final RxBool isStatsLoading = false.obs;
  final RxInt activeJobsCount = 0.obs;

  // FIXED: Initial value getter for reactive translation update
  final RxString earningsLabel = "0 ${'post_job_currency_uzs'.tr}".obs;

  // current logged-in worker id (cache)
  final RxInt workerId = 0.obs;

  bool get hasCity =>
      selectedCity.value != null && selectedCity.value!.trim().isNotEmpty;

  Future<void>? _initFuture;

  Future<void> get ready {
    return _initFuture ??= _initialize();
  }

  static String normalizeCityName(String city) {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed
        .split(RegExp(r'\s+'))
        .map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        .join(' ');
  }

  @override
  void onInit() {
    super.onInit();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    try {
      await _resolveWorkerId();

      await Future.wait([
        _loadPersistedAppliedJobs(),
        _loadPersistedFavouriteJobs(),
      ]);

      await ready;

      // Stats background mein load hongi aur label update karengi
      fetchWorkerStats();
    } catch (e) {
      developer.log("❌ $_tag initialization error: $e", name: _tag);
    }
  }

  Future<void> _initialize() async {
    try {
      final savedCity = SessionManager.getWorkerCity();
      if (savedCity != null && savedCity.trim().isNotEmpty) {
        selectedCity.value = normalizeCityName(savedCity);
        developer.log(
          "💾 [$_tag] Loaded saved city from SessionManager: ${selectedCity.value}",
          name: _tag,
        );
        await fetchJobsForCity();
      }
    } catch (e) {
      developer.log("⚠️ [$_tag] Error loading saved city: $e", name: _tag);
    }
  }

  Future<void> fetchWorkerStats() async {
    try {
      isStatsLoading.value = true;

      final result = await WorkerJobService.getMyJobs();
      activeJobsCount.value = result.activeJobs.length;

      final user = SessionManager.getUser();
      if (user != null) {
        final rawEarnings =
            user['earnings'] ??
                user['wallet_balance'] ??
                user['total_earnings'] ??
                user['balance'];

        if (rawEarnings != null) {
          // Clean non-numeric characters (like '$' or spaces if coming from API)
          final cleanEarningsStr = rawEarnings.toString().replaceAll(RegExp(r'[^0-9.]'), '');
          final val = double.tryParse(cleanEarningsStr) ?? 0;

          // Updated reactivity trigger
          earningsLabel.value = "${val.toStringAsFixed(0)} ${'post_job_currency_uzs'.tr}";
        } else {
          earningsLabel.value = "0 ${'post_job_currency_uzs'.tr}";
        }
      }
    } catch (e) {
      developer.log("❌ [$_tag] fetchWorkerStats exception: $e", name: _tag);
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> setCity(String city) async {
    if (city.trim().isEmpty) return;
    try {
      final cleanCity = normalizeCityName(city);
      await SessionManager.saveWorkerCity(cleanCity);
      selectedCity.value = cleanCity;
      await fetchJobsForCity();
    } catch (e) {
      developer.log("❌ [$_tag] Error saving city: $e", name: _tag);
    }
  }

  Future<void> changeCity() async {
    try {
      await SessionManager.clearWorkerCity();
      selectedCity.value = null;
      jobs.clear();
    } catch (e) {
      developer.log("⚠️ [$_tag] Error clearing city: $e", name: _tag);
    }
  }

  Future<void> fetchJobsForCity() async {
    if (!hasCity) return;

    try {
      isLoading.value = true;
      final cityToSearch = selectedCity.value!;
      final fetchedList = await WorkerJobService.exploreJobs(
        city: cityToSearch,
      );
      jobs.assignAll(fetchedList);
    } catch (e) {
      developer.log("❌ [$_tag] fetchJobsForCity exception: $e", name: _tag);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshJobsSilently() async {
    if (!hasCity) return;
    try {
      final cityToSearch = selectedCity.value!;
      final fetchedList = await WorkerJobService.exploreJobs(
        city: cityToSearch,
      );
      jobs.assignAll(fetchedList);
      fetchWorkerStats(); // Ensure earnings label updates on refresh as well
    } catch (e) {
      developer.log("⚠️ [$_tag] refreshJobsSilently exception: $e", name: _tag);
    }
  }

  List<WorkerExploreJobModel> jobsForCategory(String category) {
    return jobs
        .where((job) => job.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  WorkerExploreJobModel? getJobById(int jobId) {
    try {
      return jobs.firstWhere((job) => job.id == jobId);
    } catch (_) {
      return null;
    }
  }

  bool isJobApplied(int jobId) => appliedJobIds.contains(jobId);

  void markJobApplied(int jobId) {
    appliedJobIds.add(jobId);
    _persistAppliedJob(jobId);
    developer.log(
      "📌 [$_tag] Marked job ID $jobId as locally applied in session state",
      name: _tag,
    );
  }

  bool isJobSelectedForMe(WorkerExploreJobModel job) {
    return job.hasSelectedWorker && job.selectedWorkerId == workerId.value;
  }

  bool isJobTakenByOther(WorkerExploreJobModel job) {
    return job.hasSelectedWorker && job.selectedWorkerId != workerId.value;
  }

  List<WorkerExploreJobModel> get myActiveJobs {
    final myId = workerId.value;
    return jobs
        .where(
          (j) =>
      j.hasSelectedWorker &&
          j.selectedWorkerId == myId &&
          !j.isCompleted &&
          !j.isCancelled,
    )
        .toList();
  }

  bool isFavourite(int jobId) => favouriteJobIds.contains(jobId);

  Future<void> toggleFavourite(int jobId) async {
    if (favouriteJobIds.contains(jobId)) {
      favouriteJobIds.remove(jobId);
    } else {
      favouriteJobIds.add(jobId);
    }
    await _saveFavouriteJobs();
  }

  List<WorkerExploreJobModel> get myFavouriteJobs {
    return jobs.where((j) => favouriteJobIds.contains(j.id)).toList();
  }

  String _favouriteJobsKey(int wId) => 'favourite_jobs_worker_$wId';

  Future<void> _loadPersistedFavouriteJobs() async {
    try {
      final wId = workerId.value;
      if (wId == 0) return;
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_favouriteJobsKey(wId)) ?? [];
      final ids = list.map((e) => int.tryParse(e)).whereType<int>().toSet();
      favouriteJobIds.addAll(ids);
      developer.log(
        "💾 [$_tag] Loaded ${ids.length} persisted favourite job(s) for worker $wId",
        name: _tag,
      );
    } catch (e) {
      developer.log(
        "⚠️ [$_tag] Failed to load persisted favourite jobs: $e",
        name: _tag,
      );
    }
  }

  Future<void> _saveFavouriteJobs() async {
    try {
      final wId = await _resolveWorkerId();
      if (wId == 0) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _favouriteJobsKey(wId),
        favouriteJobIds.map((e) => e.toString()).toList(),
      );
    } catch (e) {
      developer.log(
        "⚠️ [$_tag] Failed to persist favourite jobs: $e",
        name: _tag,
      );
    }
  }

  String _appliedJobsKey(int wId) => 'applied_jobs_worker_$wId';

  Future<void> _loadPersistedAppliedJobs() async {
    try {
      final wId = workerId.value;
      if (wId == 0) return;
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_appliedJobsKey(wId)) ?? [];
      final ids = list.map((e) => int.tryParse(e)).whereType<int>().toSet();
      appliedJobIds.addAll(ids);
      developer.log(
        "💾 [$_tag] Loaded ${ids.length} persisted applied job(s) for worker $wId",
        name: _tag,
      );
    } catch (e) {
      developer.log(
        "⚠️ [$_tag] Failed to load persisted applied jobs: $e",
        name: _tag,
      );
    }
  }

  Future<void> _persistAppliedJob(int jobId) async {
    try {
      final wId = await _resolveWorkerId();
      if (wId == 0) return;
      final prefs = await SharedPreferences.getInstance();
      final key = _appliedJobsKey(wId);
      final list = prefs.getStringList(key) ?? [];
      if (!list.contains(jobId.toString())) {
        list.add(jobId.toString());
        await prefs.setStringList(key, list);
      }
    } catch (e) {
      developer.log(
        "⚠️ [$_tag] Failed to persist applied job $jobId: $e",
        name: _tag,
      );
    }
  }

  Future<int> _resolveWorkerId() async {
    if (workerId.value != 0) return workerId.value;
    final id = await SessionManager.getUserId();
    final parsed = int.tryParse('${id ?? ''}') ?? 0;
    workerId.value = parsed;
    return parsed;
  }

  void _updateJobStateLocally(int jobId, String newState) {
    final idx = jobs.indexWhere((j) => j.id == jobId);
    if (idx == -1) return;
    jobs[idx] = jobs[idx].copyWith(state: newState);
  }

  Future<JobActionResult> cancelJob(int jobId) async {
    final wId = await _resolveWorkerId();
    final result = await JobService.cancelJob(jobId: jobId, userId: wId);
    if (result.success) {
      _updateJobStateLocally(jobId, 'CANCELLED');
    }
    return result;
  }

  Future<JobActionResult> completeJob(int jobId) async {
    final wId = await _resolveWorkerId();
    final result = await WorkerJobService.completeJob(
      jobId: jobId,
      workerId: wId,
    );
    if (result.success) {
      _updateJobStateLocally(jobId, 'COMPLETED');
    }
    return result;
  }
}
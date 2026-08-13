import 'dart:convert';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:helper_app2/Core/Apis/sessionmanager.dart';
import '../../Features/WorkerSide/WorkerBottomNavigation/Workerhomesection/workerexplorejobmodel.dart';
import 'jobactionresult.dart';
class WorkerApiConfig {
  static const String baseUrl = "https://helpr.digital/api";
  static const String exploreJobsEndpoint = "$baseUrl/worker/jobs/explore";
  static const String applyJobEndpoint = "$baseUrl/worker/apply";
  static const String myJobsEndpoint = "$baseUrl/worker/my-jobs";

  // NEW: job lifecycle endpoints (worker side)
  static const String completeJobEndpoint = "$baseUrl/worker/jobs/complete";
  static const String confirmWorkerEndpoint = "$baseUrl/worker/jobs/confirm-worker";
}
class ApplyJobResult {
  final bool success;
  final String message;
  final int? applicationId;

  ApplyJobResult({
    required this.success,
    required this.message,
    this.applicationId,
  });
}

/// ============================================================
/// MY JOBS RESULT WRAPPER
/// ============================================================
class WorkerMyJobsResult {
  final List<WorkerMyJobModel> activeJobs;
  final List<WorkerMyJobModel> pastJobs;

  WorkerMyJobsResult({required this.activeJobs, required this.pastJobs});
}
class WorkerJobService {
  static const String _tag = "WorkerJobService";

  // NEW: Common request timeout — koi bhi API call ab is se zyada
  // der tak "latka" nahi rahega (connection issue ki soorat mein
  // bhi ye khud fail ho kar catch block mein chala jayega).
  static const Duration _requestTimeout = Duration(seconds: 15);

  static Future<int> _getWorkerId() async {
    try {
      final id = await SessionManager.getUserId();
      final parsed = int.tryParse('${id ?? ''}') ?? 0;
      developer.log("👷 [$_tag] Resolved worker_id = $parsed", name: _tag);
      return parsed;
    } catch (e) {
      developer.log("⚠️ [$_tag] Could not resolve worker_id: $e", name: _tag);
      return 0;
    }
  }

  static String _normalizeCityForApi(String city) {
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

  static Future<List<WorkerExploreJobModel>> exploreJobs({required String city}) async {
    try {
      final workerId = await _getWorkerId();
      if (workerId == 0) return [];

      final normalizedCity = _normalizeCityForApi(city);

      final response = await http.post(
        Uri.parse(WorkerApiConfig.exploreJobsEndpoint),
        headers: const {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"city": normalizedCity, "worker_id": workerId}),
      ).timeout(_requestTimeout);

      // TEMP DEBUG — pura raw response is worker ke liye
      developer.log("🔍 [exploreJobs] worker_id=$workerId RAW: ${response.body}", name: _tag);

      if (response.statusCode != 200) return [];
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] != true) return [];

      final List<dynamic> list = (data['data'] as List?) ?? [];

      // TEMP DEBUG — sirf un jobs ka data jinme koi na koi selected_worker_id ho
      for (final item in list) {
        if (item is Map && item['selected_worker_id'] != null) {
          developer.log("🔍 [exploreJobs] job ${item['id']} -> selected_worker_id=${item['selected_worker_id']} (type: ${item['selected_worker_id'].runtimeType})", name: _tag);
        }
      }
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final Map<String, dynamic>? clientInfo =
          item['client_info'] is Map
              ? Map<String, dynamic>.from(item['client_info'])
              : null;

          developer.log(
            "👤 JOB ${item['id']} | "
                "client_id: ${clientInfo?['id']} | "
                "client_name: ${clientInfo?['name']} | "
                "client_is_online RAW: ${clientInfo?['is_online']} | "
                "selected_worker_id: ${item['selected_worker_id']} | "
                "state: ${item['state']}",
            name: _tag,
          );
        }
      }
      return list.whereType<Map<String, dynamic>>().map((e) => WorkerExploreJobModel.fromJson(e)).toList();
    } catch (e, st) {
      developer.log("❌ exploreJobs EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return [];
    }
  }

  static Future<ApplyJobResult> applyForJob(int jobId) async {
    try {
      final workerId = await _getWorkerId();
      final response = await http.post(
        Uri.parse(WorkerApiConfig.applyJobEndpoint),
        headers: const {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"worker_id": workerId, "job_id": jobId}),
      ).timeout(_requestTimeout);

      final data = jsonDecode(response.body);
      return ApplyJobResult(
        success: data['success'] == true,
        message: data['message']?.toString() ?? 'worker_job_applied_success'.tr,
        applicationId: data['application_id'] != null ? int.tryParse('${data['application_id']}') : null,
      );
    } catch (e) {
      return ApplyJobResult(success: false, message: "Error: $e");
    }
  }

  static Future<WorkerMyJobsResult> getMyJobs() async {
    try {
      final workerId = await _getWorkerId();
      if (workerId == 0) return WorkerMyJobsResult(activeJobs: [], pastJobs: []);

      final response = await http.post(
        Uri.parse(WorkerApiConfig.myJobsEndpoint),
        headers: const {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"worker_id": workerId}),
      ).timeout(_requestTimeout);

      if (response.statusCode != 200) return WorkerMyJobsResult(activeJobs: [], pastJobs: []);

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['success'] != true) return WorkerMyJobsResult(activeJobs: [], pastJobs: []);

      final List<dynamic> activeJson = (data['active_jobs'] as List?) ?? [];
      final List<dynamic> pastJson = (data['past_jobs'] as List?) ?? [];

      return WorkerMyJobsResult(
        activeJobs: activeJson.whereType<Map<String, dynamic>>().map((e) => WorkerMyJobModel.fromJson(e)).toList(),
        pastJobs: pastJson.whereType<Map<String, dynamic>>().map((e) => WorkerMyJobModel.fromJson(e)).toList(),
      );
    } catch (e, st) {
      developer.log("❌ getMyJobs EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return WorkerMyJobsResult(activeJobs: [], pastJobs: []);
    }
  }
  static Future<JobActionResult> completeJob({required int jobId, required int workerId}) async {
    try {
      developer.log("📡 [$_tag] COMPLETE JOB -> ${WorkerApiConfig.completeJobEndpoint}", name: _tag);
      developer.log("📡 [$_tag] Request Body: {job_id: $jobId, worker_id: $workerId}", name: _tag);

      final response = await http.post(
        Uri.parse(WorkerApiConfig.completeJobEndpoint),
        headers: const {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"job_id": jobId, "worker_id": workerId}),
      ).timeout(_requestTimeout);

      developer.log("📥 [$_tag] Complete Job Status: ${response.statusCode}", name: _tag);
      developer.log("📥 [$_tag] Complete Job Body: ${response.body}", name: _tag);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      final success = data['success'] == true;
      return JobActionResult(
        success: success,
        message: data['message']?.toString() ?? (success ? 'worker_job_complete_success'.tr : 'worker_job_complete_unable'.tr),
      );
    } catch (e, st) {
      developer.log("❌ [$_tag] completeJob EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return JobActionResult(success: false, message: 'worker_job_error_something_went_wrong'.tr);
    }
  }

  /// ------------------------------------------------------------
  /// NEW: CONFIRM WORKER (worker-side confirmation, after client
  /// has confirmed quality first)
  /// URL: https://helpr.digital/api/worker/jobs/confirm-worker
  /// Body: { "job_id": <int>, "worker_id": <int> }
  /// ------------------------------------------------------------
  static Future<JobActionResult> confirmWorker({required int jobId, required int workerId}) async {
    try {
      developer.log("📡 [$_tag] CONFIRM WORKER -> ${WorkerApiConfig.confirmWorkerEndpoint}", name: _tag);
      developer.log("📡 [$_tag] Request Body: {job_id: $jobId, worker_id: $workerId}", name: _tag);

      final response = await http.post(
        Uri.parse(WorkerApiConfig.confirmWorkerEndpoint),
        headers: const {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"job_id": jobId, "worker_id": workerId}),
      ).timeout(_requestTimeout);

      developer.log("📥 [$_tag] Confirm Worker Status: ${response.statusCode}", name: _tag);
      developer.log("📥 [$_tag] Confirm Worker Body: ${response.body}", name: _tag);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      final success = data['success'] == true;
      return JobActionResult(
        success: success,
        message: data['message']?.toString() ?? (success ? 'worker_job_confirm_success'.tr : 'worker_job_confirm_unable'.tr),
      );
    } catch (e, st) {
      developer.log("❌ [$_tag] confirmWorker EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return JobActionResult(success: false, message: 'worker_job_error_something_went_wrong'.tr);
    }
  }
}
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Apis/sessionmanager.dart';
import 'package:http/http.dart' as http;
import '../../Features/ClientsSide/ClientBottomNavigation/clienthomesection/clientjobmodel.dart';
import 'jobactionresult.dart';

/// ============================================================
/// API CONFIG
/// ============================================================
class ApiConfig {
  static const String baseUrl = "https://helpr.digital/api";
  static const String getClientHomeEndpoint = "$baseUrl/client/home";
  static const String createJobEndpoint = "$baseUrl/client/jobs/create";
  static const String interestedWorkersEndpoint = "$baseUrl/client/jobs/interested-workers";

  // Job lifecycle endpoints (client side)
  static const String cancelJobEndpoint = "$baseUrl/client/jobs/cancel";
  static const String confirmClientEndpoint = "$baseUrl/client/jobs/confirm-client";

  // NEW: worker selection endpoint (client accepts an applicant permanently, backend-persisted)
  static const String selectWorkerEndpoint = "$baseUrl/client/jobs/select-worker";
}

/// ============================================================
/// USER DETAILS MODEL (from Get Home Data response)
/// ============================================================
class UserDetailsModel {
  final int id;
  final String username;
  final String email;
  final String? profilePic;
  final String status;
  final String walletBalance;
  final double rating;
  final bool? isOnline;

  UserDetailsModel({
    required this.id,
    required this.username,
    required this.email,
    this.profilePic,
    required this.status,
    required this.walletBalance,
    required this.rating,
    this.isOnline,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      profilePic: json['profile_pic']?.toString(),
      status: json['status']?.toString() ?? 'active',
      walletBalance: json['wallet_balance']?.toString() ?? '0.00',
      rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
      isOnline: _parseOnlineStatus(json['is_online']),
    );
  }
  static bool? _parseOnlineStatus(dynamic value) {
    if (value == null) return null;

    if (value is bool) return value;

    if (value is int) {
      if (value == 1) return true;
      if (value == 0) return false;
    }

    final normalized = value.toString().trim().toLowerCase();

    if (normalized == '1' ||
        normalized == 'true' ||
        normalized == 'online') {
      return true;
    }

    if (normalized == '0' ||
        normalized == 'false' ||
        normalized == 'offline') {
      return false;
    }

    return null;
  }
}

/// ============================================================
/// GET HOME DATA — RESPONSE WRAPPER
/// ============================================================
class ClientHomeResponse {
  final UserDetailsModel? userDetails;
  final List<JobPostModel> activeJobs;
  final List<JobPostModel> inactiveJobs;

  ClientHomeResponse({
    required this.userDetails,
    required this.activeJobs,
    required this.inactiveJobs,
  });
}

/// ============================================================
/// CREATE JOB — RESULT WRAPPER
/// ============================================================
class CreateJobResult {
  final bool success;
  final String message;
  final JobPostModel? job;

  CreateJobResult({required this.success, required this.message, this.job});
}

/// ============================================================
/// JOB SERVICE — saari job-related API calls yahin se hoti hain
/// ============================================================
class JobService {
  static const String _tag = "JobService";

  static Future<int> _getClientId() async {
    try {
      final id = await SessionManager.getUserId();
      final parsed = int.tryParse('${id ?? ''}') ?? 0;
      developer.log("👤 [$_tag] Resolved client_id = $parsed", name: _tag);
      return parsed;
    } catch (e) {
      developer.log("⚠️ [$_tag] Could not resolve client_id from SessionManager: $e", name: _tag);
      return 0;
    }
  }

  static Future<String> _encodeImageFile(File file) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final ext = file.path.split('.').last.toLowerCase();
    final mime = (ext == 'jpg' || ext == 'jpeg')
        ? 'image/jpeg'
        : (ext == 'webp' ? 'image/webp' : 'image/png');
    return 'data:$mime;base64,$base64Str';
  }

  static Future<List<String>> encodeImagesForUpload(List<File> files) async {
    final List<String> encoded = [];
    for (final file in files) {
      try {
        final data = await _encodeImageFile(file);
        encoded.add(data);
        developer.log("🖼️ [$_tag] Encoded image (${file.path.split('/').last})", name: _tag);
      } catch (e) {
        developer.log("⚠️ [$_tag] Failed to encode image ${file.path}: $e", name: _tag);
      }
    }
    return encoded;
  }

  static Future<ClientHomeResponse?> getClientHomeData() async {
    try {
      final clientId = await _getClientId();
      if (clientId == 0) {
        developer.log("❌ [$_tag] getClientHomeData aborted — no client_id in session", name: _tag);
        return null;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.getClientHomeEndpoint),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"client_id": clientId}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        developer.log("❌ [$_tag] Non-200 response for home data", name: _tag);
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (data['success'] != true) {
        developer.log("❌ [$_tag] success=false in home data response", name: _tag);
        return null;
      }

      final userJson = data['user_details'];
      final List<dynamic> activeJson = (data['active_jobs'] as List?) ?? [];
      final List<dynamic> inactiveJson = (data['inactive_jobs'] as List?) ?? [];

      final result = ClientHomeResponse(
        userDetails: userJson != null ? UserDetailsModel.fromJson(userJson) : null,
        activeJobs: activeJson
            .whereType<Map<String, dynamic>>()
            .map((e) => JobPostModel.fromJson(e))
            .toList(),
        inactiveJobs: inactiveJson
            .whereType<Map<String, dynamic>>()
            .map((e) => JobPostModel.fromJson(e))
            .toList(),
      );

      return result;
    } catch (e, st) {
      developer.log("❌ [$_tag] getClientHomeData EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return null;
    }
  }

  static Future<CreateJobResult> createJob({
    required String category,
    String? subcategory,
    required String title,
    required String city,
    required String description,
    required String budgetType,
    double? amount,
    double? perHourRate,
    double? estimatedHours,
    String? paymentMode,
    required String location,
    double? latitude,      // NEW
    double? longitude,     // NEW
    required String dateType,
    String? customDate,
    required String startTime,
    required String endTime,
    required String schedule,
    required String urgency,
    List<String>? images,
  }) async {
    try {
      final clientId = await _getClientId();
      if (clientId == 0) {
        developer.log("❌ [$_tag] createJob aborted — no client_id in session", name: _tag);
        return CreateJobResult(
          success: false,
          message: 'job_error_not_logged_in'.tr,
        );
      }

      final Map<String, dynamic> body = {
        "client_id": clientId,
        "category": category,
        "subcategory": subcategory,
        "title": title,
        "city": city,
        "description": description,
        "budget_type": budgetType,
        "amount": amount,
        "per_hour_rate": perHourRate,
        "estimated_hours": estimatedHours,
        "payment_mode": paymentMode,
        "location": location,
        if (latitude != null) "latitude": latitude,     // NEW
        if (longitude != null) "longitude": longitude, // NEW
        "date_type": dateType,
        if (customDate != null) "custom_date": customDate,
        "start_time": startTime,
        "end_time": endTime,
        "schedule": schedule,
        "urgency": urgency,
        "images": (images == null || images.isEmpty) ? null : images,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.createJobEndpoint),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      );

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        developer.log("⚠️ [$_tag] Could not parse response body as JSON", name: _tag);
      }

      if ((response.statusCode == 200 || response.statusCode == 201) && data['success'] == true) {
        final jobJson = data['job'];
        return CreateJobResult(
          success: true,
          message: data['message']?.toString() ?? 'job_success_posted'.tr,
          job: jobJson != null ? JobPostModel.fromJson(jobJson) : null,
        );
      }

      return CreateJobResult(
        success: false,
        message: data['message']?.toString() ?? 'job_error_failed_post'.tr,
      );
    } catch (e, st) {
      developer.log("❌ [$_tag] createJob EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return CreateJobResult(
        success: false,
        message: 'job_error_something_went_wrong'.tr,
      );
    }
  }
  static Future<List<WorkerApplicant>> getInterestedWorkers(int jobId) async {
    try {
      developer.log(
        "📡 [$_tag] INTERESTED WORKERS -> ${ApiConfig.interestedWorkersEndpoint}",
        name: _tag,
      );

      developer.log(
        "📤 [$_tag] Request Body: {job_id: $jobId}",
        name: _tag,
      );

      final response = await http.post(
        Uri.parse(ApiConfig.interestedWorkersEndpoint),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "job_id": jobId,
        }),
      );

      // IMPORTANT:
      // Yahan actual backend is_online value console mein nazar ayegi.
      developer.log(
        "📥 [$_tag] Interested Workers Status: ${response.statusCode}",
        name: _tag,
      );

      developer.log(
        "🟣 [$_tag] Interested Workers RAW RESPONSE: ${response.body}",
        name: _tag,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        developer.log(
          "❌ [$_tag] Non-200 interested workers response for job $jobId",
          name: _tag,
        );
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        developer.log(
          "❌ [$_tag] Invalid interested workers response format",
          name: _tag,
        );
        return [];
      }

      if (decoded['success'] != true) {
        developer.log(
          "❌ [$_tag] Interested workers success=false",
          name: _tag,
        );
        return [];
      }

      final rawList = decoded['data'];

      if (rawList is! List) {
        developer.log(
          "⚠️ [$_tag] Interested workers data is not a list",
          name: _tag,
        );
        return [];
      }

      final workers = rawList
          .whereType<Map<String, dynamic>>()
          .map(WorkerApplicant.fromJson)
          .toList();

      // Debug parsed values
      for (final worker in workers) {
        developer.log(
          "👷 [$_tag] Worker ${worker.workerId} "
              "(${worker.name}) -> isOnline: ${worker.isOnline}",
          name: _tag,
        );
      }

      return workers;
    } catch (e, stackTrace) {
      developer.log(
        "❌ [$_tag] getInterestedWorkers EXCEPTION: $e",
        name: _tag,
        error: e,
        stackTrace: stackTrace,
      );

      return [];
    }
  }
  /// ------------------------------------------------------------
  /// CANCEL JOB
  /// URL: https://helpr.digital/api/client/jobs/cancel
  /// Body: { "job_id": <int>, "user_id": <int> }
  /// ------------------------------------------------------------
  static Future<JobActionResult> cancelJob({required int jobId, required int userId}) async {
    try {
      developer.log("📡 [$_tag] CANCEL JOB -> ${ApiConfig.cancelJobEndpoint}", name: _tag);
      developer.log("📡 [$_tag] Request Body: {job_id: $jobId, user_id: $userId}", name: _tag);

      final response = await http.post(
        Uri.parse(ApiConfig.cancelJobEndpoint),
        headers: const {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"job_id": jobId, "user_id": userId}),
      );

      developer.log("📥 [$_tag] Cancel Job Status: ${response.statusCode}", name: _tag);
      developer.log("📥 [$_tag] Cancel Job Body: ${response.body}", name: _tag);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      final success = data['success'] == true;
      return JobActionResult(
        success: success,
        message: data['message']?.toString() ?? (success ? 'job_cancelled_success'.tr : 'job_cancelled_unable'.tr),
      );
    } catch (e, st) {
      developer.log("❌ [$_tag] cancelJob EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return JobActionResult(success: false, message: 'job_error_something_went_wrong'.tr);
    }
  }

  /// ------------------------------------------------------------
  /// CONFIRM CLIENT (quality confirmation by client)
  /// URL: https://helpr.digital/api/client/jobs/confirm-client
  /// Body: { "job_id": <int>, "user_id": <int> }
  /// ------------------------------------------------------------
  static Future<JobActionResult> confirmClient({required int jobId, required int userId}) async {
    try {
      developer.log("📡 [$_tag] CONFIRM CLIENT -> ${ApiConfig.confirmClientEndpoint}", name: _tag);
      developer.log("📡 [$_tag] Request Body: {job_id: $jobId, user_id: $userId}", name: _tag);

      final response = await http.post(
        Uri.parse(ApiConfig.confirmClientEndpoint),
        headers: const {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"job_id": jobId, "user_id": userId}),
      );

      developer.log("📥 [$_tag] Confirm Client Status: ${response.statusCode}", name: _tag);
      developer.log("📥 [$_tag] Confirm Client Body: ${response.body}", name: _tag);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      final success = data['success'] == true;
      return JobActionResult(
        success: success,
        message: data['message']?.toString() ?? (success ? 'job_confirmed_success'.tr : 'job_confirmed_unable'.tr),
      );
    } catch (e, st) {
      developer.log("❌ [$_tag] confirmClient EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return JobActionResult(success: false, message: 'job_error_something_went_wrong'.tr);
    }
  }

  /// ------------------------------------------------------------
  /// NEW: SELECT WORKER
  /// Client kisi applicant ko permanently select karta hai — is
  /// call ke baad job backend par CHAT_ENABLED / selected_worker_id
  /// set ho jata hai, is liye logout/login ya app restart ke baad
  /// bhi state sahi (backend se) load hogi.
  /// URL: https://helpr.digital/api/client/jobs/select-worker
  /// Body: { "job_id": <int>, "worker_id": <int>, "user_id": <int> }
  /// ------------------------------------------------------------
  static Future<JobActionResult> selectWorker({
    required int jobId,
    required int workerId,
    required int userId,
  }) async {
    try {
      developer.log("📡 [$_tag] SELECT WORKER -> ${ApiConfig.selectWorkerEndpoint}", name: _tag);
      developer.log("📡 [$_tag] Request Body: {job_id: $jobId, worker_id: $workerId, user_id: $userId}", name: _tag);

      final response = await http.post(
        Uri.parse(ApiConfig.selectWorkerEndpoint),
        headers: const {"Content-Type": "application/json", "Accept": "application/json"},
        body: jsonEncode({"job_id": jobId, "worker_id": workerId, "user_id": userId}),
      );

      developer.log("📥 [$_tag] Select Worker Status: ${response.statusCode}", name: _tag);
      developer.log("📥 [$_tag] Select Worker Body: ${response.body}", name: _tag);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      final success = data['success'] == true;
      return JobActionResult(
        success: success,
        message: data['message']?.toString() ?? (success ? 'job_select_worker_success'.tr : 'job_select_worker_unable'.tr),
      );
    } catch (e, st) {
      developer.log("❌ [$_tag] selectWorker EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return JobActionResult(success: false, message: 'job_error_something_went_wrong'.tr);
    }
  }
}
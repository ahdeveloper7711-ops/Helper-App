import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WorkerImageUtils {
  static const String _baseHost = "https://helpr.digital";

  static String resolve(String? raw) {
    if (raw == null) return '';
    final url = raw.trim();
    if (url.isEmpty) return '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return '$_baseHost$cleanPath';
  }
}

class WorkerExploreJobModel {
  final int id;
  final int clientId;
  final String category;
  final String title;
  final String description;
  final String amount;
  final String location;
  final String city;
  final double? latitude;   // ← ADD
  final double? longitude;
  final String schedule;
  final String paymentMode;
  final String state;
  final String status;
  final List<String> jobImages;
  final String postedAt;
  final WorkerJobClientInfo clientInfo;

  // NEW: job ko jis worker ke liye select kiya gaya hai uski id (backend se aati hai)
  final int? selectedWorkerId;

  const WorkerExploreJobModel({
    required this.id,
    required this.clientId,
    required this.category,
    required this.title,
    required this.description,
    this.latitude,    // ← ADD
    this.longitude,   // ← A
    required this.amount,
    required this.location,
    required this.city,
    required this.schedule,
    required this.paymentMode,
    required this.state,
    required this.status,
    required this.jobImages,
    required this.postedAt,
    required this.clientInfo,
    this.selectedWorkerId,
  });

  factory WorkerExploreJobModel.fromJson(Map<String, dynamic> json) {
    final rawImages = (json['job_images'] as List?) ??
        (json['images'] as List?) ??
        (json['photos'] as List?) ??
        [];


    return WorkerExploreJobModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      clientId: int.tryParse('${json['client_id'] ?? 0}') ?? 0,
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      location: json['location']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      latitude: json['latitude'] == null ? null : double.tryParse('${json['latitude']}'),   // ← ADD
      longitude: json['longitude'] == null ? null : double.tryParse('${json['longitude']}'),
      schedule: json['schedule']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      state: json['state']?.toString() ?? 'POSTED',
      status: json['status']?.toString() ?? 'active',
      jobImages: rawImages
          .map((e) => WorkerImageUtils.resolve(e?.toString()))
          .where((e) => e.isNotEmpty)
          .toList(),
      postedAt: json['posted_at']?.toString() ?? '',
      clientInfo: WorkerJobClientInfo.fromJson(
        (json['client_info'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      selectedWorkerId: json['selected_worker_id'] == null
          ? null
          : int.tryParse('${json['selected_worker_id']}'),
    );
  }

  /// -------------------- UI HELPERS --------------------

  bool get hasImages => jobImages.isNotEmpty;
  bool get hasCoordinates => latitude != null && longitude != null;  // ← ADD

  String get thumbnailUrl => hasImages ? jobImages.first : '';

  List<String> get fullImageUrls => jobImages;

  double get amountValue => double.tryParse(amount) ?? 0;

  String get amountLabel {
    if (amountValue <= 0) return 'worker_job_negotiable'.tr;
    return '${amountValue.toStringAsFixed(0)} ${'post_job_currency_uzs'.tr}';
  }

  String get subtitleLocation => location.isEmpty ? city : location;

  String get cityLabel => city.isEmpty ? 'worker_job_not_specified'.tr : city;

  String get paymentModeLabel {
    switch (paymentMode.toLowerCase()) {
      case 'cash':
        return 'worker_job_payment_cash'.tr;
      case 'card':
        return 'worker_job_payment_card'.tr;
      case 'escrow':
        return 'worker_job_payment_escrow'.tr;
      case 'commission_only':
        return 'worker_job_payment_commission'.tr;
      default:
        return paymentMode;
    }
  }

  String get stateLabel => state.replaceAll('_', ' ');

  // NEW: kisi bhi worker ko job mil chuki hai ya nahi
  bool get hasSelectedWorker => selectedWorkerId != null && selectedWorkerId != 0;

  // NEW: yeh check karta hai ke di gayi worker id hi selected worker hai
  bool isSelectedFor(int workerId) => hasSelectedWorker && selectedWorkerId == workerId;

  // lifecycle-state helpers (accept/cancel/complete flow ke liye)
  bool get isConfirmed => hasSelectedWorker || state.toUpperCase() == 'CHAT_ENABLED';
  bool get isCompleted => state.toUpperCase() == 'COMPLETED';
  bool get isCancelled => state.toUpperCase() == 'CANCELLED';

  // local-state update ke liye (cancel/complete/select ke baad UI turant refresh ho)
  WorkerExploreJobModel copyWith({String? state, int? selectedWorkerId}) {
    return WorkerExploreJobModel(
      id: id,
      clientId: clientId,
      category: category,
      title: title,
      description: description,
      amount: amount,
      latitude: latitude,      // ← ADD
      longitude: longitude,
      location: location,
      city: city,
      schedule: schedule,
      paymentMode: paymentMode,
      state: state ?? this.state,
      status: status,
      jobImages: jobImages,
      postedAt: postedAt,
      clientInfo: clientInfo,
      selectedWorkerId: selectedWorkerId ?? this.selectedWorkerId,
    );
  }
}

class WorkerJobClientInfo {
  final int id;
  final String name;
  final String? image;
  final double rating;

  // client ka online/offline status
  final bool isOnline;

  const WorkerJobClientInfo({
    required this.id,
    required this.name,
    this.image,
    required this.rating,
    this.isOnline = false,
  });

  factory WorkerJobClientInfo.fromJson(Map<String, dynamic> json) {
    final rawImage = json['image']?.toString() ??
        json['profile_image']?.toString() ??
        json['profile_pic']?.toString() ??
        json['avatar']?.toString();

    final resolvedImage = WorkerImageUtils.resolve(rawImage);

    return WorkerJobClientInfo(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      name: json['name']?.toString() ??
          json['username']?.toString() ??
          'worker_job_client_fallback'.tr,
      image: resolvedImage.isEmpty ? null : resolvedImage,
      rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,

      // Online / Offline
      isOnline: _parseOnlineStatus(json['is_online']),
    );
  }

  static bool _parseOnlineStatus(dynamic value) {
    if (value == null) return false;

    if (value is bool) return value;

    if (value is int) {
      return value == 1;
    }

    final normalized = value.toString().trim().toLowerCase();

    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'online';
  }

  bool get hasImage => image != null && image!.isNotEmpty;
}

// ============================================================
// ⚠️ Ye sirf "WorkerMyJobModel" class ka NAYA version hai.
// workerexplorejobmodel.dart file ke andar jo purana
// "class WorkerMyJobModel { ... }" block hai, usko poora
// hata kar neeche wale se replace kar dein.
// Baki file (WorkerImageUtils, WorkerExploreJobModel,
// WorkerJobClientInfo) bilkul waisi hi rehne dein.
// ============================================================

class WorkerMyJobModel {
  final int id;
  final int clientId;
  final String category;
  final String title;
  final String description;
  final String amount;
  final String location;
  final String city;
  final String schedule;
  final double? latitude;
  final double? longitude;
  final String paymentMode;
  final String state;
  final String status;
  final List<String> jobImages;
  final String postedAt;
  final String appliedCount;
  final WorkerJobClientInfo clientInfo;

  // job kis worker ke liye select hui hai uski id (agar select hui ho)
  final int? selectedWorkerId;

  const WorkerMyJobModel({
    required this.id,
    required this.clientId,
    required this.category,
    required this.title,
    required this.description,
    required this.amount,
    required this.location,
    required this.city,
    required this.schedule,
    this.latitude,
    this.longitude,
    required this.paymentMode,
    required this.state,
    required this.status,
    required this.jobImages,
    required this.postedAt,
    required this.appliedCount,
    required this.clientInfo,
    this.selectedWorkerId,
  });

  factory WorkerMyJobModel.fromJson(Map<String, dynamic> json) {
    final rawImages = (json['job_images'] as List?) ??
        (json['images'] as List?) ??
        (json['photos'] as List?) ??
        [];

    return WorkerMyJobModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      clientId: int.tryParse('${json['client_id'] ?? 0}') ?? 0,
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      location: json['location']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      latitude: json['latitude'] == null
          ? null
          : double.tryParse('${json['latitude']}'),   // ← ADD
      longitude: json['longitude'] == null
          ? null
          : double.tryParse('${json['longitude']}'),
      schedule: json['schedule']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      jobImages: rawImages
          .map((e) => WorkerImageUtils.resolve(e?.toString()))
          .where((e) => e.isNotEmpty)
          .toList(),
      postedAt: json['posted_at']?.toString() ?? '',
      appliedCount: json['applied_count']?.toString() ?? '',
      clientInfo: WorkerJobClientInfo.fromJson(
        (json['client_info'] as Map?)?.cast<String, dynamic>() ?? {},
      ),
      selectedWorkerId: json['selected_worker_id'] == null
          ? null
          : int.tryParse('${json['selected_worker_id']}'),
    );
  }

  /// Apply karte hi turant "My Jobs" mein dikhane ke liye optimistic entry —
  /// server confirm karne se pehle hi explore-model se my-job model banata hai.
  factory WorkerMyJobModel.fromExploreModel(WorkerExploreJobModel job) {
    return WorkerMyJobModel(
      id: job.id,
      clientId: job.clientId,
      category: job.category,
      title: job.title,
      description: job.description,
      amount: job.amount,
      location: job.location,
      city: job.city,
      schedule: job.schedule,
      paymentMode: job.paymentMode,
      state: job.state,
      latitude: job.latitude,    // ← ADD
      longitude: job.longitude,
      status: 'APPLIED',
      jobImages: job.jobImages,
      postedAt: job.postedAt,
      appliedCount: '',
      clientInfo: job.clientInfo,
      selectedWorkerId: job.selectedWorkerId,
    );
  }

  /// -------------------- UI HELPERS --------------------
  /// (WorkerExploreJobModel ke bilkul same helpers, taake
  /// WorkerJobHistoryCard bhi WorkerJobCard jaisa hi UI dikha sake)

  bool get hasImages => jobImages.isNotEmpty;
  bool get hasCoordinates => latitude != null && longitude != null;

  String get thumbnailUrl => hasImages ? jobImages.first : '';

  List<String> get fullImageUrls => jobImages;

  double get amountValue => double.tryParse(amount) ?? 0;

  String get amountLabel {
    if (amountValue <= 0) return 'worker_job_negotiable'.tr;
    return '${amountValue.toStringAsFixed(0)} ${'post_job_currency_uzs'.tr}';
  }

  String get subtitleLocation => location.isEmpty ? city : location;

  String get cityLabel => city.isEmpty ? 'worker_job_not_specified'.tr : city;

  String get paymentModeLabel {
    switch (paymentMode.toLowerCase()) {
      case 'cash':
        return 'worker_job_payment_cash'.tr;
      case 'card':
        return 'worker_job_payment_card'.tr;
      case 'escrow':
        return 'worker_job_payment_escrow'.tr;
      case 'commission_only':
        return 'worker_job_payment_commission'.tr;
      default:
        return paymentMode;
    }
  }

  String get stateLabel => state.replaceAll('_', ' ');

  bool get hasSelectedWorker => selectedWorkerId != null && selectedWorkerId != 0;

  bool isSelectedFor(int workerId) => hasSelectedWorker && selectedWorkerId == workerId;

  bool get isConfirmed => hasSelectedWorker || state.toUpperCase() == 'CHAT_ENABLED';
  bool get isCompleted => state.toUpperCase() == 'COMPLETED' || status.toUpperCase() == 'COMPLETED';
  bool get isCancelled => state.toUpperCase() == 'CANCELLED' || status.toUpperCase() == 'CANCELLED';
}
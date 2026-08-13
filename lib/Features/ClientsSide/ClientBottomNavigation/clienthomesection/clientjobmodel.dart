import 'package:flutter/material.dart';
import 'package:get/get.dart';

@immutable
class AttributeTag {
  final String text;
  final Color color;
  final bool filled;

  const AttributeTag({
    required this.text,
    required this.color,
    this.filled = false,
  });
}

@immutable
@immutable
class WorkerApplicant {
  final int workerId;
  final String name;
  final String profilePic;
  final double rating;
  final int activeStrikes;
  final List<String> skills;

  // Online / Offline status from backend
  final bool isOnline;

  const WorkerApplicant({
    required this.workerId,
    required this.name,
    this.profilePic = "",
    this.rating = 0,
    this.activeStrikes = 0,
    this.skills = const [],
    this.isOnline = false,
  });

  factory WorkerApplicant.fromJson(Map<String, dynamic> json) {
    return WorkerApplicant(
      workerId: int.tryParse('${json['worker_id'] ?? 0}') ?? 0,
      name: json['username']?.toString() ?? 'Unknown Worker',
      profilePic: json['profile_pic']?.toString() ?? '',
      rating: double.tryParse('${json['rating'] ?? 0}') ?? 0,
      activeStrikes:
      int.tryParse('${json['active_strikes'] ?? 0}') ?? 0,
      skills: (json['skills'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          const [],

      // IMPORTANT
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

  String get id => workerId.toString();

  String get ratingLabel =>
      rating > 0 ? rating.toStringAsFixed(1) : "New";

  bool get hasStrikes => activeStrikes > 0;

  bool get hasProfilePic => profilePic.trim().isNotEmpty;
}
@immutable
class JobPostModel {
  final int id;
  final int clientId;
  final int? selectedWorkerId;
  final String category;
  final String? subcategory;
  final String urgency;
  final String budgetType;
  final String title;
  final String description;
  final String? city;
  final String location;
  final double? latitude;   // NEW
  final double? longitude;  // NEW
  final double amount;
  final double? perHourRate;
  final double? estimatedHours;
  final String? paymentMode;
  final String? dateType;
  final String? customDate;
  final String? startTime;
  final String? endTime;
  final String schedule;
  final String status;
  final String state;
  final List<String> images;
  final String? categoryIconUrl;
  final String postedAt;
  final bool isPriority;

  const JobPostModel({
    required this.id,
    required this.clientId,
    this.selectedWorkerId,
    required this.category,
    this.subcategory,
    required this.urgency,
    required this.budgetType,
    required this.title,
    required this.description,
    this.city,
    required this.location,
    this.latitude,      // NEW
    this.longitude,     // NEW
    required this.amount,
    this.perHourRate,
    this.estimatedHours,
    this.paymentMode,
    this.dateType,
    this.customDate,
    this.startTime,
    this.endTime,
    required this.schedule,
    required this.status,
    required this.state,
    this.images = const [],
    this.categoryIconUrl,
    this.postedAt = "",
    this.isPriority = false,
  });

  factory JobPostModel.fromJson(Map<String, dynamic> json) {
    return JobPostModel(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      clientId: int.tryParse('${json['client_id'] ?? 0}') ?? 0,
      selectedWorkerId: (json['selected_worker_id'] == null)
          ? null
          : int.tryParse('${json['selected_worker_id']}'),
      category: json['category']?.toString() ?? 'model_job_general'.tr,
      subcategory: (json['subcategory'] == null || json['subcategory'].toString().trim().isEmpty)
          ? null
          : json['subcategory'].toString(),
      urgency: json['urgency']?.toString() ?? 'normal',
      budgetType: json['budget_type']?.toString() ?? 'fixed price',
      title: json['title']?.toString() ?? 'model_job_untitled'.tr,
      description: json['description']?.toString() ?? '',
      city: json['city']?.toString(),
      location: json['location']?.toString() ?? '',
      latitude: json['latitude'] == null ? null : double.tryParse('${json['latitude']}'),   // NEW
      longitude: json['longitude'] == null ? null : double.tryParse('${json['longitude']}'), // NEW
      amount: double.tryParse('${json['amount'] ?? 0}') ?? 0,
      perHourRate: json['per_hour_rate'] == null ? null : double.tryParse('${json['per_hour_rate']}'),
      estimatedHours: json['estimated_hours'] == null ? null : double.tryParse('${json['estimated_hours']}'),
      paymentMode: json['payment_mode']?.toString(),
      dateType: json['date_type']?.toString(),
      customDate: json['custom_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      schedule: json['schedule']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      state: json['state']?.toString() ?? 'POSTED',
      images: _parseImages(json['images']),
      categoryIconUrl: json['category_icon']?.toString(),
      postedAt: json['posted_at']?.toString() ?? '',
      isPriority: json['is_priority'] == 1 || json['is_priority'] == true,
    );
  }

  static List<String> _parseImages(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  bool get isUrgent => urgency.toLowerCase() == 'urgent' || urgency.toLowerCase() == 'critical';
  bool get isFlexible => urgency.toLowerCase() == 'flexible';

  String get urgencyLabel {
    switch (urgency.toLowerCase()) {
      case 'urgent':
        return 'model_job_urgency_urgent'.tr;
      case 'critical':
        return 'model_job_urgency_critical'.tr;
      case 'flexible':
        return 'model_job_urgency_flexible'.tr;
      default:
        return 'model_job_urgency_normal'.tr;
    }
  }

  // Ab location ko prefer karte hain (city ki zaroorat nahi)
  String get subtitleLocation => location.trim().isNotEmpty ? location : (city ?? '—');

  String get cityLabel => (city != null && city!.trim().isNotEmpty) ? city! : '—';
  String get locationLabel => location.trim().isNotEmpty ? location : '—';

  bool get hasCoordinates => latitude != null && longitude != null;

  static const String _mediaBaseUrl = "https://helpr.digital/";

  List<String> get fullImageUrls {
    return images.map((path) {
      final trimmed = path.trim();
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return trimmed;
      }
      return "$_mediaBaseUrl$trimmed";
    }).toList();
  }

  bool get hasImages => images.isNotEmpty;
  bool get hasSelectedWorker => selectedWorkerId != null && selectedWorkerId != 0;
  bool get isConfirmed => hasSelectedWorker || state.toUpperCase() == 'CHAT_ENABLED';
  bool get isCompleted => state.toUpperCase() == 'COMPLETED';
  bool get isCancelled => state.toUpperCase() == 'CANCELLED';

  String get budgetTypeLabel {
    switch (budgetType.toLowerCase()) {
      case 'hourly rate':
        return 'model_job_budget_hourly'.tr;
      case 'negotiable':
        return 'model_job_budget_negotiable'.tr;
      default:
        return 'model_job_budget_fixed'.tr;
    }
  }

  String get priceLabel {
    switch (budgetType.toLowerCase()) {
      case 'hourly rate':
        return amount > 0
            ? '${amount.toStringAsFixed(0)} ${'post_job_currency_uzs'.tr}${'model_job_budget_hourly_suffix'.tr}'
            : 'model_job_budget_hourly_label'.tr;
      case 'negotiable':
        return 'model_job_budget_negotiable'.tr;
      default:
        return amount > 0
            ? '${amount.toStringAsFixed(0)} ${'post_job_currency_uzs'.tr}'
            : 'model_job_budget_fixed'.tr;
    }
  }

  String get budgetBreakdownLabel {
    switch (budgetType.toLowerCase()) {
      case 'hourly rate':
        final rate = perHourRate ?? amount;
        if (rate > 0) {
          final hrs = (estimatedHours != null && estimatedHours! > 0)
              ? ' · ~${estimatedHours!.toStringAsFixed(0)} hrs'
              : '';
          return '${rate.toStringAsFixed(0)} ${'post_job_currency_uzs'.tr} / hour$hrs';
        }
        return 'model_job_budget_hourly'.tr;
      case 'negotiable':
        return 'model_job_budget_to_be_discussed'.tr;
      default:
        return amount > 0
            ? '${amount.toStringAsFixed(0)} ${'post_job_currency_uzs'.tr} ${'model_job_budget_one_time'.tr}'
            : 'model_job_budget_fixed'.tr;
    }
  }

  String get paymentModeLabel {
    final mode = (paymentMode ?? '').toLowerCase().trim();
    switch (mode) {
      case 'card':
        return 'model_job_payment_card'.tr;
      case 'cash':
        return 'model_job_payment_cash'.tr;
      case 'wallet':
        return 'model_job_payment_wallet'.tr;
      case 'escrow':
        return 'model_job_payment_escrow'.tr;
      case 'commission_only':
        return 'model_job_payment_commission'.tr;
      default:
        return mode.isEmpty ? 'model_job_payment_not_specified'.tr : paymentMode!;
    }
  }

  IconData get paymentModeIcon {
    switch ((paymentMode ?? '').toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'escrow':
        return Icons.lock_outline_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  DateTime? get scheduleDateTime {
    final normalized = schedule.contains('T') ? schedule : schedule.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }

  String get scheduleDateLabel {
    if (customDate != null && customDate!.trim().isNotEmpty) return customDate!;
    final dt = scheduleDateTime;
    if (dt == null) return '—';
    return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
  }

  String get startTimeLabel {
    if (startTime != null && startTime!.trim().isNotEmpty) return startTime!;
    return _fallbackTimeLabel();
  }

  String get endTimeLabel {
    if (endTime != null && endTime!.trim().isNotEmpty) return endTime!;
    return '—';
  }

  String _fallbackTimeLabel() {
    final dt = scheduleDateTime;
    if (dt == null) return '—';
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  }

  String get dateTypeLabel {
    final type = (dateType ?? '').toLowerCase();
    if (type.contains('custom')) return 'model_job_datetype_custom'.tr;
    if (type == 'today') return 'model_job_datetype_today'.tr;
    return type.isEmpty ? '—' : dateType!;
  }

  List<AttributeTag> get attributes {
    final tags = <AttributeTag>[];
    if (isUrgent) {
      tags.add(AttributeTag(text: urgency.toUpperCase(), color: const Color(0xffEF4444), filled: true));
    }
    tags.add(AttributeTag(text: budgetTypeLabel, color: const Color(0xff3B82F6)));
    if (isPriority) {
      tags.add(AttributeTag(text: 'model_job_priority'.tr, color: Colors.amber, filled: true));
    }
    return tags;
  }

  Color get stateColor {
    switch (state.toUpperCase()) {
      case 'POSTED':
        return const Color(0xff3B82F6);
      case 'COMPLETED':
        return const Color(0xff10B981);
      case 'CANCELLED':
        return const Color(0xffEF4444);
      case 'DISPUTED':
        return const Color(0xffF59E0B);
      case 'INTEREST_COLLECTING':
        return const Color(0xff8B5CF6);
      case 'CHAT_ENABLED':
        return const Color(0xff06B6D4);
      default:
        return const Color(0xff9CA3AF);
    }
  }

  JobPostModel copyWith({int? selectedWorkerId, String? state}) {
    return JobPostModel(
      id: id,
      clientId: clientId,
      selectedWorkerId: selectedWorkerId ?? this.selectedWorkerId,
      category: category,
      subcategory: subcategory,
      urgency: urgency,
      budgetType: budgetType,
      title: title,
      description: description,
      city: city,
      location: location,
      latitude: latitude,
      longitude: longitude,
      amount: amount,
      perHourRate: perHourRate,
      estimatedHours: estimatedHours,
      paymentMode: paymentMode,
      dateType: dateType,
      customDate: customDate,
      startTime: startTime,
      endTime: endTime,
      schedule: schedule,
      status: status,
      state: state ?? this.state,
      images: images,
      categoryIconUrl: categoryIconUrl,
      postedAt: postedAt,
      isPriority: isPriority,
    );
  }
}
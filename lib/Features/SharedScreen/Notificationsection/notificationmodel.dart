import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationModel {
  final int id;
  final int userId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt:
      DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
      DateTime.tryParse(json['updated_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);

    if (diff.inSeconds < 60) return 'notification_time_just_now'.tr;
    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} ${'notification_time_min_ago'.tr}";
    }
    if (diff.inHours < 24) {
      return "${diff.inHours} ${'notification_time_hour_ago'.tr}";
    }
    if (diff.inDays < 30) {
      return "${diff.inDays} ${'notification_time_day_ago'.tr}";
    }

    final months = (diff.inDays / 30).floor();
    if (months < 12) {
      return "$months ${'notification_time_month_ago'.tr}";
    }

    final years = (diff.inDays / 365).floor();
    return "$years ${'notification_time_year_ago'.tr}";
  }

  IconData get icon {
    final t = title.toLowerCase();
    final m = message.toLowerCase();
    final tp = type.toLowerCase();

    if (tp.contains('work') || t.contains('application') || m.contains('applied')) {
      return Icons.work_outline;
    }
    if (tp.contains('payment') || t.contains('payment') || t.contains('escrow') || m.contains('wallet')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (tp.contains('chat') || t.contains('message') || t.contains('chat')) {
      return Icons.chat_bubble_outline;
    }
    if (tp.contains('security') || t.contains('verif') || t.contains('security')) {
      return Icons.verified_outlined;
    }
    return Icons.notifications_none_outlined;
  }
}
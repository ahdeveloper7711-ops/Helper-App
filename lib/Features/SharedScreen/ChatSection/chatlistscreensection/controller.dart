import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Core/Apis/chatservice.dart';
import '../../../../Core/Apis/sessionmanager.dart';
import '../../../../Core/Widgets/MediaqueryHelperfile.dart';
// NOTE: Please verify this path according to your project structure —
// import the SessionManager class from wherever it is located in your project.

/// ============================================================
/// CHAT LIST MODEL
/// ============================================================
class ChatListItem {
  final int userId;
  final String username;
  final String? profilePic;
  final String lastMessage;
  final String time;
  final int unreadCount;

  ChatListItem({
    required this.userId,
    required this.username,
    this.profilePic,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
  });

  factory ChatListItem.fromJson(Map<String, dynamic> json) {
    final pic = json["profile_pic"]?.toString();
    return ChatListItem(
      userId: int.tryParse(json["user_id"].toString()) ?? 0,
      username: json["username"]?.toString() ?? "Unknown",
      profilePic: (pic == null || pic.isEmpty) ? null : pic,
      lastMessage: json["last_message"]?.toString() ?? "",
      time: json["time"]?.toString() ?? "",
      unreadCount: int.tryParse(json["unread_count"].toString()) ?? 0,
    );
  }

  ChatListItem copyWith({int? unreadCount}) {
    return ChatListItem(
      userId: userId,
      username: username,
      profilePic: profilePic,
      lastMessage: lastMessage,
      time: time,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

/// ============================================================
/// CHAT LIST CONTROLLER
/// ============================================================
class ChatListController extends GetxController {
  ChatService get _chatService => Get.isRegistered<ChatService>()
      ? Get.find<ChatService>()
      : Get.put(ChatService(), permanent: true);

  /// =========================
  /// CHAT LIST DATA (now fetched from the API)
  /// =========================
  var chats = <ChatListItem>[].obs;
  var isLoading = false.obs;

  /// =========================
  /// SEARCH TEXT
  /// =========================
  var searchQuery = "".obs;

  int? get _myId => SessionManager.getUserId();

  @override
  void onInit() {
    super.onInit();
    fetchChatList();
  }

  /// =========================
  /// FETCH CHAT LIST (POST /chat/list)
  /// =========================
  Future<void> fetchChatList({bool silent = false}) async {
    final myId = _myId;
    if (myId == null) {
      Get.snackbar(
        'chat_controller_error_title'.tr,
        'chat_controller_session_expired'.tr,
          backgroundColor: Colors.grey,
          snackPosition: SnackPosition.BOTTOM,
          padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),
      );
      return;
    }

    if (!silent) isLoading.value = true;

    final result = await _chatService.getChatList(myId);

    if (result.success) {
      final List raw = result.data ?? [];
      chats.value = raw.map((e) => ChatListItem.fromJson(Map<String, dynamic>.from(e))).toList();
    } else if (!silent) {
      Get.snackbar(
        'chat_controller_error_title'.tr,
        result.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    if (!silent) isLoading.value = false;
  }

  void setSearch(String value) => searchQuery.value = value;

  /// =========================
  /// FILTERED CHATS
  /// =========================
  List<ChatListItem> get filteredChats {
    if (searchQuery.value.isEmpty) return chats;
    return chats
        .where((c) => c.username.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  /// =========================
  /// MARK AS READ (local only — there is currently no
  /// "mark as read" API on the backend, so only the UI is updated immediately)
  /// =========================
  void markAsReadLocally(int userId) {
    final index = chats.indexWhere((c) => c.userId == userId);
    if (index != -1) {
      chats[index] = chats[index].copyWith(unreadCount: 0);
    }
  }
}
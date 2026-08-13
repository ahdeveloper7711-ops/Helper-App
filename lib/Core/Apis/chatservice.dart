import 'package:get/get.dart';

class ChatApiResult {
  final bool success;
  final String message;
  final dynamic data;

  ChatApiResult({required this.success, required this.message, this.data});
}

class ChatService extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = "https://helpr.digital/api/chat";
    httpClient.timeout = const Duration(seconds: 30);
    super.onInit();
  }

  /// POST /chat/list  -> body: { "user_id": 1 }
  Future<ChatApiResult> getChatList(int userId) async {
    try {
      final response = await post("/list", {"user_id": userId});
      return _parse(response, listKey: "chats");
    } catch (e) {
      return ChatApiResult(success: false, message: "${'chat_error_load_list'.tr}: $e");
    }
  }

  /// POST /chat/messages -> body: { "user_id": 1, "other_user_id": 2 }
  Future<ChatApiResult> getMessages({
    required int userId,
    required int otherUserId,
  }) async {
    try {
      final response = await post("/messages", {
        "user_id": userId,
        "other_user_id": otherUserId,
      });
      return _parse(response, listKey: "messages");
    } catch (e) {
      return ChatApiResult(success: false, message: "${'chat_error_load_messages'.tr}: $e");
    }
  }

  /// POST /chat/send
  /// type: "text" | "audio" | (whatever the backend supports)
  /// For a text message, sending `message` is sufficient.
  /// For audio/file, also send `fileDataBase64`.
  Future<ChatApiResult> sendMessage({
    required int senderId,
    required int receiverId,
    required String type,
    String? message,
    String? fileDataBase64,
  }) async {
    try {
      final payload = {
        "sender_id": senderId,
        "receiver_id": receiverId,
        "type": type,
        if (message != null) "message": message,
        if (fileDataBase64 != null) "file_data": fileDataBase64,
      };
      final response = await post("/send", payload);
      return _parse(response, mapKey: "message");
    } catch (e) {
      return ChatApiResult(success: false, message: "${'chat_error_send_message'.tr}: $e");
    }
  }

  /// Common response parser — all three APIs follow the response shape
  /// { "success": bool, "message"/"chats"/"messages": ... }.
  ChatApiResult _parse(Response response, {String? listKey, String? mapKey}) {
    if (response.status.hasError || response.body == null) {
      return ChatApiResult(
        success: false,
        message: response.statusText ?? 'chat_error_no_response'.tr,
      );
    }

    final body = response.body;
    if (body is! Map) {
      return ChatApiResult(success: false, message: 'chat_error_unexpected_response'.tr);
    }

    final success = body["success"] == true;
    if (!success) {
      return ChatApiResult(
        success: false,
        message: body["message"]?.toString() ?? 'chat_error_request_failed'.tr,
      );
    }

    if (listKey != null) {
      return ChatApiResult(success: true, message: 'chat_ok'.tr, data: body[listKey] ?? []);
    }
    if (mapKey != null) {
      return ChatApiResult(success: true, message: 'chat_ok'.tr, data: body[mapKey]);
    }
    return ChatApiResult(success: true, message: 'chat_ok'.tr, data: body);
  }
}
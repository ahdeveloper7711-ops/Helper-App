import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../Core/Apis/chatservice.dart';
// NOTE: Verify this import path matches your project structure.
import '../../../Core/Apis/sessionmanager.dart';
class AppSize {
  static double get height => Get.height;

  static double get width => Get.width;
}
class ChatMessageModel {
  final int id;
  final String? message;
  final String type; // "text" | "audio" | ...
  final String? fileUrl;
  final bool isMine;
  final String time;

  ChatMessageModel({
    required this.id,
    this.message,
    required this.type,
    this.fileUrl,
    required this.isMine,
    required this.time,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      message: json["message"]?.toString(),
      type: json["type"]?.toString() ?? "text",
      fileUrl: json["file_url"]?.toString(),
      isMine: json["is_mine"] == true,
      time: json["time"]?.toString() ?? "",
    );
  }
}

// ============================================================
// GETX CONTROLLER
// ============================================================
class MessageController extends GetxController {
  final int otherUserId;
  final String otherUserName;

  MessageController({required this.otherUserId, required this.otherUserName});

  ChatService get _chatService => Get.isRegistered<ChatService>()
      ? Get.find<ChatService>()
      : Get.put(ChatService(), permanent: true);

  final TextEditingController messageTextController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var hasText = false.obs;

  Timer? _pollTimer;

  int? get _myId => SessionManager.getUserId();

  @override
  void onInit() {
    super.onInit();
    fetchMessages();
    messageTextController.addListener(() {
      hasText.value = messageTextController.text.trim().isNotEmpty;
    });
    // Silently poll for new messages every 5 seconds
    // (gives a real-time feel without needing a websocket connection).
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => fetchMessages(silent: true));
  }

  /// GET conversation (POST /chat/messages)
  Future<void> fetchMessages({bool silent = false}) async {
    final myId = _myId;
    if (myId == null) return;

    if (!silent) isLoading.value = true;

    final result = await _chatService.getMessages(userId: myId, otherUserId: otherUserId);

    if (result.success) {
      final List raw = result.data ?? [];
      messages.value = raw.map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e))).toList();
      _scrollToBottom();
    } else if (!silent) {
      Get.snackbar('message_screen_error_title'.tr, result.message,  backgroundColor: Colors.grey,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),
      );
    }

    if (!silent) isLoading.value = false;
  }

  /// SEND text message (POST /chat/send)
  Future<void> sendMessage() async {
    final text = messageTextController.text.trim();
    if (text.isEmpty || isSending.value) return;

    final myId = _myId;
    if (myId == null) return;

    messageTextController.clear();
    isSending.value = true;

    final result = await _chatService.sendMessage(
      senderId: myId,
      receiverId: otherUserId,
      type: "text",
      message: text,
    );

    isSending.value = false;

    if (result.success) {
      // Refresh the list after server confirmation (the new message will
      // arrive with its assigned id).
      await fetchMessages(silent: true);
    } else {
      Get.snackbar('message_screen_send_failed_title'.tr, result.message,  backgroundColor: Colors.grey,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),
      );
      messageTextController.text = text; // restore text so the user doesn't have to retype it
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    messageTextController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

// ============================================================
// MESSAGE SCREEN (Full & Final)
// ============================================================
class Messagescreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;
  final String? otherUserProfilePic;

  const Messagescreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserProfilePic,
  });

  @override
  State<Messagescreen> createState() => _MessagescreenState();
}

class _MessagescreenState extends State<Messagescreen> {
  late final MessageController controller;
  late final String _tag;

  @override
  void initState() {
    super.initState();
    // NOTE: tag = otherUserId so that each distinct chat thread
    // (client<->workerA, client<->workerB, etc.) gets its own isolated
    // controller instance and their message data never mixes.
    _tag = widget.otherUserId.toString();
    controller = Get.put(
      MessageController(otherUserId: widget.otherUserId, otherUserName: widget.otherUserName),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<MessageController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // FIX: pehle screen par koi SystemUiOverlayStyle set nahi thi, isliye
    // pichli screen (bottom-nav) ka system-navigation-bar color persist
    // karta reh jata tha aur transition ke dauran mismatch/black glitch
    // dikhta tha. Ab yahan bhi wahi theme-matched color explicitly set
    // kar rahe hain taake dono screens ke beech seamless rahe.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
        theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
        theme.brightness == Brightness.dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness:
        theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.04),
                  theme.scaffoldBackgroundColor,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.25],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Obx(
                        () {
                      if (controller.isLoading.value && controller.messages.isEmpty) {
                        return Center(
                          child: CircularProgressIndicator(color: theme.primaryColor),
                        );
                      }

                      if (controller.messages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: AppSize.width * 0.1,
                                  color: theme.primaryColor.withOpacity(0.5),
                                ),
                              ),
                              SizedBox(height: AppSize.height * 0.02),
                              Text(
                                'message_screen_empty_state'.tr,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "pr",
                                  color: theme.canvasColor.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: controller.scrollController,
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSize.width * 0.04,
                          vertical: AppSize.height * 0.02,
                        ),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(controller.messages[index], theme);
                        },
                      );
                    },
                  ),
                ),
                _buildMessageInputField(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // APP BAR (dynamic — shows the name/profile pic of the person
  // this conversation is with)
  // ----------------------------------------------------------
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    final name = widget.otherUserName;
    final hasPic = widget.otherUserProfilePic != null && widget.otherUserProfilePic!.isNotEmpty;

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0.5,
      shadowColor: Colors.black.withOpacity(0.06),
      leadingWidth: AppSize.width * 0.12,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: theme.canvasColor,
          size: AppSize.width * 0.055,
        ),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: AppSize.width * 0.053,
              backgroundColor: theme.primaryColor,
              backgroundImage: hasPic ? NetworkImage(widget.otherUserProfilePic!) : null,
              child: hasPic
                  ? null
                  : Text(
                name.isNotEmpty ? name[0].toUpperCase() : "?",
                style: TextStyle(
                  fontFamily: "pb",
                  color: theme.cardColor,
                  fontSize: AppSize.width * 0.035,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSize.width * 0.03),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: "pb",
                color: theme.canvasColor,
                fontSize: AppSize.width * 0.042,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // MESSAGE BUBBLE
  // ----------------------------------------------------------
  Widget _buildMessageBubble(ChatMessageModel msg, ThemeData theme) {
    final bool isSender = msg.isMine;
    final bool isAudio = msg.type == "audio";

    return Padding(
      padding: EdgeInsets.only(bottom: AppSize.height * 0.018),
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: AppSize.width * 0.72),
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.width * 0.04,
              vertical: AppSize.height * 0.015,
            ),
            decoration: BoxDecoration(
              gradient: isSender
                  ? LinearGradient(
                colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.82)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              color: isSender ? null : theme.cardColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSize.width * 0.045),
                topRight: Radius.circular(AppSize.width * 0.045),
                bottomLeft: Radius.circular(
                  isSender ? AppSize.width * 0.045 : AppSize.width * 0.01,
                ),
                bottomRight: Radius.circular(
                  isSender ? AppSize.width * 0.01 : AppSize.width * 0.045,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSender ? theme.primaryColor : Colors.black).withOpacity(isSender ? 0.18 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isAudio
                ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mic_rounded,
                  size: AppSize.width * 0.045,
                  color: isSender ? theme.cardColor : theme.canvasColor,
                ),
                SizedBox(width: AppSize.width * 0.02),
                Text(
                  'message_screen_voice_message'.tr,
                  style: TextStyle(
                    fontFamily: "pr",
                    color: isSender ? theme.cardColor : theme.canvasColor,
                    fontSize: AppSize.width * 0.037,
                  ),
                ),
              ],
            )
                : Text(
              msg.message ?? "",
              style: TextStyle(
                fontFamily: "pr",
                color: isSender ? theme.cardColor : theme.canvasColor,
                fontSize: AppSize.width * 0.037,
                height: 1.35,
              ),
            ),
          ),
          SizedBox(height: AppSize.height * 0.006),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.015),
            child: Text(
              msg.time,
              style: TextStyle(
                fontFamily: "pr",
                color: theme.canvasColor.withOpacity(0.45),
                fontSize: AppSize.width * 0.027,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // BOTTOM MESSAGE INPUT FIELD
  // ----------------------------------------------------------
  Widget _buildMessageInputField(ThemeData theme) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSize.width * 0.04,
        AppSize.height * 0.012,
        AppSize.width * 0.04,
        AppSize.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.12), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: AppSize.height * 0.055),
                padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.04),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                ),
                child: TextField(
                  controller: controller.messageTextController,
                  minLines: 1,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontFamily: "pr",
                    fontSize: AppSize.width * 0.037,
                    color: theme.canvasColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'message_screen_input_hint'.tr,
                    hintStyle: TextStyle(
                      fontFamily: "pr",
                      color: theme.canvasColor.withOpacity(0.4),
                      fontSize: AppSize.width * 0.037,
                    ),
                    border: InputBorder.none,
                    isCollapsed: false,
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
            SizedBox(width: AppSize.width * 0.025),
            Obx(
                  () => GestureDetector(
                onTap: controller.isSending.value ? null : controller.sendMessage,
                child: Container(
                  height: AppSize.width * 0.115,
                  width: AppSize.width * 0.115,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: controller.hasText.value
                          ? [theme.primaryColor, theme.primaryColor.withOpacity(0.8)]
                          : [
                        theme.canvasColor.withOpacity(0.15),
                        theme.canvasColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: controller.hasText.value
                        ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                        : [],
                  ),
                  child: controller.isSending.value
                      ? SizedBox(
                    width: AppSize.width * 0.05,
                    height: AppSize.width * 0.05,
                    child: CircularProgressIndicator(strokeWidth: 2, color: theme.cardColor),
                  )
                      : Icon(
                    Icons.send_rounded,
                    color: controller.hasText.value
                        ? theme.cardColor
                        : theme.canvasColor.withOpacity(0.4),
                    size: AppSize.width * 0.05,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
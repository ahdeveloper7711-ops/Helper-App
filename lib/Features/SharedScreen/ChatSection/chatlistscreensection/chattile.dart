import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Features/SharedScreen/ChatSection/MessageScreen.dart' hide AppSize;

import '../../../../Core/Widgets/MediaqueryHelperfile.dart';
import 'controller.dart';

class ChatTile extends StatelessWidget {
  final ChatListItem chat;

  const ChatTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listController = Get.find<ChatListController>();
    final bool hasUnread = chat.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        // Immediately clear unread status in the UI
        listController.markAsReadLocally(chat.userId);

        Get.to(
              () => Messagescreen(
            otherUserId: chat.userId,
            otherUserName: chat.username,
            otherUserProfilePic: chat.profilePic,
          ),
          transition: Transition.fade,
          duration: const Duration(milliseconds: 500),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSize.height * 0.01),
        padding: EdgeInsets.all(AppSize.width * 0.02),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasUnread
                ? theme.primaryColor.withOpacity(0.25)
                : theme.dividerColor.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            /// AVATAR (real profile picture or gradient initials fallback)
            Container(
              height: AppSize.width * 0.14,
              width: AppSize.width * 0.14,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withOpacity(hasUnread ? 0.9 : 0.25),
                    theme.primaryColor.withOpacity(hasUnread ? 0.5 : 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor,
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: Container(
                    color: theme.primaryColor.withOpacity(0.12),
                    child: (chat.profilePic != null && chat.profilePic!.isNotEmpty)
                        ? Image.network(
                      chat.profilePic!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initials(theme),
                    )
                        : _initials(theme),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSize.width * 0.032),

            /// NAME + MESSAGE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.username,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "pb",
                            fontWeight: FontWeight.bold,
                            fontSize: AppSize.width * 0.037,
                            color: theme.canvasColor,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSize.width * 0.02),
                      Text(
                        chat.time,
                        style: TextStyle(
                          fontFamily: "pr",
                          color: hasUnread
                              ? theme.primaryColor
                              : theme.canvasColor.withOpacity(0.45),
                          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                          fontSize: AppSize.width * 0.027,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.height * 0.006),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: "pr",
                            color: hasUnread
                                ? theme.canvasColor.withOpacity(0.85)
                                : theme.canvasColor.withOpacity(0.55),
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            fontSize: AppSize.width * 0.031,
                          ),
                        ),
                      ),

                      /// UNREAD BADGE
                      if (hasUnread) ...[
                        SizedBox(width: AppSize.width * 0.02),
                        Container(
                          constraints: BoxConstraints(minWidth: AppSize.width * 0.05),
                          height: AppSize.width * 0.05,
                          padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.012),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.75)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            chat.unreadCount > 99 ? "99+" : chat.unreadCount.toString(),
                            style: TextStyle(
                              fontFamily: "pb",
                              color: theme.cardColor,
                              fontSize: AppSize.width * 0.026,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _initials(ThemeData theme) {
    return Center(
      child: Text(
        chat.username.isNotEmpty ? chat.username[0].toUpperCase() : "?",
        style: TextStyle(
          fontFamily: "pb",
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}
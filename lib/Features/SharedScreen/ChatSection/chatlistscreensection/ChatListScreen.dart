import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Core/Widgets/Background.dart';
import '../../../../Core/Widgets/CustomHeader.dart';
import '../../../../Core/Widgets/mediaqueryHelperfile.dart';
import 'chattile.dart';
import 'controller.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final controller = Get.put(ChatListController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBackground(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.width * 0.045,
        ),
        child: Column(
          children: [
            SizedBox(height: AppSize.height * 0.015),

            /// HEADER
            CustomHeader(
              title: 'chat_list_title'.tr,
              showBackButton: false,
              rightWidget: Icon(Icons.search_rounded, color: theme.primaryColor, size: AppSize.width * 0.07),
            ),

            SizedBox(height: AppSize.height * 0.008),

            /// SEARCH FIELD
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(AppSize.height*0.7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                onChanged: controller.setSearch,
                style: TextStyle(fontFamily: "pr", color: theme.canvasColor),
                decoration: InputDecoration(
                  hintText: 'chat_list_search_hint'.tr,
                  hintStyle: TextStyle(
                    fontFamily: "pr",
                    color: theme.canvasColor.withOpacity(0.4),
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: theme.primaryColor.withOpacity(0.6)),
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: EdgeInsets.symmetric(vertical: AppSize.height * 0.012),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.height*0.7),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.height*0.7),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.height*0.7),
                    borderSide: BorderSide(color: theme.primaryColor.withOpacity(0.4)),
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSize.height * 0.025),

            /// LIST
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: theme.primaryColor),
                  );
                }

                final list = controller.filteredChats;

                if (list.isEmpty) {
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
                            Icons.forum_outlined,
                            size: AppSize.width * 0.1,
                            color: theme.primaryColor.withOpacity(0.5),
                          ),
                        ),
                        SizedBox(height: AppSize.height * 0.02),
                        Text(
                          'chat_list_no_conversations'.tr,
                          style: TextStyle(
                            fontFamily: "pr",
                            color: theme.canvasColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: theme.primaryColor,
                  onRefresh: () => controller.fetchChatList(),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) => ChatTile(chat: list[index]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
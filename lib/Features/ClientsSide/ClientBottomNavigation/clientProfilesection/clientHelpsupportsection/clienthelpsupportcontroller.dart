import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Core/Widgets/MediaqueryHelperfile.dart';

/// ======================================================================
/// MODELS
/// (Pehle alag files mein thay: Models/chatmessagemodel.dart, Models/faqsmodel.dart)
/// ======================================================================

class ChatMessageModel {
  final String text;
  final bool isUser;
  final String time;

  const ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class FaqModel {
  final String question;
  final String answer;
  final String category;

  const FaqModel({
    required this.question,
    required this.answer,
    required this.category,
  });
}

/// ======================================================================
/// HARD CODED / STATIC DATA
/// (Yahan se API lagate waqt in lists ko controller ke methods ke zariye
/// backend response se replace kerna hoga)
/// ======================================================================

final List<FaqModel> faqData = [
  FaqModel(
    question: 'faq_question_escrow'.tr,
    answer: 'faq_answer_escrow'.tr,
    category: 'faq_category_payment'.tr,
  ),
  FaqModel(
    question: 'faq_question_fees'.tr,
    answer: 'faq_answer_fees'.tr,
    category: 'faq_category_payment'.tr,
  ),
  FaqModel(
    question: 'faq_question_badges'.tr,
    answer: 'faq_answer_badges'.tr,
    category: 'faq_category_verification'.tr,
  ),
  FaqModel(
    question: 'faq_question_dispute'.tr,
    answer: 'faq_answer_dispute'.tr,
    category: 'faq_category_disputes'.tr,
  ),
  FaqModel(
    question: 'faq_question_data'.tr,
    answer: 'faq_answer_data'.tr,
    category: 'faq_category_safety'.tr,
  ),
  FaqModel(
    question: 'faq_question_cancel'.tr,
    answer: 'faq_answer_cancel'.tr,
    category: 'faq_category_disputes'.tr,
  ),
  FaqModel(
    question: 'faq_question_cancel'.tr,
    answer: 'faq_answer_cancel'.tr,
    category: 'faq_category_disputes'.tr,
  ),
  FaqModel(
    question: 'faq_question_fees'.tr,
    answer: 'faq_answer_fees'.tr,
    category: 'faq_category_payment'.tr,
  ),
  FaqModel(
    question: 'faq_question_badges'.tr,
    answer: 'faq_answer_badges'.tr,
    category: 'faq_category_verification'.tr,
  ),
];

List<String> get faqCategories => [
  'faq_cat_all_articles'.tr,
  'faq_category_payment'.tr,
  'faq_category_verification'.tr,
  'faq_category_disputes'.tr,
  'faq_category_safety'.tr,
];

/// ======================================================================
/// CONTROLLER
/// (Yahan API integrate kerni ho tu submitTicket(), sendMessage() aur
/// filteredFaqs / faqData load kerne wale hisso ko backend calls se
/// replace/update kerna hoga)
/// ======================================================================

class Clienthelpsupportcontroller extends GetxController {
  final mainTabIndex = 0.obs;
  final categoryIndex = 0.obs;
  final expandedFaqIndex = RxnInt();
  final searchQuery = ''.obs;

  List<String> get ticketCategories => [
    'ticket_cat_payment_escrow'.tr,
    'ticket_cat_verification'.tr,
    'ticket_cat_disputes'.tr,
    'ticket_cat_account'.tr,
    'ticket_cat_technical'.tr,
    'ticket_cat_other'.tr,
  ];
  late final selectedTicketCategory = ticketCategories.first.obs;

  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final chatController = TextEditingController();

  late final messages = <ChatMessageModel>[
    ChatMessageModel(
      text: 'support_chat_welcome'.tr,
      isUser: false,
      time: 'support_chat_time_just_now'.tr,
    ),
  ].obs;

  List<FaqModel> get filteredFaqs {
    final categories = faqCategories;
    final category =
        categories[categoryIndex.value.clamp(0, categories.length - 1)];
    return faqData.where((faq) {
      final matchesCategory =
          category == 'faq_cat_all_articles'.tr || faq.category == category;
      final matchesSearch = faq.question.toLowerCase().contains(
        searchQuery.value.toLowerCase(),
      );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void changeMainTab(int index) => mainTabIndex.value = index;

  void changeCategory(int index) {
    categoryIndex.value = index;
    expandedFaqIndex.value = null;
  }

  void toggleFaq(int index) {
    expandedFaqIndex.value = expandedFaqIndex.value == index ? null : index;
  }

  /// TODO(API): Yahan par ticket submit karne wali API call add karni hai.
  void submitTicket() {
    if (subjectController.text.trim().isEmpty ||
        messageController.text.trim().isEmpty) {
      Get.snackbar(
        'support_snackbar_missing_title'.tr,
        'support_snackbar_missing_msg'.tr,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(
          vertical: AppSize.height * 0.01,
          horizontal: AppSize.height * 0.01,
        ),
      );
      return;
    }

    // ---- API CALL YAHAN LAGANI HAI (category, subject, message bhejni hai) ----
    // await ApiService.submitTicket(
    //   category: selectedTicketCategory.value,
    //   subject: subjectController.text.trim(),
    //   message: messageController.text.trim(),
    // );

    Get.snackbar(
      'support_snackbar_success_title'.tr,
      'support_snackbar_success_msg'.tr,
      snackPosition: SnackPosition.BOTTOM,
      padding: EdgeInsets.symmetric(
        vertical: AppSize.height * 0.01,
        horizontal: AppSize.height * 0.01,
      ),
    );
    subjectController.clear();
    messageController.clear();
  }

  /// TODO(API): Yahan par chat message send/receive karne wali API ya
  /// socket integration add karni hai.
  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;
    messages.add(
      ChatMessageModel(
        text: text,
        isUser: true,
        time: 'support_chat_time_now'.tr,
      ),
    );
    chatController.clear();

    // ---- API CALL YAHAN LAGANI HAI (message backend/agent ko bhejna hai) ----
    Future.delayed(const Duration(milliseconds: 600), () {
      messages.add(
        ChatMessageModel(
          text: 'support_chat_auto_reply'.tr,
          isUser: false,
          time: 'support_chat_time_now'.tr,
        ),
      );
    });
  }

  @override
  void onClose() {
    subjectController.dispose();
    messageController.dispose();
    chatController.dispose();
    super.onClose();
  }
}

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

List<FaqModel> get faqData => [
  FaqModel(
    question: 'faq_escrow_question'.tr,
    answer: 'faq_escrow_answer'.tr,
    category: 'faq_category_payment'.tr,
  ),
  FaqModel(
    question: 'faq_fees_question'.tr,
    answer: 'faq_fees_answer'.tr,
    category: 'faq_category_payment'.tr,
  ),
  FaqModel(
    question: 'faq_verification_question'.tr,
    answer: 'faq_verification_answer'.tr,
    category: 'faq_category_verification'.tr,
  ),
  FaqModel(
    question: 'faq_dispute_question'.tr,
    answer: 'faq_dispute_answer'.tr,
    category: 'faq_category_disputes'.tr,
  ),
  FaqModel(
    question: 'faq_safety_question'.tr,
    answer: 'faq_safety_answer'.tr,
    category: 'faq_category_safety'.tr,
  ),
  FaqModel(
    question: 'faq_cancel_question'.tr,
    answer: 'faq_cancel_answer'.tr,
    category: 'faq_category_disputes'.tr,
  ),
  FaqModel(
    question: 'faq_cancel_question'.tr,
    answer: 'faq_cancel_answer'.tr,
    category: 'faq_category_disputes'.tr,
  ),
  FaqModel(
    question: 'faq_fees_question'.tr,
    answer: 'faq_fees_answer'.tr,
    category: 'faq_category_payment'.tr,
  ),
  FaqModel(
    question: 'faq_verification_question'.tr,
    answer: 'faq_verification_answer'.tr,
    category: 'faq_category_verification'.tr,
  ),
];

List<String> get faqCategories => [
  'faq_cat_all'.tr,
  'faq_cat_payment'.tr,
  'faq_cat_verification'.tr,
  'faq_cat_disputes'.tr,
  'faq_cat_safety'.tr,
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
    'ticket_cat_payment'.tr,
    'ticket_cat_verification'.tr,
    'ticket_cat_disputes'.tr,
    'ticket_cat_account'.tr,
    'ticket_cat_tech'.tr,
    'ticket_cat_other'.tr,
  ];

  late final selectedTicketCategory = ticketCategories.first.obs;

  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final chatController = TextEditingController();

  List<ChatMessageModel> get messages => [
    ChatMessageModel(
      text: 'chat_welcome_msg'.tr,
      isUser: false,
      time: 'chat_time_just_now'.tr,
    ),
  ].obs;

  List<FaqModel> get filteredFaqs {
    final categoriesList = faqCategories;
    final catIndex = categoryIndex.value < categoriesList.length ? categoryIndex.value : 0;
    final category = categoriesList[catIndex];

    return faqData.where((faq) {
      final matchesCategory =
          category == 'faq_cat_all'.tr || faq.category == category;
      final matchesSearch =
      faq.question.toLowerCase().contains(searchQuery.value.toLowerCase());
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
      Get.snackbar('ticket_missing_title'.tr, 'ticket_missing_msg'.tr, backgroundColor: Colors.grey,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),
      );
      return;
    }

    // ---- API CALL YAHAN LAGANI HAI (category, subject, message bhejni hai) ----
    // await ApiService.submitTicket(
    //   category: selectedTicketCategory.value,
    //   subject: subjectController.text.trim(),
    //   message: messageController.text.trim(),
    // );

    Get.snackbar('ticket_submitted_title'.tr, 'ticket_submitted_msg'.tr);
    subjectController.clear();
    messageController.clear();
  }

  /// TODO(API): Yahan par chat message send/receive karne wali API ya
  /// socket integration add karni hai.
  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isEmpty) return;
    messages.add(ChatMessageModel(text: text, isUser: true, time: 'chat_time_now'.tr));
    chatController.clear();

    // ---- API CALL YAHAN LAGANI HAI (message backend/agent ko bhejna hai) ----
    Future.delayed(const Duration(milliseconds: 600), () {
      messages.add(ChatMessageModel(
        text: 'chat_auto_reply'.tr,
        isUser: false,
        time: 'chat_time_now'.tr,
      ));
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
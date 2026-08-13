import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clintpostjobsection/postjobsummry.dart';

import '../../../../Core/Apis/jobservice.dart';
import '../clientbottomnavigationscreen.dart';
import '../clienthomesection/clientjobcontroller.dart';
enum BudgetType { fixed, hourly, negotiable }

enum PaymentType { cash, card, wallet }

enum ScheduleDateType { today, custom }

enum UrgencyType { flexible, urgent }

class PostJobController extends GetxController {
  static const String _tag = "PostJobController";

  /// TASK TITLE
  final taskTitleController = TextEditingController();

  /// CATEGORY / SUB-CATEGORY
  final Rx<String?> selectedCategory = Rx<String?>(null);
  final Rx<String?> selectedSubCategory = Rx<String?>(null);
  final Rx<IconData?> selectedCategoryIcon = Rx<IconData?>(null);

  /// LOCATION
  /// LOCATION (with coordinates)
  final locationController = TextEditingController();
  final RxnDouble latitude = RxnDouble();
  final RxnDouble longitude = RxnDouble();

  void setSelectedLocation({
    required String address,
    required double lat,
    required double lng,
  }) {
    locationController.text = address;
    latitude.value = lat;
    longitude.value = lng;
  }

  void clearLocation() {
    locationController.clear();
    latitude.value = null;
    longitude.value = null;
  }
  /// DESCRIPTION
  final descriptionController = TextEditingController();

  /// BUDGET
  final Rx<BudgetType> budgetType = BudgetType.fixed.obs;
  final amountController = TextEditingController();
  final rateController = TextEditingController();
  final estimatedHoursController = TextEditingController();
  final Rx<PaymentType> paymentType = PaymentType.cash.obs;

  /// SCHEDULE
  final Rx<ScheduleDateType> scheduleDateType = ScheduleDateType.today.obs;
  final Rx<DateTime?> customDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> startTime = Rx<TimeOfDay?>(null);
  final Rx<TimeOfDay?> endTime = Rx<TimeOfDay?>(null);
  final Rx<UrgencyType> urgencyType = UrgencyType.flexible.obs;

  /// PHOTOS
  final RxList<File> attachedPhotos = <File>[].obs;

  /// SUBMISSION STATE
  final RxBool isSubmitting = false.obs;

  /// GETTERS FOR DISPLAY
  String get scheduleDateLabel =>
      scheduleDateType.value == ScheduleDateType.today
          ? 'post_job_today'.tr
          : (customDate.value != null
          ? "${customDate.value!.day}/${customDate.value!.month}/${customDate.value!.year}"
          : 'post_job_custom_date'.tr);

  String get startTimeLabel =>
      startTime.value != null ? startTime.value!.format(Get.context!) : 'post_job_time_placeholder'.tr;

  String get endTimeLabel =>
      endTime.value != null ? endTime.value!.format(Get.context!) : 'post_job_time_placeholder'.tr;

  String get paymentTypeLabel {
    switch (paymentType.value) {
      case PaymentType.cash:
        return 'post_job_payment_cash'.tr;
      case PaymentType.card:
        return 'post_job_payment_card'.tr;
      case PaymentType.wallet:
        return 'post_job_payment_wallet'.tr;
    }
  }

  IconData get paymentTypeIcon {
    switch (paymentType.value) {
      case PaymentType.cash:
        return Icons.payments_rounded;
      case PaymentType.card:
        return Icons.credit_card_rounded;
      case PaymentType.wallet:
        return Icons.account_balance_wallet_rounded;
    }
  }

  String get urgencyLabel =>
      urgencyType.value == UrgencyType.flexible ? 'post_job_flexible'.tr : 'post_job_urgent'.tr;

  void setCategory(String category, IconData icon) {
    selectedCategory.value = category;
    selectedCategoryIcon.value = icon;
  }

  void setSubCategory(String subCategory) {
    selectedSubCategory.value = subCategory;
  }

  void addPhoto(File file) {
    if (attachedPhotos.length < 3) {
      attachedPhotos.add(file);
    } else {
      Get.snackbar('post_job_photo_limit_title'.tr, 'post_job_photo_limit_message'.tr);
    }
  }

  void removePhoto(File file) {
    attachedPhotos.remove(file);
  }

  /// ------------------------------------------------------------
  /// BASIC FORM VALIDATION — Submit dabane se pehle chalta hai
  /// ------------------------------------------------------------
  bool validateForm() {
    if (taskTitleController.text.trim().isEmpty) {
      Get.snackbar('post_job_validation_missing_title_title'.tr, 'post_job_validation_missing_title_message'.tr,
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (selectedCategory.value == null) {
      Get.snackbar('post_job_validation_missing_category_title'.tr, 'post_job_validation_missing_category_message'.tr,
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (selectedSubCategory.value == null) {
      Get.snackbar('post_job_validation_missing_subcategory_title'.tr, 'post_job_validation_missing_subcategory_message'.tr,
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (locationController.text.trim().isEmpty || latitude.value == null || longitude.value == null) {
      Get.snackbar(
        'post_job_validation_missing_location_title'.tr,
        'post_job_validation_missing_location_message'.tr,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar('post_job_validation_missing_description_title'.tr, 'post_job_validation_missing_description_message'.tr,
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (budgetType.value == BudgetType.fixed && amountController.text.trim().isEmpty) {
      Get.snackbar('post_job_validation_missing_amount_title'.tr, 'post_job_validation_missing_amount_message'.tr,
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (budgetType.value == BudgetType.hourly && rateController.text.trim().isEmpty) {
      Get.snackbar('post_job_validation_missing_rate_title'.tr, 'post_job_validation_missing_rate_message'.tr,
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (startTime.value == null) {
      Get.snackbar('post_job_validation_missing_start_time_title'.tr, 'post_job_validation_missing_start_time_message'.tr,
          snackPosition: SnackPosition.TOP);
      return false;
    }
    if (endTime.value == null) {
      Get.snackbar('post_job_validation_missing_end_time_title'.tr, 'post_job_validation_missing_end_time_message'.tr,
          snackPosition: SnackPosition.TOP);
      return false;
    }
    return true;
  }

  /// ------------------------------------------------------------
  /// STEP 1: Form Submit -> Summary Screen (review) par le jao
  /// ------------------------------------------------------------
  void goToSummary() {
    if (!validateForm()) return;
    Get.to(() => const PostJobSummaryScreen());
  }

  /// ------------------------------------------------------------
  /// STEP 2: Summary Screen par "Confirm & Submit" -> Create Job API
  /// ------------------------------------------------------------
  Future<void> confirmAndSubmit() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    debugPrint("🚀 [$_tag] Submitting job post...");

    // ---- IMAGE ENCODING (base64 data-URI, API contract ke mutabiq) ----
    List<String>? encodedImages;
    if (attachedPhotos.isNotEmpty) {
      debugPrint("🖼️ [$_tag] Encoding ${attachedPhotos.length} photo(s) to base64...");
      encodedImages = await JobService.encodeImagesForUpload(attachedPhotos.toList());
      debugPrint("🖼️ [$_tag] Encoded ${encodedImages.length} photo(s) successfully");
    } else {
      debugPrint("🖼️ [$_tag] No photos attached for this job");
    }

    final budgetTypeApi = _budgetTypeApiValue(budgetType.value);
    final scheduleForApi = _buildScheduleForApi();
    final startTimeApi = _formatTimeForApi(startTime.value);
    final endTimeApi = _formatTimeForApi(endTime.value);
    final dateTypeApi = _dateTypeApiValue(scheduleDateType.value);
    // FIX: backend "custom date" select hone par "custom_date" field bhi
    // zaroori mangta hai ("yyyy-MM-dd" format mein). Pehle ye field bheji
    // hi nahi ja rahi thi jis se 422 "The custom date field is required..."
    // error aata tha.
    final customDateApi = scheduleDateType.value == ScheduleDateType.custom
        ? _formatDateForApi(customDate.value)
        : null;

    debugPrint(
      "🧾 [$_tag] category=${selectedCategory.value}, sub=${selectedSubCategory.value}, "
          "budgetType=$budgetTypeApi, dateType=$dateTypeApi, customDate=$customDateApi, "
          "schedule=$scheduleForApi, start=$startTimeApi, end=$endTimeApi, "
          "images=${encodedImages?.length ?? 0}",
    );
    debugPrint("==== SENDING TO API ====");
    debugPrint("lat: ${latitude.value}");
    debugPrint("lng: ${longitude.value}");
    debugPrint("location: ${locationController.text}");

    final result = await JobService.createJob(
      category: selectedCategory.value ?? '',
      subcategory: selectedSubCategory.value,
      latitude: latitude.value,
      longitude: longitude.value,
      title: taskTitleController.text.trim(),
      // NOTE: Form mein abhi separate "city" field nahi hai, isliye
      // location hi city ke taur par bhi bhej rahe hain.
      city: locationController.text.trim(),
      description: descriptionController.text.trim(),
      budgetType: budgetTypeApi,
      amount: budgetType.value == BudgetType.fixed
          ? double.tryParse(amountController.text.trim())
          : null,
      perHourRate: budgetType.value == BudgetType.hourly
          ? double.tryParse(rateController.text.trim())
          : null,
      estimatedHours: budgetType.value == BudgetType.hourly
          ? double.tryParse(estimatedHoursController.text.trim())
          : null,
      paymentMode: _paymentModeApiValue(paymentType.value),
      location: locationController.text.trim(),
      // FIX: backend sirf "today" ya "custom date" (space ke sath) accept
      // karta hai. Pehle yahan "custom" (bina space) bheja ja raha tha
      // jis se 422 "The selected date type is invalid." error aata tha.
      dateType: dateTypeApi,
      // FIX: "custom date" select hone par backend ko "custom_date" field
      // (yyyy-MM-dd) bhi chahiye — pehle bilkul bheji hi nahi ja rahi thi.
      customDate: customDateApi,
      startTime: startTimeApi,
      endTime: endTimeApi,
      schedule: scheduleForApi,
      urgency: urgencyType.value == UrgencyType.urgent ? "urgent" : "flexible",
      images: encodedImages,
    );

    isSubmitting.value = false;

    if (result.success) {
      debugPrint("✅ [$_tag] Job posted successfully: ${result.message}");

      Get.snackbar(
        'post_job_success_title'.tr,
        result.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );

      // Home screen list ko turant refresh karo taake nayi job dikh jaye
      if (Get.isRegistered<ClientJobsController>()) {
        debugPrint("🔄 [$_tag] Refreshing ClientJobsController...");
        Get.find<ClientJobsController>().refresh();
      }

      resetForm();

      // Poore navigation stack ko clear karke bottom navigation par le jao
      Get.offAll(() => const Clientbottomnavigationscreen());
    } else {
      debugPrint("❌ [$_tag] Job post failed: ${result.message}");
      Get.snackbar(
        'post_job_failed_title'.tr,
        result.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    }
  }

  /// Form ko dobara post karne ke liye clean state par le aata hai
  void resetForm() {
    taskTitleController.clear();
    locationController.clear();
    descriptionController.clear();
    amountController.clear();
    clearLocation();
    rateController.clear();
    estimatedHoursController.clear();

    selectedCategory.value = null;
    selectedSubCategory.value = null;
    selectedCategoryIcon.value = null;

    budgetType.value = BudgetType.fixed;
    paymentType.value = PaymentType.cash;

    scheduleDateType.value = ScheduleDateType.today;
    customDate.value = null;
    startTime.value = null;
    endTime.value = null;
    urgencyType.value = UrgencyType.flexible;

    attachedPhotos.clear();
  }

  /// ---------------- API FORMAT HELPERS ----------------
  /// NOTE: In sab functions ke return values seedha backend API ko
  /// jaate hain (request body). In par .tr NAHI lagaya gaya — agar
  /// language change hone par ye strings badal jayen to backend
  /// validation fail ho jayegi (422 error), kyun ke backend sirf
  /// exact English values ("cash", "today", "custom date" etc.)
  /// accept karta hai.

  String _paymentModeApiValue(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return "cash";
      case PaymentType.card:
        return "card";
      case PaymentType.wallet:
        return "wallet";
    }
  }

  String _budgetTypeApiValue(BudgetType type) {
    switch (type) {
      case BudgetType.fixed:
        return "fixed price";
      case BudgetType.hourly:
        return "hourly rate";
      case BudgetType.negotiable:
        return "negotiable";
    }
  }

  /// ScheduleDateType -> backend ki exact expected string.
  /// Backend sirf "today" aur "custom date" (space ke sath) ko
  /// valid maanta hai — Postman se confirm ho chuka hai.
  String _dateTypeApiValue(ScheduleDateType type) {
    switch (type) {
      case ScheduleDateType.today:
        return "today";
      case ScheduleDateType.custom:
        return "custom date";
    }
  }

  /// TimeOfDay -> "01:00 PM" format (jaisa API expect karti hai)
  String _formatTimeForApi(TimeOfDay? t) {
    if (t == null) return "";
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? "AM" : "PM";
    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  }

  /// DateTime -> "yyyy-MM-dd" format (backend ke "custom_date" field ke
  /// liye jab date_type == "custom date" ho).
  String? _formatDateForApi(DateTime? date) {
    if (date == null) return null;
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

  /// Date + start time ko "yyyy-MM-dd HH:mm:ss" (24-hour) format mein
  /// combine karta hai, jaisa API ke "schedule" field mein chahiye.
  String _buildScheduleForApi() {
    final date = scheduleDateType.value == ScheduleDateType.today
        ? DateTime.now()
        : (customDate.value ?? DateTime.now());
    final time = startTime.value ?? const TimeOfDay(hour: 0, minute: 0);
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');

    return "$y-$m-$d $h:$min:00";
  }

  @override
  void onClose() {
    taskTitleController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    rateController.dispose();
    estimatedHoursController.dispose();
    super.onClose();
  }
}
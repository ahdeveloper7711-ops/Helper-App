import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clintpostjobsection/postjobsummry.dart';
import 'package:helper_app2/Core/Apis/jobservice.dart';
import 'package:helper_app2/Core/Apis/paymentservice.dart';
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

  /// ========== ESTIMATE FEE STATE ==========
  final RxBool isEstimatingFee = false.obs;
  final RxString clientFee = "".obs;
  final RxString totalToPay = "".obs;
  final RxBool isFeeEnabled = false.obs;
  final RxString estimateFeeMessage = "".obs;

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
  /// BASIC FORM VALIDATION
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
  /// Amount for Estimate Fee API
  /// ------------------------------------------------------------
  double? _getAmountForEstimate() {
    switch (budgetType.value) {
      case BudgetType.fixed:
        return double.tryParse(amountController.text.trim().replaceAll(',', ''));
      case BudgetType.hourly:
        final rate = double.tryParse(rateController.text.trim().replaceAll(',', '')) ?? 0;
        final hours = double.tryParse(estimatedHoursController.text.trim()) ?? 0;
        if (rate <= 0) return null;
        // agar hours diye hain to total, warna sirf rate
        return hours > 0 ? rate * hours : rate;
      case BudgetType.negotiable:
        return null; // negotiable pe fee estimate skip
    }
  }

  /// ------------------------------------------------------------
  /// ESTIMATE FEE API CALL
  /// ------------------------------------------------------------
  Future<void> fetchEstimateFee() async {
    final amount = _getAmountForEstimate();

    // reset previous
    clientFee.value = "";
    totalToPay.value = "";
    isFeeEnabled.value = false;
    estimateFeeMessage.value = "";

    if (amount == null || amount <= 0) {
      return;
    }

    isEstimatingFee.value = true;

    try {
      final result = await PaymentService.estimateFee(amount: amount);

      if (result.success) {
        clientFee.value = result.clientFee ?? "";
        totalToPay.value = result.totalToPay ?? "";
        isFeeEnabled.value = result.isFeeEnabled;
        estimateFeeMessage.value = result.message;
      } else {
        estimateFeeMessage.value = result.message;
      }
    } finally {
      isEstimatingFee.value = false;
    }
  }

  /// ------------------------------------------------------------
  /// STEP 1: Form Submit -> Summary + Estimate Fee
  /// ------------------------------------------------------------
  void goToSummary() {
    if (!validateForm()) return;

    // Summary pe jaate hi fee estimate karo
    fetchEstimateFee();

    Get.to(() => const PostJobSummaryScreen());
  }

  /// ------------------------------------------------------------
  /// STEP 2: Confirm & Submit
  /// ------------------------------------------------------------
  Future<void> confirmAndSubmit() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;
    debugPrint("🚀 [$_tag] Submitting job post...");

    List<String>? encodedImages;
    if (attachedPhotos.isNotEmpty) {
      debugPrint("🖼️ [$_tag] Encoding ${attachedPhotos.length} photo(s) to base64...");
      encodedImages = await JobService.encodeImagesForUpload(attachedPhotos.toList());
      debugPrint("🖼️ [$_tag] Encoded ${encodedImages.length} photo(s) successfully");
    }

    final budgetTypeApi = _budgetTypeApiValue(budgetType.value);
    final scheduleForApi = _buildScheduleForApi();
    final startTimeApi = _formatTimeForApi(startTime.value);
    final endTimeApi = _formatTimeForApi(endTime.value);
    final dateTypeApi = _dateTypeApiValue(scheduleDateType.value);
    final customDateApi = scheduleDateType.value == ScheduleDateType.custom
        ? _formatDateForApi(customDate.value)
        : null;

    final result = await JobService.createJob(
      category: selectedCategory.value ?? '',
      subcategory: selectedSubCategory.value,
      latitude: latitude.value,
      longitude: longitude.value,
      title: taskTitleController.text.trim(),
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
      dateType: dateTypeApi,
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

      if (Get.isRegistered<ClientJobsController>()) {
        Get.find<ClientJobsController>().refresh();
      }

      resetForm();
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

    // fee state reset
    clientFee.value = "";
    totalToPay.value = "";
    isFeeEnabled.value = false;
    estimateFeeMessage.value = "";
  }

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

  String _dateTypeApiValue(ScheduleDateType type) {
    switch (type) {
      case ScheduleDateType.today:
        return "today";
      case ScheduleDateType.custom:
        return "custom date";
    }
  }

  String _formatTimeForApi(TimeOfDay? t) {
    if (t == null) return "";
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? "AM" : "PM";
    return "${hour.toString().padLeft(2, '0')}:$minute $period";
  }

  String? _formatDateForApi(DateTime? date) {
    if (date == null) return null;
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }

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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../Core/Widgets/Background.dart';
import '../../../../Core/Widgets/Backbutton.dart';
import '../../../../Core/Widgets/MediaqueryHelperfile.dart';
import 'postjobcontroller.dart';

class PostJobSummaryScreen extends StatelessWidget {
  const PostJobSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.05)),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppSize.heightPercent(0.02)),
                        const _SummaryHeader(),
                        SizedBox(height: AppSize.heightPercent(0.03)),

                        // ---------------- LOCATION CARD (NEW) ----------------
                        Obx(() {
                          final hasLocation = controller.latitude.value != null &&
                              controller.longitude.value != null &&
                              controller.locationController.text.trim().isNotEmpty;

                          if (!hasLocation) return const SizedBox.shrink();

                          return Column(
                            children: [
                              _SummaryCard(
                                icon: Icons.location_on_rounded,
                                title: 'post_job_location_label'.tr,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Address Text
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(AppSize.widthPercent(0.016)),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.place_rounded,
                                            size: AppSize.textPercent(0.036),
                                            color: theme.primaryColor.withOpacity(0.85),
                                          ),
                                        ),
                                        SizedBox(width: AppSize.widthPercent(0.03)),
                                        Expanded(
                                          child: Text(
                                            controller.locationController.text,
                                            style: TextStyle(
                                              fontFamily: "pb",
                                              fontSize: AppSize.textPercent(0.037),
                                              fontWeight: FontWeight.w600,
                                              height: 1.35,
                                              color: theme.canvasColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: AppSize.heightPercent(0.018)),
                                    Divider(
                                      color: theme.dividerColor.withOpacity(0.15),
                                      height: 1,
                                    ),
                                    SizedBox(height: AppSize.heightPercent(0.018)),

                                    // Non-interactive Map
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: SizedBox(
                                        height: AppSize.heightPercent(0.22),
                                        width: double.infinity,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                              controller.latitude.value!,
                                              controller.longitude.value!,
                                            ),
                                            zoom: 15.5,
                                          ),
                                          markers: {
                                            Marker(
                                              markerId: const MarkerId('job_location'),
                                              position: LatLng(
                                                controller.latitude.value!,
                                                controller.longitude.value!,
                                              ),
                                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                                BitmapDescriptor.hueAzure,
                                              ),
                                            ),
                                          },
                                          // Make map completely non-interactive
                                          zoomControlsEnabled: false,
                                          myLocationButtonEnabled: false,
                                          myLocationEnabled: false,
                                          compassEnabled: false,
                                          mapToolbarEnabled: false,
                                          rotateGesturesEnabled: false,
                                          scrollGesturesEnabled: false,
                                          tiltGesturesEnabled: false,
                                          zoomGesturesEnabled: false,
                                          liteModeEnabled: true, // better performance
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSize.heightPercent(0.02)),
                            ],
                          );
                        }),

                        // ---------------- BUDGET & PAYMENT ----------------
                        _SummaryCard(
                          iconWidget: _currencyBadge(theme),
                          title: 'post_job_summary_budget_payment_title'.tr,
                          child: Obx(
                                () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SummaryRow(
                                  icon: Icons.price_change_outlined,
                                  label: 'post_job_summary_budget_type_label'.tr,
                                  value: _budgetTypeLabel(controller.budgetType.value),
                                ),
                                _SummaryRow(
                                  icon: Icons.payments_outlined,
                                  label: 'post_job_amount_label'.tr,
                                  value: _budgetAmountLabel(controller),
                                ),
                                _SummaryRow(
                                  icon: controller.paymentTypeIcon,
                                  label: 'post_job_payment_type_label'.tr,
                                  value: controller.paymentTypeLabel,
                                  isLast: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppSize.heightPercent(0.02)),

                        // ---------------- SCHEDULE ----------------
                        _SummaryCard(
                          icon: Icons.calendar_month_rounded,
                          title: 'post_job_schedule_badge'.tr,
                          child: Obx(
                                () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SummaryRow(
                                  icon: Icons.event_rounded,
                                  label: 'post_job_summary_date_label'.tr,
                                  value: controller.scheduleDateLabel,
                                ),
                                _SummaryRow(
                                  icon: Icons.access_time_rounded,
                                  label: 'post_job_start_time_label'.tr,
                                  value: controller.startTimeLabel,
                                ),
                                _SummaryRow(
                                  icon: Icons.access_time_filled_rounded,
                                  label: 'post_job_end_time_label'.tr,
                                  value: controller.endTimeLabel,
                                  isLast: true,
                                ),
                                const SizedBox(height: 4),
                                _UrgencyChip(
                                  urgencyLabel: controller.urgencyLabel,
                                  isUrgent: controller.urgencyType.value == UrgencyType.urgent,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppSize.heightPercent(0.02)),

                        // ---------------- PHOTOS ----------------
                        Obx(
                              () => controller.attachedPhotos.isEmpty
                              ? const SizedBox.shrink()
                              : Column(
                            children: [
                              _SummaryCard(
                                icon: Icons.photo_library_outlined,
                                title: 'post_job_photo_attachment_label'.tr,
                                child: Wrap(
                                  spacing: AppSize.widthPercent(0.03),
                                  runSpacing: AppSize.widthPercent(0.03),
                                  children: controller.attachedPhotos
                                      .map(
                                        (file) => ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        file,
                                        width: AppSize.widthPercent(0.22),
                                        height: AppSize.widthPercent(0.22),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                      .toList(),
                                ),
                              ),
                              SizedBox(height: AppSize.heightPercent(0.02)),
                            ],
                          ),
                        ),

                        SizedBox(height: AppSize.heightPercent(0.01)),
                      ],
                    ),
                  ),
                ),

                // BOTTOM ACTION BUTTONS
                const _SummaryActionButtonsRow(),
                SizedBox(height: AppSize.heightPercent(0.02)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _budgetTypeLabel(BudgetType type) {
    switch (type) {
      case BudgetType.fixed:
        return 'post_job_summary_budget_fixed_price'.tr;
      case BudgetType.hourly:
        return 'post_job_summary_budget_hourly_rate'.tr;
      case BudgetType.negotiable:
        return 'post_job_summary_budget_negotiable'.tr;
    }
  }

  static String _budgetAmountLabel(PostJobController controller) {
    final String currency = 'post_job_currency_uzs'.tr;

    switch (controller.budgetType.value) {
      case BudgetType.fixed:
        final amount = controller.amountController.text;
        return amount.isEmpty
            ? "—"
            : "$currency$amount ${'post_job_summary_amount_one_time'.tr}";
      case BudgetType.hourly:
        final rate = controller.rateController.text;
        final hours = controller.estimatedHoursController.text;
        if (rate.isEmpty) return "—";
        return hours.isEmpty
            ? "$currency$rate ${'post_job_summary_amount_per_hour'.tr}"
            : "$currency$rate ${'post_job_summary_amount_per_hour'.tr} · ~$hours ${'post_job_summary_amount_hrs_suffix'.tr}";
      case BudgetType.negotiable:
        return 'post_job_summary_amount_negotiable_desc'.tr;
    }
  }
}

/// ------------------------------------------------------------
/// HEADER
/// ------------------------------------------------------------
class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const CustomBackButton(),
        SizedBox(width: AppSize.width * 0.03),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: AppSize.textPercent(0.065),
                  fontWeight: FontWeight.bold,
                  color: theme.canvasColor,
                ),
                children: [
                  TextSpan(text: 'post_job_summary_header_review'.tr),
                  TextSpan(
                    text: 'post_job_summary_header_confirm'.tr,
                    style: TextStyle(color: theme.primaryColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.heightPercent(0.006)),
            Text(
              'post_job_summary_header_subtitle'.tr,
              style: TextStyle(
                fontFamily: "pr",
                fontSize: AppSize.textPercent(0.035),
                color: theme.canvasColor.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// REUSABLE SUMMARY CARD
/// ------------------------------------------------------------
class _SummaryCard extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final Widget child;

  const _SummaryCard({
    this.icon,
    this.iconWidget,
    required this.title,
    required this.child,
  }) : assert(icon != null || iconWidget != null, 'Provide either icon or iconWidget');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.widthPercent(0.045)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSize.widthPercent(0.02)),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: iconWidget ??
                        Icon(icon, color: theme.primaryColor, size: AppSize.textPercent(0.042)),
                  ),
                  SizedBox(width: AppSize.widthPercent(0.03)),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: "pb",
                      fontSize: AppSize.textPercent(0.04),
                      fontWeight: FontWeight.bold,
                      color: theme.canvasColor,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(AppSize.widthPercent(0.018)),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: AppSize.textPercent(0.038),
                    color: theme.canvasColor.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.016)),
          Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
          SizedBox(height: AppSize.heightPercent(0.014)),
          child,
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// SUMMARY ROW
/// ------------------------------------------------------------
class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSize.heightPercent(0.02)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.widthPercent(0.016)),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: AppSize.textPercent(0.036),
              color: theme.primaryColor.withOpacity(0.85),
            ),
          ),
          SizedBox(width: AppSize.widthPercent(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: "pr",
                    fontSize: AppSize.textPercent(0.031),
                    color: theme.canvasColor.withOpacity(0.5),
                  ),
                ),
                SizedBox(height: AppSize.heightPercent(0.004)),
                Text(
                  value,
                  softWrap: true,
                  style: TextStyle(
                    fontFamily: "pb",
                    fontSize: AppSize.textPercent(0.037),
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                    color: theme.canvasColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// URGENCY CHIP
/// ------------------------------------------------------------
class _UrgencyChip extends StatelessWidget {
  final String urgencyLabel;
  final bool isUrgent;
  const _UrgencyChip({required this.urgencyLabel, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    final Color color = isUrgent ? const Color(0xffEF4444) : const Color(0xff10B981);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.widthPercent(0.03),
          vertical: AppSize.heightPercent(0.008),
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUrgent ? Icons.local_fire_department_rounded : Icons.schedule_rounded,
              color: color,
              size: AppSize.textPercent(0.036),
            ),
            SizedBox(width: AppSize.widthPercent(0.015)),
            Text(
              urgencyLabel,
              style: TextStyle(
                fontFamily: "pb",
                fontSize: AppSize.textPercent(0.032),
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// BOTTOM ACTION BUTTONS
/// ------------------------------------------------------------
class _SummaryActionButtonsRow extends StatelessWidget {
  const _SummaryActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: AppSize.heightPercent(0.02)),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, size: AppSize.textPercent(0.03), color: theme.canvasColor),
                  SizedBox(width: AppSize.widthPercent(0.015)),
                  Text(
                    'post_job_summary_edit_details_button'.tr,
                    style: TextStyle(
                      fontFamily: "pb",
                      fontSize: AppSize.textPercent(0.031),
                      fontWeight: FontWeight.bold,
                      color: theme.canvasColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: AppSize.widthPercent(0.02)),
        Expanded(
          child: Obx(
                () => GestureDetector(
              onTap: controller.isSubmitting.value ? null : () => controller.confirmAndSubmit(),
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: AppSize.heightPercent(0.02)),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: controller.isSubmitting.value
                    ? SizedBox(
                  height: AppSize.heightPercent(0.022),
                  width: AppSize.heightPercent(0.022),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                    SizedBox(width: AppSize.widthPercent(0.02)),
                    Text(
                      'post_job_summary_confirm_submit_button'.tr,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: AppSize.textPercent(0.034),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// CURRENCY BADGE
/// ------------------------------------------------------------
Widget _currencyBadge(ThemeData theme) {
  return Text(
    'post_job_currency_uzs'.tr,
    style: TextStyle(
      fontFamily: "pb",
      fontSize: AppSize.textPercent(0.04),
      color: theme.primaryColor,
      fontWeight: FontWeight.bold,
    ),
  );
}
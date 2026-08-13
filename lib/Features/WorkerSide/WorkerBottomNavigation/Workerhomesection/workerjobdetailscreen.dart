import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/Backbutton.dart';
import 'package:helper_app2/Core/Widgets/AppLoader.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/WorkerBottomnavigationScreen.dart';
import 'package:helper_app2/Features/WorkerSide/WorkerBottomNavigation/Workerhomesection/workerexplorejobmodel.dart';
import '../../../../Core/Apis/workerjobservice.dart';
import '../../../../Core/Widgets/MediaqueryHelperfile.dart';

import '../../../../Core/Widgets/networkimage.dart';
import '../../../SharedScreen/ChatSection/MessageScreen.dart' hide AppSize;

import '../Workermyjobssection/controller.dart';
import 'workerhomecontroller.dart';
import 'dart:async';

class WorkerJobDetailScreen extends StatefulWidget {
  final int jobId;
  const WorkerJobDetailScreen({super.key, required this.jobId});

  @override
  State<WorkerJobDetailScreen> createState() => _WorkerJobDetailScreenState();
}

class _WorkerJobDetailScreenState extends State<WorkerJobDetailScreen> {
  late final WorkerHomeController controller;
  Timer? _presenceTimer;
  bool _presenceRefreshRunning = false;

  @override
  void initState() {
    super.initState();

    controller = Get.find<WorkerHomeController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.refreshJobsSilently();

      _startPresenceRefresh();
    });
  }
  void _startPresenceRefresh() {
    _presenceTimer?.cancel();

    _presenceTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => _refreshClientPresence(),
    );
  }

  Future<void> _refreshClientPresence() async {
    if (_presenceRefreshRunning) return;

    _presenceRefreshRunning = true;

    try {
      await controller.refreshJobsSilently();
    } finally {
      _presenceRefreshRunning = false;
    }
  }
  @override
  void dispose() {
    _presenceTimer?.cancel();
    super.dispose();
  }
  Future<void> _handleApply(WorkerExploreJobModel job) async {
    // NEW: ek to already applied worker dobara apply na kar sake, dosra —
    // agar job kisi ko mil chuki hai (select ho chuki hai) tu koi bhi
    // (chahe applied ho ya na ho) apply na kar sake.
    if (controller.isJobApplied(job.id) || job.hasSelectedWorker) return;

    AppLoader.show(text: 'worker_job_detail_submitting_application'.tr);
    final result = await WorkerJobService.applyForJob(job.id);
    AppLoader.hide();

    if (result.success) {
      controller.markJobApplied(job.id);

      try {
        if (Get.isRegistered<WorkerJobHistoryController>()) {
          final historyController = Get.find<WorkerJobHistoryController>();
          historyController.addAppliedJobOptimistically(job);
          await historyController.refreshJobsSilently();
          print("✅ [WorkerJobDetailScreen] Successfully refreshed WorkerMyJobScreen state");
        } else {
          print("ℹ️ [WorkerJobDetailScreen] WorkerJobHistoryController not registered yet, state will load fresh on screen open.");
        }
      } catch (e) {
        print("⚠️ [WorkerJobDetailScreen] Background sync omitted: $e");
      }

      Get.snackbar('worker_job_detail_success_title'.tr, result.message,  backgroundColor: Colors.grey,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),
      );

      Get.offAll(() => const Workerbottomnavigationscreen());
    } else {
      if (result.message.toLowerCase().contains("already applied")) {
        controller.markJobApplied(job.id);
      }
      Get.snackbar('worker_job_detail_application_update_title'.tr, result.message,  backgroundColor: Colors.grey,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),
      );
    }
  }

  /// CANCEL JOB (worker side) — client/jobs/cancel API
  Future<void> _handleCancel(int jobId) async {
    AppLoader.show(text: 'worker_job_detail_cancelling_job'.tr);
    final result = await controller.cancelJob(jobId);
    AppLoader.hide();
    Get.snackbar(
      result.success ? 'worker_job_detail_job_cancelled_title'.tr : 'worker_job_detail_action_failed_title'.tr,
      result.message,
      backgroundColor: Colors.grey,
      snackPosition: SnackPosition.BOTTOM,
      padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),

    );
  }

  /// COMPLETE JOB (worker side) — worker/jobs/complete API
  Future<void> _handleComplete(int jobId) async {
    AppLoader.show(text: 'worker_job_detail_marking_completed'.tr);
    final result = await controller.completeJob(jobId);
    AppLoader.hide();
    Get.snackbar(
      result.success ? 'worker_job_detail_job_completed_title'.tr : 'worker_job_detail_action_failed_title'.tr,
      result.message,
      backgroundColor: Colors.grey,
      snackPosition: SnackPosition.BOTTOM,
      padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      final job = controller.getJobById(widget.jobId);

      if (job == null) {
        return Scaffold(
          body: AppBackground(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.05)),
                child: Column(
                  children: [
                    SizedBox(height: AppSize.heightPercent(0.02)),
                    const Row(children: [CustomBackButton()]),
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: AppSize.width * 0.16,
                                color: theme.canvasColor.withOpacity(0.25)),
                            SizedBox(height: AppSize.heightPercent(0.015)),
                            Text(
                              'worker_job_detail_not_found'.tr,
                              style: TextStyle(
                                fontFamily: "pb",
                                fontSize: AppSize.textPercent(0.04),
                                color: theme.canvasColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final myWorkerId = controller.workerId.value;
      final hasApplied = controller.isJobApplied(job.id);

      // NEW: job lifecycle state — ab "confirmed" sirf tab true hoga jab
      // yeh job KHASS is worker ke liye select hui ho, kisi aur ke liye nahi.
      final bool mySelected = job.hasSelectedWorker && job.selectedWorkerId == myWorkerId;
      final bool takenByOther = job.hasSelectedWorker && job.selectedWorkerId != myWorkerId;
      final bool completed = job.isCompleted;
      final bool cancelled = job.isCancelled;

      return Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.05)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSize.heightPercent(0.02)),
                    const Row(children: [CustomBackButton()]),
                    SizedBox(height: AppSize.heightPercent(0.02)),

                    /// ---------------- HERO HEADER ----------------
                    _JobHeroHeader(job: job, theme: theme),
                    SizedBox(height: AppSize.heightPercent(0.025)),
                    if (job.hasCoordinates) ...[
                      _LocationMapCard(job: job),
                      SizedBox(height: AppSize.heightPercent(0.02)),
                    ],
                    if (job.hasImages) ...[
                      _PhotosCard(job: job),
                      SizedBox(height: AppSize.heightPercent(0.02)),
                    ],

                    /// ---------------- OVERVIEW ----------------
                    _DetailCard(
                      icon: Icons.assignment_outlined,
                      title: 'worker_job_detail_overview_title'.tr,
                      accent: const Color(0xff3B82F6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(icon: Icons.category_outlined, label: 'worker_job_detail_label_category'.tr, value: job.category),
                          _DetailRow(icon: Icons.category_outlined, label: 'worker_job_detail_label_category'.tr, value: job.category),
                          _DetailRow(
                            icon: Icons.flag_outlined,
                            label: 'worker_job_detail_label_status'.tr,
                            value: job.state,
                            isLast: true,
                          ),
                          _DetailRow(
                            icon: Icons.flag_outlined,
                            label: 'worker_job_detail_label_status'.tr,
                            value: job.state,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(0.02)),

                    /// ---------------- BUDGET & PAYMENT ----------------
                    /// NOTE: uses the currency text badge instead of the
                    /// old $ / attach_money_rounded icon.
                    _DetailCard(
                      iconWidget: _currencyBadge(theme),
                      title: 'worker_job_detail_budget_title'.tr,
                      accent: const Color(0xff10B981),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(icon: Icons.receipt_long_outlined, label: 'worker_job_detail_label_amount'.tr, value: job.amountLabel),
                          _DetailRow(
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'worker_job_detail_label_payment_mode'.tr,
                            value: job.paymentModeLabel,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(0.02)),

                    /// ---------------- SCHEDULE ----------------
                    _DetailCard(
                      icon: Icons.calendar_month_rounded,
                      title: 'worker_job_detail_schedule_title'.tr,
                      accent: const Color(0xff8B5CF6),
                      child: _DetailRow(
                        icon: Icons.event_rounded,
                        label: 'worker_job_detail_label_date_time'.tr,
                        value: job.schedule,
                        isLast: true,
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(0.02)),

                    /// ---------------- DESCRIPTION ----------------
                    _DetailCard(
                      icon: Icons.notes_rounded,
                      title: 'worker_job_detail_description_title'.tr,
                      accent: const Color(0xffF59E0B),
                      child: Text(
                        job.description.isEmpty ? 'worker_job_detail_no_description'.tr : job.description,
                        style: TextStyle(
                          fontFamily: "pr",
                          fontSize: AppSize.textPercent(0.036),
                          height: 1.55,
                          color: theme.canvasColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(0.02)),
                    /// ---------------- POSTED BY (client info) ----------------
                    _DetailCard(
                      icon: Icons.person_outline_rounded,
                      title: 'worker_job_detail_posted_by_title'.tr,
                      accent: const Color(0xffEC4899),
                      child: Row(
                        children: [
                          _ClientAvatar(job: job, theme: theme, size: AppSize.width * 0.13),
                          SizedBox(width: AppSize.widthPercent(0.03)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.clientInfo.name,
                                  style: TextStyle(
                                    fontFamily: "pb",
                                    fontSize: AppSize.textPercent(0.038),
                                    fontWeight: FontWeight.bold,
                                    color: theme.canvasColor,
                                  ),
                                ),
                                SizedBox(height: AppSize.heightPercent(0.004)),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                                    const SizedBox(width: 3),
                                    Text(
                                      job.clientInfo.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontFamily: "pb",
                                        fontSize: AppSize.textPercent(0.031),
                                        color: theme.canvasColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: AppSize.heightPercent(0.006)),
                                // ONLINE / OFFLINE indicator for the client
                                _OnlineStatusPill(isOnline: job.clientInfo.isOnline),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSize.heightPercent(0.035)),

                    /// ---------------- ACTION BUTTONS (LIFECYCLE-AWARE) ----------------
                    if (mySelected && completed)
                      _statusBanner(
                        theme: theme,
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xff10B981),
                        text: 'worker_job_detail_completed_banner'.tr,
                      )
                    else if (mySelected && cancelled)
                      _statusBanner(
                        theme: theme,
                        icon: Icons.cancel_rounded,
                        color: const Color(0xffEF4444),
                        text: 'worker_job_detail_cancelled_banner'.tr,
                      )
                    else if (mySelected) ...[
                        // Client ne is worker ko select kar diya -> Chat + Cancel + Mark Completed
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Get.to(() => Messagescreen(
                                  otherUserId: job.clientInfo.id, // agar clientInfo mein "id" field na ho, to jo bhi client ka actual user id wala field hai wo use karein
                                  otherUserName: job.clientInfo.name,
                                  otherUserProfilePic: job.clientInfo.hasImage ? job.clientInfo.image : null,
                                ),transition: Transition.fade),
                                child: Container(
                                  height: AppSize.heightPercent(0.065),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: AppSize.textPercent(0.042),
                                        color: theme.primaryColor,
                                      ),
                                      SizedBox(width: AppSize.widthPercent(0.02)),
                                      Text(
                                        'worker_job_detail_chat_with_client'.tr,
                                        style: TextStyle(
                                          fontFamily: "pb",
                                          fontSize: AppSize.textPercent(0.035),
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSize.widthPercent(0.03)),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _handleCancel(job.id),
                                child: Container(
                                  height: AppSize.heightPercent(0.065),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xffEF4444), Color(0xffDC2626)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xffEF4444).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                                      SizedBox(width: AppSize.widthPercent(0.02)),
                                      Text(
                                        'worker_job_detail_cancel_job_button'.tr,
                                        style: TextStyle(
                                          fontFamily: "pb",
                                          fontSize: AppSize.textPercent(0.035),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSize.heightPercent(0.014)),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () => _handleComplete(job.id),
                            child: Container(
                              height: AppSize.heightPercent(0.065),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xff10B981), Color(0xff059669)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xff10B981).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.task_alt_rounded, size: 18, color: Colors.white),
                                  SizedBox(width: AppSize.widthPercent(0.02)),
                                  Text(
                                    'worker_job_detail_mark_completed_button'.tr,
                                    style: TextStyle(
                                      fontFamily: "pb",
                                      fontSize: AppSize.textPercent(0.035),
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ] else if (takenByOther)
                      // NEW: job kisi aur worker ko mil chuki hai — na Apply, na Chat
                        _statusBanner(
                          theme: theme,
                          icon: Icons.block_rounded,
                          color: theme.canvasColor.withOpacity(0.5),
                          text: 'worker_job_detail_taken_by_other_banner'.tr,
                        )
                      else if (hasApplied)
                        // Apply ho chuki hai lekin abhi client ne confirm nahi ki ->
                        // Apply button ghaib, sirf Chat button + waiting status
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () => Get.to(() => Messagescreen(
                                    otherUserId: job.clientInfo.id, // agar clientInfo mein "id" field na ho, to jo bhi client ka actual user id wala field hai wo use karein
                                    otherUserName: job.clientInfo.name,
                                    otherUserProfilePic: job.clientInfo.hasImage ? job.clientInfo.image : null,
                                  ),transition: Transition.fade),
                                  child: Container(
                                    height: AppSize.heightPercent(0.065),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: AppSize.textPercent(0.042),
                                          color: theme.primaryColor,
                                        ),
                                        SizedBox(width: AppSize.widthPercent(0.02)),
                                        Text(
                                          'worker_job_detail_chat_with_client'.tr,
                                          style: TextStyle(
                                            fontFamily: "pb",
                                            fontSize: AppSize.textPercent(0.035),
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: AppSize.heightPercent(0.014)),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSize.widthPercent(0.04),
                                  vertical: AppSize.heightPercent(0.014),
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF59E0B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xffF59E0B).withOpacity(0.25)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.hourglass_top_rounded, size: 16, color: Color(0xffF59E0B)),
                                    SizedBox(width: AppSize.widthPercent(0.02)),
                                    Flexible(
                                      child: Text(
                                        'worker_job_detail_waiting_confirmation'.tr,
                                        style: TextStyle(
                                          fontFamily: "pr",
                                          fontSize: AppSize.textPercent(0.032),
                                          color: theme.canvasColor.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                        // Abhi tak apply nahi ki, job bhi open hai -> Chat + Apply
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Get.to(() => Messagescreen(
                                    otherUserId: job.clientInfo.id, // agar clientInfo mein "id" field na ho, to jo bhi client ka actual user id wala field hai wo use karein
                                    otherUserName: job.clientInfo.name,
                                    otherUserProfilePic: job.clientInfo.hasImage ? job.clientInfo.image : null,
                                  ),transition: Transition.fade),
                                  child: Container(
                                    height: AppSize.heightPercent(0.07),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: AppSize.textPercent(0.042),
                                          color: theme.primaryColor,
                                        ),
                                        SizedBox(width: AppSize.widthPercent(0.02)),
                                        Text(
                                          'worker_job_detail_chat_with_client'.tr,
                                          style: TextStyle(
                                            fontFamily: "pb",
                                            fontSize: AppSize.textPercent(0.035),
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSize.widthPercent(0.03)),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _handleApply(job),
                                  child: Container(
                                    height: AppSize.heightPercent(0.07),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.primaryColor.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded, size: AppSize.textPercent(0.045), color: theme.cardColor),
                                        SizedBox(width: AppSize.widthPercent(0.02)),
                                        Text(
                                          'worker_job_detail_apply_button'.tr,
                                          style: TextStyle(
                                            fontFamily: "pb",
                                            fontSize: AppSize.textPercent(0.038),
                                            fontWeight: FontWeight.bold,
                                            color: theme.cardColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                    SizedBox(height: AppSize.heightPercent(0.03)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// lifecycle status banner (completed / cancelled / taken-by-other)
  static Widget _statusBanner({
    required ThemeData theme,
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.widthPercent(0.04),
        vertical: AppSize.heightPercent(0.02),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.widthPercent(0.02)),
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          SizedBox(width: AppSize.widthPercent(0.03)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: "pb",
                fontSize: AppSize.textPercent(0.034),
                fontWeight: FontWeight.bold,
                color: theme.canvasColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// CURRENCY BADGE — replaces every $ / attach_money_rounded icon
/// with the app's actual currency text, everywhere money appears.
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

/// ------------------------------------------------------------
/// HERO HEADER — job title, location, price & state, gradient card
/// (same visual language as the client-side job detail hero header)
/// ------------------------------------------------------------
class _JobHeroHeader extends StatelessWidget {
  final WorkerExploreJobModel job;
  final ThemeData theme;
  const _JobHeroHeader({required this.job, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.widthPercent(0.05)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontFamily: "pb",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
              ),
              SizedBox(width: AppSize.widthPercent(0.02)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.widthPercent(0.028),
                  vertical: AppSize.heightPercent(0.007),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  job.state.replaceAll('_', ' '),
                  style: const TextStyle(
                    fontFamily: "pb",
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.012)),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.subtitleLocation,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: "pr", fontSize: 13, color: Colors.white70),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.02)),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          SizedBox(height: AppSize.heightPercent(0.016)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('worker_job_detail_label_amount'.tr,
                      style: const TextStyle(fontFamily: "pr", fontSize: 11, color: Colors.white60)),
                  const SizedBox(height: 2),
                  Text(
                    job.amountLabel,
                    style: const TextStyle(
                      fontFamily: "pb",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, color: theme.primaryColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      job.paymentModeLabel,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// SMALL REUSABLE ONLINE/OFFLINE PILL
/// ------------------------------------------------------------
class _OnlineStatusPill extends StatelessWidget {
  final bool isOnline;
  const _OnlineStatusPill({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? const Color(0xff1DBF73) : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'worker_job_detail_online_pill'.tr : 'worker_job_detail_offline_pill'.tr,
            style: TextStyle(
              fontSize: AppSize.textPercent(0.028),
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// REUSABLE READ-ONLY DETAIL CARD — now supports either a plain
/// IconData OR a custom iconWidget (used for the currency badge).
/// ------------------------------------------------------------
class _DetailCard extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final Widget child;
  final Color accent;

  const _DetailCard({
    this.icon,
    this.iconWidget,
    required this.title,
    required this.child,
    this.accent = const Color(0xff3B82F6),
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
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.widthPercent(0.02)),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: iconWidget ?? Icon(icon, color: accent, size: AppSize.textPercent(0.042)),
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
          SizedBox(height: AppSize.heightPercent(0.016)),
          Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
          SizedBox(height: AppSize.heightPercent(0.016)),
          child,
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// DETAIL ROW — icon + label on top, FULL value below (wraps, never cuts)
/// ------------------------------------------------------------
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
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
            padding: EdgeInsets.all(AppSize.widthPercent(0.018)),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
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
/// PHOTOS CARD — with tap-to-zoom fullscreen viewer, same as the
/// client-side job detail screen for a consistent experience.
/// ------------------------------------------------------------
class _PhotosCard extends StatelessWidget {
  final WorkerExploreJobModel job;
  const _PhotosCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final urls = job.fullImageUrls;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.widthPercent(0.045)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.widthPercent(0.02)),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library_outlined, color: theme.primaryColor, size: AppSize.textPercent(0.042)),
              ),
              SizedBox(width: AppSize.widthPercent(0.03)),
              Text(
                'worker_job_detail_photos_title'.tr,
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: AppSize.textPercent(0.04),
                  fontWeight: FontWeight.bold,
                  color: theme.canvasColor,
                ),
              ),
              const Spacer(),
              Text(
                (urls.length > 1
                    ? 'worker_job_detail_photo_count_plural'
                    : 'worker_job_detail_photo_count_singular')
                    .trParams({'count': '${urls.length}'}),
                style: TextStyle(
                  fontFamily: "pr",
                  fontSize: AppSize.textPercent(0.03),
                  color: theme.canvasColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.016)),
          Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
          SizedBox(height: AppSize.heightPercent(0.014)),
          SizedBox(
            height: AppSize.widthPercent(0.28),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: urls.length,
              separatorBuilder: (_, __) => SizedBox(width: AppSize.widthPercent(0.025)),
              itemBuilder: (context, index) {
                final url = urls[index];
                return GestureDetector(
                  onTap: () => _openFullscreenViewer(context, urls, index),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: AppSize.widthPercent(0.28),
                      height: AppSize.widthPercent(0.28),
                      child: NetworkImageRetry(url: url),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openFullscreenViewer(BuildContext context, List<String> urls, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return _FullscreenImageViewer(urls: urls, initialIndex: initialIndex);
        },
      ),
    );
  }
}

/// ------------------------------------------------------------
/// FULLSCREEN IMAGE VIEWER
/// ------------------------------------------------------------
class _FullscreenImageViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const _FullscreenImageViewer({required this.urls, required this.initialIndex});

  @override
  State<_FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<_FullscreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.urls.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      widget.urls[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white54,
                        size: 48,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (widget.urls.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${_currentIndex + 1} / ${widget.urls.length}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

/// ------------------------------------------------------------
/// CLIENT AVATAR
/// ------------------------------------------------------------
class _ClientAvatar extends StatelessWidget {
  final WorkerExploreJobModel job;
  final ThemeData theme;
  final double size;

  const _ClientAvatar({required this.job, required this.theme, required this.size});

  @override
  Widget build(BuildContext context) {
    final hasImage = job.clientInfo.hasImage;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? NetworkImageRetry(
        url: job.clientInfo.image!,
        placeholderIconBuilder: (context) => _personIcon(),
      )
          : _personIcon(),
    );
  }

  Widget _personIcon() {
    return Icon(
      Icons.person_rounded,
      size: size * 0.55,
      color: theme.primaryColor,
    );
  }
}
class _LocationMapCard extends StatelessWidget {
  final WorkerExploreJobModel job;
  const _LocationMapCard({required this.job});

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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.widthPercent(0.02)),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.location_on_rounded, color: theme.primaryColor, size: AppSize.textPercent(0.042)),
              ),
              SizedBox(width: AppSize.widthPercent(0.03)),
              Text(
                'post_job_location_label'.tr,
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: AppSize.textPercent(0.04),
                  fontWeight: FontWeight.bold,
                  color: theme.canvasColor,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.016)),
          Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
          SizedBox(height: AppSize.heightPercent(0.014)),
          Text(
            job.location.isNotEmpty ? job.location : job.city,
            style: TextStyle(
              fontFamily: "pb",
              fontSize: AppSize.textPercent(0.037),
              fontWeight: FontWeight.w600,
              height: 1.35,
              color: theme.canvasColor,
            ),
          ),
          SizedBox(height: AppSize.heightPercent(0.018)),
          Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
          SizedBox(height: AppSize.heightPercent(0.018)),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: AppSize.heightPercent(0.22),
              width: double.infinity,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(job.latitude!, job.longitude!),
                  zoom: 15.5,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('worker_job_${job.id}'),
                    position: LatLng(job.latitude!, job.longitude!),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                liteModeEnabled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
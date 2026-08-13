import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Features/SharedScreen/ChatSection/MessageScreen.dart' hide AppSize;
import '../../../../Core/Widgets/Background.dart';
import '../../../../Core/Widgets/Backbutton.dart';
import '../../../../Core/Widgets/MediaqueryHelperfile.dart';
import '../../../../Core/Widgets/AppLoader.dart';
import 'clientjobcontroller.dart';
import 'clientjobmodel.dart';

class ClientConfirmWorkerScreen extends StatelessWidget {
  final JobPostModel job;
  final WorkerApplicant worker;


  const ClientConfirmWorkerScreen({
    super.key,
    required this.job,
    required this.worker,
  });

  Future<void> _handleAccept(ClientJobsController controller, ThemeData theme) async {
    AppLoader.show(text: 'client_confirm_worker_selecting'.tr);
    final result = await controller.selectWorker(job.id, worker.id);
    AppLoader.hide();

    Get.snackbar(
      result.success ? 'client_confirm_worker_selected_title'.tr : 'client_confirm_worker_action_failed_title'.tr,
      result.message,
      snackPosition: SnackPosition.BOTTOM,
      padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),      backgroundColor: result.success ? theme.primaryColor : null,
      colorText: result.success ? theme.cardColor : null,
    );
  }

  Future<void> _handleCancel(ClientJobsController controller) async {
    AppLoader.show(text: 'client_confirm_worker_cancelling'.tr);
    final result = await controller.cancelJob(job.id);
    AppLoader.hide();
    Get.snackbar(
      result.success ? 'client_confirm_worker_cancelled_title'.tr : 'client_confirm_worker_action_failed_title'.tr,
      result.message,
      snackPosition: SnackPosition.BOTTOM,
      padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),    );
  }

  Future<void> _handleComplete(ClientJobsController controller) async {
    AppLoader.show(text: 'client_confirm_worker_completing'.tr);
    final result = await controller.completeJob(job.id, worker.workerId);
    AppLoader.hide();
    Get.snackbar(
      result.success ? 'client_confirm_worker_completed_title'.tr : 'client_confirm_worker_action_failed_title'.tr,
      result.message,
      snackPosition: SnackPosition.BOTTOM,
      padding: EdgeInsets.symmetric(vertical: AppSize.height*0.01,horizontal: AppSize.height*0.01),    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientJobsController>();
    final theme = Theme.of(context);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.05)),
            child: Column(
              children: [
                SizedBox(height: AppSize.heightPercent(0.02)),

                Row(
                  children: [
                    const CustomBackButton(),
                    SizedBox(width: AppSize.width * 0.03),
                    Text(
                      'client_confirm_worker_header_title'.tr,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: AppSize.textPercent(0.05),
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.heightPercent(0.02)),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileHeroCard(worker: worker, job: job, theme: theme,size: 0,),
                        SizedBox(height: AppSize.heightPercent(0.02)),

                        if (worker.skills.isNotEmpty) ...[
                          _InfoCard(
                            icon: Icons.build_outlined,
                            title: 'client_confirm_worker_skills'.tr,
                            accent: const Color(0xff8B5CF6),
                            child: Wrap(
                              spacing: AppSize.widthPercent(0.02),
                              runSpacing: AppSize.heightPercent(0.01),
                              children: worker.skills.map((s) => _skillPill(s, theme)).toList(),
                            ),
                            theme: theme,
                          ),
                          SizedBox(height: AppSize.heightPercent(0.02)),
                        ],

                        _InfoCard(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'client_confirm_worker_job_budget'.tr,
                          accent: const Color(0xff10B981),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      job.title,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: "pr",
                                        fontSize: AppSize.textPercent(0.036),
                                        color: theme.canvasColor.withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    job.budgetBreakdownLabel,
                                    style: TextStyle(
                                      fontFamily: "pb",
                                      fontSize: AppSize.textPercent(0.04),
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSize.heightPercent(0.01)),
                              Row(
                                children: [
                                  Icon(job.paymentModeIcon, size: AppSize.textPercent(0.036), color: theme.canvasColor.withOpacity(0.5)),
                                  SizedBox(width: AppSize.widthPercent(0.015)),
                                  Text(
                                    'client_confirm_worker_payment_via'.trParams({'mode': job.paymentModeLabel}),
                                    style: TextStyle(
                                      fontFamily: "pr",
                                      fontSize: AppSize.textPercent(0.032),
                                      color: theme.canvasColor.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          theme: theme,
                        ),

                        SizedBox(height: AppSize.heightPercent(0.03)),
                      ],
                    ),
                  ),
                ),

                /// BOTTOM ACTION BUTTONS — poora lifecycle yahan handle hota hai
                Obx(() {
                  final liveJob = controller.getJobById(job.id) ?? job;
                  final bool accepted = controller.isWorkerAccepted(liveJob.id, worker.id);
                  final bool confirmed = controller.hasAcceptedWorker(liveJob.id);
                  final bool someoneElseAccepted = confirmed && !accepted;
                  final bool isCompleted = liveJob.isCompleted;
                  final bool isCancelled = liveJob.isCancelled;

                  // ---------------- COMPLETED STATE ----------------
                  if (accepted && isCompleted) {
                    return _statusBanner(
                      theme: theme,
                      icon: Icons.check_circle_rounded,
                      color: const Color(0xff10B981),
                      text: 'client_confirm_worker_completed_banner'.tr,
                    );
                  }

                  // ---------------- CANCELLED STATE ----------------
                  if (accepted && isCancelled) {
                    return _statusBanner(
                      theme: theme,
                      icon: Icons.cancel_rounded,
                      color: const Color(0xffEF4444),
                      text: 'client_confirm_worker_cancelled_banner'.tr,
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSize.heightPercent(0.02)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => Get.to(() => Messagescreen(
                                  otherUserId: worker.workerId, // aap ne already isi field ko completeJob(job.id, worker.workerId) mein use kiya hua hai, isliye yehi asal worker user id hai
                                  otherUserName: worker.name,
                                  otherUserProfilePic: worker.hasProfilePic ? worker.profilePic : null,
                                )),                                child: Container(
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
                                    Icon(Icons.chat_bubble_outline_rounded,
                                        size: AppSize.textPercent(0.042), color: theme.primaryColor),
                                    SizedBox(width: AppSize.widthPercent(0.02)),
                                    Text(
                                      'client_confirm_worker_chat_button'.tr,
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

                            // ---------------- ACCEPT / CANCEL BUTTON ----------------
                            Expanded(
                              child: GestureDetector(
                                onTap: someoneElseAccepted
                                    ? null
                                    : () {
                                  if (accepted) {
                                    _handleCancel(controller);
                                  } else {
                                    _handleAccept(controller, theme);
                                  }
                                },
                                child: Container(
                                  height: AppSize.heightPercent(0.065),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: someoneElseAccepted
                                        ? null
                                        : LinearGradient(
                                      colors: accepted
                                          ? [const Color(0xffEF4444), const Color(0xffEF4444).withOpacity(0.8)]
                                          : [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    color: someoneElseAccepted ? theme.canvasColor.withOpacity(0.15) : null,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: someoneElseAccepted
                                        ? []
                                        : [
                                      BoxShadow(
                                        color: (accepted ? const Color(0xffEF4444) : theme.primaryColor).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        someoneElseAccepted
                                            ? Icons.block_rounded
                                            : (accepted ? Icons.close_rounded : Icons.check_rounded),
                                        size: AppSize.textPercent(0.042),
                                        color: someoneElseAccepted ? theme.canvasColor.withOpacity(0.5) : theme.cardColor,
                                      ),
                                      SizedBox(width: AppSize.widthPercent(0.02)),
                                      Text(
                                        someoneElseAccepted
                                            ? 'client_confirm_worker_unavailable'.tr
                                            : (accepted ? 'client_confirm_worker_cancel_job'.tr : 'client_confirm_worker_accept_worker'.tr),
                                        style: TextStyle(
                                          fontFamily: "pb",
                                          fontSize: AppSize.textPercent(0.035),
                                          fontWeight: FontWeight.bold,
                                          color: someoneElseAccepted
                                              ? theme.canvasColor.withOpacity(0.5)
                                              : theme.cardColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ---------------- MARK AS COMPLETED BUTTON ----------------
                        if (accepted) ...[
                          SizedBox(height: AppSize.heightPercent(0.014)),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () => _handleComplete(controller),
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
                                      'client_confirm_worker_mark_completed'.tr,
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
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _statusBanner({
    required ThemeData theme,
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSize.heightPercent(0.02)),
      child: Container(
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
      ),
    );
  }

  static Widget _skillPill(String text, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.widthPercent(0.03),
        vertical: AppSize.heightPercent(0.008),
      ),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "pb",
          fontSize: AppSize.textPercent(0.031),
          fontWeight: FontWeight.w600,
          color: theme.primaryColor,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// HERO PROFILE CARD — gradient banner + overlapping avatar
/// ------------------------------------------------------------
class _ProfileHeroCard extends StatelessWidget {
  final WorkerApplicant worker;
  final JobPostModel job;
  final ThemeData theme;
  final double size;


  const _ProfileHeroCard({required this.worker, required this.job,required this.size, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// GRADIENT BANNER + AVATAR
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                height: AppSize.heightPercent(0.075),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Positioned(
                left: AppSize.widthPercent(0.045),
                bottom: -AppSize.width * 0.09,
                child: Container(
                  height: AppSize.width * 0.19,
                  width: AppSize.width * 0.19,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    child: worker.hasProfilePic
                        ? Image.network(
                      worker.profilePic,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _personIcon(),
                    )
                        : _personIcon(),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSize.width * 0.1),

          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSize.widthPercent(0.045),
              0,
              AppSize.widthPercent(0.045),
              AppSize.widthPercent(0.045),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name,
                  style: TextStyle(
                    fontFamily: "pb",
                    fontSize: AppSize.textPercent(0.048),
                    fontWeight: FontWeight.bold,
                    color: theme.canvasColor,
                  ),
                ),
                SizedBox(height: AppSize.heightPercent(0.008)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            worker.ratingLabel,
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
                    SizedBox(width: AppSize.widthPercent(0.02)),

                    _LiveWorkerStatus(
                      jobId: job.id,
                      workerId: worker.workerId,
                      fallbackStatus: worker.isOnline,
                    ),
                    if (worker.hasStrikes) ...[
                      SizedBox(width: AppSize.widthPercent(0.02)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange.shade700),
                            const SizedBox(width: 3),
                            Text(
                              worker.activeStrikes > 1
                                  ? 'client_confirm_worker_active_strikes'.trParams({'count': worker.activeStrikes.toString()})
                                  : 'client_confirm_worker_active_strike'.trParams({'count': worker.activeStrikes.toString()}),
                              style: TextStyle(
                                fontFamily: "pr",
                                fontSize: AppSize.textPercent(0.028),
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: AppSize.heightPercent(0.018)),
                Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
                SizedBox(height: AppSize.heightPercent(0.016)),
                Row(
                  children: [
                    Expanded(
                      child: _statTile(
                        icon: Icons.build_outlined,
                        label: 'client_confirm_worker_skills'.tr,
                        value: worker.skills.isEmpty ? "—" : "${worker.skills.length} listed",
                        theme: theme,
                      ),
                    ),
                    Container(height: AppSize.height * 0.04, width: 1, color: theme.dividerColor.withOpacity(0.2)),
                    Expanded(
                      child: _statTile(
                        icon: Icons.badge_outlined,
                        label: 'client_confirm_worker_applied_for'.tr,
                        value: job.title,
                        theme: theme,
                        isLongText: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _personIcon() {
    return Icon(
      Icons.person_rounded,
      size: size * 0.55,
      color: theme.primaryColor,
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    bool isLongText = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.02)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSize.textPercent(0.036), color: theme.primaryColor),
              SizedBox(width: AppSize.widthPercent(0.015)),
              Text(
                label,
                style: TextStyle(
                  fontFamily: "pr",
                  fontSize: AppSize.textPercent(0.028),
                  color: theme.canvasColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.004)),
          Text(
            value,
            maxLines: isLongText ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: "pb",
              fontSize: AppSize.textPercent(0.033),
              fontWeight: FontWeight.bold,
              color: theme.canvasColor,
            ),
          ),
        ],
      ),
    );
  }
}
class _LiveWorkerStatus extends StatelessWidget {
  final int jobId;
  final int workerId;
  final bool fallbackStatus;

  const _LiveWorkerStatus({
    required this.jobId,
    required this.workerId,
    required this.fallbackStatus,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ClientJobsController>();

    return Obx(() {
      bool isOnline = fallbackStatus;

      final workers = controller.interestedWorkersFor(jobId);

      for (final item in workers) {
        if (item is WorkerApplicant &&
            item.workerId == workerId) {
          isOnline = item.isOnline;
          break;
        }
      }

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSize.widthPercent(0.022),
          vertical: AppSize.heightPercent(0.005),
        ),
        decoration: BoxDecoration(
          color: isOnline
              ? theme.primaryColor.withOpacity(0.12)
              : theme.canvasColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: AppSize.width * 0.018,
              height: AppSize.width * 0.018,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline
                    ? theme.primaryColor
                    : theme.canvasColor.withOpacity(0.4),
              ),
            ),
            SizedBox(width: AppSize.widthPercent(0.012)),
            Text(
              isOnline ? 'Online' : 'Offline',
              style: TextStyle(
                fontFamily: "pb",
                fontSize: AppSize.textPercent(0.027),
                fontWeight: FontWeight.w600,
                color: isOnline
                    ? theme.primaryColor
                    : theme.canvasColor.withOpacity(0.55),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// ------------------------------------------------------------
/// INFO CARD — with colored accent icon chip
/// ------------------------------------------------------------
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final ThemeData theme;
  final Color accent;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
    required this.theme,
    this.accent = const Color(0xff3B82F6),
  });

  @override
  Widget build(BuildContext context) {
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
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: AppSize.textPercent(0.042)),
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
          SizedBox(height: AppSize.heightPercent(0.014)),
          child,
        ],
      ),
    );
  }
}
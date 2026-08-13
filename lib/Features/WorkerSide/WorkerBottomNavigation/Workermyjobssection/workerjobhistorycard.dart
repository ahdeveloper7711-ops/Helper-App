import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helper_app2/Core/Widgets/AppColors.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Widgets/networkimage.dart';
import '../Workerhomesection/workerexplorejobmodel.dart';
import '../Workerhomesection/workerhomecontroller.dart';
class WorkerJobHistoryCard extends StatefulWidget {
  final WorkerMyJobModel job;
  final int myWorkerId;

  const WorkerJobHistoryCard({
    super.key,
    required this.job,
    required this.myWorkerId,
  });

  @override
  State<WorkerJobHistoryCard> createState() => _WorkerJobHistoryCardState();
}

class _WorkerJobHistoryCardState extends State<WorkerJobHistoryCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeAnimation;

  WorkerMyJobModel get job => widget.job;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _sizeAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeInOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  String _getTranslatedState(String stateText) {
    final formatted = stateText.toLowerCase().replaceAll('_', ' ').trim();
    switch (formatted) {
      case 'pending':
        return 'job_state_pending'.tr;
      case 'ongoing':
        return 'job_state_ongoing'.tr;
      case 'completed':
        return 'job_state_completed'.tr;
      case 'cancelled':
        return 'job_state_cancelled'.tr;
      default:
        return stateText.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.isRegistered<WorkerHomeController>()
        ? Get.find<WorkerHomeController>()
        : Get.put(WorkerHomeController());

    final bool mySelected = job.hasSelectedWorker && job.selectedWorkerId == widget.myWorkerId;
    final bool takenByOther = job.hasSelectedWorker && job.selectedWorkerId != widget.myWorkerId;
    final bool completed = job.isCompleted;
    final bool cancelled = job.isCancelled;

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.height * 0.012),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 🎨 LEFT ACCENT STRIPE
              Container(
                width: 4.5,
                color: AppColors.primary,
              ),

              /// MAIN CARD CONTENT
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleExpand,
                  child: Padding(
                    padding: EdgeInsets.all(AppSize.width * 0.035),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// TOP ROW — always visible
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: AppSize.width * 0.11,
                              width: AppSize.width * 0.11,
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              clipBehavior: Clip.antiAlias,
                              alignment: Alignment.center,
                              child: job.hasImages
                                  ? NetworkImageRetry(url: job.thumbnailUrl)
                                  : Icon(Icons.person, color: theme.primaryColor, size: AppSize.width * 0.06),
                            ),
                            SizedBox(width: AppSize.width * 0.03),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: AppSize.width * 0.015,
                                    runSpacing: AppSize.height * 0.005,
                                    children: [
                                      Text(
                                        job.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: AppSize.width * 0.036,
                                          fontWeight: FontWeight.bold,
                                          color: theme.canvasColor,
                                        ),
                                      ),
                                      _smallFilledPill(
                                        completed
                                            ? 'job_state_completed'.tr
                                            : cancelled
                                            ? 'job_state_cancelled'.tr
                                            : (mySelected || takenByOther)
                                            ? 'worker_job_card_selected'.tr
                                            : _getTranslatedState(job.state),
                                        completed
                                            ? const Color(0xff10B981)
                                            : cancelled
                                            ? const Color(0xffEF4444)
                                            : mySelected
                                            ? theme.primaryColor
                                            : (takenByOther
                                            ? theme.canvasColor.withOpacity(0.4)
                                            : theme.primaryColor.withOpacity(0.75)),
                                        theme,
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSize.width * 0.018,
                                          vertical: AppSize.height * 0.003,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.14),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            Text(
                                              job.clientInfo.rating.toStringAsFixed(1),
                                              style: TextStyle(
                                                fontFamily: "pb",
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber.shade800,
                                                fontSize: AppSize.width * 0.025,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppSize.height * 0.003),
                                  Text(
                                    job.clientInfo.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: AppSize.width * 0.030,
                                      fontWeight: FontWeight.w500,
                                      color: theme.canvasColor.withOpacity(0.55),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// BOOKMARK BUTTON
                            Obx(() {
                              final bool isFav = controller.isFavourite(job.id);
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => controller.toggleFavourite(job.id),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.01),
                                  child: Icon(
                                    isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                    color: isFav ? theme.primaryColor : theme.canvasColor.withOpacity(0.6),
                                    size: AppSize.width * 0.055,
                                  ),
                                ),
                              );
                            }),

                            /// DROPDOWN TOGGLE ICON
                            _ExpandToggleButton(
                              expanded: _expanded,
                              onTap: _toggleExpand,
                              theme: theme,
                            ),
                          ],
                        ),

                        SizedBox(height: AppSize.height * 0.012),

                        /// LOCATION + PRICE — always visible
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: AppSize.width * 0.04, color: theme.canvasColor.withOpacity(0.5)),
                            SizedBox(width: AppSize.width * 0.01),
                            Expanded(
                              child: Text(
                                job.subtitleLocation,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.canvasColor.withOpacity(0.6),
                                  fontSize: AppSize.width * 0.031,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              job.amountLabel,
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: AppSize.width * 0.035,
                              ),
                            ),
                          ],
                        ),

                        /// ⚡ EXPANDABLE SECTION
                        SizeTransition(
                          sizeFactor: _sizeAnimation,
                          axisAlignment: 0.0,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: AppSize.height * 0.014),
                                Divider(color: theme.dividerColor.withOpacity(0.12), height: 1),
                                SizedBox(height: AppSize.height * 0.014),

                                /// ---------------- OVERVIEW ----------------
                                _miniSection(
                                  theme: theme,
                                  accent: const Color(0xff3B82F6),
                                  title: 'worker_job_detail_overview_title'.tr,
                                  icon: Icons.assignment_outlined,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _miniRow('worker_job_detail_label_category'.tr, job.category, theme),
                                      _miniRow('worker_job_detail_label_status'.tr, _getTranslatedState(job.state), theme, isLast: true),
                                    ],
                                  ),
                                ),
                                SizedBox(height: AppSize.height * 0.012),

                                /// ---------------- BUDGET & PAYMENT ----------------
                                _miniSection(
                                  theme: theme,
                                  accent: const Color(0xff10B981),
                                  title: 'worker_job_detail_budget_title'.tr,
                                  iconWidget: _currencyBadge(theme),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _miniRow('worker_job_detail_label_amount'.tr, job.amountLabel, theme),
                                      _miniRow('worker_job_detail_label_payment_mode'.tr, job.paymentModeLabel, theme, isLast: true),
                                    ],
                                  ),
                                ),
                                SizedBox(height: AppSize.height * 0.012),

                                /// ---------------- SCHEDULE ----------------
                                _miniSection(
                                  theme: theme,
                                  accent: const Color(0xff8B5CF6),
                                  title: 'worker_job_detail_schedule_title'.tr,
                                  icon: Icons.calendar_month_rounded,
                                  child: _miniRow('worker_job_detail_label_date_time'.tr, job.schedule, theme, isLast: true),
                                ),
                                SizedBox(height: AppSize.height * 0.012),

                                /// ---------------- DESCRIPTION ----------------
                                _miniSection(
                                  theme: theme,
                                  accent: const Color(0xffF59E0B),
                                  title: 'worker_job_detail_description_title'.tr,
                                  icon: Icons.notes_rounded,
                                  child: Text(
                                    job.description.isEmpty ? 'worker_job_detail_no_description'.tr : job.description,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: theme.canvasColor.withOpacity(0.85),
                                      fontSize: AppSize.width * 0.031,
                                      height: 1.4,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                SizedBox(height: AppSize.height * 0.012),
                                if (job.latitude != null && job.longitude != null) ...[
                                  SizedBox(height: AppSize.height * 0.012),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(AppSize.width * 0.028),
                                    decoration: BoxDecoration(
                                      color: theme.cardColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(AppSize.width * 0.012),
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.location_on_rounded, size: AppSize.width * 0.034, color: theme.primaryColor),
                                            ),
                                            SizedBox(width: AppSize.width * 0.02),
                                            Text(
                                              'post_job_location_label'.tr,
                                              style: TextStyle(
                                                fontFamily: "pb",
                                                fontSize: AppSize.width * 0.032,
                                                fontWeight: FontWeight.bold,
                                                color: theme.canvasColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: AppSize.height * 0.01),
                                        Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
                                        SizedBox(height: AppSize.height * 0.01),
                                        Text(
                                          job.location,
                                          style: TextStyle(
                                            fontFamily: "pb",
                                            fontSize: AppSize.width * 0.031,
                                            fontWeight: FontWeight.w600,
                                            color: theme.canvasColor,
                                          ),
                                        ),
                                        SizedBox(height: AppSize.height * 0.012),
                                        Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
                                        SizedBox(height: AppSize.height * 0.012),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: SizedBox(
                                            height: AppSize.height * 0.16,
                                            width: double.infinity,
                                            child: GoogleMap(
                                              initialCameraPosition: CameraPosition(
                                                target: LatLng(job.latitude!, job.longitude!),
                                                zoom: 15.2,
                                              ),
                                              markers: {
                                                Marker(
                                                  markerId: MarkerId('card_${job.id}'),
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
                                  ),
                                ],


                                /// ---------------- POSTED BY ----------------
                                _miniSection(
                                  theme: theme,
                                  accent: const Color(0xffEC4899),
                                  title: 'worker_job_detail_posted_by_title'.tr,
                                  icon: Icons.person_outline_rounded,
                                  child: Row(
                                    children: [
                                      Container(
                                        height: AppSize.width * 0.09,
                                        width: AppSize.width * 0.09,
                                        decoration: BoxDecoration(
                                          color: theme.primaryColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        alignment: Alignment.center,
                                        child: job.clientInfo.hasImage
                                            ? NetworkImageRetry(url: job.clientInfo.image!)
                                            : Icon(Icons.person_rounded, color: theme.primaryColor, size: AppSize.width * 0.045),
                                      ),
                                      SizedBox(width: AppSize.width * 0.025),
                                      Expanded(
                                        child: Text(
                                          job.clientInfo.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: "pb",
                                            color: theme.canvasColor,
                                            fontSize: AppSize.width * 0.032,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      _smallFilledPill(
                                        job.clientInfo.isOnline ? 'worker_job_detail_online_pill'.tr : 'worker_job_detail_offline_pill'.tr,
                                        job.clientInfo.isOnline ? const Color(0xff1DBF73) : Colors.grey,
                                        theme,
                                      ),
                                    ],
                                  ),
                                ),

                                if (job.postedAt.isNotEmpty) ...[
                                  SizedBox(height: AppSize.height * 0.012),
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_rounded, size: AppSize.width * 0.032, color: theme.canvasColor.withOpacity(0.4)),
                                      SizedBox(width: AppSize.width * 0.012),
                                      Text(
                                        job.postedAt,
                                        style: TextStyle(
                                          color: theme.canvasColor.withOpacity(0.45),
                                          fontSize: AppSize.width * 0.028,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: AppSize.height * 0.01),
                        Divider(color: theme.dividerColor.withOpacity(0.12), height: 1),
                        SizedBox(height: AppSize.height * 0.006),

                        /// BOTTOM ROW — status indicator (left) + See Detail (right).
                        /// ❌ Apply button NAHI hai — history card se dobara apply
                        /// nahi ho sakta.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: completed
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 15, color: Color(0xff10B981)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'job_state_completed'.tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: "pb",
                                        color: const Color(0xff10B981),
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSize.width * 0.029,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : cancelled
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cancel_rounded, size: 15, color: Color(0xffEF4444)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'job_state_cancelled'.tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: "pb",
                                        color: const Color(0xffEF4444),
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSize.width * 0.029,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : mySelected
                                  ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, size: 15, color: theme.primaryColor),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'worker_job_card_selected'.tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: "pb",
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSize.width * 0.029,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.hourglass_top_rounded, size: 14, color: Color(0xffF59E0B)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'worker_job_detail_waiting_confirmation'.tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: "pr",
                                        color: theme.canvasColor.withOpacity(0.6),
                                        fontSize: AppSize.width * 0.027,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            /// "See Detail" yahan poore card ko expand karta hai
                            /// (alag screen par navigate nahi karta).
                            TextButton(
                              onPressed: _toggleExpand,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSize.width * 0.02,
                                  vertical: AppSize.height * 0.006,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'worker_job_card_see_detail'.tr,
                                    style: TextStyle(
                                      fontFamily: "pb",
                                      fontSize: AppSize.width * 0.033,
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: AppSize.width * 0.01),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: AppSize.width * 0.035,
                                    color: theme.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
class _ExpandToggleButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;
  final ThemeData theme;
  const _ExpandToggleButton({required this.expanded, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: expanded ? 0.5 : 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: theme.primaryColor,
        size: AppSize.width * 0.065,
      ),
    );
  }
}

Widget _currencyBadge(ThemeData theme) {
  return Text(
    'post_job_currency_uzs'.tr,
    style: TextStyle(
      fontFamily: "pb",
      fontSize: AppSize.width * 0.028,
      color: theme.primaryColor,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget _miniSection({
  required ThemeData theme,
  required Color accent,
  required String title,
  IconData? icon,
  Widget? iconWidget,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(AppSize.width * 0.028),
    decoration: BoxDecoration(
      color: accent.withOpacity(0.04),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accent.withOpacity(0.12)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSize.width * 0.012),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: iconWidget ?? Icon(icon, size: AppSize.width * 0.034, color: accent),
            ),
            SizedBox(width: AppSize.width * 0.02),
            Text(
              title,
              style: TextStyle(
                fontFamily: "pb",
                fontSize: AppSize.width * 0.032,
                fontWeight: FontWeight.bold,
                color: theme.canvasColor.withOpacity(0.9),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.height * 0.008),
        child,
      ],
    ),
  );
}

Widget _miniRow(String label, String value, ThemeData theme, {bool isLast = false}) {
  return Padding(
    padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: AppSize.width * 0.28,
          child: Text(
            label,
            style: TextStyle(
              color: theme.canvasColor.withOpacity(0.55),
              fontSize: AppSize.width * 0.030,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            softWrap: true,
            style: TextStyle(
              color: theme.canvasColor,
              fontSize: AppSize.width * 0.031,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _smallFilledPill(String text, Color color, ThemeData theme) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSize.width * 0.02,
      vertical: AppSize.height * 0.003,
    ),
    decoration: BoxDecoration(
      color: color.withOpacity(0.14),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: "pb",
        fontSize: AppSize.width * 0.025,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helper_app2/Core/Widgets/AppColors.dart';
import '../../../../Core/Widgets/MediaqueryHelperfile.dart';
import '../clienthomesection/clientjobcontroller.dart';
import '../clienthomesection/clientjobdetailscreen.dart';
import '../clienthomesection/clientjobmodel.dart';


/// ------------------------------------------------------------
/// CLIENT JOB HISTORY CARD
/// Client ke "My Jobs" screen ke liye — ClientJobCard (home/explore
/// screen) ki bilkul hoobehoo UI/animation/functionality. Data model
/// same (JobPostModel) hone ki wajah se koi field missing nahi —
/// isliye is card mein sab kuch (bookmark, expand, see detail) waisa
/// hi kaam karta hai jaisa ClientJobCard mein karta hai.
/// ------------------------------------------------------------
class ClientJobHistoryCard extends StatefulWidget {
  final JobPostModel job;
  final VoidCallback? onTap;

  const ClientJobHistoryCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  State<ClientJobHistoryCard> createState() => _ClientJobHistoryCardState();
}

class _ClientJobHistoryCardState extends State<ClientJobHistoryCard> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _expandController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeAnimation;

  JobPostModel get job => widget.job;

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
      case 'pending': return 'job_state_pending'.tr;
      case 'ongoing': return 'job_state_ongoing'.tr;
      case 'completed': return 'job_state_completed'.tr;
      case 'cancelled': return 'job_state_cancelled'.tr;
      default: return stateText.replaceAll('_', ' ');
    }
  }

  String _getTranslatedText(String text) {
    final lower = text.toLowerCase().trim();
    if (lower.contains('cleaning')) return 'category_cleaning'.tr;
    if (lower.contains('delivery')) return 'category_delivery'.tr;
    if (lower.contains('handyman')) return 'category_handyman'.tr;
    if (lower.contains('moving')) return 'category_moving'.tr;
    if (lower.contains('pet care')) return 'category_pet_care'.tr;
    return text;
  }

  void _goToDetail() {
    Get.to(() => JobDetailScreen(jobId: job.id), transition: Transition.fade);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ClientJobsController>();

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
                              child: job.hasImages
                                  ? Image.network(
                                job.fullImageUrls.first,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Icon(Icons.person, color: theme.primaryColor, size: AppSize.width * 0.06);
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.person, color: theme.primaryColor, size: AppSize.width * 0.06),
                              )
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
                                        _getTranslatedText(job.title),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: AppSize.width * 0.036,
                                          fontWeight: FontWeight.bold,
                                          color: theme.canvasColor,
                                        ),
                                      ),
                                      if (job.isFlexible)
                                        _smallOutlinePill('job_card_flexible'.tr, theme.canvasColor.withOpacity(0.5), theme),
                                      _smallFilledPill(_getTranslatedState(job.state), job.stateColor, theme),
                                    ],
                                  ),
                                  SizedBox(height: AppSize.height * 0.003),
                                  Text(
                                    _getTranslatedText(job.category),
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
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                job.priceLabel,
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSize.width * 0.035,
                                ),
                              ),
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
                                  title: 'job_detail_overview'.tr,
                                  icon: Icons.assignment_outlined,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _miniRow('job_detail_category'.tr, _getTranslatedText(job.category), theme),
                                      if (job.subcategory != null)
                                        _miniRow('job_detail_subcategory'.tr, job.subcategory!, theme),
                                      _miniRow('job_detail_city'.tr, job.cityLabel, theme),
                                      _miniRow('job_detail_location'.tr, job.locationLabel, theme),
                                      _miniRow('job_detail_status'.tr, _getTranslatedState(job.state), theme, isLast: true),
                                    ],
                                  ),
                                ),
                                SizedBox(height: AppSize.height * 0.012),

                                /// ---------------- BUDGET & PAYMENT ----------------
                                _miniSection(
                                  theme: theme,
                                  accent: const Color(0xff10B981),
                                  title: 'job_detail_budget_payment'.tr,
                                  iconWidget: _currencyBadge(theme),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _miniRow('job_detail_budget_type'.tr, job.budgetTypeLabel, theme),
                                      _miniRow('job_detail_amount'.tr, job.budgetBreakdownLabel, theme),
                                      _miniRow('job_detail_payment_mode'.tr, job.paymentModeLabel, theme, isLast: true),
                                    ],
                                  ),
                                ),
                                SizedBox(height: AppSize.height * 0.012),

                                /// ---------------- SCHEDULE ----------------
                                _miniSection(
                                  theme: theme,
                                  accent: const Color(0xff8B5CF6),
                                  title: 'job_detail_schedule'.tr,
                                  icon: Icons.calendar_month_rounded,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _miniRow('job_detail_date'.tr, job.scheduleDateLabel, theme),
                                      _miniRow('job_detail_start_time'.tr, job.startTimeLabel, theme),
                                      _miniRow('job_detail_end_time'.tr, job.endTimeLabel, theme),
                                      _miniRow('job_detail_date_type'.tr, job.dateTypeLabel, theme, isLast: true),
                                    ],
                                  ),
                                ),
                                SizedBox(height: AppSize.height * 0.012),

                                /// ---------------- DESCRIPTION ----------------
                                _miniSection(
                                  theme: theme,
                                  accent: const Color(0xffF59E0B),
                                  title: 'job_detail_description'.tr,
                                  icon: Icons.notes_rounded,
                                  child: Text(
                                    job.description.isEmpty ? 'job_detail_no_description'.tr : job.description,
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

                                /// ---------------- ATTRIBUTES ----------------
                                _miniSection(
                                  theme: theme,
                                  accent: const Color(0xffEC4899),
                                  title: 'job_detail_attributes'.tr,
                                  icon: Icons.label_outline_rounded,
                                  child: Wrap(
                                    spacing: AppSize.width * 0.018,
                                    runSpacing: AppSize.height * 0.008,
                                    children: [
                                      _smallFilledPill(
                                        job.urgencyLabel.toUpperCase(),
                                        job.isUrgent ? const Color(0xffEF4444) : const Color(0xff10B981),
                                        theme,
                                      ),
                                      ...job.attributes
                                          .where((a) => a.text.toUpperCase() != job.urgency.toUpperCase())
                                          .map((attr) => attr.filled
                                          ? _smallFilledPill(_getTranslatedText(attr.text), attr.color, theme)
                                          : _smallOutlinePill(_getTranslatedText(attr.text), attr.color, theme)),
                                    ],
                                  ),
                                ),
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

                                if (job.postedAt.isNotEmpty) ...[
                                  SizedBox(height: AppSize.height * 0.012),
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_rounded, size: AppSize.width * 0.032, color: theme.canvasColor.withOpacity(0.4)),
                                      SizedBox(width: AppSize.width * 0.012),
                                      Text(
                                        'job_card_posted_prefix'.tr + job.postedAt,
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

                        /// SEE MORE DETAIL BUTTON
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: widget.onTap ?? _goToDetail,
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
                                  'job_card_see_detail'.tr,
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

Widget _smallOutlinePill(String text, Color color, ThemeData theme) {
  return Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSize.width * 0.02,
      vertical: AppSize.height * 0.003,
    ),
    decoration: BoxDecoration(
      border: Border.all(color: color.withOpacity(0.35)),
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
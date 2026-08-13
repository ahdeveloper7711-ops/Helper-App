import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Core/Widgets/AppLoader.dart';
import '../../../../Core/Widgets/Background.dart';
import '../../../../Core/Widgets/Backbutton.dart';
import '../../../../Core/Widgets/MediaqueryHelperfile.dart';
import 'clientjobcontroller.dart';
import 'clientjobmodel.dart';
import 'clientconfirmworkerscreen.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late final ClientJobsController controller;
  Timer? _presenceTimer;
  bool _presenceRefreshRunning = false;

  @override
  void initState() {
    super.initState();

    controller = Get.find<ClientJobsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final alreadyCached =
      controller.hasFetchedInterestedWorkers(widget.jobId);

      if (!alreadyCached) {
        AppLoader.show(
          text: 'job_detail_loading_applicants'.tr,
        );
      }

      await controller.fetchInterestedWorkers(
        widget.jobId,
        forceRefresh: true,
      );

      if (!alreadyCached) {
        AppLoader.hide();
      }

      _startPresenceRefresh();
    });
  }
  void _startPresenceRefresh() {
    _presenceTimer?.cancel();

    _presenceTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => _refreshWorkerPresence(),
    );
  }

  Future<void> _refreshWorkerPresence() async {
    if (_presenceRefreshRunning) return;

    _presenceRefreshRunning = true;

    try {
      await controller.fetchInterestedWorkers(
        widget.jobId,
        forceRefresh: true,
      );
    } finally {
      _presenceRefreshRunning = false;
    }
  }
  @override
  void dispose() {
    _presenceTimer?.cancel();
    super.dispose();
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
                              'job_detail_not_found'.tr,
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
      // ✅ Ab yahan print karo (job null nahi hai)
      print("===== LOCATION DEBUG =====");
      print("Location text: ${job.location}");
      print("Latitude: ${job.latitude}");
      print("Longitude: ${job.longitude}");
      print("Has coordinates: ${job.latitude != null && job.longitude != null}");

      final workers = controller.interestedWorkersFor(job.id);

      // NEW: agar job confirm ho chuki hai, tu sirf accepted worker
      // dikhayenge, or "Interested Worker" title/subtitle hide ho jayenge —
      // professional apps ki trah (baaki applicants ko screen se hata dena).
      final bool confirmed = controller.hasAcceptedWorker(job.id);
      final String? acceptedWorkerId =
          controller.acceptedWorkerIds[job.id] ?? job.selectedWorkerId?.toString();

      final displayWorkers = confirmed
          ? workers.where((w) => w.id == acceptedWorkerId).toList()
          : workers;

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
                    if (job.latitude != null && job.longitude != null) ...[
                      _LocationMapCard(job: job),
                      SizedBox(height: AppSize.heightPercent(0.02)),
                    ],

                    if (job.hasImages) ...[
                      /// ---------------- LOCATION (Address + Map) ----------------
                      if (job.hasCoordinates) ...[
                        SizedBox(height: AppSize.heightPercent(0.02)),
                      ],
                      _PhotosCard(job: job),
                      SizedBox(height: AppSize.heightPercent(0.02)),
                    ],

                    if (job.hasSelectedWorker) ...[
                      _AssignedWorkerBanner(job: job),
                      SizedBox(height: AppSize.heightPercent(0.02)),
                    ],

                    /// ---------------- OVERVIEW ----------------
                    _DetailCard(
                      icon: Icons.assignment_outlined,
                      title: 'job_detail_overview'.tr,
                      accent: const Color(0xff3B82F6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(icon: Icons.category_outlined, label: 'job_detail_category'.tr, value: job.category),
                          if (job.subcategory != null)
                            _DetailRow(icon: Icons.subdirectory_arrow_right_rounded, label: 'job_detail_subcategory'.tr, value: job.subcategory!),
                          _DetailRow(
                            icon: Icons.flag_outlined,
                            label: 'job_detail_status'.tr,
                            value: job.state.replaceAll('_', ' '),
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
                      title: 'job_detail_budget_payment'.tr,
                      accent: const Color(0xff10B981),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(icon: Icons.price_change_outlined, label: 'job_detail_budget_type'.tr, value: job.budgetTypeLabel),
                          _DetailRow(icon: Icons.receipt_long_outlined, label: 'job_detail_amount'.tr, value: job.budgetBreakdownLabel),
                          _DetailRow(
                            icon: job.paymentModeIcon,
                            label: 'job_detail_payment_mode'.tr,
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
                      title: 'job_detail_schedule'.tr,
                      accent: const Color(0xff8B5CF6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailRow(icon: Icons.event_rounded, label: 'job_detail_date'.tr, value: job.scheduleDateLabel),
                          _DetailRow(icon: Icons.access_time_rounded, label: 'job_detail_start_time'.tr, value: job.startTimeLabel),
                          _DetailRow(icon: Icons.access_time_filled_rounded, label: 'job_detail_end_time'.tr, value: job.endTimeLabel),
                          _DetailRow(
                            icon: Icons.today_rounded,
                            label: 'job_detail_date_type'.tr,
                            value: job.dateTypeLabel,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(0.02)),

                    /// ---------------- DESCRIPTION ----------------
                    _DetailCard(
                      icon: Icons.notes_rounded,
                      title: 'job_detail_description'.tr,
                      accent: const Color(0xffF59E0B),
                      child: Text(
                        job.description.isEmpty ? 'job_detail_no_description'.tr : job.description,
                        style: TextStyle(
                          fontFamily: "pr",
                          fontSize: AppSize.textPercent(0.036),
                          height: 1.55,
                          color: theme.canvasColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(0.02)),

                    /// ---------------- ATTRIBUTES ----------------
                    _DetailCard(
                      icon: Icons.label_outline_rounded,
                      title: 'job_detail_attributes'.tr,
                      accent: const Color(0xffEC4899),
                      child: Wrap(
                        spacing: AppSize.widthPercent(0.02),
                        runSpacing: AppSize.heightPercent(0.01),
                        children: [
                          _pill(job.urgencyLabel.toUpperCase(),
                              job.isUrgent ? const Color(0xffEF4444) : const Color(0xff10B981), true, theme),
                          ...job.attributes
                              .where((a) => a.text.toUpperCase() != job.urgency.toUpperCase())
                              .map((attr) => _pill(attr.text, attr.color, attr.filled, theme)),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSize.heightPercent(0.03)),

                    /// ------------------------------------------------
                    /// INTERESTED WORKER SECTION — live API data
                    /// NEW: agar worker confirm ho chuka hai (job accepted),
                    /// tu title/subtitle + refresh icon hide ho jate hain,
                    /// aur sirf accepted worker ka card show hota hai.
                    /// ------------------------------------------------
                    if (!confirmed) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(AppSize.widthPercent(0.018)),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.groups_2_rounded,
                                    color: theme.primaryColor, size: AppSize.textPercent(0.04)),
                              ),
                              SizedBox(width: AppSize.widthPercent(0.025)),
                              Text(
                                'job_detail_interested_worker'.tr,
                                style: TextStyle(
                                  fontFamily: "pb",
                                  fontSize: AppSize.textPercent(0.046),
                                  fontWeight: FontWeight.bold,
                                  color: theme.canvasColor,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () async {
                              AppLoader.show(text: 'job_detail_refreshing'.tr);
                              await controller.fetchInterestedWorkers(job.id, forceRefresh: true);
                              AppLoader.hide();
                            },
                            child: Container(
                              padding: EdgeInsets.all(AppSize.widthPercent(0.02)),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.refresh_rounded, color: theme.primaryColor, size: AppSize.textPercent(0.048)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSize.heightPercent(0.008)),
                      Padding(
                        padding: EdgeInsets.only(left: AppSize.widthPercent(0.001)),
                        child: Text(
                          workers.isEmpty
                              ? 'job_detail_no_applicants_yet'.tr
                              : 'job_detail_worker_applied'.trParams({'count': workers.length.toString()}),
                          style: TextStyle(
                            fontFamily: "pr",
                            fontSize: AppSize.textPercent(0.034),
                            color: theme.canvasColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSize.heightPercent(0.02)),
                    ],

                    if (displayWorkers.isEmpty)
                      _EmptyApplicantsState(theme: theme)
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayWorkers.length,
                        itemBuilder: (context, index) {
                          return _WorkerApplicantCard(job: job, worker: displayWorkers[index]);
                        },
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

  static Widget _pill(String text, Color color, bool filled, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.028), vertical: AppSize.heightPercent(0.008)),
      decoration: BoxDecoration(
        color: filled ? color.withOpacity(0.15) : null,
        border: filled ? null : Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "pb",
          fontSize: AppSize.textPercent(0.03),
          fontWeight: FontWeight.bold,
          color: color,
        ),
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
/// ------------------------------------------------------------
class _JobHeroHeader extends StatelessWidget {
  final JobPostModel job;
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
          SizedBox(height: AppSize.heightPercent(0.02)),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          SizedBox(height: AppSize.heightPercent(0.016)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('job_detail_budget_type'.tr,
                      style: const TextStyle(fontFamily: "pr", fontSize: 11, color: Colors.white60)),
                  const SizedBox(height: 2),
                  Text(
                    job.priceLabel,
                    style: const TextStyle(
                      fontFamily: "pb",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (job.isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: Color(0xffEF4444), size: 14),
                      const SizedBox(width: 3),
                      Text(
                        job.urgencyLabel.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: "pb",
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffEF4444),
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
/// ASSIGNED WORKER BANNER — jab selected_worker_id already set ho
/// ------------------------------------------------------------
class _AssignedWorkerBanner extends StatelessWidget {
  final JobPostModel job;
  const _AssignedWorkerBanner({required this.job});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.widthPercent(0.04),
        vertical: AppSize.heightPercent(0.018),
      ),
      decoration: BoxDecoration(
        color: const Color(0xff06B6D4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff06B6D4).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.widthPercent(0.02)),
            decoration: BoxDecoration(
              color: const Color(0xff06B6D4).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: Color(0xff06B6D4)),
          ),
          SizedBox(width: AppSize.widthPercent(0.03)),
          Expanded(
            child: Text(
              'job_detail_assigned_banner'.tr,
              style: TextStyle(
                fontFamily: "pb",
                fontSize: AppSize.textPercent(0.033),
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
/// PHOTOS CARD — job post karte waqt attach ki gayi images dikhata hai
/// (multiple images — jitni bhi client ne add ki hongi sab dikhengi)
/// ------------------------------------------------------------
class _PhotosCard extends StatelessWidget {
  final JobPostModel job;
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
                'job_detail_photos'.tr,
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: AppSize.textPercent(0.04),
                  fontWeight: FontWeight.bold,
                  color: theme.canvasColor,
                ),
              ),
              const Spacer(),
              Text(
                urls.length > 1
                    ? 'job_detail_photo_count_plural'.trParams({'count': urls.length.toString()})
                    : 'job_detail_photo_count_single'.trParams({'count': urls.length.toString()}),
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
                    child: Image.network(
                      url,
                      width: AppSize.widthPercent(0.28),
                      height: AppSize.widthPercent(0.28),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          width: AppSize.widthPercent(0.28),
                          height: AppSize.widthPercent(0.28),
                          color: theme.dividerColor.withOpacity(0.1),
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: AppSize.widthPercent(0.06),
                            height: AppSize.widthPercent(0.06),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.primaryColor,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: AppSize.widthPercent(0.28),
                          height: AppSize.widthPercent(0.28),
                          color: theme.dividerColor.withOpacity(0.1),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: theme.canvasColor.withOpacity(0.3),
                            size: AppSize.textPercent(0.06),
                          ),
                        );
                      },
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
/// WORKER APPLICANT CARD — "client/jobs/interested-workers" data
/// NEW: worker ke naam ke neeche ab ONLINE/OFFLINE status pill bhi
/// dikhta hai — worker.isOnline (assumed bool field, API se "is_online"
/// ki tarah aata hai, jaisa profile/home screens mein use hota hai).
/// ------------------------------------------------------------
class _WorkerApplicantCard extends StatelessWidget {
  final JobPostModel job;
  final WorkerApplicant worker;
  const _WorkerApplicantCard({required this.job, required this.worker});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.heightPercent(0.016)),
      padding: EdgeInsets.all(AppSize.widthPercent(0.035)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WorkerAvatar(worker: worker, theme: theme, size: AppSize.width * 0.13),
          SizedBox(width: AppSize.widthPercent(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        worker.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: "pb",
                          fontSize: AppSize.textPercent(0.038),
                          fontWeight: FontWeight.bold,
                          color: theme.canvasColor,
                        ),
                      ),
                    ),
                    // NEW: ONLINE / OFFLINE indicator for the worker
                    _OnlineStatusPill(isOnline: worker.isOnline),
                  ],
                ),
                SizedBox(height: AppSize.heightPercent(0.006)),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      worker.ratingLabel,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: AppSize.textPercent(0.031),
                        color: theme.canvasColor,
                      ),
                    ),
                    if (worker.hasStrikes) ...[
                      SizedBox(width: AppSize.widthPercent(0.025)),
                      Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange.shade700),
                      const SizedBox(width: 3),
                      Text(
                        worker.activeStrikes > 1
                            ? 'job_detail_strike_plural'.trParams({'count': worker.activeStrikes.toString()})
                            : 'job_detail_strike_single'.trParams({'count': worker.activeStrikes.toString()}),
                        style: TextStyle(
                          fontFamily: "pr",
                          fontSize: AppSize.textPercent(0.028),
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
                if (worker.skills.isNotEmpty) ...[
                  SizedBox(height: AppSize.heightPercent(0.008)),
                  Wrap(
                    spacing: AppSize.widthPercent(0.014),
                    runSpacing: AppSize.heightPercent(0.006),
                    children: worker.skills
                        .take(3)
                        .map((s) => _skillChip(s, theme))
                        .toList(),
                  ),
                ],
                SizedBox(height: AppSize.heightPercent(0.01)),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Get.to(() => ClientConfirmWorkerScreen(job: job, worker: worker)),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.widthPercent(0.03),
                        vertical: AppSize.heightPercent(0.008),
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'job_detail_see_detail'.tr,
                            style: TextStyle(
                              fontFamily: "pb",
                              fontSize: AppSize.textPercent(0.028),
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          SizedBox(width: AppSize.widthPercent(0.01)),
                          Icon(Icons.arrow_forward_rounded, size: AppSize.textPercent(0.03), color: theme.primaryColor),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _skillChip(String text, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.02), vertical: AppSize.heightPercent(0.003)),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "pr",
          fontSize: AppSize.textPercent(0.026),
          color: theme.primaryColor,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// SMALL REUSABLE ONLINE/OFFLINE PILL — same style used on the
/// worker-side job detail screen, for consistency across the app.
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
            isOnline ? 'job_detail_online'.tr : 'job_detail_offline'.tr,
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
/// WORKER AVATAR — network image with initials fallback
/// ------------------------------------------------------------
class _WorkerAvatar extends StatelessWidget {
  final WorkerApplicant worker;
  final ThemeData theme;
  final double size;

  const _WorkerAvatar({required this.worker, required this.theme, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: worker.hasProfilePic
          ? Image.network(
        worker.profilePic,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _personIcon(),
        loadingBuilder: (context, child, progress) => progress == null ? child : _personIcon(),
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

/// ------------------------------------------------------------
/// EMPTY APPLICANTS STATE
/// ------------------------------------------------------------
class _EmptyApplicantsState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyApplicantsState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSize.heightPercent(0.04)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.widthPercent(0.04)),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.people_outline_rounded, size: AppSize.textPercent(0.08), color: theme.primaryColor.withOpacity(0.5)),
          ),
          SizedBox(height: AppSize.heightPercent(0.016)),
          Text(
            'job_detail_no_workers_applied'.tr,
            style: TextStyle(
              fontFamily: "pr",
              fontSize: AppSize.textPercent(0.034),
              color: theme.canvasColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
/// ------------------------------------------------------------
/// LOCATION MAP CARD — Address + non-interactive map (same as Summary)
/// ------------------------------------------------------------
class _LocationMapCard extends StatelessWidget {
  final JobPostModel job;
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
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.widthPercent(0.02)),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: theme.primaryColor,
                  size: AppSize.textPercent(0.042),
                ),
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
                  job.locationLabel,
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
          Divider(color: theme.dividerColor.withOpacity(0.15), height: 1),
          SizedBox(height: AppSize.heightPercent(0.018)),

          // Non-interactive Map
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
                    markerId: MarkerId('job_${job.id}'),
                    position: LatLng(job.latitude!, job.longitude!),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure,
                    ),
                  ),
                },
                // Completely non-interactive
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
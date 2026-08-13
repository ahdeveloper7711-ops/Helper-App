import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Widgets/AppLoader.dart';
import '../../../../Core/Apis/onlinestatuscontroller.dart';
import '../../../../Core/AppTheme/themecontroller.dart';
import '../../../../Core/Widgets/iconcircle.dart';
import '../../../../Core/Widgets/profileavator.dart';
import '../../../SharedScreen/Notificationsection/NotificationScreen.dart';
import '../../../ClientsSide/ClientBottomNavigation/clientProfilesection/clientProfilescreensection/clientProfilecontroller.dart';
import '../../../SharedScreen/Notificationsection/notificationcontroller.dart';
import 'workerhomecontroller.dart';
import 'workerjobcard.dart'; // NEW: shared job card widget
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Workerhomescreen extends StatefulWidget {
  final VoidCallback? onNavigateToActiveJobs; // NEW: parent (bottom nav) se aayega

  const Workerhomescreen({super.key, this.onNavigateToActiveJobs});

  @override
  State<Workerhomescreen> createState() => _WorkerhomescreenState();
}

class _WorkerhomescreenState extends State<Workerhomescreen> {
  late final WorkerHomeController controller;

  // Local, self-contained loader flag — GetX dialog stack se bilkul
  // independent, isliye Get.offAll() ke baad kabhi stuck nahi hota.
  bool _showLoader = false;

  void _setLoader(bool value) {
    if (!mounted) return;
    setState(() => _showLoader = value);
  }

  @override
  void initState() {
    super.initState();

    // Safety net: agar purani screen ka GetX dialog kahin reh gaya ho
    // to usay bhi band kar do (ab is screen ka apna loader us par depend nahi karta)
    AppLoader.forceClose();

    controller = Get.put(WorkerHomeController());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!controller.hasCity) return;

      _setLoader(true);
      try {
        // Controller ka apna initialization already onInit mein chal raha hai,
        // hum uski asal completion ka wait karain — fixed delay ki jagah.
        await controller.ready;
      } catch (e) {
        debugPrint("⚠️ Worker screen init error: $e");
      } finally {
        _setLoader(false);
      }
    });
  }

  Future<void> _handleSetCity(String city) async {
    _setLoader(true);
    try {
      await controller.setCity(city);
    } catch (e) {
      debugPrint("⚠️ [Workerhomescreen] setCity error: $e");
    } finally {
      _setLoader(false);
    }
  }

  Future<void> _handleRefresh() async {
    _setLoader(true);
    try {
      await controller.fetchJobsForCity();
      await controller.fetchWorkerStats();
    } catch (e) {
      debugPrint("⚠️ [Workerhomescreen] refresh error: $e");
    } finally {
      _setLoader(false);
    }
  }

  // NEW: job cards wala sliver ab ek alag method mein — Obx sirf
  // is single widget ko wrap karta hai, isi se GetX ka error fix hota hai.
  Widget _buildJobsSliver(double hPad) {
    if (!controller.hasCity) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final jobs = controller.jobs;
    final myWorkerId = controller.workerId.value;

    if (jobs.isEmpty) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        sliver: SliverToBoxAdapter(
          child: _EmptyJobsState(
            city: controller.selectedCity.value ?? '',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) =>
              WorkerJobCard(job: jobs[index], myWorkerId: myWorkerId),
          childCount: jobs.length,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hPad = AppSize.width * 0.05;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: AppSize.height * 0.13), // upar/neeche adjust karne ke liye
        child: FloatingActionButton(
          backgroundColor: theme.primaryColor,
          shape: const CircleBorder(),
          onPressed: widget.onNavigateToActiveJobs,
          child: Icon(Icons.work_history, color: theme.cardColor),
        ),
      ),
      body: AppBackground(
        child: Stack(
          children: [
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppSize.height * 0.01),
                          _WorkerHomeHeader(),
                          SizedBox(height: AppSize.height * 0.02),
                          const _WorkerHomeStatsRow(),
                          SizedBox(height: AppSize.height * 0.03),
                          Obx(() {
                            if (!controller.hasCity) {
                              return _AddCitySection(onSubmitCity: _handleSetCity);
                            }
                            return _JobsSectionHeader(
                              controller: controller,
                              onRefresh: _handleRefresh,
                            );
                          }),
                          SizedBox(height: AppSize.height * 0.02),
                        ],
                      ),
                    ),
                  ),

                  Obx(() => _buildJobsSliver(hPad)),

                  SliverToBoxAdapter(child: SizedBox(height: AppSize.height * 0.03)),
                ],
              ),
            ),

            // Local loader overlay — koi Get.dialog/Navigator involved nahi
            if (_showLoader)
              Positioned.fill(
                child: Container(
                  color: Colors.black12,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
/// ======================================================================
/// CATEGORY JOBS SCREEN (kam items, ListView.builder use hoga)
/// ======================================================================

class Workercatogoryjobs extends StatelessWidget {
  final String category;

  const Workercatogoryjobs({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<WorkerHomeController>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.5,
        iconTheme: IconThemeData(color: theme.canvasColor),
        title: Text(
          category,
          style: TextStyle(
            color: theme.canvasColor,
            fontWeight: FontWeight.bold,
            fontSize: AppSize.width * 0.045,
          ),
        ),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Obx(() {
            final jobs = controller.jobsForCategory(category);
            final myWorkerId = controller.workerId.value;

            if (jobs.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: AppSize.height * 0.1),
                child: Center(
                  child: Text(
                    'worker_home_no_jobs_in_category'.trParams({'category': category}),
                    style: TextStyle(color: theme.canvasColor.withOpacity(0.6)),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.width * 0.05,
                vertical: AppSize.height * 0.02,
              ),
              itemCount: jobs.length,
              itemBuilder: (context, index) =>
                  WorkerJobCard(job: jobs[index], myWorkerId: myWorkerId),
            );
          }),
        ),
      ),
    );
  }
}

/// ======================================================================
/// ADD CITY SECTION (unchanged)
/// ======================================================================

class _AddCitySection extends StatefulWidget {
  final Future<void> Function(String city) onSubmitCity;

  const _AddCitySection({required this.onSubmitCity});

  @override
  State<_AddCitySection> createState() => _AddCitySectionState();
}

class _AddCitySectionState extends State<_AddCitySection> {
  final TextEditingController _cityController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<PlacePrediction> _predictions = [];
  OverlayEntry? _overlayEntry;
  Timer? _debounce;
  bool _isLoading = false;

  // Apni Google API key (jo Post Job mein use ho rahi hai)
  static const String _apiKey = "AIzaSyDAv6imR4b4bd_5SidA09rzU54sG8sBk6k";

  @override
  void initState() {
    super.initState();
    _cityController.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _removeOverlay();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _cityController.removeListener(_onTextChanged);
    _cityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    final query = _cityController.text.trim();
    if (query.length < 2) {
      _predictions = [];
      _removeOverlay();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchPredictions(query);
    });
  }

  Future<void> _fetchPredictions(String input) async {
    setState(() => _isLoading = true);
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=${Uri.encodeComponent(input)}'
            '&types=(cities)'
            '&key=$_apiKey',
      );

      print("🔍 Places URL: $url");

      final res = await http.get(url);
      print("🔍 Places Status: ${res.statusCode}");
      print("🔍 Places Body: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final status = data['status']?.toString();
        print("🔍 Places API status: $status");

        final list = (data['predictions'] as List?) ?? [];
        _predictions = list
            .map((e) => PlacePrediction(
          description: e['description']?.toString() ?? '',
          placeId: e['place_id']?.toString() ?? '',
        ))
            .where((p) => p.description.isNotEmpty)
            .toList();

        print("🔍 Predictions count: ${_predictions.length}");
        _showOverlay();
      }
    } catch (e) {
      print("❌ Places error: $e");
      _predictions = [];
      _removeOverlay();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  void _showOverlay() {
    _removeOverlay();
    if (_predictions.isEmpty || !_focusNode.hasFocus) return;

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        return Positioned(
          width: MediaQuery.of(context).size.width - (AppSize.width * 0.10),
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, AppSize.height * 0.07),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(14),
              color: theme.cardColor,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: AppSize.height * 0.28),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: _predictions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: theme.dividerColor.withOpacity(0.15),
                  ),
                  itemBuilder: (context, index) {
                    final p = _predictions[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.location_city_rounded,
                          color: theme.primaryColor, size: 20),
                      title: Text(
                        p.description,
                        style: TextStyle(
                          fontFamily: "pr",
                          fontSize: AppSize.width * 0.033,
                          color: theme.canvasColor,
                        ),
                      ),
                      onTap: () => _selectCity(p.description),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectCity(String cityName) {
    // Sirf city name nikaal lo (pehle comma se pehle)
    final clean = cityName.split(',').first.trim();
    _cityController.text = clean;
    _cityController.selection = TextSelection.fromPosition(
      TextPosition(offset: _cityController.text.length),
    );
    _predictions = [];
    _removeOverlay();
    _focusNode.unfocus();
  }

  Future<void> _submit() async {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      Get.snackbar(
        'worker_home_city_required_title'.tr,
        'worker_home_city_required_message'.tr,
        backgroundColor: Colors.grey,
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(
          vertical: AppSize.height * 0.01,
          horizontal: AppSize.height * 0.01,
        ),
      );
      return;
    }
    await widget.onSubmitCity(city);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.width * 0.05),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_city_rounded,
            color: theme.primaryColor,
            size: AppSize.width * 0.09,
          ),
          SizedBox(height: AppSize.height * 0.015),
          Text(
            'worker_home_add_city_title'.tr,
            style: TextStyle(
              fontSize: AppSize.width * 0.045,
              fontWeight: FontWeight.bold,
              color: theme.canvasColor,
            ),
          ),
          SizedBox(height: AppSize.height * 0.006),
          Text(
            'worker_home_add_city_subtitle'.tr,
            style: TextStyle(
              fontSize: AppSize.width * 0.032,
              color: theme.canvasColor.withOpacity(0.5),
            ),
          ),
          SizedBox(height: AppSize.height * 0.02),

          /// Autocomplete field
          CompositedTransformTarget(
            link: _layerLink,
            child: TextField(
              controller: _cityController,
              focusNode: _focusNode,
              style: TextStyle(color: theme.canvasColor),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: 'worker_home_city_hint'.tr,
                hintStyle: TextStyle(color: theme.canvasColor.withOpacity(0.4)),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.canvasColor.withOpacity(0.4),
                ),
                suffixIcon: _isLoading
                    ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primaryColor,
                    ),
                  ),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(height: AppSize.height * 0.018),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                height: AppSize.height * 0.06,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'worker_home_find_jobs_button'.tr,
                  style: TextStyle(
                    color: theme.cardColor,
                    fontWeight: FontWeight.bold,
                    fontSize: AppSize.width * 0.036,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple model for predictions
class PlacePrediction {
  final String description;
  final String placeId;
  PlacePrediction({required this.description, required this.placeId});
}
/// ======================================================================
/// JOBS SECTION HEADER
/// ======================================================================

class _JobsSectionHeader extends StatelessWidget {
  final WorkerHomeController controller;
  final Future<void> Function() onRefresh;

  const _JobsSectionHeader({required this.controller, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(
          () => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'worker_home_jobs_in_city'.trParams({'city': '${controller.selectedCity.value}'}),
                  style: TextStyle(
                    fontSize: AppSize.width * 0.05,
                    fontWeight: FontWeight.bold,
                    color: theme.canvasColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'worker_home_swipe_subtitle'.tr,
                  style: TextStyle(
                    fontSize: AppSize.width * 0.03,
                    color: theme.canvasColor.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRefresh,
            child: IconCircle(
              icon: Icons.refresh_rounded,
              height: AppSize.height * 0.045,
              width: AppSize.height * 0.045,
              iconColor: theme.canvasColor,
            ),
          ),
          SizedBox(width: AppSize.width * 0.02),
          GestureDetector(
            onTap: () => controller.changeCity(),
            child: IconCircle(
              icon: Icons.edit_location_alt_outlined,
              height: AppSize.height * 0.045,
              width: AppSize.height * 0.045,
              iconColor: theme.canvasColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyJobsState extends StatelessWidget {
  final String city;

  const _EmptyJobsState({required this.city});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.06),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: AppSize.width * 0.12,
            color: theme.canvasColor.withOpacity(0.3),
          ),
          SizedBox(height: AppSize.height * 0.015),
          Text(
            'worker_home_no_jobs_in_city'.trParams({'city': city}),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.canvasColor.withOpacity(0.5),
              fontSize: AppSize.width * 0.034,
            ),
          ),
        ],
      ),
    );
  }
}

/// ======================================================================
/// HOME HEADER — ONLINE/OFFLINE ab SHARED OnlineStatusController se aata
/// hai (Client side ke sath bhi same controller, Worker Profile screen
/// ke sath sync mein). Ye StatelessWidget hai kyunke local state ki
/// zaroorat khatam ho gayi hai — sara status GetX Rx se aata hai.
/// ======================================================================

class _WorkerHomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThemeController themeController = Get.find();

    final ProfileController controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    final OnlineStatusController onlineStatusController =
    Get.isRegistered<OnlineStatusController>()
        ? Get.find<OnlineStatusController>()
        : Get.put(OnlineStatusController(), permanent: true);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(
              () => Row(
            children: [
              Stack(
                children: [
                  ProfileAvatar(radius: AppSize.width * 0.05),
                  if (controller.isLoading.value)
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: AppSize.width * 0.045,
                          backgroundColor: Colors.black.withOpacity(0.25),
                          child: const SizedBox(
                            height: 14,
                            width: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppSize.width * 0.02),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'worker_home_welcome'.tr,
                    style: TextStyle(
                      fontSize: AppSize.width * 0.032,
                      color: theme.canvasColor.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    controller.displayUsername,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppSize.width * 0.038,
                      fontWeight: FontWeight.bold,
                      color: theme.canvasColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            Obx(() {
              final isOnline = onlineStatusController.isOnline.value;
              final isUpdating = onlineStatusController.isUpdating.value;
              return GestureDetector(
                onTap: onlineStatusController.toggleOnlineStatus,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isOnline ? theme.primaryColor : theme.canvasColor)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      if (isUpdating)
                        SizedBox(
                          height: 9,
                          width: 9,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: isOnline ? theme.primaryColor : theme.canvasColor.withOpacity(0.5),
                          ),
                        )
                      else
                        Icon(
                          Icons.circle,
                          size: 9,
                          color: isOnline ? theme.primaryColor : theme.canvasColor.withOpacity(0.5),
                        ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'worker_home_online'.tr : 'worker_home_offline'.tr,
                        style: TextStyle(
                          color: isOnline ? theme.primaryColor : theme.canvasColor.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            SizedBox(width: AppSize.width * 0.01),
            GestureDetector(
              onTap: () => themeController.toggleTheme(),
              child: IconCircle(
                icon: Get.isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                height: AppSize.height * 0.045,
                width: AppSize.height * 0.045,
                iconSize: AppSize.height * 0.025,
              ),
            ),
            SizedBox(width: AppSize.width * 0.01),
            Obx(() {
              // Shared global controller instance
              final notifController = Get.isRegistered<NotificationController>()
                  ? Get.find<NotificationController>()
                  : Get.put(NotificationController(), permanent: true);

              final unreadCount = notifController.unreadCount;

              return GestureDetector(
                onTap: () async {
                  // Notification screen se wapas aane par notifications refresh honge
                  await Get.to(
                        () => const NotificationScreen(),
                    transition: Transition.fade,
                    duration: const Duration(milliseconds: 500),
                  );
                  notifController.fetchNotifications(isRefresh: true);
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconCircle(
                      icon: Icons.notifications,
                      height: AppSize.height * 0.05,
                      width: AppSize.height * 0.05,
                      iconColor: theme.canvasColor,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            })         ],
        ),
      ],
    );
  }
}

/// ======================================================================
/// HOME STATS ROW
/// ======================================================================

class _WorkerHomeStatsRow extends StatelessWidget {
  const _WorkerHomeStatsRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<WorkerHomeController>();

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(AppSize.width * 0.04),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'worker_home_earnings_label'.tr,
                  style: TextStyle(
                    color: theme.cardColor.withOpacity(0.75),
                    fontSize: AppSize.width * 0.03,
                  ),
                ),
                SizedBox(height: AppSize.height * 0.005),
                Obx(
                      () => controller.isStatsLoading.value
                      ? SizedBox(
                    height: AppSize.width * 0.05,
                    width: AppSize.width * 0.05,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.cardColor,
                    ),
                  )
                      : Obx(() => Text(
                        controller.earningsLabel.value,
                        style: TextStyle(
                          color: theme.cardColor,
                          fontSize: AppSize.width * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: AppSize.width * 0.03),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(AppSize.width * 0.04),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(
                  'worker_home_active_label'.tr,
                  style: TextStyle(
                    color: theme.canvasColor.withOpacity(0.5),
                    fontSize: AppSize.width * 0.03,
                  ),
                ),
                SizedBox(height: AppSize.height * 0.005),
                Obx(
                      () => controller.isStatsLoading.value
                      ? SizedBox(
                    height: AppSize.width * 0.05,
                    width: AppSize.width * 0.05,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.canvasColor,
                    ),
                  )
                      : Text(
                    controller.activeJobsCount.value.toString(),
                    style: TextStyle(
                      color: theme.canvasColor,
                      fontSize: AppSize.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/clintpostjobsection/taskjobcatogory.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../Core/Widgets/Background.dart';
import '../../../../Core/Widgets/ImagePickerBottomsheet.dart';
import '../../../../Core/Widgets/MediaqueryHelperfile.dart';
import 'postjobcontroller.dart';

class Clientpostjobscreen extends StatefulWidget {
  final VoidCallback? onBack;

  const Clientpostjobscreen({super.key,this.onBack});

  @override
  State<Clientpostjobscreen> createState() => _ClientpostjobscreenState();
}
class _ClientpostjobscreenState extends State<Clientpostjobscreen> {
  final PostJobController controller = Get.put(PostJobController(), permanent: true);
  @override
  void initState() {
    super.initState();
    // Agar Android ne camera capture ke doran process kill kar diya tha,
    // to app dobara open hote hi pending image yahan se retrieve hogi.
    WidgetsBinding.instance.addPostFrameCallback((_) => _retrieveLostImageIfAny());
  }
  Future<void> _retrieveLostImageIfAny() async {
    try {
      final LostDataResponse response = await ImagePicker().retrieveLostData();

      if (response.isEmpty) return; // koi pending/lost image nahi thi

      if (response.file != null) {
        debugPrint("✅ Lost image recovered after process kill: ${response.file!.path}");
        controller.addPhoto(File(response.file!.path));
      } else if (response.exception != null) {
        debugPrint("❌ Lost data retrieval error: ${response.exception}");
      }
    } catch (e) {
      debugPrint("❌ retrieveLostData failed: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.05)),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSize.heightPercent(0.02)),
                  const _PostJobHeader(),
                  SizedBox(height: AppSize.heightPercent(0.03)),

                  _TaskTitleField(controller: controller.taskTitleController),
                  SizedBox(height: AppSize.heightPercent(0.025)),

                  const _CategorySelectorRow(),
                  SizedBox(height: AppSize.heightPercent(0.025)),

                  _LocationField(controller: controller.locationController),
                  SizedBox(height: AppSize.heightPercent(0.025)),

                  _DescriptionField(controller: controller.descriptionController),
                  SizedBox(height: AppSize.heightPercent(0.025)),

                  const _BudgetContainer(),
                  SizedBox(height: AppSize.heightPercent(0.025)),

                  const _ScheduleContainer(),
                  SizedBox(height: AppSize.heightPercent(0.025)),

                  const _PhotoAttachmentContainer(),
                  SizedBox(height: AppSize.heightPercent(0.03)),

                  const _ActionButtonsRow(),
                  SizedBox(height: AppSize.heightPercent(0.03)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// HEADER — with soft icon badge for a premium touch
/// ------------------------------------------------------------
class _PostJobHeader extends StatelessWidget {
  const _PostJobHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        SizedBox(width: AppSize.width * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: "pb",
                    fontSize: AppSize.textPercent(0.06),
                    fontWeight: FontWeight.bold,
                    color: theme.canvasColor,
                  ),
                  children: [
                    TextSpan(text: 'post_job_title_post_a'.tr),
                    TextSpan(
                      text: 'post_job_title_task'.tr,
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSize.heightPercent(0.005)),
              Text(
                'post_job_subtitle'.tr,
                style: TextStyle(
                  fontFamily: "pr",
                  fontSize: AppSize.textPercent(0.03),
                  color: theme.canvasColor.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(AppSize.widthPercent(0.028)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(Icons.post_add_rounded, color: Colors.white, size: AppSize.textPercent(0.055)),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// REUSABLE SECTION LABEL — with small accent dot
/// ------------------------------------------------------------
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
        ),
        Text(
          text.toUpperCase(),
          style: TextStyle(
            fontFamily: "pb",
            fontSize: AppSize.textPercent(0.032),
            fontWeight: FontWeight.w600,
            color: theme.canvasColor.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// SHARED SOFT-CARD DECORATION (shadow + rounded + border)
/// ------------------------------------------------------------
BoxDecoration _softFieldDecoration(ThemeData theme, {bool highlighted = false}) {
  return BoxDecoration(
    color: theme.cardColor,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: highlighted ? theme.primaryColor.withOpacity(0.6) : theme.dividerColor.withOpacity(0.18),
      width: highlighted ? 1.3 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

/// ------------------------------------------------------------
/// TASK TITLE FIELD
/// ------------------------------------------------------------
class _TaskTitleField extends StatelessWidget {
  final TextEditingController controller;
  const _TaskTitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('post_job_task_title_label'.tr),
        SizedBox(height: AppSize.heightPercent(0.01)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.04)),
          decoration: _softFieldDecoration(theme),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontFamily: "pr",
              fontSize: AppSize.textPercent(0.037),
              color: theme.canvasColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'post_job_task_title_hint'.tr,
              hintStyle: TextStyle(
                fontFamily: "pr",
                fontSize: AppSize.textPercent(0.037),
                color: theme.canvasColor.withOpacity(0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// CATEGORY / SUB-CATEGORY ROW
/// ------------------------------------------------------------
class _CategorySelectorRow extends StatelessWidget {
  const _CategorySelectorRow();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// CATEGORY
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('post_job_category_label'.tr),
              SizedBox(height: AppSize.heightPercent(0.01)),
              GestureDetector(
                onTap: () {
                  _CategorySelectSheet.show(
                    onCategorySelected: (category) {
                      controller.setCategory(category.name, category.icon);
                      controller.selectedSubCategory.value = null;
                    },
                  );
                },
                child: Obx(
                      () => _SelectorBox(
                    label: controller.selectedCategory.value ?? 'post_job_select_category_default'.tr,
                    icon: controller.selectedCategoryIcon.value,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSize.widthPercent(0.03)),

        /// SUB-CATEGORY
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('post_job_subcategory_label'.tr),
              SizedBox(height: AppSize.heightPercent(0.01)),
              GestureDetector(
                onTap: () {
                  _SubCategorySelectSheet.show(
                    onSubCategorySelected: (sub) {
                      controller.setSubCategory(sub);
                    },
                  );
                },
                child: Obx(
                      () => _SelectorBox(
                    label: controller.selectedSubCategory.value ?? 'post_job_select_subcategory_default'.tr,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SelectorBox extends StatelessWidget {
  final String label;
  final IconData? icon;
  const _SelectorBox({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.widthPercent(0.035),
        vertical: AppSize.heightPercent(0.014),
      ),
      decoration: _softFieldDecoration(theme),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(AppSize.widthPercent(0.015)),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: AppSize.textPercent(0.04), color: theme.primaryColor),
            ),
            SizedBox(width: AppSize.widthPercent(0.02)),
          ],
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              style: TextStyle(
                fontFamily: "pb",
                fontSize: AppSize.textPercent(0.036),
                color: theme.canvasColor.withOpacity(0.8),
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.canvasColor.withOpacity(0.4),
            size: AppSize.textPercent(0.05),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// CATEGORY BOTTOM SHEET
/// ------------------------------------------------------------
class _CategorySelectSheet {
  static void show({
    required Function(TaskCategory category) onCategorySelected,
  }) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.widthPercent(0.05),
              vertical: AppSize.heightPercent(0.025),
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: EdgeInsets.only(bottom: AppSize.heightPercent(0.02)),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'post_job_select_category_sheet_title'.tr,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: AppSize.textPercent(0.05),
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, color: theme.canvasColor.withOpacity(0.6), size: 18),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.heightPercent(0.02)),

                /// ✅ FIX: Ab List DraggableScrollableSheet ke scrollController
                /// ke sath Expanded + ListView.separated (shrinkWrap false,
                /// normal scroll physics) use karti hai — is se overflow
                /// nahi hota chahay categories kitni bhi ho jayen.
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: TaskCategoryData.categories.length,
                    separatorBuilder: (_, __) => Divider(
                      height: AppSize.heightPercent(0.03),
                      color: theme.dividerColor.withOpacity(0.15),
                    ),
                    itemBuilder: (context, index) {
                      final category = TaskCategoryData.categories[index];
                      return GestureDetector(
                        onTap: () {
                          Get.back();
                          onCategorySelected(category);
                        },
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSize.widthPercent(0.022)),
                              decoration: BoxDecoration(
                                color: category.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(category.icon, color: category.color, size: AppSize.textPercent(0.05)),
                            ),
                            SizedBox(width: AppSize.widthPercent(0.035)),
                            Expanded(
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontFamily: "pb",
                                  fontSize: AppSize.textPercent(0.04),
                                  color: theme.canvasColor.withOpacity(0.8),
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: theme.canvasColor.withOpacity(0.4)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
    );
  }
}
/// ------------------------------------------------------------
/// SUB-CATEGORY BOTTOM SHEET
/// ------------------------------------------------------------
class _SubCategorySelectSheet {
  static void show({
    required Function(String subCategory) onSubCategorySelected,
  }) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.widthPercent(0.05),
              vertical: AppSize.heightPercent(0.025),
            ),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: EdgeInsets.only(bottom: AppSize.heightPercent(0.02)),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'post_job_select_subcategory_sheet_title'.tr,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: AppSize.textPercent(0.05),
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded, color: theme.canvasColor.withOpacity(0.6), size: 18),
                      ),
                    ),
                  ],
                ),
                Text(
                  'post_job_all_subcategories'.tr,
                  style: TextStyle(
                    fontFamily: "pr",
                    fontSize: AppSize.textPercent(0.035),
                    color: theme.canvasColor.withOpacity(0.4),
                  ),
                ),
                SizedBox(height: AppSize.heightPercent(0.02)),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: TaskCategoryData.categories.length,
                    itemBuilder: (context, index) {
                      final category = TaskCategoryData.categories[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: AppSize.heightPercent(0.02)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(category.icon, color: category.color, size: AppSize.textPercent(0.045)),
                                SizedBox(width: AppSize.widthPercent(0.02)),
                                Text(
                                  category.name.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: "pb",
                                    fontSize: AppSize.textPercent(0.03),
                                    fontWeight: FontWeight.w600,
                                    color: theme.canvasColor.withOpacity(0.5),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSize.heightPercent(0.012)),
                            ...category.subCategories.map(
                                  (sub) => Padding(
                                padding: EdgeInsets.only(bottom: AppSize.heightPercent(0.012)),
                                child: GestureDetector(
                                  onTap: () {
                                    Get.back();
                                    onSubCategorySelected(sub);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSize.widthPercent(0.04),
                                      vertical: AppSize.heightPercent(0.016),
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.brightness == Brightness.light
                                          ? const Color(0xffF5F6F8)
                                          : theme.scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: category.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: AppSize.widthPercent(0.03)),
                                        Expanded(
                                          child: Text(
                                            sub,
                                            style: TextStyle(
                                              fontFamily: "pr",
                                              fontSize: AppSize.textPercent(0.037),
                                              color: theme.canvasColor.withOpacity(0.8),
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.chevron_right_rounded,
                                            color: theme.canvasColor.withOpacity(0.3), size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
    );
  }
}

/// ------------------------------------------------------------
/// LOCATION FIELD
/// ------------------------------------------------------------
/// ------------------------------------------------------------
/// LOCATION FIELD — Google Places Autocomplete (Professional)
/// ------------------------------------------------------------
class _LocationField extends StatefulWidget {
  final TextEditingController controller;
  const _LocationField({required this.controller});

  @override
  State<_LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<_LocationField> {
  final PostJobController postJobController = Get.find<PostJobController>();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  List<PlacePrediction> _predictions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  Timer? _debounce;

  // ⚠️ API KEY — baad mein secure jagah move kar lena
  static const String _apiKey = "AIzaSyDAv6imR4b4bd_5SidA09rzU54sG8sBk6k";

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        // thoda delay taake tap pe suggestion select ho sake
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String query) {
    _debounce?.cancel();

    if (query.trim().length < 3) {
      setState(() {
        _predictions = [];
        _showSuggestions = false;
        _isLoading = false;
      });
      // agar user clear kare to coordinates bhi clear
      if (query.isEmpty) {
        postJobController.clearLocation();
      }
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () {
      _fetchPredictions(query);
    });
  }

  Future<void> _fetchPredictions(String input) async {
    setState(() {
      _isLoading = true;
      _showSuggestions = true;
    });

    try {
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
            "?input=${Uri.encodeComponent(input)}"
            "&key=$_apiKey"
            "&types=geocode|establishment"
            "&language=en",
      );

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        final List predictions = data["predictions"] ?? [];
        setState(() {
          _predictions = predictions.map((p) => PlacePrediction.fromJson(p)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _predictions = [];
          _isLoading = false;
        });
        debugPrint("Places Autocomplete error: ${data["status"]} - ${data["error_message"]}");
      }
    } catch (e) {
      setState(() {
        _predictions = [];
        _isLoading = false;
      });
      debugPrint("Places fetch error: $e");
    }
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    setState(() {
      _showSuggestions = false;
      _isLoading = true;
    });

    try {
      // Place Details se lat/lng nikalte hain
      final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/details/json"
            "?place_id=${prediction.placeId}"
            "&fields=geometry,formatted_address,name"
            "&key=$_apiKey",
      );

      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data["status"] == "OK") {
        final result = data["result"];
        final location = result["geometry"]["location"];
        final double lat = location["lat"];
        final double lng = location["lng"];
        final String address = result["formatted_address"] ?? prediction.description;

        postJobController.setSelectedLocation(
          address: address,
          lat: lat,
          lng: lng,
        );

        // keyboard band karo
        _focusNode.unfocus();
      } else {
        Get.snackbar(
          "Location Error",
          "Could not fetch location details",
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      debugPrint("Place Details error: $e");
      Get.snackbar(
        "Location Error",
        "Something went wrong while selecting location",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('post_job_location_label'.tr),
        SizedBox(height: AppSize.heightPercent(0.01)),

        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.02)),
            decoration: _softFieldDecoration(
              theme,
              highlighted: _focusNode.hasFocus || postJobController.latitude.value != null,
            ),
            child: Padding(
              padding: EdgeInsets.only(top: AppSize.height * 0.014),
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: _onTextChanged,
                style: TextStyle(
                  fontFamily: "pr",
                  fontSize: AppSize.textPercent(0.037),
                  color: theme.canvasColor,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: theme.primaryColor,
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
                      : (widget.controller.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: theme.canvasColor.withOpacity(0.5),
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      postJobController.clearLocation();
                      setState(() {
                        _predictions = [];
                        _showSuggestions = false;
                      });
                    },
                  )
                      : null),
                  hintText: 'post_job_location_hint'.tr,
                  hintStyle: TextStyle(
                    fontFamily: "pr",
                    fontSize: AppSize.textPercent(0.037),
                    color: theme.canvasColor.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Suggestions Overlay
        if (_showSuggestions && (_predictions.isNotEmpty || _isLoading))
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, AppSize.heightPercent(0.07)),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(18),
              color: theme.cardColor,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: AppSize.heightPercent(0.32),
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: _isLoading && _predictions.isEmpty
                    ? Padding(
                  padding: EdgeInsets.all(AppSize.widthPercent(0.05)),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: theme.primaryColor,
                    ),
                  ),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(
                    vertical: AppSize.heightPercent(0.01),
                  ),
                  itemCount: _predictions.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: theme.dividerColor.withOpacity(0.12),
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return InkWell(
                      onTap: () => _selectPrediction(prediction),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSize.widthPercent(0.04),
                          vertical: AppSize.heightPercent(0.015),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSize.widthPercent(0.018)),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                size: AppSize.textPercent(0.038),
                                color: theme.primaryColor,
                              ),
                            ),
                            SizedBox(width: AppSize.widthPercent(0.03)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prediction.mainText,
                                    style: TextStyle(
                                      fontFamily: "pb",
                                      fontSize: AppSize.textPercent(0.036),
                                      color: theme.canvasColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (prediction.secondaryText.isNotEmpty) ...[
                                    SizedBox(height: 2),
                                    Text(
                                      prediction.secondaryText,
                                      style: TextStyle(
                                        fontFamily: "pr",
                                        fontSize: AppSize.textPercent(0.03),
                                        color: theme.canvasColor.withOpacity(0.55),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Simple model for Place Prediction
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured = json["structured_formatting"] ?? {};
    return PlacePrediction(
      placeId: json["place_id"] ?? "",
      description: json["description"] ?? "",
      mainText: structured["main_text"] ?? json["description"] ?? "",
      secondaryText: structured["secondary_text"] ?? "",
    );
  }
}
/// ------------------------------------------------------------
/// DESCRIPTION FIELD
/// ------------------------------------------------------------
class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const _DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('post_job_description_label'.tr),
        SizedBox(height: AppSize.heightPercent(0.01)),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.widthPercent(0.04),
            vertical: AppSize.heightPercent(0.005),
          ),
          decoration: _softFieldDecoration(theme),
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: TextStyle(
              fontFamily: "pr",
              fontSize: AppSize.textPercent(0.037),
              color: theme.canvasColor,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'post_job_description_hint'.tr,
              hintStyle: TextStyle(
                fontFamily: "pr",
                fontSize: AppSize.textPercent(0.037),
                color: theme.canvasColor.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// BUDGET CONTAINER + TABS + CONTENTS
/// ------------------------------------------------------------
class _BudgetContainer extends StatelessWidget {
  const _BudgetContainer();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    const Color accent = Color(0xff10B981);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.widthPercent(0.045)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5)),
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
                child: Icon(Icons.payments_rounded, color: accent, size: AppSize.textPercent(0.042)),
              ),
              SizedBox(width: AppSize.widthPercent(0.03)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'post_job_budget_title'.tr,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: AppSize.textPercent(0.042),
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),
                    Obx(
                          () => Text(
                        _subtitleFor(controller.budgetType.value),
                        style: TextStyle(
                          fontFamily: "pr",
                          fontSize: AppSize.textPercent(0.032),
                          color: theme.canvasColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.heightPercent(0.02)),
          const _BudgetTypeTabs(),
          Obx(() {
            switch (controller.budgetType.value) {
              case BudgetType.fixed:
                return const _FixedPriceContent();
              case BudgetType.hourly:
                return const _HourlyRateContent();
              case BudgetType.negotiable:
                return const _NegotiableContent();
            }
          }),
        ],
      ),
    );
  }

  String _subtitleFor(BudgetType type) {
    switch (type) {
      case BudgetType.fixed:
        return 'post_job_budget_subtitle_fixed'.tr;
      case BudgetType.hourly:
        return 'post_job_budget_subtitle_hourly'.tr;
      case BudgetType.negotiable:
        return 'post_job_budget_subtitle_negotiable'.tr;
    }
  }
}

class _BudgetTypeTabs extends StatelessWidget {
  const _BudgetTypeTabs();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSize.widthPercent(0.01)),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xffF5F6F8)
            : theme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(
            () => Row(
          children: BudgetType.values.map((type) {
            final bool isSelected = controller.budgetType.value == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.budgetType.value = type,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: AppSize.heightPercent(0.014)),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                      colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    color: isSelected ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _labelFor(type),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: isSelected ? "pb" : "pr",
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: AppSize.textPercent(0.033),
                      color: isSelected ? Colors.white : theme.canvasColor.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _labelFor(BudgetType type) {
    switch (type) {
      case BudgetType.fixed:
        return 'post_job_tab_fixed_price'.tr;
      case BudgetType.hourly:
        return 'post_job_tab_hourly_rate'.tr;
      case BudgetType.negotiable:
        return 'post_job_tab_negotiable'.tr;
    }
  }
}

class _FixedPriceContent extends StatelessWidget {
  const _FixedPriceContent();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSize.heightPercent(0.02)),
        _SectionLabel('post_job_amount_label'.tr),
        SizedBox(height: AppSize.heightPercent(0.01)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.04)),
          decoration: _softFieldDecoration(theme, highlighted: true),
          child: Row(
            children: [
              Text(
                'post_job_currency_uzs'.tr,
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: AppSize.textPercent(0.04),
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: AppSize.widthPercent(0.02)),
              Expanded(
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontFamily: "pb",
                    fontSize: AppSize.textPercent(0.042),
                    color: theme.canvasColor,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'post_job_amount_hint'.tr,
                    hintStyle: TextStyle(color: theme.canvasColor.withOpacity(0.3)),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      final val = int.tryParse(controller.amountController.text) ?? 0;
                      controller.amountController.text = (val + 1).toString();
                    },
                    child: Icon(Icons.keyboard_arrow_up_rounded, color: theme.canvasColor.withOpacity(0.5), size: 18),
                  ),
                  GestureDetector(
                    onTap: () {
                      final val = int.tryParse(controller.amountController.text) ?? 0;
                      if (val > 0) controller.amountController.text = (val - 1).toString();
                    },
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: theme.canvasColor.withOpacity(0.5), size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.heightPercent(0.02)),
        const _PaymentTypeDropdown(),
      ],
    );
  }
}

class _HourlyRateContent extends StatelessWidget {
  const _HourlyRateContent();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSize.heightPercent(0.02)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// RATE PER HOUR
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('post_job_rate_per_hour_label'.tr),
                  SizedBox(height: AppSize.heightPercent(0.01)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.03)),
                    decoration: _softFieldDecoration(theme, highlighted: true),
                    child: Row(
                      children: [
                        Text(
                          'post_job_currency_uzs'.tr,
                          style: TextStyle(
                            fontFamily: "pb",
                            fontSize: AppSize.textPercent(0.04),
                            color: theme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: AppSize.widthPercent(0.015)),
                        Expanded(
                          child: TextField(
                            controller: controller.rateController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontFamily: "pb",
                              fontSize: AppSize.textPercent(0.04),
                              color: theme.canvasColor,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'post_job_rate_hint'.tr,
                              hintStyle: TextStyle(color: theme.canvasColor.withOpacity(0.3)),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.keyboard_arrow_up_rounded, color: theme.canvasColor.withOpacity(0.3), size: 16),
                            Icon(Icons.keyboard_arrow_down_rounded, color: theme.canvasColor.withOpacity(0.3), size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSize.widthPercent(0.03)),

            /// ESTIMATED HOURS
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('post_job_estimated_hours_label'.tr),
                  Text(
                    'post_job_optional'.tr,
                    style: TextStyle(
                      fontFamily: "pr",
                      fontSize: AppSize.textPercent(0.028),
                      color: theme.canvasColor.withOpacity(0.4),
                    ),
                  ),
                  SizedBox(height: AppSize.heightPercent(0.006)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.03)),
                    decoration: _softFieldDecoration(theme),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: theme.canvasColor.withOpacity(0.5), size: 16),
                        SizedBox(width: AppSize.widthPercent(0.015)),
                        Expanded(
                          child: TextField(
                            controller: controller.estimatedHoursController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontFamily: "pb",
                              fontSize: AppSize.textPercent(0.04),
                              color: theme.canvasColor,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'post_job_hours_hint'.tr,
                              hintStyle: TextStyle(color: theme.canvasColor.withOpacity(0.3)),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.keyboard_arrow_up_rounded, color: theme.canvasColor.withOpacity(0.3), size: 16),
                            Icon(Icons.keyboard_arrow_down_rounded, color: theme.canvasColor.withOpacity(0.3), size: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.heightPercent(0.02)),
        const _PaymentTypeDropdown(),
      ],
    );
  }
}

class _NegotiableContent extends StatelessWidget {
  const _NegotiableContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color bgColor = theme.brightness == Brightness.light
        ? const Color(0xffFFFBEB)
        : theme.cardColor.withOpacity(0.3);
    final Color iconBgColor = theme.brightness == Brightness.light
        ? const Color(0xffFEF3C7)
        : theme.primaryColor.withOpacity(0.2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSize.heightPercent(0.02)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSize.widthPercent(0.05),
            vertical: AppSize.heightPercent(0.025),
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.widthPercent(0.025)),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: theme.primaryColor.withOpacity(0.15), blurRadius: 10),
                  ],
                ),
                child: Text(
                  'post_job_currency_uzs'.tr,
                  style: TextStyle(
                    fontFamily: "pb",
                    fontSize: AppSize.textPercent(0.04),
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: AppSize.heightPercent(0.015)),
              Text(
                'post_job_negotiable_budget_title'.tr,
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: AppSize.textPercent(0.04),
                  fontWeight: FontWeight.bold,
                  color: theme.canvasColor,
                ),
              ),
              SizedBox(height: AppSize.heightPercent(0.008)),
              Text(
                'post_job_negotiable_budget_desc'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "pr",
                  fontSize: AppSize.textPercent(0.033),
                  color: theme.canvasColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.heightPercent(0.02)),
        const _PaymentTypeDropdown(),
      ],
    );
  }
}

class _PaymentTypeDropdown extends StatelessWidget {
  const _PaymentTypeDropdown();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('post_job_payment_type_label'.tr),
        SizedBox(height: AppSize.heightPercent(0.01)),
        Obx(
              () => Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.widthPercent(0.04),
              vertical: AppSize.heightPercent(0.004),
            ),
            decoration: _softFieldDecoration(theme),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<PaymentType>(
                value: controller.paymentType.value,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.canvasColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
                items: PaymentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(_iconFor(type), color: theme.primaryColor, size: AppSize.textPercent(0.045)),
                        SizedBox(width: AppSize.widthPercent(0.025)),
                        Text(
                          _labelFor(type),
                          style: TextStyle(
                            fontFamily: "pb",
                            fontSize: AppSize.textPercent(0.037),
                            color: theme.canvasColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.paymentType.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Icons.payments_rounded;
      case PaymentType.card:
        return Icons.credit_card_rounded;
      case PaymentType.wallet:
        return Icons.account_balance_wallet_rounded;
    }
  }

  String _labelFor(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'post_job_payment_cash'.tr;
      case PaymentType.card:
        return 'post_job_payment_card'.tr;
      case PaymentType.wallet:
        return 'post_job_payment_wallet'.tr;
    }
  }
}

/// ------------------------------------------------------------
/// SCHEDULE CONTAINER + DATE + TIME + URGENCY
/// ------------------------------------------------------------
class _ScheduleContainer extends StatelessWidget {
  const _ScheduleContainer();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    const Color accent = Color(0xff3B82F6);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSize.widthPercent(0.045)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER: Schedule badge + summary chip
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.widthPercent(0.02)),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_month_rounded, color: accent, size: AppSize.textPercent(0.042)),
              ),
              SizedBox(width: AppSize.widthPercent(0.03)),
              Text(
                'post_job_schedule_badge'.tr,
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: AppSize.textPercent(0.04),
                  fontWeight: FontWeight.bold,
                  color: theme.canvasColor,
                ),
              ),
              SizedBox(width: AppSize.widthPercent(0.03)),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.widthPercent(0.03),
                    vertical: AppSize.heightPercent(0.01),
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                        () => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time_rounded, color: theme.primaryColor, size: AppSize.textPercent(0.035)),
                        SizedBox(width: AppSize.widthPercent(0.015)),
                        Flexible(
                          child: Text(
                            "${controller.scheduleDateLabel} — ${controller.startTimeLabel}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: "pb",
                              fontSize: AppSize.textPercent(0.033),
                              color: theme.primaryColor,
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

          SizedBox(height: AppSize.heightPercent(0.022)),

          /// DATE + START TIME
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(child: _ChooseDateDropdown()),
              SizedBox(width: AppSize.widthPercent(0.03)),
              Expanded(
                child: Obx(
                      () => _TimeSelectorField(
                    label: 'post_job_start_time_label'.tr,
                    value: controller.startTimeLabel,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: controller.startTime.value ?? TimeOfDay.now(),
                        builder: (context, child) => Theme(data: theme, child: child!),
                      );
                      if (picked != null) {
                        controller.startTime.value = picked;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSize.heightPercent(0.02)),

          /// END TIME + URGENCY
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(
                      () => _TimeSelectorField(
                    label: 'post_job_end_time_label'.tr,
                    value: controller.endTimeLabel,
                    onTap: () async {
                      if (controller.startTime.value == null) {
                        Get.snackbar('post_job_select_start_time_title'.tr, 'post_job_select_start_time_message'.tr,
                            backgroundColor: theme.cardColor, colorText: theme.canvasColor);
                        return;
                      }
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: controller.startTime.value!,
                        builder: (context, child) => Theme(data: theme, child: child!),
                      );
                      if (picked != null) {
                        controller.endTime.value = picked;
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: AppSize.widthPercent(0.03)),
              const Expanded(child: _UrgencyDropdown()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChooseDateDropdown extends StatelessWidget {
  const _ChooseDateDropdown();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('post_job_choose_date_label'.tr),
        SizedBox(height: AppSize.heightPercent(0.01)),
        Obx(
              () => Container(
            decoration: _softFieldDecoration(theme, highlighted: true),
            child: PopupMenuButton<ScheduleDateType>(
              padding: EdgeInsets.zero,
              offset: Offset(0, AppSize.heightPercent(0.06)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: theme.cardColor,
              onSelected: (value) async {
                controller.scheduleDateType.value = value;
                if (value == ScheduleDateType.custom) {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) => Theme(
                      data: theme,
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    controller.customDate.value = picked;
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: ScheduleDateType.today,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'post_job_today'.tr,
                        style: TextStyle(
                          fontFamily: "pb",
                          fontSize: AppSize.textPercent(0.037),
                          color: theme.primaryColor,
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: ScheduleDateType.custom,
                  child: Text(
                    'post_job_custom_date'.tr,
                    style: TextStyle(
                      fontFamily: "pr",
                      fontSize: AppSize.textPercent(0.037),
                      color: theme.canvasColor,
                    ),
                  ),
                ),
              ],
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.widthPercent(0.035),
                  vertical: AppSize.heightPercent(0.016),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: theme.primaryColor, size: AppSize.textPercent(0.04)),
                    SizedBox(width: AppSize.widthPercent(0.02)),
                    Expanded(
                      child: Text(
                        controller.scheduleDateLabel,
                        style: TextStyle(
                          fontFamily: "pb",
                          fontSize: AppSize.textPercent(0.037),
                          color: theme.canvasColor,
                        ),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_up_rounded, color: theme.canvasColor.withOpacity(0.5)),
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

class _TimeSelectorField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeSelectorField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        SizedBox(height: AppSize.heightPercent(0.01)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSize.widthPercent(0.035),
              vertical: AppSize.heightPercent(0.016),
            ),
            decoration: _softFieldDecoration(theme),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded, color: theme.canvasColor.withOpacity(0.5), size: AppSize.textPercent(0.04)),
                SizedBox(width: AppSize.widthPercent(0.02)),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontFamily: "pb",
                      fontSize: AppSize.textPercent(0.037),
                      color: theme.canvasColor,
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

class _UrgencyDropdown extends StatelessWidget {
  const _UrgencyDropdown();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('post_job_urgency_label'.tr),
        SizedBox(height: AppSize.heightPercent(0.01)),
        Obx(
              () => Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSize.widthPercent(0.02)),
            decoration: _softFieldDecoration(theme),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<UrgencyType>(
                value: controller.urgencyType.value,
                isExpanded: true,
                dropdownColor: theme.cardColor,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: theme.canvasColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
                items: UrgencyType.values.map((type) {
                  final bool isUrgent = type == UrgencyType.urgent;
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(
                          isUrgent ? Icons.local_fire_department_rounded : Icons.schedule_rounded,
                          color: isUrgent ? const Color(0xffEF4444) : const Color(0xff10B981),
                          size: AppSize.textPercent(0.028),
                        ),
                        SizedBox(width: AppSize.widthPercent(0.015)),
                        Text(
                          isUrgent ? 'post_job_urgent'.tr : 'post_job_flexible'.tr,
                          style: TextStyle(
                            fontFamily: "pb",
                            fontSize: AppSize.textPercent(0.026),
                            color: theme.canvasColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) controller.urgencyType.value = value;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ------------------------------------------------------------
/// PHOTO ATTACHMENT + DASHED BORDER PAINTER
/// ------------------------------------------------------------
class _PhotoAttachmentContainer extends StatelessWidget {
  const _PhotoAttachmentContainer();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );

      if (picked == null) return; // User cancelled camera/gallery

      // Safety check: if the Android Activity was killed while the camera
      // was open (common OS behavior for memory reclaim), the in-memory
      // GetX controller instance may have been lost. Instead of crashing
      // on Get.find(), re-register it gracefully.
      final PostJobController controller = Get.isRegistered<PostJobController>()
          ? Get.find<PostJobController>()
          : Get.put(PostJobController(), permanent: true);

      controller.addPhoto(File(picked.path));
    } catch (e, st) {
      debugPrint("❌ Image pick error: $e\n$st");
      Get.snackbar(
        'post_job_image_pick_error_title'.tr,
        'post_job_image_pick_error_message'.tr,
        snackPosition: SnackPosition.TOP,
      );
    }
  }
  void _openPicker() {
    ImagePickerBottomSheet.show(
      onCameraTap: () => _pickImage(ImageSource.camera),
      onGalleryTap: () => _pickImage(ImageSource.gallery),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('post_job_photo_attachment_label'.tr),
        SizedBox(height: AppSize.heightPercent(0.01)),
        Obx(() {
          if (controller.attachedPhotos.isEmpty) {
            return GestureDetector(
              onTap: _openPicker,
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: theme.primaryColor.withOpacity(0.35),
                  radius: 20,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: AppSize.heightPercent(0.04)),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSize.widthPercent(0.028)),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: theme.primaryColor.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Icon(Icons.image_outlined, color: Colors.white, size: AppSize.textPercent(0.06)),
                      ),
                      SizedBox(height: AppSize.heightPercent(0.015)),
                      Text(
                        'post_job_drag_drop_photos'.tr,
                        style: TextStyle(
                          fontFamily: "pb",
                          fontSize: AppSize.textPercent(0.035),
                          color: theme.canvasColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSize.heightPercent(0.006)),
                      Text(
                        'post_job_photos_limit_hint'.tr,
                        style: TextStyle(
                          fontFamily: "pr",
                          fontSize: AppSize.textPercent(0.03),
                          color: theme.canvasColor.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Wrap(
            spacing: AppSize.widthPercent(0.03),
            runSpacing: AppSize.widthPercent(0.03),
            children: [
              ...controller.attachedPhotos.map(
                    (file) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        file,
                        width: AppSize.widthPercent(0.26),
                        height: AppSize.widthPercent(0.26),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => controller.removePhoto(file),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.canvasColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4),
                            ],
                          ),
                          child: Icon(Icons.close_rounded, color: theme.cardColor, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.attachedPhotos.length < 3)
                GestureDetector(
                  onTap: _openPicker,
                  child: Container(
                    width: AppSize.widthPercent(0.26),
                    height: AppSize.widthPercent(0.26),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.add_rounded, color: theme.canvasColor.withOpacity(0.5)),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    this.radius = 16,
    this.dashWidth = 6,
    this.dashSpace = 4,
    this.strokeWidth = 1.4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _dashPath(path, dashWidth: dashWidth, dashSpace: dashSpace);
    canvas.drawPath(dashedPath, paint);
  }

  Path _dashPath(Path source, {required double dashWidth, required double dashSpace}) {
    final dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashSpace;
        if (draw) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}

/// ------------------------------------------------------------
/// CANCEL / SUBMIT ACTION BUTTONS
/// ------------------------------------------------------------
class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostJobController>();
    final theme = Theme.of(context);

    return Row(
      children: [
        /// CANCEL BUTTON
        Expanded(
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: AppSize.heightPercent(0.02)),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: theme.dividerColor.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Text(
                'post_job_cancel_button'.tr,
                style: TextStyle(
                  fontFamily: "pb",
                  fontSize: AppSize.textPercent(0.04),
                  fontWeight: FontWeight.bold,
                  color: theme.canvasColor,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: AppSize.widthPercent(0.04)),

        /// SUBMIT BUTTON
        /// UPDATE: ab seedha submit nahi karta, pehle Summary/Review
        /// screen dikhata hai (validation ke sath).
        Expanded(
          child: GestureDetector(
            onTap: () => controller.goToSummary(),
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: AppSize.heightPercent(0.02)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'post_job_submit_button'.tr,
                    style: TextStyle(
                      fontFamily: "pb",
                      fontSize: AppSize.textPercent(0.04),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: AppSize.widthPercent(0.015)),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
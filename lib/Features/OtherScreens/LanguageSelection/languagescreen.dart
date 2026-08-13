import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Core/Widgets/Background.dart';
import '../../../Core/Widgets/Button.dart';
import '../../../Core/Widgets/MediaqueryHelperfile.dart';
import '../RoleSelection/roleselectionscreen.dart';
import 'controller.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final LanguageController controller = Get.put(LanguageController());

  // Language Data with ISO Codes & Subtitles
  final List<Map<String, String>> languages = [
    {"name": "English", "sub": "English", "code": "EN"},
    {"name": "O'zbekcha", "sub": "Uzbek", "code": "UZ"},
    {"name": "Русский", "sub": "Russian", "code": "RU"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.06),
            child: Column(
              children: [
                SizedBox(height: AppSize.height * 0.03),

                /// MODERN GRADIENT LOGO BOX
                Container(
                  height: AppSize.height * 0.10,
                  width: AppSize.height * 0.10,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "J",
                      style: TextStyle(
                        fontSize: 38,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSize.height * 0.035),

                /// TITLE & SUBTITLE
                Text(
                  "onboarding_language_title".tr,
                  style: TextStyle(
                    fontSize: AppSize.width * 0.065,
                    fontWeight: FontWeight.bold,
                    color: theme.canvasColor,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: AppSize.height * 0.012),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.width * 0.04,
                  ),
                  child: Text(
                    "onboarding_language_subtitle".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSize.width * 0.035,
                      color: theme.canvasColor.withOpacity(0.55),
                      height: 1.4,
                    ),
                  ),
                ),

                SizedBox(height: AppSize.height * 0.04),

                /// LANGUAGE TILES LIST
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final item = languages[index];
                    return _languageTile(
                      lang: item["name"]!,
                      code: item["code"]!,
                      theme: theme,
                    );
                  },
                ),

                SizedBox(height: AppSize.height * 0.05),

                /// CONTINUE BUTTON
                CustomButton(
                  title: "common_continue".tr,
                  textSize: AppSize.height * 0.022,
                  titlePadding: EdgeInsets.only(right: AppSize.height * 0.05),
                  onTap: () {
                    Get.to(
                      () => RoleSelectionScreen(),
                      transition: Transition.fade,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                  rightWidget: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  rightPadding: EdgeInsets.only(right: AppSize.width * 0.14),
                ),
                SizedBox(height: AppSize.height * 0.03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// PROFESSIONAL & ANIMATED LANGUAGE TILE WIDGET
  Widget _languageTile({
    required String lang,
    required String code,
    required ThemeData theme,
  }) {
    return Obx(() {
      final isSelected = controller.isSelected(lang);

      return GestureDetector(
        onTap: () => controller.selectLanguage(lang),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(bottom: AppSize.height * 0.018),
          padding: EdgeInsets.symmetric(
            vertical: AppSize.height * 0.018,
            horizontal: AppSize.width * 0.04,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(0.06)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : theme.dividerColor.withOpacity(0.12),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? theme.primaryColor.withOpacity(0.12)
                    : Colors.black.withOpacity(0.03),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              /// Language Code Badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.primaryColor
                      : theme.primaryColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    code,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : theme.primaryColor,
                    ),
                  ),
                ),
              ),

              SizedBox(width: AppSize.width * 0.035),

              Text(
                lang,
                style: TextStyle(
                  fontSize: AppSize.width * 0.042,
                  fontWeight: FontWeight.w600,
                  color: theme.canvasColor,
                ),
              ),

              const Spacer(),

              /// Custom Animated Selection Indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? theme.primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColor
                        : theme.canvasColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      );
    });
  }
}

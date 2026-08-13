import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:helper_app2/Core/Widgets/mediaqueryHelperfile.dart';
import 'package:helper_app2/Core/Apis/sessionmanager.dart';
import 'package:helper_app2/Core/Widgets/Background.dart';
import 'package:helper_app2/Core/Widgets/Button.dart';
import 'package:helper_app2/Features/ClientsSide/ClientBottomNavigation/ClientBottomnavigationScreen.dart';
import '../../../../../Core/Localization/languagehelper.dart';
import '../../../../../Core/Widgets/Backbutton.dart';
import 'clientProfilecontroller.dart';

class LanguageScreen2 extends StatefulWidget {
  const LanguageScreen2({super.key});

  @override
  State<LanguageScreen2> createState() => _LanguageScreen2State();
}

class _LanguageScreen2State extends State<LanguageScreen2> {
  final ProfileController controller = Get.find<ProfileController>();

  /// Local (temporary) selection — sirf visual highlight ke liye.
  /// Jab tak Continue na dabaya jaye, na to app ka actual locale
  /// change hoga, na hi controller/persisted state update hoga.
  late String _selectedLanguage;
  bool _isApplying = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = SessionManager.getLanguage();
    // Screen hamesha ACTUAL currently-applied language se hi start ho
    // (controller.selectedLanguage.value = wahi language jo last baar
    // Continue dabane par confirm/apply/persist hui thi).
    controller.selectedLanguage.value = _selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GetBuilder<ProfileController>(
      builder: (_) {
        return AppBackground(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.06),
              child: Column(
                children: [
                  SizedBox(height: AppSize.height * 0.02),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: CustomBackButton()),
                  SizedBox(height: AppSize.height * 0.04),
                  /// LOGO
                  Container(
                    height: AppSize.height * 0.12,
                    width: AppSize.height * 0.12,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "J",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSize.height * 0.03),

                  /// TITLE
                  Text(
                    "languagesheettitle".tr,
                    style: TextStyle(
                      fontSize: AppSize.width * 0.07,
                      fontWeight: FontWeight.bold,
                      color: theme.canvasColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: AppSize.height * 0.01),

                  Text(
                    "languagesheetsubtitle".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSize.width * 0.035,
                      color: theme.canvasColor.withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: AppSize.height * 0.045),

                  /// LANGUAGE TILES
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _langTile(theme, "English", "assets/images/usa.jpg"),
                          SizedBox(height: AppSize.height * 0.02),
                          _langTile(theme, "O'zbekcha", "assets/images/uz.jpg"),
                          SizedBox(height: AppSize.height * 0.02),
                          _langTile(theme, "Русский", "assets/images/ru.jpg"),
                        ],
                      ),
                    ),
                  ),

                  /// CONTINUE BUTTON
                  CustomButton(
                    title: _isApplying ? "languagesheetloading".tr : "languagesheetcontinue".tr,
                    onTap: _isApplying ? () {} : _applyAndContinue,
                    rightWidget: _isApplying
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    rightPadding: EdgeInsets.only(right: AppSize.height * 0.04),
                  ),
                  SizedBox(height: AppSize.height * 0.04),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// SINGLE LANGUAGE TILE (sirf local/visual selection — koi apply nahi hota yahan)
  Widget _langTile(ThemeData theme, String title, String flag) {
    final bool isSelected = _selectedLanguage == title;

    return GestureDetector(
      onTap: () {
        // ⚠️ Yahan sirf local UI state update hogi. App ka actual locale,
        // controller.selectedLanguage, aur persisted language — ye sab
        // TABHI change honge jab user "Continue" button dabaye ga.
        // Isse back button se peeche jaane par kuch bhi apply nahi hoga.
        setState(() {
          _selectedLanguage = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: EdgeInsets.all(AppSize.width * 0.04),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : theme.dividerColor.withOpacity(0.3),
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            /// FLAG
            Container(
              height: AppSize.width * 0.11,
              width: AppSize.width * 0.11,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.primaryColor
                      : Colors.transparent,
                  width: 2,
                ),
                image: DecorationImage(
                  image: AssetImage(flag),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: AppSize.width * 0.035),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: AppSize.width * 0.045,
                      color: theme.canvasColor,
                    ),
                  ),
            Spacer(),
            /// SELECTED INDICATOR
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSelected
                  ? Icon(
                Icons.check_circle,
                key: const ValueKey('checked'),
                color: theme.primaryColor,
              )
                  : Icon(
                Icons.circle_outlined,
                key: const ValueKey('unchecked'),
                color: theme.canvasColor.withOpacity(0.25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// APPLY SELECTED LANGUAGE + NAVIGATE — sirf yahan actual locale change hota hai
  Future<void> _applyAndContinue() async {
    setState(() => _isApplying = true);

    try {
      // 1) Controller ki authoritative state update karo (yehi agli dafa
      //    screen khulne par initState mein use hogi)
      controller.setLanguage(_selectedLanguage);

      // 2) App ka actual locale ab confirm hone par hi change ho
      final Locale newLocale = LanguageHelper.localeFor(_selectedLanguage);
      Get.updateLocale(newLocale);

      // 3) Selection persist karo
      await SessionManager.saveLanguage(_selectedLanguage);

      // 4) Client bottom navigation par le jao
      Get.offAll(() => Clientbottomnavigationscreen());
    } catch (e) {
      setState(() => _isApplying = false);
      Get.snackbar(
        "Error",
        "Something went wrong while changing language.",
        snackPosition: SnackPosition.BOTTOM,
        padding: EdgeInsets.symmetric(
          vertical: AppSize.height * 0.01,
          horizontal: AppSize.height * 0.01,
        ),
      );
    }
  }
}
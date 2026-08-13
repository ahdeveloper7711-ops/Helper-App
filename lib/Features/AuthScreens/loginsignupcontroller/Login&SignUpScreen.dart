import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import '../../../Core/Widgets/Background.dart';
import '../../../Core/Widgets/Button.dart';
import '../../../Core/Widgets/CustomHeader.dart';
import '../../../Core/Widgets/MediaqueryHelperfile.dart';
import 'authcontroller.dart';
class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final AuthController controller = Get.put(AuthController());
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String countryCode = "+92";
  String countryFlag = "🇵🇰";

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Professional, theme-matched country picker bottom sheet.
  void _openCountryPicker(BuildContext context, ThemeData theme) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      favorite: const ['PK'],
      countryListTheme: CountryListThemeData(
        backgroundColor: theme.scaffoldBackgroundColor,
        bottomSheetHeight: AppSize.height * 0.75,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        inputDecoration: InputDecoration(
          hintText: 'auth_search_country'.tr,
          hintStyle: TextStyle(color: theme.canvasColor.withOpacity(0.4)),
          prefixIcon: Icon(Icons.search, color: theme.primaryColor),
          filled: true,
          fillColor: theme.cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        searchTextStyle: TextStyle(
          fontFamily: "pr",
          color: theme.canvasColor,
        ),
        textStyle: TextStyle(
          fontFamily: "pr",
          color: theme.canvasColor,
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          countryCode = "+${country.phoneCode}";
          countryFlag = country.flagEmoji;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSize.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSize.height * 0.02),
                    CustomHeader(
                      title: "",
                      showBackButton: true,
                      onBack: () => Get.back(),
                    ),
                    SizedBox(height: AppSize.height * 0.03),
                    Center(
                      child: Image(
                        image: const AssetImage("assets/images/logo.png"),
                        height: AppSize.height * 0.15,
                      ),
                    ),
                    SizedBox(height: AppSize.height * 0.04),
                    Text(
                      'auth_signup_login_title'.tr,
                      style: TextStyle(
                        fontFamily: "pb",
                        fontSize: AppSize.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: theme.canvasColor,
                      ),
                    ),
                    SizedBox(height: AppSize.height * 0.01),
                    Text(
                      'auth_details_subtitle'.tr,
                      style: TextStyle(
                        fontFamily: "pr",
                        color: theme.canvasColor.withOpacity(0.55),
                        fontSize: AppSize.height * 0.02,
                      ),
                    ),
                    SizedBox(height: AppSize.height * 0.04),

                    // Toggle Phone / Email
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(AppSize.height*0.6),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Obx(
                                  () => GestureDetector(
                                onTap: () => controller.toggleMethod(true),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.015),
                                  decoration: BoxDecoration(
                                    color: controller.isPhone.value
                                        ? theme.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppSize.height*0.6),
                                    boxShadow: controller.isPhone.value
                                        ? [
                                      BoxShadow(
                                        color: theme.primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'auth_phone_tab'.tr,
                                    style: TextStyle(
                                      fontFamily: "pb",
                                      fontWeight: FontWeight.w600,
                                      color: controller.isPhone.value
                                          ? Colors.white
                                          : theme.canvasColor.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Obx(
                                  () => GestureDetector(
                                onTap: () => controller.toggleMethod(false),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOut,
                                  padding: EdgeInsets.symmetric(vertical: AppSize.height * 0.015),
                                  decoration: BoxDecoration(
                                    color: !controller.isPhone.value
                                        ? theme.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppSize.height*0.6),
                                    boxShadow: !controller.isPhone.value
                                        ? [
                                      BoxShadow(
                                        color: theme.primaryColor.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'auth_email_tab'.tr,
                                    style: TextStyle(
                                      fontFamily: "pb",
                                      fontWeight: FontWeight.w600,
                                      color: !controller.isPhone.value
                                          ? Colors.white
                                          : theme.canvasColor.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSize.height * 0.03),

                    // Input Field (Phone or Email)
                    Obx(
                          () => controller.isPhone.value
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              fontFamily: "pr",
                              color: theme.canvasColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'auth_phone_hint'.tr,
                              hintStyle: TextStyle(
                                color: theme.canvasColor.withOpacity(0.4),
                              ),
                              // Inline country-code selector, built into
                              // the same field — flag + dial code +
                              // divider + dropdown arrow.
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _openCountryPicker(context, theme),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(width: 8),
                                      Text(
                                        countryFlag,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        countryCode,
                                        style: TextStyle(
                                          fontFamily: "pb",
                                          fontWeight: FontWeight.w600,
                                          color: theme.canvasColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: theme.canvasColor.withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        height: 22,
                                        width: 1,
                                        color: theme.dividerColor.withOpacity(0.25),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                  ),
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(
                                minWidth: 0,
                                minHeight: 0,
                              ),
                              filled: true,
                              fillColor: theme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSize.height*0.6),
                                borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSize.height*0.6),
                                borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSize.height*0.6),
                                borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                              ),
                            ),
                          ),
                          if (controller.phoneError.value.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 6),
                              child: Text(
                                controller.phoneError.value,
                                style: const TextStyle(color: Color(0xffEF4444), fontSize: 12),
                              ),
                            ),
                        ],
                      )
                          : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontFamily: "pr",
                              color: theme.canvasColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'auth_email_hint'.tr,
                              hintStyle: TextStyle(
                                color: theme.canvasColor.withOpacity(0.4),
                              ),
                              prefixIcon: Icon(Icons.email_outlined, color: theme.primaryColor),
                              filled: true,
                              fillColor: theme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSize.height*0.6),
                                borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSize.height*0.6),
                                borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.2)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSize.height*0.6),
                                borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
                              ),
                            ),
                          ),
                          if (controller.emailError.value.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 6),
                              child: Text(
                                controller.emailError.value,
                                style: const TextStyle(color: Color(0xffEF4444), fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: AppSize.height * 0.04),

                    // Continue Button
                    Obx(
                          () => CustomButton(
                        title: controller.isLoading.value
                            ? 'auth_button_loading'.tr
                            : 'auth_button_continue'.tr,
                        onTap: controller.isLoading.value
                            ? () {}
                            : () {
                          controller.continueAuth(
                            phone: controller.isPhone.value
                                ? "$countryCode${phoneController.text}"
                                : phoneController.text,
                            email: emailController.text,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: AppSize.height * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
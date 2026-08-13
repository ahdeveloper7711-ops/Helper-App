import 'package:get/get.dart';
import 'package:helper_app2/Core/Apis/sessionmanager.dart';

import '../../../Core/Localization/languagehelper.dart';

class LanguageController extends GetxController {
  RxString selectedLanguage = "English".obs;

  @override
  void onInit() {
    super.onInit();
    // Agar kisi wajah se pehle se koi language save ho (default
    // "English" already set hai warna) usay reflect kar do.
    selectedLanguage.value = SessionManager.getLanguage();
  }

  Future<void> selectLanguage(String lang) async {
    selectedLanguage.value = lang;

    // Turant app-wide locale switch — is se isi screen ka text,
    // aur aage Login/Signup screen bhi turant nayi language mein
    // dikhna shuru ho jayegi, koi app restart nahi chahiye.
    final locale = LanguageHelper.localeFor(lang);
    Get.updateLocale(locale);

    // Persist karo — taake user "Continue" dabane se pehle bhi app
    // band kar de to agli baar yehi language load ho (aur baad mein
    // Settings > Language sheet mein bhi yehi selected dikhe).
    await SessionManager.saveLanguage(lang);
  }

  bool isSelected(String lang) {
    return selectedLanguage.value == lang;
  }
}
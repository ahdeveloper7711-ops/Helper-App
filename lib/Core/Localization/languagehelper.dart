import 'dart:ui';
class LanguageHelper {
  static const Map<String, Locale> _localeMap = {
    "English": Locale('en', 'US'),
    "O'zbekcha": Locale('uz', 'UZ'),
    "Русский": Locale('ru', 'RU'),
  };

  /// Default/fallback locale — agar koi label match na ho.
  static const Locale defaultLocale = Locale('en', 'US');

  /// LanguageSheet ke label se Locale nikalo.
  static Locale localeFor(String label) {
    return _localeMap[label] ?? defaultLocale;
  }

  /// Locale se wapis label nikalo (app start par saved language
  /// dobara UI mein highlight karne ke kaam aata hai).
  static String labelForLocale(Locale locale) {
    final key = '${locale.languageCode}_${locale.countryCode}';
    switch (key) {
      case 'uz_UZ':
        return "O'zbekcha";
      case 'ru_RU':
        return "Русский";
      case 'en_US':
      default:
        return "English";
    }
  }
}
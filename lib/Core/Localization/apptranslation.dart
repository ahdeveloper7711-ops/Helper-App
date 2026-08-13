import 'package:get/get.dart';

import 'En_us.dart';
import 'RU_ru.dart';
import 'UZ_uz.dart';
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUS,
    'uz_UZ': uzUZ,
    'ru_RU': ruRU,
  };
}
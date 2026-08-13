import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class SessionManager {
  static final GetStorage _box = GetStorage();

  static const String _userKey = "user_data";
  static const String _isLoggedInKey = "is_logged_in";
  static const String _roleKey = "user_role";
  static const String _tempRoleKey = "temp_selected_role";
  static const String _workerCityKey = "worker_selected_city";

  // Online/offline status persistence key
  static const String _isOnlineKey = "user_online_status";

  static const String _languageKey = "app_selected_language";

  static String normalizeRole(String rawRole) {
    final r = rawRole.trim().toLowerCase();
    if (r == "client" || r == "job") return "job";
    if (r == "worker" || r == "work") return "work";
    print("🟡 UNKNOWN ROLE VALUE RECEIVED: $rawRole -> defaulting to 'work'");
    return "work";
  }

  static String mapLocalRoleToBackend(String localRole) {
    return localRole == "job" ? "client" : "worker";
  }

  // ==========================================================
  // SAVE USER
  // ==========================================================
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final oldUser = getUser() ?? {};

    final oldId = oldUser['id']?.toString();
    final newId = userData['id']?.toString();

    Map<String, dynamic> baseUser = oldUser;
    if (oldId != null &&
        oldId.isNotEmpty &&
        newId != null &&
        newId.isNotEmpty &&
        oldId != newId) {
      print(
          "🟠 [SessionManager] DIFFERENT ACCOUNT DETECTED (old id=$oldId, new id=$newId) -> discarding stale cached user before save");
      baseUser = {};

      await _box.remove(_isOnlineKey);
      print("🟠 [SessionManager] Also cleared stale online-status for previous account");
    }

    final mergedUser = {...baseUser, ...userData};

    if ((mergedUser["username"] == null ||
        mergedUser["username"].toString().isEmpty) &&
        mergedUser["fullname"] != null) {
      mergedUser["username"] = mergedUser["fullname"];
    }

    if ((mergedUser["profile_pic"] == null ||
        mergedUser["profile_pic"].toString().isEmpty) &&
        mergedUser["profile_image"] != null) {
      mergedUser["profile_pic"] = mergedUser["profile_image"];
    }

    await _box.write(_userKey, jsonEncode(mergedUser));
    await _box.write(_isLoggedInKey, true);

    print("✅ SESSION SAVED : $mergedUser");
  }

  static Map<String, dynamic>? getUser() {
    final data = _box.read(_userKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static int? getUserId() {
    final user = getUser();
    if (user != null && user.containsKey('id')) {
      return user['id'] is int
          ? user['id']
          : int.tryParse(user['id'].toString());
    }
    return null;
  }

  /// ==========================================================
  /// GET AUTH TOKEN (Added for ApiService authorization header)
  /// ==========================================================
  static String? getToken() {
    final user = getUser();
    if (user != null) {
      // Common token keys used in backends
      return user['token']?.toString() ??
          user['access_token']?.toString() ??
          user['bearer_token']?.toString();
    }
    return null;
  }

  static bool isLoggedIn() {
    return _box.read(_isLoggedInKey) ?? false;
  }

  // ==========================================================
  // TEMP ROLE
  // ==========================================================
  static Future<void> saveTempRole(String role) async {
    await _box.write(_tempRoleKey, role);
    print("📝 TEMP ROLE SAVED : $role");
  }

  static String? getTempRole() {
    return _box.read(_tempRoleKey);
  }

  // ==========================================================
  // FINAL ROLE
  // ==========================================================
  static Future<void> saveRole(String role) async {
    final normalized = normalizeRole(role);
    await _box.write(_roleKey, normalized);
    print("✅ FINAL ROLE SAVED : $normalized");
  }

  static String? getRole() {
    return _box.read(_roleKey);
  }

  // ==========================================================
  // UPDATE ROLE PERMANENTLY
  // ==========================================================
  static Future<void> updateRolePermanently(
      String newRole,
      Map<String, dynamic> updatedUserData,
      ) async {
    final normalized = normalizeRole(newRole);
    final oldUser = getUser() ?? {};
    final mergedUser = {...oldUser, ...updatedUserData};

    if ((mergedUser["username"] == null ||
        mergedUser["username"].toString().isEmpty) &&
        mergedUser["fullname"] != null) {
      mergedUser["username"] = mergedUser["fullname"];
    }

    if ((mergedUser["profile_pic"] == null ||
        mergedUser["profile_pic"].toString().isEmpty) &&
        mergedUser["profile_image"] != null) {
      mergedUser["profile_pic"] = mergedUser["profile_image"];
    }

    await _box.write(_roleKey, normalized);
    await _box.write(_userKey, jsonEncode(mergedUser));

    print("🔄 ROLE UPDATED PERMANENTLY TO : $normalized");
    print("✅ USER DATA UPDATED : $mergedUser");
  }

  // ==========================================================
  // WORKER CITY
  // ==========================================================
  static Future<void> saveWorkerCity(String city) async {
    await _box.write(_workerCityKey, city);
    print("🏙️ WORKER CITY SAVED : $city");
  }

  static String? getWorkerCity() {
    return _box.read(_workerCityKey);
  }

  static Future<void> clearWorkerCity() async {
    await _box.remove(_workerCityKey);
    print("🏙️ WORKER CITY CLEARED");
  }

  // ==========================================================
  // ONLINE / OFFLINE STATUS
  // ==========================================================
  static Future<void> saveOnlineStatus(bool isOnline) async {
    await _box.write(_isOnlineKey, isOnline);
    print("🟢 ONLINE STATUS SAVED : ${isOnline ? 'ONLINE' : 'OFFLINE'}");
  }

  static bool getOnlineStatus() {
    final value = _box.read(_isOnlineKey);

    if (value is bool) return value;
    if (value is int) return value == 1;

    final normalized = value?.toString().trim().toLowerCase();

    return normalized == '1' ||
        normalized == 'true' ||
        normalized == 'online';
  }
  static bool hasSavedOnlineStatus() {
    return _box.hasData(_isOnlineKey);
  }

  // ==========================================================
  // APP LANGUAGE
  // ==========================================================
  static Future<void> saveLanguage(String languageLabel) async {
    await _box.write(_languageKey, languageLabel);
    print("🌐 LANGUAGE SAVED : $languageLabel");
  }

  static String getLanguage() {
    return _box.read(_languageKey) ?? "English";
  }
  static const String _isDarkModeKey = "app_is_dark_mode";

  static Future<void> saveThemeMode(bool isDarkMode) async {
    await _box.write(_isDarkModeKey, isDarkMode);
    print("🎨 THEME SAVED : ${isDarkMode ? 'DARK' : 'LIGHT'}");
  }

  static bool getThemeMode() {
    return _box.read(_isDarkModeKey) ?? false;
  }

  // ==========================================================
  // CLEAR SESSION
  // ==========================================================
  static Future<void> clearSession() async {
    await _box.remove(_userKey);
    await _box.remove(_roleKey);
    await _box.remove(_tempRoleKey);
    await _box.remove(_isOnlineKey);

    await _box.write(_isLoggedInKey, false);

    print("🚪 SESSION CLEARED");
  }
}
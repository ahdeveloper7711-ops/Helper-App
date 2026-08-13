// TODO: apne project ke actual path ke hisaab se ye 2 imports adjust karlein

import 'package:get/get.dart';
import 'package:helper_app2/Core/Apis/sessionmanager.dart';

import 'auth_api.dart';

/// PROFILE SERVICE (SHARED - Client aur Worker dono sides isi ko use karte hain)
/// Client profile se related sari APIs (view / update) isi file mein hongi.
/// ApiService (generic post/get) ko yahan reuse kiya gaya hai, taa ka
/// koi bhi naya endpoint add karna ho tu sirf ek method add karna paray.
class ProfileService {
  static const String _viewEndpoint = "/user/profile/view";
  static const String _updateEndpoint = "/user/profile/update";

  /// -------------------- GET PROFILE --------------------
  /// SessionManager se saved user ki id nikal ker view API ko call karta hai.
  static Future<Map<String, dynamic>> viewProfile() async {
    final savedUser = SessionManager.getUser();
    final userId = savedUser != null ? savedUser["id"] : null;

    if (userId == null) {
      return {"error": 'profile_error_session_not_found'.tr};
    }

    final result = await ApiService.postRequest(
      endpoint: _viewEndpoint,
      body: {"user_id": userId},
    );

    return result;
  }

  /// -------------------- UPDATE PROFILE --------------------
  /// username, phone, (agar select ki gayi ho tu) profile_pic base64,
  /// aur (agar worker side se aaya ho tu) skills bhej ker profile
  /// update karta hai.
  ///
  /// [skills] ka matlab:
  /// - null   -> body mein bhejo hi nahi (backend mein jo pehle se hain
  ///             wahi skills rahengi, koi change nahi)
  /// - []     -> khali list bhejo -> skills PERMANENTLY clear ho jayengi.
  ///             Ye tab use hota hai jab worker apna role client mein
  ///             switch karta hai (client profile mein skills hoti hi nahi)
  /// - [..]   -> naye skills set ho jayenge (worker edit profile screen se)
  static Future<Map<String, dynamic>> updateProfile({
    required String username,
    required String phone,
    String? profilePicBase64,
    List<String>? skills,
  }) async {
    final savedUser = SessionManager.getUser();
    final userId = savedUser != null ? savedUser["id"] : null;

    if (userId == null) {
      return {"error": 'profile_error_session_not_found'.tr};
    }

    final Map<String, dynamic> body = {
      "user_id": userId,
      "username": username,
      "phone": phone,
    };

    // Profile pic sirf tab bhejo jab user na naya image select kiya ho,
    // warna purani wali server side hi rahay gi.
    if (profilePicBase64 != null && profilePicBase64.isNotEmpty) {
      body["profile_pic"] = profilePicBase64;
    }

    // Skills sirf tab bhejo jab explicitly pass ki gayi hon (null nahi).
    if (skills != null) {
      body["skills"] = skills;
    }

    final result = await ApiService.postRequest(
      endpoint: _updateEndpoint,
      body: body,
    );

    return result;
  }
}
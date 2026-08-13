import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'sessionmanager.dart'; // Ensure correct path to your SessionManager

/// GENERIC API SERVICE
/// Sab APIs isi service sa call hongi taa ka code clean or reusable rahay
class ApiService {
  static const String baseUrl = "https://helpr.digital/api";

  static Future<Map<String, dynamic>> postRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");

    print("➡️ API CALL      : $url");
    print("➡️ REQUEST BODY  : $body");

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (requiresAuth) {
      final token = SessionManager.getToken(); // Assuming token getter exists
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    try {
      final response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(const Duration(seconds: 20));

      print("⬅️ STATUS CODE   : ${response.statusCode}");
      print("⬅️ RESPONSE BODY : ${response.body}");

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {"message": "api_error_invalid_response".tr};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"statusCode": response.statusCode, "data": decoded};
      } else {
        // Agar backend se koi message aa raha hai to wo display hoga,
        // warna fallback error message .tr format mein use hoga.
        final backendMsg = (decoded is Map && decoded['message'] != null)
            ? decoded['message'].toString()
            : null;

        final fallbackMsg = "${'api_error_something_wrong'.tr} (${response.statusCode})";

        return {
          "statusCode": response.statusCode,
          "data": decoded,
          "error": backendMsg ?? fallbackMsg,
        };
      }
    } catch (e) {
      print("❌ API EXCEPTION : $e");
      return {
        "statusCode": 0,
        "error": "api_error_no_connection".tr,
      };
    }
  }

  static Future<Map<String, dynamic>> getRequest({
    required String endpoint,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");

    print("➡️ GET API CALL  : $url");

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (requiresAuth) {
      final token = SessionManager.getToken();
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    try {
      final response = await http
          .get(
        url,
        headers: headers,
      )
          .timeout(const Duration(seconds: 20));

      print("⬅️ STATUS CODE   : ${response.statusCode}");
      print("⬅️ RESPONSE BODY : ${response.body}");

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = {"message": "api_error_invalid_response".tr};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"statusCode": response.statusCode, "data": decoded};
      } else {
        final backendMsg = (decoded is Map && decoded['message'] != null)
            ? decoded['message'].toString()
            : null;

        final fallbackMsg = "${'api_error_something_wrong'.tr} (${response.statusCode})";

        return {
          "statusCode": response.statusCode,
          "data": decoded,
          "error": backendMsg ?? fallbackMsg,
        };
      }
    } catch (e) {
      print("❌ API EXCEPTION : $e");
      return {
        "statusCode": 0,
        "error": "api_error_no_connection".tr,
      };
    }
  }
}
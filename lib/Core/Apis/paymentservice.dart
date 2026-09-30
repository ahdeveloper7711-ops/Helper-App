import 'dart:convert';
import 'dart:developer' as developer;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:helper_app2/Core/Apis/sessionmanager.dart';

class PaymentApiConfig {
  static const String baseUrl = "https://helpr.digital/api";
  static const String workerTopUpEndpoint = "$baseUrl/worker/wallet/topup";
  static const String estimateFeeEndpoint = "$baseUrl/jobs/estimate-fee";
}

class TopUpResult {
  final bool success;
  final String message;
  final double? newBalance;

  TopUpResult({
    required this.success,
    required this.message,
    this.newBalance,
  });
}

class EstimateFeeResult {
  final bool success;
  final String message;
  final String? clientFee;
  final bool isFeeEnabled;
  final String? totalToPay;

  EstimateFeeResult({
    required this.success,
    required this.message,
    this.clientFee,
    this.isFeeEnabled = false,
    this.totalToPay,
  });
}

class PaymentService {
  static const String _tag = "PaymentService";
  static const Duration _timeout = Duration(seconds: 20);

  static Future<int> _getUserId() async {
    try {
      final id = await SessionManager.getUserId();
      return int.tryParse('${id ?? ''}') ?? 0;
    } catch (e) {
      developer.log("⚠️ [$_tag] Could not resolve user_id: $e", name: _tag);
      return 0;
    }
  }

  /// ============================================================
  /// WORKER TOP-UP
  /// POST /api/worker/wallet/topup
  /// Body: { "worker_id": int, "amount": double, "payment_method": "card" }
  /// ============================================================
  static Future<TopUpResult> workerTopUp({
    required double amount,
    String paymentMethod = "card",
  }) async {
    try {
      final workerId = await _getUserId();
      if (workerId == 0) {
        return TopUpResult(
          success: false,
          message: 'wallet_error_not_logged_in'.tr,
        );
      }

      if (amount <= 0) {
        return TopUpResult(
          success: false,
          message: 'wallet_error_invalid_amount'.tr,
        );
      }

      final body = {
        "worker_id": workerId,
        "amount": amount,
        "payment_method": paymentMethod.toLowerCase(),
      };

      developer.log("📡 [$_tag] WORKER TOP-UP -> ${PaymentApiConfig.workerTopUpEndpoint}", name: _tag);
      developer.log("📤 [$_tag] Body: $body", name: _tag);

      final response = await http
          .post(
        Uri.parse(PaymentApiConfig.workerTopUpEndpoint),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      developer.log("📥 [$_tag] Status: ${response.statusCode}", name: _tag);
      developer.log("📥 [$_tag] Body: ${response.body}", name: _tag);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      final success = data['success'] == true;

      double? newBalance;
      if (data['new_balance'] != null) {
        newBalance = double.tryParse('${data['new_balance']}');
      } else if (data['wallet_balance'] != null) {
        newBalance = double.tryParse('${data['wallet_balance']}');
      } else if (data['balance'] != null) {
        newBalance = double.tryParse('${data['balance']}');
      }

      return TopUpResult(
        success: success,
        message: data['message']?.toString() ??
            (success
                ? 'wallet_topup_success'.tr
                : 'wallet_topup_failed'.tr),
        newBalance: newBalance,
      );
    } catch (e, st) {
      developer.log("❌ [$_tag] workerTopUp EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return TopUpResult(
        success: false,
        message: 'wallet_error_something_went_wrong'.tr,
      );
    }
  }

  /// ============================================================
  /// ESTIMATE FEE (Client) — future use ke liye ready
  /// POST /api/jobs/estimate-fee
  /// Body: { "client_id": int, "amount": double }
  /// ============================================================
  static Future<EstimateFeeResult> estimateFee({required double amount}) async {
    try {
      final clientId = await _getUserId();
      if (clientId == 0) {
        return EstimateFeeResult(
          success: false,
          message: 'wallet_error_not_logged_in'.tr,
        );
      }

      final body = {
        "client_id": clientId,
        "amount": amount,
      };

      developer.log("📡 [$_tag] ESTIMATE FEE -> ${PaymentApiConfig.estimateFeeEndpoint}", name: _tag);
      developer.log("📤 [$_tag] Body: $body", name: _tag);

      final response = await http
          .post(
        Uri.parse(PaymentApiConfig.estimateFeeEndpoint),
        headers: const {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(body),
      )
          .timeout(_timeout);

      developer.log("📥 [$_tag] Status: ${response.statusCode}", name: _tag);
      developer.log("📥 [$_tag] Body: ${response.body}", name: _tag);

      Map<String, dynamic> data = {};
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      final success = data['success'] == true;

      return EstimateFeeResult(
        success: success,
        message: data['message']?.toString() ??
            (success ? 'estimate_fee_success'.tr : 'estimate_fee_failed'.tr),
        clientFee: data['client_fee']?.toString(),
        isFeeEnabled: data['is_fee_enabled'] == true || data['is_fee_enabled'] == 1,
        totalToPay: data['total_to_pay']?.toString(),
      );
    } catch (e, st) {
      developer.log("❌ [$_tag] estimateFee EXCEPTION: $e", name: _tag, error: e, stackTrace: st);
      return EstimateFeeResult(
        success: false,
        message: 'wallet_error_something_went_wrong'.tr,
      );
    }
  }
}
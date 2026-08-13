import 'package:flutter/material.dart';
class WorkerJobHistoryRepository {
  static Color statusToColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case "COMPLETED":
        return theme.primaryColor;
      case "APPLIED":
        return Colors.blue.shade400;
      case "ACTIVE":
      case "POSTED":
      case "CHAT_ENABLED":
        return theme.canvasColor.withOpacity(0.6);
      case "CANCELLED":
        return Colors.red.shade400;
      case "DISPUTED":
        return Colors.orange.shade700;
      default:
        return theme.canvasColor.withOpacity(0.6);
    }
  }
}
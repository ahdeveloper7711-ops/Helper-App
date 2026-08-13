/// ============================================================
/// SHARED RESULT WRAPPER — cancel / complete / confirm APIs
/// (client aur worker dono services isay use karti hain, taake
/// "JobActionResult" naam do jagah duplicate/ambiguous na ho)
/// ============================================================
class JobActionResult {
  final bool success;
  final String message;

  JobActionResult({required this.success, required this.message});
}
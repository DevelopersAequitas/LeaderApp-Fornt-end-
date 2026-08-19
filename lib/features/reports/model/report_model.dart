/// Model representing a leadership report submission.
class ReportModel {
  final String type; // "Weekly" or "Monthly"
  final String status; // "Submitted" or "Actioned"
  final String date; // E.g., "Jul 1, 2026"
  final String content;
  final String author;

  const ReportModel({
    required this.type,
    required this.status,
    required this.date,
    required this.content,
    required this.author,
  });
}

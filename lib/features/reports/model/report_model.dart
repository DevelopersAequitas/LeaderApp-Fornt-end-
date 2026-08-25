/// Model representing coordinates for attendance & performance spline charts.
class ReportsChartPoint {
  final String month;
  final double value;

  const ReportsChartPoint({required this.month, required this.value});

  factory ReportsChartPoint.fromJson(Map<String, dynamic> json) {
    return ReportsChartPoint(
      month: json['month']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'value': value,
      };
}

/// Model representing a leadership report submission.
class ReportModel {
  final String id;
  final String type; // "Weekly" or "Monthly"
  final String status; // "Submitted", "Approved", "Actioned"
  final String date; // E.g., "Jul 1, 2026"
  final String content;
  final String author;
  final int? attendancePercentage;
  final String? dealsClosedValue;

  const ReportModel({
    this.id = '',
    required this.type,
    required this.status,
    required this.date,
    required this.content,
    required this.author,
    this.attendancePercentage,
    this.dealsClosedValue,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id']?.toString() ?? '',
      type: json['report_type'] as String? ?? json['type'] as String? ?? 'Monthly',
      status: json['status'] as String? ?? 'Approved',
      date: json['period'] as String? ?? json['submitted_at'] as String? ?? json['date'] as String? ?? '',
      content: json['summary_text'] as String? ?? json['content'] as String? ?? '',
      author: json['submitted_by'] as String? ?? json['author'] as String? ?? '',
      attendancePercentage: (json['attendance_percentage'] as num?)?.round(),
      dealsClosedValue: json['deals_closed_value']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'status': status,
        'date': date,
        'content': content,
        'author': author,
        'attendance_percentage': attendancePercentage,
        'deals_closed_value': dealsClosedValue,
      };
}

/// Model representing a dynamic generated download URL for reports.
class ReportDownloadModel {
  final String reportId;
  final String fileName;
  final String fileFormat;
  final String fileSize;
  final String downloadUrl;
  final int expiresInSeconds;

  const ReportDownloadModel({
    required this.reportId,
    required this.fileName,
    required this.fileFormat,
    required this.fileSize,
    required this.downloadUrl,
    required this.expiresInSeconds,
  });

  factory ReportDownloadModel.fromJson(Map<String, dynamic> json) {
    return ReportDownloadModel(
      reportId: json['report_id']?.toString() ?? json['id']?.toString() ?? '',
      fileName: json['file_name'] as String? ?? 'Report.pdf',
      fileFormat: json['file_format'] as String? ?? 'PDF',
      fileSize: json['file_size'] as String? ?? '',
      downloadUrl: json['download_url'] as String? ?? '',
      expiresInSeconds: json['expires_in_seconds'] as int? ?? 3600,
    );
  }

  Map<String, dynamic> toJson() => {
        'report_id': reportId,
        'file_name': fileName,
        'file_format': fileFormat,
        'file_size': fileSize,
        'download_url': downloadUrl,
        'expires_in_seconds': expiresInSeconds,
      };
}

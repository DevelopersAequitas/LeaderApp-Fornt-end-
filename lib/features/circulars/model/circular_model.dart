/// Model representing an official administrative circular/announcement targeted to specific roles.
class CircularModel {
  final String id;
  final String title;
  final String content;
  final List<String> targetRoles;
  final String priority; // 'Urgent', 'Important', 'General'
  final String publishedAt;
  final String authorName;
  final String authorRole;
  final String? attachmentUrl;
  final bool isRead;

  const CircularModel({
    required this.id,
    required this.title,
    required this.content,
    required this.targetRoles,
    this.priority = 'General',
    required this.publishedAt,
    required this.authorName,
    required this.authorRole,
    this.attachmentUrl,
    this.isRead = false,
  });

  factory CircularModel.fromJson(Map<String, dynamic> json) {
    final roles = <String>[];
    if (json['target_roles'] is List) {
      for (final r in json['target_roles']) {
        roles.add(r.toString());
      }
    } else if (json['target_roles'] is String) {
      roles.add(json['target_roles'] as String);
    }

    return CircularModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Official Circular',
      content: json['content'] as String? ?? '',
      targetRoles: roles.isNotEmpty ? roles : const ['all'],
      priority: json['priority'] as String? ?? 'General',
      publishedAt: json['published_at'] as String? ?? json['date'] as String? ?? 'Today',
      authorName: json['author_name'] as String? ?? json['created_by'] as String? ?? 'National Directorate',
      authorRole: json['author_role'] as String? ?? 'Super Admin',
      attachmentUrl: json['attachment_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'target_roles': targetRoles,
        'priority': priority,
        'published_at': publishedAt,
        'author_name': authorName,
        'author_role': authorRole,
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
        'is_read': isRead,
      };

  CircularModel copyWith({
    String? id,
    String? title,
    String? content,
    List<String>? targetRoles,
    String? priority,
    String? publishedAt,
    String? authorName,
    String? authorRole,
    String? attachmentUrl,
    bool? isRead,
  }) {
    return CircularModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      targetRoles: targetRoles ?? this.targetRoles,
      priority: priority ?? this.priority,
      publishedAt: publishedAt ?? this.publishedAt,
      authorName: authorName ?? this.authorName,
      authorRole: authorRole ?? this.authorRole,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isRead: isRead ?? this.isRead,
    );
  }
}

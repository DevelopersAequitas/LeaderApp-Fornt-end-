enum NotificationType {
  referral,
  deal,
  alert,
  meeting,
  report,
}

class NotificationModel {
  final String id;
  final String title;
  final NotificationType type;
  final String description;
  final String time;
  final bool isUnread;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.time,
    required this.isUnread,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final cat = (json['category'] ?? json['type'] ?? 'alert').toString().toLowerCase();
    NotificationType notifType = NotificationType.alert;
    if (cat.contains('referral')) {
      notifType = NotificationType.referral;
    } else if (cat.contains('deal') || cat.contains('transaction') || cat.contains('finance')) {
      notifType = NotificationType.deal;
    } else if (cat.contains('meeting') || cat.contains('event')) {
      notifType = NotificationType.meeting;
    } else if (cat.contains('report') || cat.contains('analytics')) {
      notifType = NotificationType.report;
    } else {
      notifType = NotificationType.alert;
    }

    final isUnread = json['is_unread'] as bool? ??
        (json['is_read'] != null ? !(json['is_read'] as bool) : (json['read_at'] == null));

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Notification',
      type: notifType,
      description: json['body'] as String? ?? json['message'] as String? ?? json['description'] as String? ?? '',
      time: json['created_at_human'] as String? ??
          json['created_at'] as String? ??
          json['time'] as String? ??
          'Recent',
      isUnread: isUnread,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': type.name,
        'message': description,
        'created_at': time,
        'is_unread': isUnread,
      };

  NotificationModel copyWith({
    String? id,
    String? title,
    NotificationType? type,
    String? description,
    String? time,
    bool? isUnread,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      time: time ?? this.time,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

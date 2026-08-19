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

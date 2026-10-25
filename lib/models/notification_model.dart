class NotificationModel {
  final String id;
  final String message;
  final String time;
  final bool isRead;
  final String? type;
  final String? icon;

  NotificationModel({
    required this.id,
    required this.message,
    required this.time,
    required this.isRead,
    this.type,
    this.icon,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      message: json['text'] ?? json['message'] ?? 'Notification',
      time: json['time'] ?? json['created_at'] ?? 'Just now',
      isRead: json['read'] == true || json['is_read'] == true,
      type: json['type'] ?? 'info',
      icon: json['icon'] ?? '📌',
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      message: message,
      time: time,
      isRead: isRead ?? this.isRead,
      type: type,
      icon: icon,
    );
  }
}

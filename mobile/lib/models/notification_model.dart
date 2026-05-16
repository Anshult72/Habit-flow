class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      metadata: json['metadata'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'message': message,
        'metadata': metadata,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };
}

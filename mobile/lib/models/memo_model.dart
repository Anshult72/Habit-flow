class MemoModel {
  final String id;
  final String title;
  final String content;
  final String? category;
  final String? priority;
  final String color;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  MemoModel({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    this.priority,
    required this.color,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemoModel.fromJson(Map<String, dynamic> json) {
    return MemoModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
      priority: json['priority'],
      color: json['color'] ?? '#FF6B2C',
      isPinned: json['isPinned'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'priority': priority,
      'color': color,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

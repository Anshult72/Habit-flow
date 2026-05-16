class MissionModel {
  final String id;
  final String title;
  final String? desc;
  final String? category;
  final DateTime? targetDate;
  final String priority;
  final String? motivationQuote;
  final DateTime createdAt;
  final DateTime updatedAt;

  MissionModel({
    required this.id,
    required this.title,
    this.desc,
    this.category,
    this.targetDate,
    required this.priority,
    this.motivationQuote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'],
      title: json['title'],
      desc: json['desc'],
      category: json['category'],
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      priority: json['priority'] ?? 'Medium',
      motivationQuote: json['motivationQuote'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'category': category,
      'targetDate': targetDate?.toIso8601String(),
      'priority': priority,
      'motivationQuote': motivationQuote,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MissionModel copyWith({
    String? id,
    String? title,
    String? desc,
    String? category,
    DateTime? targetDate,
    String? priority,
    String? motivationQuote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MissionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      priority: priority ?? this.priority,
      motivationQuote: motivationQuote ?? this.motivationQuote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

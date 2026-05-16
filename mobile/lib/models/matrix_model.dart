class MatrixModel {
  final String id;
  final String title;
  final String desc;
  final int quadrant;
  final bool completed;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  MatrixModel({
    required this.id,
    required this.title,
    this.desc = '',
    this.quadrant = 1,
    this.completed = false,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatrixModel.fromJson(Map<String, dynamic> json) {
    return MatrixModel(
      id: json['id'],
      title: json['title'],
      desc: json['desc'] ?? '',
      quadrant: json['quadrant'] ?? 1,
      completed: json['completed'] ?? false,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'quadrant': quadrant,
      'completed': completed,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

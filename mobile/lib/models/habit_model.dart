class HabitModel {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final String color;
  final String icon;
  final String frequency;
  final String difficulty;
  final int goal;
  final List<HabitCompletionModel> completions;

  HabitModel({
    required this.id,
    required this.title,
    this.description,
    this.category,
    required this.color,
    required this.icon,
    required this.frequency,
    required this.difficulty,
    required this.goal,
    required this.completions,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      color: json['color'] ?? '#FF6B2C',
      icon: json['icon'] ?? 'Zap',
      frequency: json['frequency'] ?? 'Daily',
      difficulty: json['difficulty'] ?? 'Medium',
      goal: json['goal'] ?? 30,
      completions: (json['completions'] as List? ?? [])
          .map((e) => HabitCompletionModel.fromJson(e))
          .toList(),
    );
  }
}

class HabitCompletionModel {
  final String id;
  final String date;
  final bool completed;

  HabitCompletionModel({
    required this.id,
    required this.date,
    required this.completed,
  });

  factory HabitCompletionModel.fromJson(Map<String, dynamic> json) {
    return HabitCompletionModel(
      id: json['id'],
      date: json['date'],
      completed: json['completed'] ?? true,
    );
  }
}

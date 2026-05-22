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
  /// Whether this habit currently earns XP (computed by backend eligibility rules).
  /// Nullable so hot-reload stale instances and absent JSON keys are both safe.
  final bool? isXpEligible;
  /// XP awarded per completion. Null when not yet computed.
  final int? xpValue;

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
    this.isXpEligible,      // null means "assume eligible" — treated as true in UI
    this.xpValue,           // null means "use complexity default" — computed in UI
  });

  bool get isCompleted {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return completions.any((c) => c.date == today && c.completed);
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? color,
    String? icon,
    String? frequency,
    String? difficulty,
    int? goal,
    List<HabitCompletionModel>? completions,
    bool? isCompleted, // Added to support manual toggle if needed in notifier
    bool? isXpEligible,
    int? xpValue,
  }) {
    // If isCompleted is passed, we update today's completion
    List<HabitCompletionModel> updatedCompletions = completions ?? this.completions;
    if (isCompleted != null) {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final index = updatedCompletions.indexWhere((c) => c.date == today);
      if (index != -1) {
        updatedCompletions = List.from(updatedCompletions);
        updatedCompletions[index] = HabitCompletionModel(
          id: updatedCompletions[index].id,
          date: today,
          completed: isCompleted,
        );
      } else {
        updatedCompletions = [
          ...updatedCompletions,
          HabitCompletionModel(id: 'temp_${DateTime.now().millisecondsSinceEpoch}', date: today, completed: isCompleted),
        ];
      }
    }

    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      frequency: frequency ?? this.frequency,
      difficulty: difficulty ?? this.difficulty,
      goal: goal ?? this.goal,
      completions: updatedCompletions,
      isXpEligible: isXpEligible ?? this.isXpEligible,
      xpValue: xpValue ?? this.xpValue,
    );
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      color: json['color'] ?? '#FF6B2C',
      icon: json['icon'] ?? 'Zap',
      frequency: json['frequency'] ?? 'Daily',
      difficulty: json['difficulty'] ?? 'Standard',
      goal: json['goal'] ?? 30,
      completions: (json['completions'] as List? ?? [])
          .map((e) => HabitCompletionModel.fromJson(e))
          .toList(),
      // '!= false' safely handles null (absent key) → true (eligible by default)
      isXpEligible: json['isXpEligible'] != false ? true : false,
      xpValue: (json['xpValue'] is int) ? (json['xpValue'] as int) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'color': color,
      'icon': icon,
      'frequency': frequency,
      'difficulty': difficulty,
      'goal': goal,
      'completions': completions.map((e) => e.toJson()).toList(),
      'isXpEligible': isXpEligible,
      'xpValue': xpValue,
    };
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
      // Safe bool parsing: json['completed'] is dynamic; guard against null/int
      // values that could sneak through from cached data or unexpected formats.
      completed: json['completed'] is bool ? json['completed'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'completed': completed,
    };
  }
}

class PlannerDayModel {
  final String id;
  final String date;
  final List<PlannerSlotModel> slots;

  PlannerDayModel({
    required this.id,
    required this.date,
    required this.slots,
  });

  factory PlannerDayModel.fromJson(Map<String, dynamic> json) {
    return PlannerDayModel(
      id: json['id'],
      date: json['date'],
      slots: (json['slots'] as List).map((e) => PlannerSlotModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'slots': slots.map((s) => s.toJson()).toList(),
      };
}

class PlannerSlotModel {
  final String id;
  final String timeRange;
  final List<PlannerTaskModel> tasks;

  PlannerSlotModel({
    required this.id,
    required this.timeRange,
    required this.tasks,
  });

  factory PlannerSlotModel.fromJson(Map<String, dynamic> json) {
    return PlannerSlotModel(
      id: json['id'],
      timeRange: json['timeRange'],
      tasks: (json['tasks'] as List).map((e) => PlannerTaskModel.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timeRange': timeRange,
        'tasks': tasks.map((t) => t.toJson()).toList(),
      };
}

class PlannerTaskModel {
  final String id;
  final String title;
  final bool completed;
  final int order;

  PlannerTaskModel({
    required this.id,
    required this.title,
    required this.completed,
    required this.order,
  });

  factory PlannerTaskModel.fromJson(Map<String, dynamic> json) {
    return PlannerTaskModel(
      id: json['id'],
      title: json['title'],
      completed: json['completed'] ?? false,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
        'order': order,
      };
}

class SubjectModel {
  final String id;
  final String title;
  final String? category;
  final int progress;
  final List<ChapterModel>? chapters;
  final SubjectCount? count;

  SubjectModel({
    required this.id,
    required this.title,
    this.category,
    required this.progress,
    this.chapters,
    this.count,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      progress: json['progress'] ?? 0,
      chapters: json['chapters'] != null
          ? (json['chapters'] as List).map((e) => ChapterModel.fromJson(e)).toList()
          : null,
      count: json['_count'] != null ? SubjectCount.fromJson(json['_count']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'progress': progress,
        if (chapters != null) 'chapters': chapters!.map((e) => e.toJson()).toList(),
        if (count != null) '_count': count!.toJson(),
      };
}

class SubjectCount {
  final int chapters;
  SubjectCount({required this.chapters});
  factory SubjectCount.fromJson(Map<String, dynamic> json) => SubjectCount(chapters: json['chapters'] ?? 0);
  Map<String, dynamic> toJson() => {'chapters': chapters};
}

class ChapterModel {
  final String id;
  final String title;
  final String status;
  final int progress;
  final String? notes;
  final List<TopicModel>? topics;

  ChapterModel({
    required this.id,
    required this.title,
    required this.status,
    required this.progress,
    this.notes,
    this.topics,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'],
      title: json['title'],
      status: json['status'] ?? 'Not Started',
      progress: json['progress'] ?? 0,
      notes: json['notes'],
      topics: json['topics'] != null
          ? (json['topics'] as List).map((e) => TopicModel.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
        'progress': progress,
        'notes': notes,
        if (topics != null) 'topics': topics!.map((e) => e.toJson()).toList(),
      };
}

class TopicModel {
  final String id;
  final String title;
  final String status;

  TopicModel({
    required this.id,
    required this.title,
    required this.status,
  });

  bool get completed => status == 'Completed';

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      title: json['title'],
      status: json['status'] ?? 'Not Started',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
      };
}

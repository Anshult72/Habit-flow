class SubjectModel {
  final String id;
  final String title;
  final String? category;
  final int progress;
  final List<ChapterModel>? chapters;
  final SubjectCount? count;
  
  // Progression tracking fields
  final int streakCount;
  final String? lastStreakDate;
  final Map<String, int> completedTopicsLog;
  final Map<String, bool> xpAwardedTopics;
  final Map<String, bool> moduleCompletionBonusAwarded;
  final Map<String, bool> chapterCompletionBonusAwarded;
  final int xpEarned;
  final int? totalHours;
  final Map<String, bool>? _unlockedModules;
  Map<String, bool> get unlockedModules => _unlockedModules ?? const {};

  SubjectModel({
    required this.id,
    required this.title,
    this.category,
    required this.progress,
    this.chapters,
    this.count,
    this.streakCount = 0,
    this.lastStreakDate,
    this.completedTopicsLog = const {},
    this.xpAwardedTopics = const {},
    this.moduleCompletionBonusAwarded = const {},
    this.chapterCompletionBonusAwarded = const {},
    this.xpEarned = 0,
    this.totalHours = 0,
    Map<String, bool>? unlockedModules,
  }) : _unlockedModules = unlockedModules ?? const {};

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString(),
      progress: _safeInt(json['progress']),
      chapters: json['chapters'] != null
          ? (json['chapters'] as List)
              .map((e) => ChapterModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : null,
      count: json['_count'] != null
          ? SubjectCount.fromJson(Map<String, dynamic>.from(json['_count'] as Map))
          : null,
      streakCount: _safeInt(json['streakCount']),
      lastStreakDate: json['lastStreakDate']?.toString(),
      completedTopicsLog: _parseIntMap(json['completedTopicsLog']),
      xpAwardedTopics: _parseBoolMap(json['xpAwardedTopics']),
      moduleCompletionBonusAwarded: _parseBoolMap(json['moduleCompletionBonusAwarded']),
      chapterCompletionBonusAwarded: _parseBoolMap(json['chapterCompletionBonusAwarded']),
      xpEarned: _safeInt(json['xpEarned']),
      totalHours: _safeInt(json['totalHours']),
      unlockedModules: _parseBoolMap(json['unlockedModules']),
    );
  }

  /// Safely parse any dynamic value to int. Handles null, num, String, bool.
  static int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Map<String, int> _parseIntMap(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    return raw.map((k, v) => MapEntry(k.toString(), _safeInt(v)));
  }

  static Map<String, bool> _parseBoolMap(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    return raw.map<String, bool>((k, v) => MapEntry(k.toString(), v == true));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'progress': progress,
        if (chapters != null) 'chapters': chapters!.map((e) => e.toJson()).toList(),
        if (count != null) '_count': count!.toJson(),
        'streakCount': streakCount,
        'lastStreakDate': lastStreakDate,
        'completedTopicsLog': completedTopicsLog,
        'xpAwardedTopics': xpAwardedTopics,
        'moduleCompletionBonusAwarded': moduleCompletionBonusAwarded,
        'chapterCompletionBonusAwarded': chapterCompletionBonusAwarded,
        'xpEarned': xpEarned,
        'totalHours': totalHours,
        'unlockedModules': unlockedModules,
      };
}

class SubjectCount {
  final int chapters;
  SubjectCount({required this.chapters});
  factory SubjectCount.fromJson(Map<String, dynamic> json) => SubjectCount(chapters: SubjectModel._safeInt(json['chapters']));
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Not Started',
      progress: SubjectModel._safeInt(json['progress']),
      notes: json['notes']?.toString(),
      topics: json['topics'] != null
          ? (json['topics'] as List)
              .map((e) => TopicModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Not Started',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'status': status,
      };
}

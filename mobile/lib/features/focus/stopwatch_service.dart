import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/local_storage_service.dart';

class StopwatchSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? startedAt;
  final int accumulatedMs;
  final bool isRunning;
  final String? category;
  final String? notes;

  const StopwatchSession({
    required this.id,
    required this.title,
    required this.createdAt,
    this.startedAt,
    required this.accumulatedMs,
    required this.isRunning,
    this.category,
    this.notes,
  });

  int get currentElapsedMs {
    if (!isRunning || startedAt == null) return accumulatedMs;
    return accumulatedMs + DateTime.now().difference(startedAt!).inMilliseconds;
  }

  StopwatchSession copyWith({
    String? title,
    DateTime? startedAt,
    int? accumulatedMs,
    bool? isRunning,
    String? category,
    String? notes,
  }) {
    return StopwatchSession(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      accumulatedMs: accumulatedMs ?? this.accumulatedMs,
      isRunning: isRunning ?? this.isRunning,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'startedAt': startedAt?.toIso8601String(),
        'accumulatedMs': accumulatedMs,
        'isRunning': isRunning,
        'category': category,
        'notes': notes,
      };

  factory StopwatchSession.fromJson(Map<String, dynamic> json) => StopwatchSession(
        id: json['id'],
        title: json['title'],
        createdAt: DateTime.parse(json['createdAt']),
        startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt']) : null,
        accumulatedMs: json['accumulatedMs'] ?? 0,
        isRunning: json['isRunning'] ?? false,
        category: json['category'],
        notes: json['notes'],
      );
}

class StopwatchNotifier extends StateNotifier<List<StopwatchSession>> {
  final LocalStorageService _storage;
  static const _storageKey = 'stopwatch_sessions';

  StopwatchNotifier(this._storage) : super([]) {
    _loadSessions();
  }

  void _loadSessions() {
    final data = _storage.readData(_storageKey);
    if (data != null && data is List) {
      state = data.map((e) => StopwatchSession.fromJson(e)).toList();
    }
  }

  void _saveSessions() {
    final data = state.map((e) => e.toJson()).toList();
    _storage.saveData(_storageKey, data);
  }

  void createSession(String title, {String? category, String? notes}) {
    final session = StopwatchSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
      accumulatedMs: 0,
      isRunning: false,
      category: category,
      notes: notes,
    );
    state = [session, ...state];
    _saveSessions();
  }

  void startSession(String id) {
    state = state.map((s) {
      if (s.id == id && !s.isRunning) {
        return s.copyWith(isRunning: true, startedAt: DateTime.now());
      }
      return s;
    }).toList();
    _saveSessions();
  }

  void pauseSession(String id) {
    state = state.map((s) {
      if (s.id == id && s.isRunning) {
        final now = DateTime.now();
        final ms = now.difference(s.startedAt!).inMilliseconds;
        return s.copyWith(
          isRunning: false,
          accumulatedMs: s.accumulatedMs + ms,
          startedAt: null, // Clear startedAt on pause to avoid double counting
        );
      }
      return s;
    }).toList();
    _saveSessions();
  }

  void resetSession(String id) {
    state = state.map((s) {
      if (s.id == id) {
        return s.copyWith(isRunning: false, accumulatedMs: 0, startedAt: null);
      }
      return s;
    }).toList();
    _saveSessions();
  }

  void deleteSession(String id) {
    state = state.where((s) => s.id != id).toList();
    _saveSessions();
  }
}

final stopwatchProvider = StateNotifierProvider<StopwatchNotifier, List<StopwatchSession>>((ref) {
  final storage = ref.watch(localStorageProvider);
  return StopwatchNotifier(storage);
});

// ─── History System ────────────────────────────────────────────────────────

class FocusHistorySession {
  final String id;
  final String title;
  final String type; // 'stopwatch', 'pomodoro', 'timer'
  final DateTime completedAt;
  final int durationMs;
  final String? category;
  final String? notes;

  const FocusHistorySession({
    required this.id,
    required this.title,
    required this.type,
    required this.completedAt,
    required this.durationMs,
    this.category,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'completedAt': completedAt.toIso8601String(),
        'durationMs': durationMs,
        'category': category,
        'notes': notes,
      };

  factory FocusHistorySession.fromJson(Map<String, dynamic> json) => FocusHistorySession(
        id: json['id'],
        title: json['title'],
        type: json['type'] ?? 'stopwatch',
        completedAt: DateTime.parse(json['completedAt']),
        durationMs: json['durationMs'] ?? 0,
        category: json['category'],
        notes: json['notes'],
      );
}

class FocusHistoryNotifier extends StateNotifier<List<FocusHistorySession>> {
  final LocalStorageService _storage;
  static const _storageKey = 'focus_history';

  FocusHistoryNotifier(this._storage) : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    final data = _storage.readData(_storageKey);
    if (data != null && data is List) {
      state = data.map((e) => FocusHistorySession.fromJson(e)).toList();
    }
  }

  void _saveHistory() {
    final data = state.map((e) => e.toJson()).toList();
    _storage.saveData(_storageKey, data);
  }

  void addCompletedSession(StopwatchSession session) {
    final history = FocusHistorySession(
      id: session.id,
      title: session.title,
      type: 'stopwatch',
      completedAt: DateTime.now(),
      durationMs: session.currentElapsedMs,
      category: session.category,
      notes: session.notes,
    );
    state = [history, ...state];
    _saveHistory();
  }
}

final focusHistoryProvider = StateNotifierProvider<FocusHistoryNotifier, List<FocusHistorySession>>((ref) {
  final storage = ref.watch(localStorageProvider);
  return FocusHistoryNotifier(storage);
});

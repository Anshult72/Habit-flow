import 'package:dio/dio.dart';
import '../models/habit_model.dart';
import '../core/storage/local_storage_service.dart';
import '../core/sync/sync_manager.dart';

/// Offline-First Habit Service (Master Template)
class HabitService {
  final Dio _dio;
  final LocalStorageService _localStorage;
  final SyncManager _syncManager;

  static const String _cacheKey = 'habits_cache';

  HabitService(this._dio, this._localStorage, this._syncManager);

  /// Helper to get current cached habits
  List<HabitModel> _getCachedHabits() {
    final cachedData = _localStorage.readData(_cacheKey);
    if (cachedData != null) {
      return (cachedData as List).map((e) => HabitModel.fromJson(e)).toList();
    }
    return [];
  }

  /// Helper to save habits to cache
  Future<void> _saveToCache(List<HabitModel> habits) async {
    final jsonData = habits.map((h) => h.toJson()).toList();
    await _localStorage.saveData(_cacheKey, jsonData);
  }

  /// GET: Fetch all habits.
  /// Instantly returns local cache if available, then fetches from API and silently updates cache.
  Future<List<HabitModel>> getHabits() async {
    // 1. Immediately load from cache
    List<HabitModel> habits = _getCachedHabits();

    // 2. Fetch fresh data from API in background
    try {
      final response = await _dio.get('/habits');
      final serverHabits = (response.data as List).map((e) => HabitModel.fromJson(e)).toList();
      
      // 3. Save fresh data to local cache
      await _localStorage.saveData(_cacheKey, response.data);
      habits = serverHabits;
    } catch (e) {
      // If offline or error, we just rely on the cached habits
      if (habits.isEmpty) {
        rethrow;
      }
    }

    return habits;
  }

  /// POST: Create a new habit.
  Future<HabitModel> createHabit(Map<String, dynamic> data) async {
    // 1. Optimistically create a local version
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempHabit = HabitModel.fromJson({
      'id': tempId,
      ...data,
      'createdAt': DateTime.now().toIso8601String(),
      'completions': [],
    });

    // 2. Save immediately to local cache so it survives app restart offline
    final cachedHabits = _getCachedHabits();
    cachedHabits.add(tempHabit);
    await _saveToCache(cachedHabits);

    // 3. Queue the actual API call for background sync
    await _syncManager.enqueueAction('POST', '/habits', data: data);

    return tempHabit;
  }

  /// PATCH: Update an existing habit.
  Future<HabitModel> updateHabit(String id, Map<String, dynamic> data) async {
    // 1. Update local cache immediately
    final cachedHabits = _getCachedHabits();
    final index = cachedHabits.indexWhere((h) => h.id == id);
    
    HabitModel updatedHabit;
    if (index != -1) {
      final oldHabit = cachedHabits[index];
      updatedHabit = HabitModel.fromJson({
        ...oldHabit.toJson(),
        ...data,
      });
      cachedHabits[index] = updatedHabit;
      await _saveToCache(cachedHabits);
    } else {
      updatedHabit = HabitModel.fromJson({'id': id, ...data});
    }

    // 2. Queue the API call
    await _syncManager.enqueueAction('PATCH', '/habits/$id', data: data);
    
    return updatedHabit;
  }

  /// DELETE: Delete a habit.
  Future<void> deleteHabit(String id) async {
    // 1. Remove from local cache immediately
    final cachedHabits = _getCachedHabits();
    cachedHabits.removeWhere((h) => h.id == id);
    await _saveToCache(cachedHabits);

    // 2. Queue the API call
    // If it's a temp habit (created offline), the backend might 404, SyncManager will discard 404s.
    await _syncManager.enqueueAction('DELETE', '/habits/$id');
  }

  /// POST /toggle: Toggle completion for a date.
  Future<HabitModel> toggleHabit(String habitId, String date) async {
    // 1. Update local cache immediately
    final cachedHabits = _getCachedHabits();
    final index = cachedHabits.indexWhere((h) => h.id == habitId);
    
    HabitModel? updatedHabit;
    if (index != -1) {
      final habit = cachedHabits[index];
      final completions = List<HabitCompletionModel>.from(habit.completions);
      final completionIndex = completions.indexWhere((c) => c.date == date);
      
      if (completionIndex != -1) {
        completions[completionIndex] = HabitCompletionModel(
          id: completions[completionIndex].id,
          date: date,
          completed: !completions[completionIndex].completed,
        );
      } else {
        completions.add(HabitCompletionModel(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          date: date,
          completed: true,
        ));
      }
      
      updatedHabit = habit.copyWith(completions: completions);
      cachedHabits[index] = updatedHabit;
      await _saveToCache(cachedHabits);
    }

    // 2. Queue the API call
    await _syncManager.enqueueAction('POST', '/habits/$habitId/toggle', data: {'date': date});
    
    return updatedHabit ?? HabitModel(
      id: habitId,
      title: 'Syncing...',
      difficulty: 'Easy',
      frequency: 'daily',
      goal: 1,
      color: 'blue',
      icon: 'check',
      completions: [HabitCompletionModel(id: 'temp_${DateTime.now().millisecondsSinceEpoch}', date: date, completed: true)],
    );
  }
}

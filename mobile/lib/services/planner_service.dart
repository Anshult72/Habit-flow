import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/planner_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../core/sync/sync_manager.dart';

class PlannerService {
  final Dio _dio;
  final LocalStorageService _localStorage;
  final SyncManager _syncManager;

  PlannerService(this._dio, this._localStorage, this._syncManager);

  String _getCacheKey(String date) => 'planner_cache_$date';

  /// GET: Fetch planner day data.
  Future<PlannerDayModel> getDay(String date) async {
    final cacheKey = _getCacheKey(date);
    final cachedData = _localStorage.readData(cacheKey);
    PlannerDayModel? plannerDay;

    if (cachedData != null) {
      plannerDay = PlannerDayModel.fromJson(cachedData);
    }

    try {
      final response = await _dio.get('/planner/$date');
      plannerDay = PlannerDayModel.fromJson(response.data);
      await _localStorage.saveData(cacheKey, response.data);
    } catch (e) {
      if (plannerDay == null) {
        rethrow;
      }
    }

    return plannerDay;
  }

  /// Helper: Update a specific day in the cache directly
  Future<void> _updateDayInCache(String date, PlannerDayModel day) async {
    await _localStorage.saveData(_getCacheKey(date), day.toJson());
  }

  /// POST: Add a task to a slot.
  Future<PlannerTaskModel> addTask(String date, String slotId, String title) async {
    final cacheKey = _getCacheKey(date);
    final cachedData = _localStorage.readData(cacheKey);
    
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempTask = PlannerTaskModel(
      id: tempId,
      title: title,
      completed: false,
      order: 999, // default last
    );

    if (cachedData != null) {
      final day = PlannerDayModel.fromJson(cachedData);
      final newSlots = day.slots.map((slot) {
        if (slot.id == slotId) {
          return PlannerSlotModel(
            id: slot.id,
            timeRange: slot.timeRange,
            tasks: [...slot.tasks, tempTask],
          );
        }
        return slot;
      }).toList();
      
      final updatedDay = PlannerDayModel(id: day.id, date: day.date, slots: newSlots);
      await _updateDayInCache(date, updatedDay);
    }

    await _syncManager.enqueueAction('POST', '/planner/task', data: {
      'slotId': slotId,
      'title': title,
    });

    return tempTask;
  }

  /// PATCH: Update a task.
  Future<PlannerTaskModel> updateTask(String date, String taskId, Map<String, dynamic> data) async {
    final cacheKey = _getCacheKey(date);
    final cachedData = _localStorage.readData(cacheKey);
    PlannerTaskModel? updatedTask;

    if (cachedData != null) {
      final day = PlannerDayModel.fromJson(cachedData);
      final newSlots = day.slots.map((slot) {
        final taskIndex = slot.tasks.indexWhere((t) => t.id == taskId);
        if (taskIndex != -1) {
          final oldTask = slot.tasks[taskIndex];
          updatedTask = PlannerTaskModel.fromJson({
            ...oldTask.toJson(),
            ...data,
          });
          final newTasks = List<PlannerTaskModel>.from(slot.tasks);
          newTasks[taskIndex] = updatedTask!;
          return PlannerSlotModel(id: slot.id, timeRange: slot.timeRange, tasks: newTasks);
        }
        return slot;
      }).toList();
      
      final updatedDay = PlannerDayModel(id: day.id, date: day.date, slots: newSlots);
      await _updateDayInCache(date, updatedDay);
    }

    await _syncManager.enqueueAction('PATCH', '/planner/task/$taskId', data: data);

    return updatedTask ?? PlannerTaskModel.fromJson({'id': taskId, ...data});
  }

  /// DELETE: Remove a task.
  Future<void> deleteTask(String date, String taskId) async {
    final cacheKey = _getCacheKey(date);
    final cachedData = _localStorage.readData(cacheKey);

    if (cachedData != null) {
      final day = PlannerDayModel.fromJson(cachedData);
      final newSlots = day.slots.map((slot) {
        if (slot.tasks.any((t) => t.id == taskId)) {
          final newTasks = slot.tasks.where((t) => t.id != taskId).toList();
          return PlannerSlotModel(id: slot.id, timeRange: slot.timeRange, tasks: newTasks);
        }
        return slot;
      }).toList();
      
      final updatedDay = PlannerDayModel(id: day.id, date: day.date, slots: newSlots);
      await _updateDayInCache(date, updatedDay);
    }

    await _syncManager.enqueueAction('DELETE', '/planner/task/$taskId');
  }
}

final plannerServiceProvider = Provider((ref) {
  return PlannerService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
    ref.watch(syncManagerProvider),
  );
});

final plannerProvider = AsyncNotifierProviderFamily<PlannerNotifier, PlannerDayModel, String>(() {
  return PlannerNotifier();
});

class PlannerNotifier extends FamilyAsyncNotifier<PlannerDayModel, String> {
  @override
  Future<PlannerDayModel> build(String arg) async {
    return ref.watch(plannerServiceProvider).getDay(arg);
  }

  Future<void> addTask(String slotId, String title) async {
    try {
      await ref.read(plannerServiceProvider).addTask(arg, slotId, title);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleTask(String taskId, bool completed) async {
    try {
      await ref.read(plannerServiceProvider).updateTask(arg, taskId, {'completed': completed});
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeTask(String taskId) async {
    try {
      await ref.read(plannerServiceProvider).deleteTask(arg, taskId);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}

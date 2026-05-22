import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mission_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../core/sync/sync_manager.dart';

class MissionsService {
  final Dio _dio;
  final LocalStorageService _localStorage;
  final SyncManager _syncManager;

  static const String _cacheKey = 'missions_cache';

  MissionsService(this._dio, this._localStorage, this._syncManager);

  List<MissionModel> _getCachedMissions() {
    final cachedData = _localStorage.readData(_cacheKey);
    if (cachedData != null) {
      return (cachedData as List).map((e) => MissionModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _saveToCache(List<MissionModel> missions) async {
    await _localStorage.saveData(_cacheKey, missions.map((e) => e.toJson()).toList());
  }

  Future<List<MissionModel>> getMissions() async {
    List<MissionModel> cached = _getCachedMissions();

    try {
      final response = await _dio.get('/missions');
      List<MissionModel> remote = (response.data as List).map((e) => MissionModel.fromJson(e)).toList();
      
      // Get all pending offline/sync actions
      final pendingActions = _syncManager.getPendingActions();
      
      // Create a copy of the remote list to build the highly-consistent merged list
      final List<MissionModel> merged = [...remote];

      // 1. Process pending POST actions (preserve local temporary items)
      final tempFromCache = cached.where((m) => m.id.startsWith('temp_')).toList();
      for (final temp in tempFromCache) {
        // Only keep if not already in remote list (matching title & category)
        if (!merged.any((m) => m.title == temp.title && m.category == temp.category)) {
          final isDeletedPending = pendingActions.any((action) =>
              action.method == 'DELETE' && action.path.endsWith(temp.id));
          if (!isDeletedPending) {
            merged.add(temp);
          }
        }
      }

      // Reconstruct temp items from pending POST actions if they aren't in cached list
      for (final action in pendingActions) {
        if (action.method == 'POST' && action.path == '/missions' && action.data != null) {
          final data = action.data as Map<String, dynamic>;
          final hasMatch = merged.any((m) => m.title == data['title'] && m.category == data['category']);
          if (!hasMatch) {
            merged.add(MissionModel.fromJson({
              'id': 'temp_${action.id}',
              ...data,
              'priority': data['priority'] ?? 'Medium',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            }));
          }
        }
      }

      // 2. Process pending DELETE actions on the merged list
      for (final action in pendingActions) {
        if (action.method == 'DELETE' && action.path.startsWith('/missions/')) {
          final deleteId = action.path.substring('/missions/'.length);
          merged.removeWhere((m) => m.id == deleteId);
        }
      }

      // 3. Process pending PATCH actions on the merged list
      for (final action in pendingActions) {
        if (action.method == 'PATCH' && action.path.startsWith('/missions/') && action.data != null) {
          final patchId = action.path.substring('/missions/'.length);
          final index = merged.indexWhere((m) => m.id == patchId);
          if (index != -1) {
            final patchData = action.data as Map<String, dynamic>;
            merged[index] = MissionModel.fromJson({
              ...merged[index].toJson(),
              ...patchData,
              'updatedAt': DateTime.now().toIso8601String(),
            });
          }
        }
      }

      await _saveToCache(merged);
      return merged;
    } catch (e) {
      return cached;
    }
  }

  Future<MissionModel> createMission(Map<String, dynamic> data) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final tempItem = MissionModel.fromJson({
      'id': tempId,
      ...data,
      'priority': data['priority'] ?? 'Medium',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    final cachedMissions = _getCachedMissions();
    cachedMissions.add(tempItem);
    await _saveToCache(cachedMissions);

    await _syncManager.enqueueAction('POST', '/missions', data: data);

    return tempItem;
  }

  Future<MissionModel> updateMission(String id, Map<String, dynamic> data) async {
    final cachedMissions = _getCachedMissions();
    final index = cachedMissions.indexWhere((m) => m.id == id);

    MissionModel? updatedItem;
    if (index != -1) {
      final oldItem = cachedMissions[index];
      updatedItem = MissionModel.fromJson({
        ...oldItem.toJson(),
        ...data,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      cachedMissions[index] = updatedItem;
      await _saveToCache(cachedMissions);
    }

    await _syncManager.enqueueAction('PATCH', '/missions/$id', data: data);

    return updatedItem ?? MissionModel.fromJson({'id': id, ...data});
  }

  Future<void> deleteMission(String id) async {
    final cachedMissions = _getCachedMissions();
    cachedMissions.removeWhere((m) => m.id == id);
    await _saveToCache(cachedMissions);

    await _syncManager.enqueueAction('DELETE', '/missions/$id');
  }
}

final missionsServiceProvider = Provider((ref) {
  return MissionsService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
    ref.watch(syncManagerProvider),
  );
});

final missionsProvider = AsyncNotifierProvider<MissionsNotifier, List<MissionModel>>(() {
  return MissionsNotifier();
});

class MissionsNotifier extends AsyncNotifier<List<MissionModel>> {
  @override
  Future<List<MissionModel>> build() async {
    return ref.watch(missionsServiceProvider).getMissions();
  }

  Future<void> addMission(Map<String, dynamic> data) async {
    try {
      await ref.read(missionsServiceProvider).createMission(data);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMission(String id, Map<String, dynamic> data) async {
    try {
      await ref.read(missionsServiceProvider).updateMission(id, data);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMission(String id) async {
    try {
      await ref.read(missionsServiceProvider).deleteMission(id);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}

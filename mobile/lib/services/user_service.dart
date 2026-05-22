import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';
import '../core/storage/local_storage_service.dart';
import '../core/sync/sync_manager.dart';

/// Service that talks to the NestJS backend's /api/users endpoints.
/// Implements Offline-First architecture.
class UserService {
  final Dio _dio;
  final LocalStorageService _localStorage;
  final SyncManager _syncManager;

  static const String _cacheKey = 'user_profile_cache';

  UserService(this._dio, this._localStorage, this._syncManager);

  /// Helper to get current cached profile
  UserModel? _getCachedProfile() {
    final cachedData = _localStorage.readData(_cacheKey);
    if (cachedData != null) {
      return UserModel.fromJson(cachedData);
    }
    return null;
  }

  /// GET /api/auth/me — ensures user exists in Postgres and returns profile.
  Future<UserModel> getProfile() async {
    UserModel? user = _getCachedProfile();

    try {
      final response = await _dio.get('/auth/me');
      final userData = response.data['user'] ?? response.data;
      user = UserModel.fromJson(userData);
      
      // Save fresh data to cache
      await _localStorage.saveData(_cacheKey, userData);
      return user;
    } catch (e) {
      if (user != null) {
        return user;
      }
      rethrow;
    }
  }

  /// PATCH /api/users/profile — update profile fields.
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    UserModel? cachedUser = _getCachedProfile();
    
    // 1. Optimistic local cache update (if possible)
    if (cachedUser != null) {
      // In a real app we'd merge `data` into `cachedUser`.
      // For now, we'll just queue the request.
    }

    // 2. Queue or execute the mutation
    try {
      final response = await _dio.patch('/users/profile', data: data);
      final updatedUser = UserModel.fromJson(response.data);
      await _localStorage.saveData(_cacheKey, response.data);
      return updatedUser;
    } catch (e) {
      // Offline fallback: Queue it!
      await _syncManager.enqueueAction('PATCH', '/users/profile', data: data);
      
      if (cachedUser != null) {
        return cachedUser;
      }
      rethrow;
    }
  }

  /// Optimistic updates to cached XP for instant UI feedback.
  Future<void> addLocalXp(int amount) async {
    final cached = _getCachedProfile();
    if (cached != null) {
      final updated = UserModel(
        id: cached.id,
        userId: cached.userId,
        email: cached.email,
        name: cached.name,
        avatarUrl: cached.avatarUrl,
        city: cached.city,
        state: cached.state,
        xp: (cached.xp + amount).clamp(0, 999999999).toInt(),
        level: cached.level,
        streakShields: cached.streakShields,
      );
      await _localStorage.saveData(_cacheKey, updated.toJson());
    }
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
    ref.watch(syncManagerProvider),
  );
});

class UserProfileNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() async {
    return ref.watch(userServiceProvider).getProfile();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(userServiceProvider).getProfile());
  }

  Future<void> addOptimisticXp(int amount) async {
    if (state.hasValue) {
      final user = state.value!;
      final newXp = (user.xp + amount).clamp(0, 999999999).toInt();
      
      // Let backend calculate real level, but we can optimistically guess if we want
      // For now just update XP so it propagates globally instantly.
      state = AsyncData(user.copyWith(xp: newXp));
      
      // Also write to local cache instantly
      await ref.read(userServiceProvider).addLocalXp(amount);
    }
  }
}

final userProfileProvider = AsyncNotifierProvider<UserProfileNotifier, UserModel>(() {
  return UserProfileNotifier();
});

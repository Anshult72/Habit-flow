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
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
    ref.watch(syncManagerProvider),
  );
});

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  return ref.watch(userServiceProvider).getProfile();
});

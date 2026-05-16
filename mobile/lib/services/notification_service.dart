import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../core/sync/sync_manager.dart';
import '../models/notification_model.dart';

class NotificationService {
  final Dio _dio;
  final LocalStorageService _localStorage;
  final SyncManager _syncManager;

  static const String _cacheKey = 'notifications_cache';

  NotificationService(this._dio, this._localStorage, this._syncManager);

  Future<List<NotificationModel>> getNotifications() async {
    final cachedData = _localStorage.readData(_cacheKey);
    List<NotificationModel> notifications = [];

    if (cachedData != null) {
      notifications = (cachedData as List).map((e) => NotificationModel.fromJson(e)).toList();
    }

    try {
      final response = await _dio.get('/notifications');
      notifications = (response.data as List).map((e) => NotificationModel.fromJson(e)).toList();
      await _localStorage.saveData(_cacheKey, response.data);
    } catch (e) {
      if (notifications.isEmpty) rethrow;
    }

    return notifications;
  }

  Future<void> markAsRead(String id) async {
    // 1. Optimistic local update
    final cachedData = _localStorage.readData(_cacheKey);
    if (cachedData != null) {
      final notifications = (cachedData as List).map((e) => NotificationModel.fromJson(e)).toList();
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = notifications[index];
        notifications[index] = NotificationModel(
          id: old.id,
          type: old.type,
          title: old.title,
          message: old.message,
          metadata: old.metadata,
          isRead: true,
          createdAt: old.createdAt,
        );
        await _localStorage.saveData(_cacheKey, notifications.map((e) => e.toJson()).toList());
      }
    }

    // 2. Queue API request
    await _syncManager.enqueueAction('PATCH', '/notifications/$id/read');
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
    ref.watch(syncManagerProvider),
  );
});

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  return ref.watch(notificationServiceProvider).getNotifications();
});

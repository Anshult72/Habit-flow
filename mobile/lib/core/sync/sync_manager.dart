import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../network/network_info_service.dart';
import '../network/api_client.dart';

/// Represents an API mutation action to be synced later.
class SyncAction {
  final String id;
  final String method; // 'POST', 'PUT', 'DELETE', 'PATCH'
  final String path;
  final dynamic data;
  final int timestamp;

  SyncAction({
    required this.id,
    required this.method,
    required this.path,
    this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'method': method,
        'path': path,
        'data': data,
        'timestamp': timestamp,
      };

  factory SyncAction.fromJson(Map<String, dynamic> json) => SyncAction(
        id: json['id'],
        method: json['method'],
        path: json['path'],
        data: json['data'],
        timestamp: json['timestamp'],
      );
}

/// Manages a queue of pending offline actions and syncs them when online.
class SyncManager {
  static const String _syncBoxName = 'sync_queue';
  late Box<String> _syncBox;
  final NetworkInfoService _networkInfo;
  final Dio _dio;
  bool _isSyncing = false;

  SyncManager(this._networkInfo, this._dio);

  Future<void> init() async {
    _syncBox = await Hive.openBox<String>(_syncBoxName);

    // Listen for network changes to trigger sync
    _networkInfo.onNetworkChange.listen((isOnline) {
      if (isOnline) {
        syncPendingActions();
      }
    });

    // Initial sync if online
    if (_networkInfo.isOnline) {
      syncPendingActions();
    }
  }

  /// Add an action to the sync queue.
  Future<void> enqueueAction(String method, String path, {dynamic data}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final action = SyncAction(
      id: id,
      method: method,
      path: path,
      data: data,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    await _syncBox.put(id, jsonEncode(action.toJson()));
    debugPrint('[SyncManager] Enqueued ${action.method} ${action.path}');

    // If online, immediately try to sync
    if (_networkInfo.isOnline) {
      syncPendingActions();
    }
  }

  /// Process all pending actions.
  Future<void> syncPendingActions() async {
    if (_isSyncing || !_networkInfo.isOnline) return;
    if (_syncBox.isEmpty) return;

    _isSyncing = true;
    debugPrint('[SyncManager] Starting sync of ${_syncBox.length} pending actions...');

    // Sort actions by timestamp
    final keys = _syncBox.keys.toList();
    final actions = keys.map((k) {
      final jsonStr = _syncBox.get(k)!;
      return SyncAction.fromJson(jsonDecode(jsonStr));
    }).toList();
    
    actions.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final action in actions) {
      if (!_networkInfo.isOnline) break; // Network lost during sync
      
      bool success = await _executeAction(action);
      if (success) {
        await _syncBox.delete(action.id);
        debugPrint('[SyncManager] Synced & removed ${action.method} ${action.path}');
      } else {
        // Stop syncing if one action fails persistently (prevent out-of-order execution)
        debugPrint('[SyncManager] Failed to sync ${action.method} ${action.path}. Stopping sync queue.');
        break; 
      }
    }

    _isSyncing = false;
  }

  Future<bool> _executeAction(SyncAction action) async {
    try {
      await _dio.request(
        action.path,
        data: action.data,
        options: Options(method: action.method),
      );
      return true;
    } on DioException catch (e) {
      // If it's a 4xx error (except 401, 408, 429), it's probably a permanent client error.
      // We might want to discard it to prevent blocking the queue forever.
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        if (statusCode != null && statusCode >= 400 && statusCode < 500 && statusCode != 401 && statusCode != 408 && statusCode != 429) {
          debugPrint('[SyncManager] Permanent client error $statusCode for ${action.path}. Discarding.');
          return true; // Return true to delete it from the queue
        }
      }
      return false; // Temporary network/server error, keep in queue
    } catch (e) {
      return false;
    }
  }
}

final syncManagerProvider = Provider<SyncManager>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  final dio = ref.watch(dioProvider);
  return SyncManager(networkInfo, dio);
});

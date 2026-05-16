import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_model.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../core/sync/sync_manager.dart';

class AnalyticsService {
  final Dio _dio;
  final LocalStorageService _localStorage;
  final SyncManager _syncManager;

  static const String _leaderboardCacheKey = 'analytics_leaderboard_cache';
  static const String _productivityCacheKey = 'analytics_productivity_cache';
  static const String _focusStatsCacheKey = 'analytics_focus_stats_cache';

  AnalyticsService(this._dio, this._localStorage, this._syncManager);

  Future<List<LeaderboardUserModel>> getLeaderboard() async {
    final cachedData = _localStorage.readData(_leaderboardCacheKey);
    List<LeaderboardUserModel> leaderboard = [];

    if (cachedData != null) {
      leaderboard = (cachedData as List).map((e) => LeaderboardUserModel.fromJson(e)).toList();
    }

    try {
      final response = await _dio.get('/analytics/leaderboard');
      leaderboard = (response.data as List).map((e) => LeaderboardUserModel.fromJson(e)).toList();
      await _localStorage.saveData(_leaderboardCacheKey, response.data);
    } catch (e) {
      if (leaderboard.isEmpty) rethrow;
    }

    return leaderboard;
  }

  Future<int> getProductivityScore() async {
    final cachedData = _localStorage.readData(_productivityCacheKey);
    int score = cachedData ?? 0;

    try {
      final response = await _dio.get('/analytics/productivity');
      score = response.data['score'] ?? 0;
      await _localStorage.saveData(_productivityCacheKey, score);
    } catch (e) {
      if (cachedData == null) rethrow;
    }

    return score;
  }

  Future<Map<String, dynamic>> getFocusStats() async {
    final cachedData = _localStorage.readData(_focusStatsCacheKey);
    Map<String, dynamic> stats = cachedData != null ? Map<String, dynamic>.from(cachedData) : {};

    try {
      final response = await _dio.get('/analytics/focus/stats');
      stats = response.data;
      await _localStorage.saveData(_focusStatsCacheKey, stats);
    } catch (e) {
      if (stats.isEmpty) rethrow;
    }

    return stats;
  }

  Future<void> logFocusSession(String type, int duration, int xp) async {
    // 1. Optimistic update of local focus stats
    final cachedStats = _localStorage.readData(_focusStatsCacheKey);
    if (cachedStats != null) {
      final stats = Map<String, dynamic>.from(cachedStats);
      // Rough local extrapolation based on typical stats structure:
      if (stats.containsKey('totalSessions')) stats['totalSessions'] = (stats['totalSessions'] ?? 0) + 1;
      if (stats.containsKey('totalFocusMinutes')) stats['totalFocusMinutes'] = (stats['totalFocusMinutes'] ?? 0) + duration;
      await _localStorage.saveData(_focusStatsCacheKey, stats);
    }

    // 2. Queue the API call
    await _syncManager.enqueueAction('POST', '/analytics/focus/session', data: {
      'type': type,
      'duration': duration,
      'xpEarned': xp,
    });
  }
}

final analyticsServiceProvider = Provider((ref) {
  return AnalyticsService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
    ref.watch(syncManagerProvider),
  );
});

// Since we use FutureProviders here, they naturally fetch once and cache in Riverpod's state.
// They will now instantly hit Hive through the service layer.
final leaderboardProvider = FutureProvider<List<LeaderboardUserModel>>((ref) async {
  return ref.watch(analyticsServiceProvider).getLeaderboard();
});

final productivityScoreProvider = FutureProvider<int>((ref) async {
  return ref.watch(analyticsServiceProvider).getProductivityScore();
});

final focusStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(analyticsServiceProvider).getFocusStats();
});

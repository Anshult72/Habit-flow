import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../models/duel_model.dart';

class DuelService {
  final Dio _dio;
  final LocalStorageService _localStorage;

  static const String _cacheKey = 'duels_cache';

  DuelService(this._dio, this._localStorage);

  Future<List<DuelModel>> getDuels() async {
    final cachedData = _localStorage.readData(_cacheKey);
    List<DuelModel> duels = [];

    if (cachedData != null) {
      duels = (cachedData as List).map((e) => DuelModel.fromJson(e)).toList();
    }

    try {
      final response = await _dio.get('/duels');
      duels = (response.data as List).map((e) => DuelModel.fromJson(e)).toList();
      await _localStorage.saveData(_cacheKey, response.data);
    } catch (e) {
      if (duels.isEmpty) rethrow;
    }

    return duels;
  }

  // Mutations strictly require internet
  Future<DuelModel> createChallenge(String targetUserId, int entryXP, int durationDays) async {
    final response = await _dio.post('/duels/challenge', data: {
      'targetUserId': targetUserId,
      'entryXP': entryXP,
      'durationDays': durationDays,
    });
    return DuelModel.fromJson(response.data['duel'] ?? response.data);
  }

  Future<void> respondToRequest(String requestId, bool accept) async {
    await _dio.post('/duels/requests/$requestId/respond', data: {'accept': accept});
  }

  Future<DuelModel> joinDuel(String inviteCode) async {
    final response = await _dio.post('/duels/join/$inviteCode');
    return DuelModel.fromJson(response.data);
  }

  Future<void> cancelDuel(String id) async {
    await _dio.delete('/duels/$id');
  }

  Future<DuelModel> createDuel(Map<String, dynamic> data) async {
    final response = await _dio.post('/duels', data: data);
    return DuelModel.fromJson(response.data);
  }

  Future<void> acceptDuel(String id) async {
    await respondToRequest(id, true);
  }

  Future<void> declineDuel(String id) async {
    await respondToRequest(id, false);
  }
}

final duelServiceProvider = Provider<DuelService>((ref) {
  return DuelService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
  );
});

final duelsProvider = FutureProvider<List<DuelModel>>((ref) async {
  return ref.watch(duelServiceProvider).getDuels();
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/duel_model.dart';

/// Service that talks to the NestJS backend's /api/duels endpoints.
class DuelService {
  final Dio _dio;

  DuelService(this._dio);

  Future<List<DuelModel>> getDuels() async {
    final response = await _dio.get('/duels');
    return (response.data as List).map((e) => DuelModel.fromJson(e)).toList();
  }

  Future<DuelModel> createChallenge(String targetUserId, int entryXP, int durationDays) async {
    final response = await _dio.post('/duels/challenge', data: {
      'targetUserId': targetUserId,
      'entryXP': entryXP,
      'durationDays': durationDays,
    });
    // Backend returns { duel, request }
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
}

final duelServiceProvider = Provider<DuelService>((ref) {
  return DuelService(ref.watch(dioProvider));
});

final duelsProvider = FutureProvider<List<DuelModel>>((ref) async {
  return ref.watch(duelServiceProvider).getDuels();
});

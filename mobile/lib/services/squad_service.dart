import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/squad_model.dart';

/// Service that talks to the NestJS backend's /api/squads endpoints.
class SquadService {
  final Dio _dio;

  SquadService(this._dio);

  Future<List<SquadModel>> getSquads() async {
    final response = await _dio.get('/squads');
    return (response.data as List).map((e) => SquadModel.fromJson(e)).toList();
  }

  Future<SquadModel> createSquad(String name, int entryXP, int durationDays) async {
    final response = await _dio.post('/squads', data: {
      'name': name,
      'entryXP': entryXP,
      'durationDays': durationDays,
    });
    return SquadModel.fromJson(response.data);
  }

  Future<void> inviteUser(String squadId, String targetUserId) async {
    await _dio.post('/squads/$squadId/invite', data: {'targetUserId': targetUserId});
  }

  Future<void> respondToRequest(String requestId, bool accept) async {
    await _dio.post('/squads/requests/$requestId/respond', data: {'accept': accept});
  }

  Future<SquadModel> joinSquad(String inviteCode) async {
    final response = await _dio.post('/squads/join/$inviteCode');
    return SquadModel.fromJson(response.data);
  }

  Future<void> deleteSquad(String id) async {
    await _dio.delete('/squads/$id');
  }
}

final squadServiceProvider = Provider<SquadService>((ref) {
  return SquadService(ref.watch(dioProvider));
});

final squadsProvider = FutureProvider<List<SquadModel>>((ref) async {
  return ref.watch(squadServiceProvider).getSquads();
});

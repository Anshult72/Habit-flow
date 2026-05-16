import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../models/squad_model.dart';

class SquadService {
  final Dio _dio;
  final LocalStorageService _localStorage;

  static const String _cacheKey = 'squads_cache';

  SquadService(this._dio, this._localStorage);

  Future<List<SquadModel>> getSquads() async {
    final cachedData = _localStorage.readData(_cacheKey);
    List<SquadModel> squads = [];

    if (cachedData != null) {
      squads = (cachedData as List).map((e) => SquadModel.fromJson(e)).toList();
    }

    try {
      final response = await _dio.get('/squads');
      squads = (response.data as List).map((e) => SquadModel.fromJson(e)).toList();
      await _localStorage.saveData(_cacheKey, response.data);
    } catch (e) {
      if (squads.isEmpty) rethrow;
    }

    return squads;
  }

  // Mutations strictly require internet to prevent multiplayer desyncs
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
  return SquadService(
    ref.watch(dioProvider),
    ref.watch(localStorageProvider),
  );
});

final squadsProvider = FutureProvider<List<SquadModel>>((ref) async {
  return ref.watch(squadServiceProvider).getSquads();
});

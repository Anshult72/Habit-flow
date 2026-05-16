import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mission_model.dart';
import '../core/network/api_client.dart';

class MissionsService {
  final Dio _dio;

  MissionsService(this._dio);

  Future<List<MissionModel>> getMissions() async {
    final response = await _dio.get('/missions');
    return (response.data as List).map((e) => MissionModel.fromJson(e)).toList();
  }

  Future<MissionModel> createMission(Map<String, dynamic> data) async {
    final response = await _dio.post('/missions', data: data);
    return MissionModel.fromJson(response.data);
  }

  Future<MissionModel> updateMission(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/missions/$id', data: data);
    return MissionModel.fromJson(response.data);
  }

  Future<void> deleteMission(String id) async {
    await _dio.delete('/missions/$id');
  }
}

final missionsServiceProvider = Provider((ref) => MissionsService(ref.watch(dioProvider)));

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

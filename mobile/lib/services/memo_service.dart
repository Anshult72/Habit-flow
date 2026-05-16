import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/memo_model.dart';
import '../core/network/api_client.dart';

class MemoService {
  final Dio _dio;

  MemoService(this._dio);

  Future<List<MemoModel>> getMemos() async {
    final response = await _dio.get('/memos');
    return (response.data as List).map((e) => MemoModel.fromJson(e)).toList();
  }

  Future<MemoModel> createMemo(Map<String, dynamic> data) async {
    final response = await _dio.post('/memos', data: data);
    return MemoModel.fromJson(response.data);
  }

  Future<MemoModel> updateMemo(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/memos/$id', data: data);
    return MemoModel.fromJson(response.data);
  }

  Future<void> deleteMemo(String id) async {
    await _dio.delete('/memos/$id');
  }
}

final memoServiceProvider = Provider((ref) => MemoService(ref.watch(dioProvider)));

final memosProvider = AsyncNotifierProvider<MemosNotifier, List<MemoModel>>(() {
  return MemosNotifier();
});

class MemosNotifier extends AsyncNotifier<List<MemoModel>> {
  @override
  Future<List<MemoModel>> build() async {
    return ref.watch(memoServiceProvider).getMemos();
  }

  Future<void> addMemo(Map<String, dynamic> data) async {
    try {
      await ref.read(memoServiceProvider).createMemo(data);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMemo(String id, Map<String, dynamic> data) async {
    try {
      await ref.read(memoServiceProvider).updateMemo(id, data);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> togglePin(String id, bool currentStatus) async {
    try {
      await ref.read(memoServiceProvider).updateMemo(id, {'isPinned': !currentStatus});
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMemo(String id) async {
    try {
      await ref.read(memoServiceProvider).deleteMemo(id);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}

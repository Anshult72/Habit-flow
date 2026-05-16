import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/matrix_model.dart';
import '../core/network/api_client.dart';

class MatrixService {
  final Dio _dio;

  MatrixService(this._dio);

  Future<List<MatrixModel>> getTasks() async {
    final response = await _dio.get('/matrix');
    return (response.data as List).map((e) => MatrixModel.fromJson(e)).toList();
  }

  Future<MatrixModel> createTask(Map<String, dynamic> data) async {
    final response = await _dio.post('/matrix', data: data);
    return MatrixModel.fromJson(response.data);
  }

  Future<MatrixModel> updateTask(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/matrix/$id', data: data);
    return MatrixModel.fromJson(response.data);
  }

  Future<void> deleteTask(String id) async {
    await _dio.delete('/matrix/$id');
  }
}

final matrixServiceProvider = Provider((ref) => MatrixService(ref.watch(dioProvider)));

final matrixProvider = AsyncNotifierProvider<MatrixNotifier, List<MatrixModel>>(() {
  return MatrixNotifier();
});

class MatrixNotifier extends AsyncNotifier<List<MatrixModel>> {
  @override
  Future<List<MatrixModel>> build() async {
    return ref.watch(matrixServiceProvider).getTasks();
  }

  Future<void> addTask(Map<String, dynamic> data) async {
    try {
      await ref.read(matrixServiceProvider).createTask(data);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    try {
      await ref.read(matrixServiceProvider).updateTask(id, data);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleCompletion(String id, bool completed) async {
    try {
      await ref.read(matrixServiceProvider).updateTask(id, {'completed': !completed});
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeTask(String id) async {
    try {
      await ref.read(matrixServiceProvider).deleteTask(id);
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}

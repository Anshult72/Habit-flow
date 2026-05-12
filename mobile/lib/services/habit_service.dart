import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/habit_model.dart';

/// Service that talks to the NestJS backend's /api/habits endpoints.
///
/// Mirrors the web frontend's habit CRUD exactly.
/// Backend uses SupabaseAuthGuard → req.user.sub → resolveUserId.
class HabitService {
  final Dio _dio;

  HabitService(this._dio);

  /// GET /api/habits — fetch all habits for the authenticated user.
  Future<List<HabitModel>> getHabits() async {
    final response = await _dio.get('/habits');
    return (response.data as List).map((e) => HabitModel.fromJson(e)).toList();
  }

  /// POST /api/habits — create a new habit.
  Future<HabitModel> createHabit(Map<String, dynamic> data) async {
    final response = await _dio.post('/habits', data: data);
    return HabitModel.fromJson(response.data);
  }

  /// PATCH /api/habits/:id — update an existing habit.
  Future<HabitModel> updateHabit(String id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/habits/$id', data: data);
    return HabitModel.fromJson(response.data);
  }

  /// DELETE /api/habits/:id — delete a habit.
  Future<void> deleteHabit(String id) async {
    await _dio.delete('/habits/$id');
  }

  /// POST /api/habits/:id/toggle — toggle completion for a date.
  Future<HabitModel> toggleHabit(String habitId, String date) async {
    final response = await _dio.post('/habits/$habitId/toggle', data: {'date': date});
    return HabitModel.fromJson(response.data);
  }
}

final habitServiceProvider = Provider<HabitService>((ref) {
  return HabitService(ref.watch(dioProvider));
});

final habitsProvider = FutureProvider<List<HabitModel>>((ref) async {
  return ref.watch(habitServiceProvider).getHabits();
});

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

/// Service that talks to the NestJS backend's /api/users endpoints.
///
/// Mirrors the web frontend's user-related API calls.
class UserService {
  final Dio _dio;

  UserService(this._dio);

  /// GET /api/auth/me — ensures user exists in Postgres and returns profile.
  Future<UserModel> getProfile() async {
    final response = await _dio.get('/auth/me');
    // Backend /auth/me returns { success: true, user: { ... } }
    final userData = response.data['user'] ?? response.data;
    return UserModel.fromJson(userData);
  }

  /// PATCH /api/users/profile — update profile fields.
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/users/profile', data: data);
    return UserModel.fromJson(response.data);
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(dioProvider));
});

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  return ref.watch(userServiceProvider).getProfile();
});

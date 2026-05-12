import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/auth_service.dart';
import '../constants/app_constants.dart';

/// Dio interceptor that automatically injects the Supabase JWT
/// into every request to the NestJS backend.
///
/// This mirrors the web frontend's `apiFetch()` in `lib/api.ts`:
///   headers['Authorization'] = `Bearer ${session?.access_token}`;
class _AuthInterceptor extends Interceptor {
  final Ref _ref;

  _AuthInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final authService = _ref.read(authServiceProvider);
    final token = authService.accessToken;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    // Bypass localtunnel warning page
    options.headers['Bypass-Tunnel-Reminder'] = 'true';

    debugPrint('[Dio] ${options.method} ${options.uri}');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      debugPrint('[Dio] 401 Unauthorized — session may be expired');
    }
    super.onError(err, handler);
  }
}

/// Central Dio client provider. All services use this.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(_AuthInterceptor(ref));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[DioLog] $obj'),
    ));
  }

  return dio;
});

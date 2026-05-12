import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';

class AnalyticsService {
  final Dio _dio;

  AnalyticsService(this._dio);

  Future<int> getProductivityScore() async {
    final response = await _dio.get('/analytics/productivity');
    return response.data['score'] ?? 0;
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(dioProvider));
});

final productivityScoreProvider = FutureProvider<int>((ref) async {
  return ref.watch(analyticsServiceProvider).getProductivityScore();
});

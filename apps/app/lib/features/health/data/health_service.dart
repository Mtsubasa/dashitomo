import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import 'health_response.dart';

final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService(ref.watch(dioProvider));
});

class HealthService {
  const HealthService(this._dio);

  final Dio _dio;

  Future<HealthResponse> fetchHealth() async {
    final response = await _dio.get<Map<String, dynamic>>('/healthz');
    final data = response.data;
    if (data == null) {
      throw const FormatException('Health response body is empty.');
    }
    return HealthResponse.fromJson(data);
  }
}

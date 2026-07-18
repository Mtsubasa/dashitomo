import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'health_response.dart';
import 'health_service.dart';

final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  return HealthRepository(ref.watch(healthServiceProvider));
});

class HealthRepository {
  const HealthRepository(this._service);

  final HealthService _service;

  Future<HealthResponse> getHealth() => _service.fetchHealth();
}

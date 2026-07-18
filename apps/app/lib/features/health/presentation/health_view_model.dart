import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/health_repository.dart';
import '../data/health_response.dart';

final healthViewModelProvider =
    AsyncNotifierProvider<HealthViewModel, HealthResponse>(HealthViewModel.new);

class HealthViewModel extends AsyncNotifier<HealthResponse> {
  @override
  Future<HealthResponse> build() {
    return ref.watch(healthRepositoryProvider).getHealth();
  }

  void retry() {
    ref.invalidateSelf();
  }
}
